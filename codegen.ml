(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

module L = Llvm
module A = Ast

module StringMap = Map.Make(String)
module SymbolsMap = Map.Make(String)


let translate (statements, functions) =
  let context = L.global_context () in
  let the_module = L.create_module context "MicroC"
  and i32_t  = L.i32_type  context
  and i8_t   = L.i8_type   context
  and i1_t   = L.i1_type   context
  and flt_t  = L.double_type context
  and str_t  = L.pointer_type (L.i8_type context)
  and void_t = L.void_type context 
  (* and idlist_t = L.pointer_type (match L.type_by_name llm "struct.IdList" with
    None -> raise (Invalid_argument "Option.get idlist")
  | Some x -> x) *)  in

  let ltype_of_typ = function
      A.Int -> i32_t
    | A.Float -> flt_t
    | A.Bool -> i1_t
    | A.Void -> void_t 
    | A.Str -> str_t
    | _ -> raise(Failure("No matching pattern in ltype_of_typ"))
    (* | A.List _ -> idlist_t  *)
  in

  (*take out globals*)
  let globals =
    let rec test_function pass_list head = match head with
        A.Vdecl (a, b) -> (a, b)::pass_list
      | A.Block (a) -> List.fold_left test_function pass_list a
      |_ -> pass_list
    in List.fold_left test_function [] statements
  in

  (* Declare each global variable; remember its value in a map *)
  let global_vars =
    let global_var m (t, n) =
      let init = L.const_int (ltype_of_typ t) 0
      in StringMap.add n (L.define_global n init the_module) m in
    List.fold_left global_var StringMap.empty globals in

  (* Declare printf(), which the print built-in function will call *)
  let printf_t = L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func = L.declare_function "printf" printf_t the_module in

  (* Define each function (arguments and return type) so we can call it *)
  let function_decls =
    let function_decl m fdecl =
      let name = fdecl.A.fname
      and formal_types =
      Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.A.formals)
      in let ftype = L.function_type (ltype_of_typ fdecl.A.typ) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl StringMap.empty functions in
  
  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = try StringMap.find fdecl.A.fname function_decls 
                            with Not_found -> raise(Failure("No matching pattern in build_function_body"))in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
    and float_format_str = L.build_global_stringptr "%f\n" "fmt" builder
    and bool_format_str = L.build_global_stringptr "%d ? \"true\" : \"false\"" "fmt" builder 
    and string_format_str = L.build_global_stringptr "%s\n" "fmt" builder
      in
    
    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m (t, n) p = L.set_value_name n p;
	       let local = L.build_alloca (ltype_of_typ t) n builder in
	       ignore (L.build_store p local builder);
	       StringMap.add n local m in

      let add_local m (t, n) =
	       let local_var = L.build_alloca (ltype_of_typ t) n builder
	         in StringMap.add n local_var m 
         in

      let locals =
        let rec test pass_list = function
            [] -> pass_list
          | hd :: tl -> let newlist = 
                          let match_fuc hd pass_list= match hd with
                            A.Vdecl (a, b) -> (a, b)::pass_list
                          | A.Block (a) -> test pass_list a
                          | _ -> pass_list
                          in match_fuc hd pass_list
                        in test newlist tl

        in
        let test_function pass_list head = match head with
            A.Vdecl (a, b) -> (a, b)::pass_list
          | A.Block (block) -> test pass_list block
          | _ -> pass_list
        in List.fold_left test_function [] fdecl.A.body in
      
      let formals = List.fold_left2 add_formal StringMap.empty fdecl.A.formals
          (Array.to_list (L.params the_function)) in
      List.fold_left add_local formals locals in
    (* print_endline(string_of_int(StringMap.cardinal local_vars)); *)

    (* Return the value for a variable or formal argument *)
    let lookup n = try StringMap.find n local_vars
                  with Not_found -> try StringMap.find n global_vars with Not_found -> raise(Failure("No matching pattern in Global_vars access in lookup"))
    in

    let symbol_vars =

      let add_to_symbol_table m (t, n) =
        SymbolsMap.add n t m in

      let locals =
        let rec test pass_list = function
            [] -> pass_list
          | hd :: tl -> let newlist = 
                          let match_fuc hd pass_list= match hd with
                            A.Vdecl (a, b) -> (a, b)::pass_list
                          | A.Block (a) -> test pass_list a
                          | _ -> pass_list
                          in match_fuc hd pass_list
                        in test newlist tl

        in
        let test_function pass_list head = match head with
            A.Vdecl (a, b) -> (a, b)::pass_list
          | A.Block (block) -> test pass_list block
          | _ -> pass_list
        in List.fold_left test_function [] fdecl.A.body in

      let symbolmap = List.fold_left add_to_symbol_table SymbolsMap.empty fdecl.A.formals in
        List.fold_left add_to_symbol_table symbolmap locals in

      let global_vars_2 = 
        let add_to_symbol_table m (t, n) =
          SymbolsMap.add n t m in
        List.fold_left add_to_symbol_table SymbolsMap.empty globals in

    (* Return the type for a variable or formal argument *)
    let lookup_datatype n = try SymbolsMap.find n symbol_vars
      with Not_found -> try SymbolsMap.find n global_vars_2 with Not_found -> raise(Failure("No matching pattern in globals access in lookup_datatype"))
    in

    (* Construct code for an expression; return its value *)
    (*builder type*)
    let int_binops op =  (
      match op with
        A.Add     -> L.build_add
      | A.Sub     -> L.build_sub
      | A.Mult    -> L.build_mul
      | A.Div     -> L.build_sdiv
            (*Mod*)
      | A.Equal   -> L.build_icmp L.Icmp.Eq
      | A.Neq     -> L.build_icmp L.Icmp.Ne
      | A.Less    -> L.build_icmp L.Icmp.Slt
      | A.Leq     -> L.build_icmp L.Icmp.Sle
      | A.Greater -> L.build_icmp L.Icmp.Sgt
      | A.Geq     -> L.build_icmp L.Icmp.Sge
      | _ -> raise (Failure "Invalid Int Binop")
    )
    in

    let float_binops op =  (
      match op with
          A.Add     -> L.build_fadd
        | A.Sub     -> L.build_fsub
        | A.Mult    -> L.build_fmul
        | A.Div     -> L.build_fdiv
        | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
        | A.Neq     -> L.build_fcmp L.Fcmp.One
        | A.Less    -> L.build_fcmp L.Fcmp.Ult
        | A.Leq     -> L.build_fcmp L.Fcmp.Ole
        | A.Greater -> L.build_fcmp L.Fcmp.Ogt
        | A.Geq     -> L.build_fcmp L.Fcmp.Oge
        | _ -> raise (Failure "Invalid")
      )
    in

    let bool_binops op =  (
    match op with
        | A.And     -> L.build_and
        | A.Or      -> L.build_or
        | A.Equal   -> L.build_icmp L.Icmp.Eq
        | A.Neq     -> L.build_icmp L.Icmp.Ne
        | _ -> raise (Failure "Unsupported bool binop")
      )
    in

    let rec expr builder = function
        A.Literal i -> L.const_int i32_t i
      | A.FloatLit f  -> L.const_float flt_t f
      | A.StringLit s -> L.build_global_stringptr s "str" builder
      | A.BoolLit b -> L.const_int i1_t (if b then 1 else 0)
      | A.Noexpr -> L.const_int i32_t 0
      | A.Id s -> L.build_load (lookup s) s builder
      | A.Binop (e1, op, e2) ->
	       let e1' = expr builder e1
	       and e2' = expr builder e2 in
            (match e1 with
              A.BoolLit b -> (bool_binops op) e1' e2' "tmp" builder
            | A.FloatLit f -> (float_binops op) e1' e2' "tmp" builder
            | A.Literal i -> (int_binops op) e1' e2' "tmp" builder
            | A.Id s ->(
                let mytyp = lookup_datatype s in
                      (
                        match mytyp with
                          A.Int ->(
                            match op with
                             A.Add
                            |A.Sub
                            |A.Mult
                            |A.Div
                            |A.Mod
                            |A.Equal
                            |A.Neq
                            |A.Less
                            |A.Leq
                            |A.Greater
                            |A.Geq -> (int_binops op) e1' e2' "tmp" builder
                            | _ -> raise(Failure "Invalid Int Binop")
                         )
                        | A.Bool -> (bool_binops op) e1' e2' "tmp" builder
                        | A.Float -> (float_binops op) e1' e2' "tmp" builder
                        |_ -> raise (Failure "Invalid Type of ID binop")
                    ))
            |_ -> raise (Failure "Invalid Binop e1 Type")
            )
      | A.Unop(op, e) ->
        let e' = expr builder e in
          (match op with
            A.Neg     -> 
                (match e with
                     A.FloatLit f -> L.build_fneg
                    |A.Literal i -> L.build_neg
                    |A.Id s ->
                            let mytyp = lookup_datatype s in
                            (match mytyp with
                                 A.Int -> L.build_neg
                                |A.Float -> L.build_fneg
                                | _ -> raise (Failure "Invalid Unop id type")
                            )
                    | _ -> raise (Failure "Invalid Unop type")
                 )
          | A.Not     -> L.build_not) e' "tmp" builder
      | A.Assign (s, e) -> let e' = expr builder e in
	                   ignore (L.build_store e' (lookup s) builder); e'
      | A.Call ("print", [e]) ->
        L.build_call printf_func [| int_format_str ; (expr builder e) |]
         "printf" builder
      | A.Call ("printf", [e]) ->
        L.build_call printf_func [| float_format_str ; (expr builder e) |]
         "printf" builder
      | A.Call ("printb", [e]) ->
        (* let find_str b = match b with
          A.BoolLit b -> if b then "true" else "false"
        | _ -> raise(Failure("Not a bool type"))
          in 
          let str_e = find_str e in
        L.build_call printf_func [| bool_format_str ; (L.build_global_stringptr str_e "str" builder) |]
	       "printf" builder *)
         L.build_call printf_func [| bool_format_str ; (expr builder e) |]
         "printf" builder
         (* let a = expr builder e in
         let b0 = L.const_int i32_t 0 in
         let b1 = L.const_int i32_t 1 in
         let c0 = L.const_int i1_t 0 in 
         let c1 = L.const_int i1_t 1 in
          let test_u input = match input with
              (* b0 -> L.build_call printf_func [| bool_format_str ;  (L.build_global_stringptr "false" "str" builder) |]
          "printf" builder *)
            (* | b1 -> L.build_call printf_func [| bool_format_str ;  (L.build_global_stringptr "true" "str" builder) |]
          "printf" builder *)
            (* | c0 -> L.build_call printf_func [| bool_format_str ;  (L.build_global_stringptr "false" "str" builder) |]
          "printf" builder *)
            | c1 -> L.build_call printf_func [| bool_format_str ;  (L.build_global_stringptr "true" "str" builder) |]
          "printf" builder
            | _ -> raise(Failure("Not a bool type"))
        in test_u a *)
      | A.Call ("prints", [e]) -> L.build_call printf_func [| (string_format_str) ; (expr builder e) |]
          "printf" builder
      | A.Call (f, act) ->
         let (fdef, fdecl) = try StringMap.find f function_decls 
                            with Not_found -> raise(Failure("Not_found expr in A.Call"))
                          in
          let actuals = List.rev (List.map (expr builder) (List.rev act)) in
          let result = (match fdecl.A.typ with A.Void -> ""
                                            | _ -> f ^ "_result") in
         L.build_call fdef (Array.of_list actuals) result builder

      | _ -> raise(Failure("No matching pattern in expr"))
    in

    (* Invoke "f builder" if the current block doesn't already
       have a terminal (e.g., a branch). *)
    let add_terminal builder f =
      match L.block_terminator (L.insertion_block builder) with
	       Some _ -> ()
      | None -> ignore (f builder) in
	
    (* Build the code for the given statement; return the builder for
       the statement's successor *)
    let rec stmt builder = function
        A.Block sl -> List.fold_left stmt builder sl
      | A.Vdecl _ -> builder
      | A.Elseif _ -> builder
      | A.Foreach _ -> builder
      | A.Break  -> builder
      | A.Continue  -> builder
      | A.Expr e -> ignore (expr builder e); builder
      | A.Return e -> ignore (match fdecl.A.typ with
          A.Void -> L.build_ret_void builder
        | _ -> L.build_ret (expr builder e) builder); builder

      | A.If (predicate, then_stmt, elif_stmt, else_stmt) ->
        let bool_val = expr builder predicate in
        let merge_bb = L.append_block context "merge" the_function in

        let then_bb = L.append_block context "then" the_function in
	         add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
          (L.build_br merge_bb);

        (* let elif_bb = L.append_block context "elif" the_function in
   add_terminal (stmt (L.builder_at_end context elif_bb) elif_stmt)
     (L.build_br merge_bb); *)

        let else_bb = L.append_block context "else" the_function in
	 add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
	   (L.build_br merge_bb);

        ignore (L.build_cond_br bool_val then_bb else_bb builder);
	 L.builder_at_end context merge_bb

      | A.While (predicate, body) ->
	  let pred_bb = L.append_block context "while" the_function in
	  ignore (L.build_br pred_bb builder);

	  let body_bb = L.append_block context "while_body" the_function in
	  add_terminal (stmt (L.builder_at_end context body_bb) body)
	    (L.build_br pred_bb);

	  let pred_builder = L.builder_at_end context pred_bb in
	  let bool_val = expr pred_builder predicate in

	  let merge_bb = L.append_block context "merge" the_function in
	  ignore (L.build_cond_br bool_val body_bb merge_bb pred_builder);
	  L.builder_at_end context merge_bb

      | A.For (e1, e2, e3, body) -> stmt builder
	    ( A.Block [A.Expr e1 ; A.While (e2, A.Block [body ; A.Expr e3]) ] )

      | _ -> raise(Failure("No matching pattern in stmt"))
    in

    (* Build the code for each statement in the function *)
    let builder = stmt builder (A.Block fdecl.A.body) in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match fdecl.A.typ with
        A.Void -> L.build_ret_void
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

   try List.iter build_function_body functions;
  the_module
with Not_found -> raise(Failure("No matching pattern in buuilding function"))

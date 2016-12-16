(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

open Llvm
open Ast

module L = Llvm
module A = Ast

module StringMap = Map.Make(String)
module SymbolsMap = Map.Make(String)


let struct_types:(string, lltype) Hashtbl.t = Hashtbl.create 10
let struct_datatypes:(string, string) Hashtbl.t = Hashtbl.create 10

let struct_field_indexes:(string, int) Hashtbl.t = Hashtbl.create 50
let struct_field_datatypes:(string, typ) Hashtbl.t = Hashtbl.create 50

let translate (statements, functions, structs) =
  let context = L.global_context () in
  let the_module = L.create_module context "MicroC" in
  (* let llctx = L.global_context () in
  let llmem = L.MemoryBuffer.of_file "bindings.bc" in
  let llm = Llvm_bitreader.parse_bitcode llctx llmem in *)
  
  
  let i32_t  = L.i32_type  context
  and i8_t   = L.i8_type   context
  and i1_t   = L.i1_type   context
  and flt_t  = L.double_type context
  and str_t  = L.pointer_type (L.i8_type context)
  and void_t = L.void_type context 
 in

  let find_struct name =
    try Hashtbl.find struct_types name
    with | Not_found ->  raise (Failure ("Struct not found")) in

  
  let ltype_of_typ input = match input with
      A.Int   -> i32_t
    | A.Float -> flt_t
    | A.Bool  -> i1_t
    | A.Void  -> void_t 
    | A.Str   -> str_t
    | A.Objecttype(struct_name) -> find_struct struct_name
    | _ -> raise(Failure("No matching pattern in ltype_of_typ"))
  in



  (*Define the structs and its fields' datatype, storing in struct_types and struct_field_datatypes*)
    let struct_decl_stub sdecl =
      let struct_t = L.named_struct_type context sdecl.A.sname in (*make llvm for this struct type*)
        Hashtbl.add struct_types sdecl.sname struct_t;  (* add to map name vs llvm_stuct_type *)
    in

    let struct_decl_field_datatypes sdecl =
          let svar_decl_list =
            let rec test_function pass_list head = match head with
                A.Vdecl (t, n) -> (t, n)::pass_list
                | A.Block (a) -> List.fold_left test_function pass_list a
                |_ -> pass_list
            in List.fold_left test_function [] sdecl.A.s_stmt_list
          in

      let type_list = List.map (fun (t,_) -> t) svar_decl_list in (*map the datatypes*)
      let name_list = List.map (fun (_,n) -> n) svar_decl_list in (*map the names*)
  (* Add key all fields in the struct *)
      ignore(
        List.map2 (fun f t -> 
          let n = sdecl.sname ^ "." ^ f in
          Hashtbl.add struct_field_datatypes n t; (*add name, datatype*)  
        ) name_list type_list;
        );

    in

    let struct_decl sdecl =
          let svar_decl_list =
            let rec test_function pass_list head = match head with
                A.Vdecl (t, n) -> (t, n)::pass_list
                | A.Block (a) -> List.fold_left test_function pass_list a
                |_ -> pass_list
            in List.fold_left test_function [] sdecl.A.s_stmt_list
          in

      let struct_t = Hashtbl.find struct_types sdecl.sname in (*get llvm struct_t code for it*)
      let type_list = List.map (fun (t,_) -> ltype_of_typ t) svar_decl_list in (*map the datatypes*)
      let name_list = List.map (fun (_,n) -> n) svar_decl_list in (*map the names*)
      let type_list = i32_t :: type_list in
      let name_list = ".k" :: name_list in
      let type_array = (Array.of_list type_list) in
      List.iteri (fun i f ->
        let n = sdecl.sname ^ "." ^ f in
        Hashtbl.add struct_field_indexes n i; (*add to name struct_field_indices*)
      ) name_list;
    L.struct_set_body struct_t type_array true
  in
  
  (* Add var_types for each struct so we can create it *)
  let _ = List.map (fun s -> struct_decl_stub s) structs in
  let _ = List.map (fun s -> struct_decl s) structs in
  let _ = List.map (fun s -> struct_decl_field_datatypes s) structs in

  (*take out globals*)
  let globals =
    let rec test_function pass_list head = match head with
        A.Vdecl (a, b) -> (a, b)::pass_list
      | A.Block (a) -> List.fold_left test_function pass_list a
      |_ -> pass_list
    in List.fold_left test_function [] statements
  in

(*   let add_map map (n, t) = StringMap.add n t map in
 *)  let global_map = List.fold_left (fun map (t, n) -> StringMap.add n t map) StringMap.empty globals
  in
  (* Declare each global variable; remember its value in a map *)
    let global_vars =
      let global_var m (t, n) =
        let init = L.const_null (ltype_of_typ t)
        in StringMap.add n ((L.define_global n init the_module)) m in
      List.fold_left global_var StringMap.empty globals in

  (* Global assignment *)
  let lookup_global n = try StringMap.find n global_vars 
      with Not_found -> raise(Failure("Global value" ^ n ^" not declared"))
    in

  let rec global_expr = function
      A.Literal i -> L.const_int i32_t i
    | A.FloatLit f  -> L.const_float flt_t f
    | A.StringLit s -> (* str_t *) (* ignore(L.define_global ("test") (L.const_stringz context s) the_module );  *) L.const_pointer_null str_t (* L.const_stringz context s *)
    | A.BoolLit b -> L.const_int i1_t (if b then 1 else 0)
    (* | A.Id s -> L.build_load (lookup_global s) s *)
    | A.Assign (s, e) -> let e' = global_expr e 
                    and gl = lookup_global s
                    and t = StringMap.find s global_map in
                    (* match t with 
                    | A.Str ->(ignore (L.delete_global gl);
                      ignore(L.define_global s (e') the_module ); e')
                    | _ -> *)(ignore (L.delete_global gl);
                        ignore (L.define_global s e' the_module); e')

    | _ -> raise(Failure("Expression not allowed in global"))
  in

  let rec global_stmt = function
      A.Block sl -> List.iter global_stmt sl
    | A.Vdecl _ -> ()
    | A.Expr e -> ignore (global_expr e);
    | _ -> raise(Failure("statements not allowed in global"))
  in

  List.iter global_stmt statements;

  let store_str typ name pass_list = match typ with
      A.Str -> name::pass_list
    | _ -> pass_list
  in

  let rec store_str_var pass_list = function
      A.Block sl -> List.fold_left store_str_var pass_list sl
    | A.Vdecl (typ, name) -> store_str typ name pass_list
    | _ -> pass_list
  in
  let str_var_list = List.fold_left store_str_var [] statements in


  (* let map_str_var name = match typ with
    | A.StringLit s
    | A.Assign (s, e) -> lookup s in list  List.mem let e' = global_expr e
      in let check_empty inp = match value with
        | patt -> expr
        | _ -> " "
      in check_empty e' *)

  (* Declare printf(), which the print built-in function will call *)
 
  let printf_t = L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func = L.declare_function "printf" printf_t the_module in
  let print_number_ty = L.function_type i32_t [| i32_t |] in
  let print_number_func = L.declare_function "print_number" print_number_ty the_module in 

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
    let local_struct_datatypes:(string, string) Hashtbl.t = Hashtbl.create 10 in

    let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
    and float_format_str = L.build_global_stringptr "%f\n" "fmt" builder
    and bool_format_str = L.build_global_stringptr "%d\n" "fmt" builder 
    and string_format_str = L.build_global_stringptr "%s\n" "fmt" builder
      in
    
    (*if name == main add check string add string value*)


    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    (*let local_vars =
      let add_formal m (t, n) p = L.set_value_name n p;
	       let local = L.build_alloca (ltype_of_typ t) n builder in
	       ignore (L.build_store p local builder);
	       StringMap.add n local m in*)

    let local_vars =
      let add_formal m (t, n) p = L.set_value_name n p;
        let formal = match t with
                |Objecttype(struct_n) ->
                        ignore(Hashtbl.add struct_datatypes n struct_n);
                        let local = L.build_alloca (ltype_of_typ t) n builder in
                        ignore (L.build_store p local builder); local

                | _ -> let local = L.build_alloca (ltype_of_typ t) n builder in
                      ignore (L.build_store p local builder); local
          in
         StringMap.add n formal m in 

      let add_local m (t, n) =
	       let local_t = match t with
                |Objecttype(struct_n) ->
                    ignore(Hashtbl.add struct_datatypes n struct_n);  (* add to map name vs type *)
                    find_struct struct_n
                | _ -> ltype_of_typ t
          in
          let llvm_for_allocation = L.build_alloca local_t n builder in
        StringMap.add n llvm_for_allocation m
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

    (* Return the value for a variable or formal argument, for a struct return the pointer *)
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


    (*print function helper*)
    (* let rec gen_type = function
      A.Literal _    -> A.Int
    | A.FloatLit _   -> A.Float
    | A.BoolLit _    -> A.Bool
    | A.StringLit _  -> A.Str
    | A.Id s         -> (match (lookup_datatype s) with
                        |  _ as ty -> ty)
    | A.Call(s,_)    -> let fdecl = 
                        List.find (fun x -> x.A.fname = s) functions in
                        (match fdecl.A.typ with
                        |  _ as ty -> ty)
    | A.Binop(e1, _, _) -> gen_type e1
    | A.Unop(_, e1)     -> gen_type e1
    | A.Assign(s, _)    -> gen_type (A.Id(s))
    | A.StructAccess(var, field) -> (match (lookup_struct_datatype(var,field)) with
                                    |A.Bool -> A.Bool
                                    |A.Float -> A.Float
                                    |A.Str -> A.Str
                                    |_ -> raise(Failure "No match struct type")
                                    )
    | A.Noexpr          -> raise (Failure "corrupted tree - Noexpr as a statement")
    in *)

    let format_str x_type = match x_type with
          "i32"    -> int_format_str
        | "double"  -> float_format_str
        | "i8*" -> string_format_str
        | "i1" -> string_format_str
        | _ -> (* string_format_str *) raise (Failure "Invalid printf type")
    in


    (* Construct code for an expression; return its value *)
    (*builder type*)
    let int_binops op =  (
      match op with
        A.Add     -> L.build_add
      | A.Sub     -> L.build_sub
      | A.Mult    -> L.build_mul
      | A.Div     -> L.build_sdiv
      | A.Mod     -> L.build_urem
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
        | A.Mod     -> L.build_frem
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

    (* Return the datatype for a struct *)
    let lookup_struct_datatype(id, field) = 
      let struct_name = Hashtbl.find struct_datatypes id in (*gets name of struct*)
      let search_term = ( struct_name ^ "." ^ field) in (*builds struct_name.field*)
      let my_datatype = Hashtbl.find struct_field_datatypes search_term in (*get datatype*)
      my_datatype
    in

    (*Struct access function*)
    let struct_access struct_id struct_field isAssign builder = (*id field*)

        let search_term = (struct_name ^ "." ^ struct_field) in
        let field_index = try Hashtbl.find struct_field_indexes search_term
                          with Not_found ->raise(Failure(search_term^""))
        in
        let value = lookup struct_id in
        (*and t = find_struct struct_name in
        let struct_pt = L.build_pointercast value t "tmp" builder in *)
      let _val = L.build_struct_gep value field_index struct_field builder in
      let _val =
        if isAssign then
                build_load _val struct_field builder
            else
          _val
      in
      _val
    in


    let rec expr builder = function
        A.Literal i -> L.const_int i32_t i
      | A.FloatLit f  -> L.const_float flt_t f
      | A.StringLit s -> L.build_global_stringptr s "str" builder
      | A.BoolLit b -> L.const_int i1_t (if b then 1 else 0)
      | A.Noexpr -> L.const_int i32_t 0
      | A.Id s -> L.build_load (lookup s) s builder
      | A.StructAccess (id,field) -> 
      ignore(print_endline("; SAccess"^id));(
            struct_access id field true builder
        )
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
            | A.StructAccess(id, field) ->(
              let my_datatype = lookup_struct_datatype(id,field) in (*get datatype*)
                  (match my_datatype with
                  | A.Bool -> (bool_binops op) e1' e2' "tmp" builder
                  | A.Int -> (int_binops op) e1' e2' "tmp" builder
                  | A.Float -> (float_binops op) e1' e2' "tmp" builder
                  | _ ->  raise (Failure "Invalid Types of Struct binop")
                )
              )
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
                    | A.StructAccess(id,field) ->(
                      let my_datatype = lookup_struct_datatype(id,field) in (*get datatype*)
                        match my_datatype with
                        | A.Int -> L.build_neg
                        | A.Float -> L.build_fneg
                        | _ ->  raise (Failure "Invalid Types of Struct binop")
                        )
                    | _ -> raise (Failure "Invalid Unop type")
                 )
          | A.Not     -> L.build_not) e' "tmp" builder
      | A.Assign (s, e) -> let e' = expr builder e in
	                   ignore (L.build_store e' (lookup s) builder); e'
      | A.StructAssign (id, field, e) -> 
                            let e' = expr builder e in
                            let des =(struct_access id field false builder) in
                            ignore (L.build_store e' des builder);e'
      | A.Call ("print", [e]) ->
      ignore(print_endline("; print"));
        let e' = expr builder e in
        (* ignore(print_endline(L.string_of_llvalue(d')));
          let find_bool input = match L.string_of_llvalue(input) with

            "i1 false" -> print_endline("as");L.build_global_stringptr "false" "bool" builder
          | "i1 true"  -> print_endline("as");L.build_global_stringptr "true" "bool" builder
          | a -> print_endline("as");L.build_global_stringptr "true" "bool"
        in
        let e' = find_bool d' in *)

        let typ_e' = L.string_of_lltype(L.type_of e') in
(*         print_endline(typ_e');
 *)        if typ_e' = "i1" then
          if (L.string_of_llvalue(e')) = "i1 true" then
        L.build_call printf_func [| format_str typ_e' ; L.build_global_stringptr ("true") "str" builder |] "printf" builder
          else
          L.build_call printf_func [| format_str typ_e' ; L.build_global_stringptr ("flase") "str" builder |] "printf" builder
        else
        L.build_call printf_func [| format_str typ_e' ; e' |] "printf" builder
          (* L.build_call printf_func [| int_format_str ; (expr builder e) |]
          "printf" builder *)
         
      | A.Call ("test_print_number", [e]) ->
        L.build_call print_number_func [| (expr builder e) |] "print_number" builder
         
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
      | A.Vdecl (t, n) -> ignore(print_endline("; Vdecl "^n));builder
      | A.Elseif _ -> builder
      | A.Foreach _ -> builder
      | A.Break  -> builder
      | A.Continue  -> builder
      | A.Expr e -> ignore (try expr builder e with Not_found -> raise(Failure("In stmt function Expr error"))); builder
      | A.Return e -> ignore(print_endline("; Return")); ignore (match fdecl.A.typ with
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
    let builder = try stmt builder (A.Block fdecl.A.body) with Not_found -> raise(Failure("stmt function error")) in

      (* Add a return if the last block falls off the end *)
      add_terminal builder (match fdecl.A.typ with
        A.Void -> L.build_ret_void
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

   try List.iter build_function_body functions;
   (* ignore(Llvm_linker.link_modules the_module llm); *)
  the_module
with Not_found -> raise(Failure("No matching pattern in buuilding function"))



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
module TypMap = Map.Make(String)


let struct_types:(string, lltype) Hashtbl.t = Hashtbl.create 10
let struct_datatypes:(string, string) Hashtbl.t = Hashtbl.create 10

let struct_field_indexes:(string, int) Hashtbl.t = Hashtbl.create 50
let struct_field_datatypes:(string, typ) Hashtbl.t = Hashtbl.create 50

let translate (statements, functions, structs) =
  let context = L.global_context () in
  let the_module = L.create_module context "eGrapher" in
  let llctx = L.global_context () in
  let llmem = L.MemoryBuffer.of_file "list.bc" in
  let llm = Llvm_bitreader.parse_bitcode llctx llmem in
  
  
  let i32_t  = L.i32_type  context
  and i8_t   = L.i8_type   context
  and i1_t   = L.i1_type   context
  and flt_t  = L.double_type context
  and str_t  = L.pointer_type (L.i8_type context)
  and void_t = L.void_type context
  and node_t = L.pointer_type (match L.type_by_name llm "struct.ListNode" with
    None -> raise (Invalid_argument "Option.get ListNode")
  | Some x -> x)
  and list_t = L.pointer_type (match L.type_by_name llm "struct.NodeList" with
    None -> raise (Invalid_argument "Option.get")
  | Some x -> x)
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
    | A.ListTyp _  -> list_t
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
      | _ -> pass_list
    in List.fold_left test_function [] statements
  in

   (*record list type*)
  let global_typ = 
    let find_list m (t, n) = match t with
    | A.ListTyp a -> TypMap.add n a m 
    | _ -> m
    in List.fold_left find_list TypMap.empty globals
  in

  let global_map = List.fold_left (fun map (t, n) -> StringMap.add n t map) StringMap.empty globals
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
    | A.Assign (s, e) -> 
                    (* match e with
                    | A.StringLit cont-> let gl = lookup_global s in
                     (ignore (L.delete_global gl);
                      L.define_global s (L.const_stringz context cont) the_module)
                    | _ -> ( *)
                    match e with
                    | A.Literal _ 
                    | A.FloatLit _
                    | A.BoolLit _ -> 
                    let e' = global_expr e
                    and gl = lookup_global s in
                    (* match t with 
                    | A.Str ->(ignore (L.delete_global gl);
                      ignore(L.define_global s (e') the_module ); e')
                    | _ -> *)(ignore (L.delete_global gl);
                        ignore (L.define_global s e' the_module); e')
                    | _ -> raise(Failure("Assign variable type is not primitive type"))

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
  let print_bool_t = L.function_type i32_t [| i32_t |] in
  let print_bool_f = L.declare_function "print_bool" print_bool_t the_module in 

  (* Declare draw triangle *)
  let triangle_t = L.function_type i32_t [| L.pointer_type i8_t |] in 
  let triangle_func = L.declare_function "system" triangle_t the_module in

  (* Declare list functions *)
  let initIdList_t  = L.function_type list_t [| |] in
  let initIdList_f  = L.declare_function "init_List" initIdList_t the_module in

  let appendId_t    = L.function_type list_t [| list_t; L.pointer_type i8_t |] in
  let appendId_f    = L.declare_function "add_back" appendId_t the_module in

  let int_to_pointer_t = L.function_type (L.pointer_type i8_t) [| i32_t |] in
  let int_to_pointer_f = L.declare_function "int_to_pointer" int_to_pointer_t the_module in

  let float_to_pointer_t = L.function_type (L.pointer_type i8_t) [| flt_t |] in
  let float_to_pointer_f = L.declare_function "float_to_pointer" float_to_pointer_t the_module in

  let pointer_to_int_t = L.function_type i32_t [| L.pointer_type i8_t |] in
  let pointer_to_int_f = L.declare_function "pointer_to_int" pointer_to_int_t the_module in

  let pointer_to_float_t = L.function_type flt_t [| L.pointer_type i8_t |] in
  let pointer_to_float_f = L.declare_function "pointer_to_float" pointer_to_float_t the_module in
  
  let index_acess_t = L.function_type (L.pointer_type i8_t) [| list_t; i32_t |] in
  let index_acess_f = L.declare_function "index_acess" index_acess_t the_module in

  let list_length_t = L.function_type i32_t [| list_t |] in
  let list_length_f = L.declare_function "length" list_length_t the_module in

  let list_remove_t = L.function_type i32_t [| list_t; i32_t |] in
  let list_remove_f = L.declare_function "remove_node" list_remove_t the_module in

  let node_change_t = L.function_type i32_t [| list_t; i32_t; L.pointer_type i8_t |] in
  let node_change_f = L.declare_function "node_change" node_change_t the_module in 

(*   let removeIdList_t = L.function_type idlist_t [| idlist_t; L.pointer_type i8_t |] in
  let removeIdList_f = L.declare_function "removeIdList" removeIdList_t the_module in
  let findNodeId_t = L.function_type node_t [| idlist_t; L.pointer_type i8_t |] in
  let findNodeId_f = L.declare_function "findNodeId" findNodeId_t the_module in
  let isEmptyIdList_t = L.function_type i8_t [| idlist_t |] in 
  let isEmptyIdList_f = L.declare_function "isEmptyList" isEmptyIdList_t the_module in *)

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
                            with Not_found -> raise(Failure("No matching pattern in build_function_body"))
    in

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
         (* l_val = L.build_load (lookup objs) objs builder in
            let check = L.build_call list_length_f [| l_val |] "tmp" builder in
            let l_val = L.build_call initIdList_f [||] "init" builder in *)
      let add_local m (t, n) = 
        match t with
            Objecttype(struct_n) -> ignore(Hashtbl.add struct_datatypes n struct_n);
            StringMap.add n (L.build_alloca (find_struct struct_n) n builder) m
          | ListTyp(ty) -> 
              let alloc = L.build_alloca (ltype_of_typ t) n builder in
              let p = L.build_call initIdList_f [||] "init" builder in
              ignore (L.build_store p alloc builder);
              StringMap.add n alloc m
          | _ -> 
          StringMap.add n (L.build_alloca (ltype_of_typ t) n builder) m
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

      let locals = 
          if fdecl.A.fname = "main" then
          let add_list old_list (t, n) = match t with
              ListTyp(ty) -> (t, n) :: old_list
            | _ -> old_list
          in List.fold_left add_list locals globals
        else locals
      in
        
      let formals = List.fold_left2 add_formal StringMap.empty fdecl.A.formals
          (Array.to_list (L.params the_function)) in
      List.fold_left add_local formals locals in

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

       (*record list type*)
      let locals_typ = 
        let find_list m (t, n) = match t with
        | A.ListTyp a -> TypMap.add n a m 
        | _ -> m
        in List.fold_left find_list global_typ (fdecl.A.formals@locals)
      in
    (* print_endline(string_of_int(StringMap.cardinal local_vars)); *)

    (* Return list type when called *)
    let look_typ n = try TypMap.find n locals_typ
                  with Not_found -> raise(Failure("No matching list type in any variable"))
    in

    (* Return the value for a variable or formal argument, for a struct return the pointer *)
    let lookup n = try StringMap.find n local_vars
                  with Not_found -> try StringMap.find n global_vars with Not_found -> raise(Failure("No matching pattern in Local_vars/Global_vars access in lookup"))
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

    let format_str x_type = match x_type with
          "i32"    -> int_format_str
        | "double"  -> float_format_str
        | "i8*" -> string_format_str
        | "i1" -> int_format_str
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
      let struct_name = try Hashtbl.find struct_datatypes struct_id with Not_found -> try Hashtbl.find local_struct_datatypes struct_id with Not_found -> raise(Failure("111"))
    in
        let search_term = (struct_name ^ "." ^ struct_field) in
        let field_index =try Hashtbl.find struct_field_indexes search_term
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

    (* let str_float str = try float_of_string(String.concat "." [(String.sub str 4 (String.length str-4));"0"]) with Not_found -> raise(Failure("fucked up"))
    in *)
    let rec expr builder = function
        A.Literal i -> L.const_int i32_t i
      | A.FloatLit f  -> L.const_float flt_t f
      | A.StringLit s -> L.build_global_stringptr s "str" builder
      | A.BoolLit b -> L.const_int i1_t (if b then 1 else 0)
      | A.Noexpr -> L.const_int i32_t 0
      | A.Id s -> L.build_load (lookup s) s builder
      | A.StructAccess (id,field) -> 
      (* ignore(print_endline("; SAccess"^id)); *)(
            struct_access id field true builder
        )
      | A.Binop (e1, op, e2) ->
	       let e1' = expr builder e1
	       and e2' = expr builder e2 in
         let combine = (L.string_of_lltype(L.type_of e1'), L.string_of_lltype(L.type_of e2'))
          in
            let binop_match combine e1' e2'= match combine with
                ("i32", "i32") -> (* ignore(print_endline("; binop"^string_of_llvalue(e2'))); *)(int_binops op) e1' e2' "tmp" builder
              | ("double", "i32") -> let e3' = build_sitofp e2' flt_t "x" builder in (float_binops op) e1' e3' "tmp" builder
              | ("i32", "double") -> let e3' = build_sitofp e1' flt_t "x" builder in (float_binops op) e3' e2' "tmp" builder
              | ("double", "double") -> (float_binops op) e1' e2' "tmp" builder
              | ("i1", "i1") -> (bool_binops op) e1' e2' "tmp" builder
              | _ -> raise (Failure "Invalid binop type")
            in
          binop_match combine e1' e2'
      | A.Unop(op, e) ->
        let e' = expr builder e in
          (match op with
            A.Neg     -> 
                (match e with
                      A.FloatLit f -> L.build_fneg
                    | A.Literal i -> L.build_neg
                    | A.Id s ->
                      let mytyp = lookup_datatype s in
                        (match mytyp with
                            A.Int -> L.build_neg
                          | A.Float -> L.build_fneg
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

      | A.Objcall (objs, funs, args) ->
          let check_fun objs funs args = match funs with
            | "add" -> (let l_val = L.build_load (lookup objs) objs builder in
(*             let check = L.build_call list_length_f [| l_val |] "tmp" builder in
 *)            
(*                     print_endline(";"^ string_of_bool(L.is_null(check)));
                       print_endline(";"^ (L.string_of_llvalue(check)));
                       print_endline(";"^ (L.value_name(check))); *)
                       let d_val = expr builder (List.hd args) in
                       let void_d_ptr =
                       match look_typ objs with
                       | A.Int ->
                       L.build_call int_to_pointer_f [| d_val |] "tmp" builder
                       | A.Float ->
                       L.build_call float_to_pointer_f [| d_val |] "tmp" builder
                       | _ -> raise(Failure("List contains element other then int or float")) 
                         in
                       let app = L.build_call appendId_f [| l_val; void_d_ptr |] "tmp" builder
                     in
                       (* ignore (L.build_store app (lookup objs) builder); *)
                       app)

            | "get" -> (let l_val = L.build_load (lookup objs) objs builder in
                       let d_val = expr builder (List.hd args) in
                       let void_ptr = L.build_call index_acess_f [| l_val;d_val |] "tmp" builder in
                       match look_typ objs with
                       | A.Int ->
                       L.build_call  pointer_to_int_f [| void_ptr |] "tmp" builder
                       | A.Float ->
                       L.build_call  pointer_to_float_f [| void_ptr |] "tmp" builder
                       | _ -> raise(Failure("List contains element other then int or float")) 
                       L.build_call  pointer_to_int_f [| void_ptr |] "tmp" builder)
                       (* let void_res = L.build_call index_acess_f [| void_d_ptr;d_val |] "tmp" builder in
                       L.build_call pointer_to_int_f [| void_res |] "tmp" builder *)

            | "remove" -> (let l_val = L.build_load (lookup objs) objs builder in
                          let d_val = expr builder (List.hd args) in
                          let app = L.build_call list_remove_f [| l_val;d_val |] "rmv" builder in
                            app )

            | _ -> L.const_int i32_t 42
          in 
          check_fun objs funs args
      | A.ListAssign (id, pos, e) -> 
                    (let l_val = L.build_load (lookup id) id builder in
                      let position = expr builder pos in
                      let data = expr builder e in
                      let data2 = 
                        match TypMap.find id locals_typ with
                        | A.Int ->
                        L.build_call  int_to_pointer_f [| data |] "tmp" builder
                        | A.Float ->
                        L.build_call  float_to_pointer_f [| data |] "tmp" builder
                        | _ -> raise(Failure("List contains element other then int or float")) 
                      in
                      L.build_call node_change_f [| l_val;position;data2 |] "tmp" builder )
                      
      | A.Call ("triangle", [a1;a2;a3;a4;a5;a6]) -> 
        let triangle_args= String.concat " " ["./lib/run "; string_of_expr(a1);string_of_expr(a2);string_of_expr(a3);string_of_expr(a4);string_of_expr(a5);string_of_expr(a6)] in
        let e' =  L.build_global_stringptr triangle_args "str" builder in
        L.build_call triangle_func [| e' |] "triangle" builder 

      | A.Call ("print", [e]) ->
        (* ignore(print_endline("; print")); *)
        let e' = expr builder e in
        let typ_e' = L.string_of_lltype(L.type_of e') in
          if typ_e' = "i1" then
            (* if (L.string_of_llvalue(e')) = "i1 true" then
            L.build_call printf_func [| format_str typ_e' ; L.build_global_stringptr ("true") "str" builder |] "printf" builder
            else
            L.build_call printf_func [| format_str typ_e' ; L.build_global_stringptr ("flase") "str" builder |] "printf" builder *)
            let e1' = build_sitofp e' flt_t "x" builder in
            let e2' = build_fptosi e1' i32_t "x2" builder in
            (* ignore(print_endline("; "^L.string_of_lltype(L.type_of e2'))); *)
            L.build_call print_bool_f [| e2' |] "print_bool" builder
            (* L.build_call printf_func [| format_str typ_e' ; e' |] "printf" builder *)
          else
          L.build_call printf_func [| format_str typ_e' ; e' |] "printf" builder
          (* L.build_call printf_func [| int_format_str ; (expr builder e) |]
          "printf" builder *)
         
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
      | A.Vdecl (t, n) -> (* ignore(print_endline("; Vdecl "^n)); *)builder
      | A.Elseif _ -> builder
      | A.Foreach _ -> builder
      | A.Break  -> builder
      | A.Continue  -> builder
      | A.Expr e -> ignore (try expr builder e with Not_found -> raise(Failure("In stmt function Expr error"))); builder
      | A.Return e -> (* ignore(print_endline("; Return")); *) ignore (match fdecl.A.typ with
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



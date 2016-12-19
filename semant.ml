(* Semantic checking for the eGrapher compiler *)

open Ast

module StringMap = Map.Make(String)

let check (statements, functions, structs) =

  (*struct check*)
  let struct_map = 
    let test m s =
      let in_map = 
        let x_map map a = 
          match a with
          Vdecl (t, n) ->
            StringMap.add n t map
          | _ -> raise (Failure ("should not assign value in struct"))
        in
        List.fold_left x_map StringMap.empty s.s_stmt_list
        
      in
      StringMap.add s.sname in_map m
    in
    List.fold_left test StringMap.empty structs
  in
  (* Raise an exception if the given list has a duplicate *)
  let report_duplicate exceptf list =
    let rec helper = function
        n1 :: n2 :: _ when n1 = n2 -> raise (Failure (exceptf n1))
      | _ :: t -> helper t
      | [] -> ()
    in helper (List.sort compare list)
  in

  (* Raise an exception if a given binding is to a void type *)
  let check_not_void exceptf = function
      (Void, n) -> raise (Failure (exceptf n))
    | _ -> ()
  in
  
  (* Raise an exception of the given rvalue type cannot be assigned to
     the given lvalue type *)
  let check_assign lvaluet rvaluet err =
    match (lvaluet, rvaluet) with
      (ListTyp a, ListTyp b) -> if a = b then lvaluet else raise err
    | (Objecttype a, Objecttype b) ->  if a = b then lvaluet else raise err
    | (a, b) -> ignore(print_endline("; "^string_of_typ a));if lvaluet == rvaluet then lvaluet else raise err
  in

  (* Separate global variable from statements *)
  (* Only allow variable declaration and assignment*)
  let globals = 
    let rec test pass_list = function
        [] -> pass_list
      | hd :: tl -> let newlist = 
                      let match_fuc hd pass_list= match hd with
                        Vdecl (a, b) -> (a, b)::pass_list
                      | Expr (a) -> (fun x -> match x with Assign _-> pass_list | _ -> raise (Failure ("Wrong declare type in Block")) ) a
                      | _ -> raise (Failure ("wrong declare in Block"))
                      in match_fuc hd pass_list
      in test newlist tl
    in
        let test_function pass_list head = match head with
            Vdecl (a, b) -> (a, b)::pass_list
          | Expr (a) -> (fun x -> match x with Assign _-> pass_list | _ -> raise (Failure ("wrong declare in Block")) ) a
          | Block (block) ->  test pass_list block
          | _ -> raise (Failure ("Should not declare other than vdecl"))
        in List.fold_left test_function [] statements
      in
      
  List.iter (check_not_void (fun n -> "illegal void global " ^ n)) globals;
   
  report_duplicate (fun n -> "duplicate global " ^ n) (List.map snd globals);

  (**** Checking Functions ****)

  (* Check that a function named print is not defined *)
  if List.mem "print" (List.map (fun fd -> fd.fname) functions)
  then raise (Failure ("function print may not be defined")) else ();

  (* Check that there are no duplicate function names *)
  report_duplicate (fun n -> "duplicate function " ^ n)
    (List.map (fun fd -> fd.fname) functions);

  (* Function declaration for a named function *)
  let built_in_decls =  StringMap.add "print"
     { typ = Void; fname = "print"; formals = [(Int, "x")];
        body = [] } (StringMap.singleton "plot"
     { typ = Void; fname = "printb"; formals = [(Bool, "x")];
        body = [] })
   in
   (* let built_in_decls = StringMap.add "prints"
     { typ = Void; fname = "printf"; formals = [(Float, "x")];
        body = [] } built_in_decls
   in
   let built_in_decls = StringMap.add "prints"
     { typ = Void; fname = "prints"; formals = [(Str, "x")];
        body = [] } built_in_decls
   in *)

  (* Add all function into function_decls *)
  let function_decls = List.fold_left (fun m fd -> StringMap.add fd.fname fd m)
                         built_in_decls functions
  in

  (* Check if function is declared before *)
  let function_decl s = try StringMap.find s function_decls
       with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in

  let _ = function_decl "main" in (* Ensure "main" is defined *)

  let check_function func =

    (* Get all function locals*)
    let func_locals = 
      let rec get_local pass_list head = match head with
          Vdecl (typ, name) -> (typ, name)::pass_list
        | Block (block) -> List.fold_left get_local pass_list block
        | _ -> pass_list
      in List.fold_left get_local [] func.body
    in

    List.iter (check_not_void (fun n -> "illegal void formal " ^ n ^
      " in " ^ func.fname)) func.formals;

    List.iter (check_not_void (fun n -> "illegal void local " ^ n ^
      " in " ^ func.fname)) func_locals;

    report_duplicate (fun n -> "duplicate formal or local " ^ n ^ " in function " ^ func.fname ^ "()")
      (List.map snd (func.formals@func_locals));

    let local_syb = List.fold_left (fun m (t, n) -> StringMap.add n t m)
      StringMap.empty (func.formals @ func_locals )
    and glob_syb = List.fold_left (fun m (t, n) -> StringMap.add n t m)
      StringMap.empty (globals)
    in

    let type_of_identifier s=
      try StringMap.find s local_syb
      with Not_found -> try StringMap.find s glob_syb
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in

    (* Add all object methods *)
    (* let obj_methods =  StringMap.add "add"
       (ListTyp Void,Int,1) (StringMap.singleton "plot"
       (Int,Int,1))
    in

    let obj_method s = try StringMap.find s obj_methods
         with Not_found -> raise (Failure ("unrecognized object function " ^ s))
    in *)

    (* Return the type of an expression or throw an exception *)
    let rec expr = function
		    Literal _ -> Int
      | BoolLit _ -> Bool
      | FloatLit _ -> Float
      | StringLit _ -> Str
      | Id s -> type_of_identifier s
      | Binop(e1, op, e2) as e -> let t1 = expr e1 and t2 = expr e2 in
				(match op with
          		  Add | Sub | Mult | Div when (t1 = Int || t1 = Float) && (t2 = Int || t2 = Float) -> (if t1 = Float || t2 = Float then Float
          		  						 else Int)
				| Equal | Neq when t1 = t2 -> Bool
				| Less | Leq | Greater | Geq when t1 = Int && t2 = Int -> Bool
				| And | Or when t1 = Bool && t2 = Bool -> Bool
        		| _ -> raise (Failure ("illegal binary operator " ^
              		string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
              		string_of_typ t2 ^ " in " ^ string_of_expr e))
        		)
      | Unop(op, e) as ex -> let t = expr e in
	 	     (match op with
	   	     Neg when t = Int -> Int
	 	     | Not when t = Bool -> Bool
         | _ -> raise (Failure ("illegal unary operator " ^ string_of_uop op ^
	  		   string_of_typ t ^ " in " ^ string_of_expr ex)))
      | Noexpr -> Void
      | Assign(var, e) as ex -> let lt = type_of_identifier var
                                and rt = expr e in
        check_assign lt rt (Failure ("illegal assignment " ^ string_of_typ lt ^
				     " = " ^ string_of_typ rt ^ " in " ^ 
				     string_of_expr ex))
      | Objcall(obj, meth, args) ->
        (match meth with
          "add" ->
          (let lst = type_of_identifier obj in
            match lst with
              ListTyp(t) -> let ele = expr (List.hd args) in
                if t <> ele then
                  raise (Failure("variable "^obj^" is not matching type of input"))
                else
                  ListTyp(t)
            | _ -> raise (Failure("variable "^obj^" is not matching type of "^meth^" method "))
          )
          | "get" -> 
            (let lst = type_of_identifier obj in
            match lst with
              ListTyp(t) -> t
            | _ -> raise (Failure("variable "^obj^" is not matching type of "^meth^" method "))
          )
        | _ -> raise (Failure("have not define obj call"))
        )
      | Call(fname, actuals) as call -> 
         (let fd = function_decl fname in
         if List.length actuals != List.length fd.formals then
           raise (Failure ("expecting " ^ string_of_int
             (List.length fd.formals) ^ " arguments in " ^ string_of_expr call))
         else
            match fname with 
            "print" -> ignore(expr (List.hd actuals));Int 
            | _ ->
              List.iter2 (fun (ft, _) e -> let et = expr e in
                ignore (check_assign ft et
                (Failure ("illegal actual argument found " ^ string_of_typ et ^
                " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e))))
             fd.formals actuals;
           fd.typ)
      | StructAccess (id,field) -> ( let item = type_of_identifier id in
                                    match item with
                                      Objecttype st_n -> (let args = StringMap.find st_n struct_map in 
                                        try StringMap.find field args with Not_found -> raise(Failure("struct has no matched field "^field))
                                      )
                                    | _-> raise (Failure ("No matched struct")) )

      | StructAssign (id, field, e) -> let item = type_of_identifier id in
                                      match item with
                                      Objecttype st_n -> (let args = StringMap.find st_n struct_map in 
                                        let left = try  StringMap.find field args with Not_found -> raise(Failure("struct has no matched field")) in
                                        let et = expr e
                                      in
                                        check_assign left et (Failure ("illegal actual argument found in structassign "^id)) 
                                      )
                                    | _-> raise (Failure ("No matched struct"))
    in

    let check_bool_expr e = if expr e != Bool
     then raise (Failure ("expected Boolean expression in " ^ string_of_expr e))
     else () in

    (* Verify a statement or throw an exception *)
    let rec stmt = function
        Block sl -> let rec check_block = function
             [Return _ as s] -> stmt s
           | Return _ :: _ -> raise (Failure "nothing may follow a return")
           | Block sl :: ss -> check_block (sl @ ss)
           | s :: ss -> stmt s ; check_block ss
           | [] -> ()
        in check_block sl
      | Expr e -> ignore (expr e)
      | Vdecl (e1, e2) -> ()
      | Return e -> let t = expr e in if t = func.typ then () else
         raise (Failure ("return gives " ^ string_of_typ t ^ " expected " ^
                         string_of_typ func.typ ^ " in " ^ string_of_expr e))
           
      | If(p, b, b1, b2) -> check_bool_expr p; stmt b; stmt b1; stmt b2
      | Elseif(e, s) -> check_bool_expr e; stmt s
      | For(e1, e2, e3, st) -> ignore (expr e1); check_bool_expr e2;
                               ignore (expr e3); stmt st
      | While(p, s) -> check_bool_expr p; stmt s
      | _ -> raise (Failure ("Not a vaid stmt"))
    in

    stmt (Block func.body)
   
  in
  List.iter check_function functions

    (* let fun_local = 
      let rec test_function pass_list head = match head with
        Vdecl (a, b) -> (a, b)::pass_list
      | Block (a) -> List.fold_left test_function pass_list a
      |_ -> pass_list
      in List.fold_left test_function [] statements
    in
    (* Type of each variable (global, formal, or local *)
    let symbols = List.fold_left (fun m (t, n) -> StringMap.add n t m)
      StringMap.empty (globals @ func.formals @ fun_local ) *)

    (* in *)
      (* Verify a statement or throw an exception *)
    (* let rec stmt = function
  Block sl -> let rec check_block = function
           [Return _ as s] -> stmt s
         | Return _ :: _ -> raise (Failure "nothing may follow a return")
         | Block sl :: ss -> check_block (sl @ ss)
         | s :: ss -> stmt s ; check_block ss
         | [] -> ()
        in check_block sl *)
      (* | Expr e -> ignore (expr e) *)
      (* | Return e -> let t = expr e in if t = func.typ then () else
         raise (Failure ("return gives " ^ string_of_typ t ^ " expected " ^
                         string_of_typ func.typ ^ " in " ^ string_of_expr e)) *)
           
      (* | If(p, b1, b2,c) -> check_bool_expr p; stmt b1; stmt b2
      | For(e1, e2, e3, st) -> ignore (expr e1); check_bool_expr e2;
                               ignore (expr e3); stmt st
      | While(p, s) -> check_bool_expr p; stmt s *)
    (* in
    stmt (Block func.body) *)






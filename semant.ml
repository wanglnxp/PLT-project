(* Semantic checking for the MicroC compiler *)

open Ast

module StringMap = Map.Make(String)

let check (statements, functions) =

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
     if lvaluet == rvaluet then lvaluet else raise err
  in

  let globals = 
    let rec test pass_list = function
        [] -> pass_list
      | hd :: tl -> let newlist = 
                      let match_fuc hd pass_list= match hd with
                        Vdecl (a, b) -> (a, b)::pass_list
                      | Expr (a) -> pass_list
                      | _ -> raise (Failure ("wrong declare in Block"))
                      in match_fuc hd pass_list
      in test newlist tl
    in
        let test_function pass_list head = match head with
            Vdecl (a, b) -> (a, b)::pass_list
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
   let built_in_decls = StringMap.add "prints"
     { typ = Void; fname = "printf"; formals = [(Float, "x")];
        body = [] } built_in_decls
   in
   let built_in_decls = StringMap.add "prints"
     { typ = Void; fname = "prints"; formals = [(Str, "x")];
        body = [] } built_in_decls
   in

  (* Add all function into function_decls *)
  let function_decls = List.fold_left (fun m fd -> StringMap.add fd.fname fd m)
                         built_in_decls functions
  in

  (* Check if function is declared before *)
  let function_decl s = try StringMap.find s function_decls
       with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in

  let check_function func =

    List.iter (check_not_void (fun n -> "illegal void formal " ^ n ^
      " in " ^ func.fname)) func.formals;

    report_duplicate (fun n -> "duplicate formal " ^ n ^ " in " ^ func.fname)
      (List.map snd func.formals);

    (* check function local *)
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
  in
  List.iter check_function functions






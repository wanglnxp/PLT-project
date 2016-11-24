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
       locals = []; body = [] })
   in
   let built_in_decls = StringMap.add "prints"
     { typ = Void; fname = "prints"; formals = [(Str, "x")];
       locals = []; body = [] } built_in_decls
   in

  let function_decls = List.fold_left (fun m fd -> StringMap.add fd.fname fd m)
                         built_in_decls functions
  in






  


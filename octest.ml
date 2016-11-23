module StringMap = Map.Make(String)

type stmt =
    Vdecl of string * int
  | Others of string * int

let stlist = [Vdecl("a", 1);Others("a", 2);Vdecl("b", 2)]

let map1 = StringMap.empty
let map2 = StringMap.empty
let map3 = StringMap.empty

let rec test pass_map = function
	|hd::(tl:stmt list) -> let check_block head temp = match head with
					|Vdecl (a, b) -> if not (StringMap.mem a temp) then 
						StringMap.add a b temp
					else raise (Failure ("Redeclared"))
					|Others (a, b) -> if StringMap.mem a temp then temp else raise (Failure ("not declared"))
				in test (check_block hd pass_map) tl
	|[] -> pass_map

let map1 = test StringMap.empty stlist

let print_users key times =
	print_int times;
	print_endline(" " ^ key)

let() = StringMap.iter print_users map1

(* let globals =
    let rec test2 pass_list = function
      |hd::(tl:stmt list) -> let check_block head temp = match head with
                                |Vdecl (a, b) ->(a, b)::pass_list
                                |_ -> pass_list
                                in test2 (check_block hd pass_list) tl
      |[] -> pass_list
    in test2 [] stlist *)


let  test_function pass_list head = match head with
	 Vdecl (a, b) -> (a, b)::pass_list
	|_ -> pass_list

let globals = List.fold_left test_function [] stlist

let printnew (a,b) = print_string a; print_string " ";print_int b;print_endline("")
let() = List.iter printnew globals

(* let a =  1
in
let add b = b + 1
in
let b = add a
in

print_int b;

print_string "Hello world!\n";


let a =  1
in
let add b = b + 1
in
let b = add a
in

print_int b;

print_string "Hello world!\n" *)

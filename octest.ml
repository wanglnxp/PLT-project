module StringMap = Map.Make(String)

type stmt =
    Vdecl of string * int
  | Others of string * int

let stlist = [Vdecl("a", 1);Others("b", 2)]

let map1 = StringMap.empty
let map2 = StringMap.empty
let map3 = StringMap.empty

let stmt temp stmt=
	|Vdecl (a, b) -> StringMap.add a b temp

 
let map3 = List.fold_left stmt StringMap.empty stlist

(* let map1 = StringMap.empty
let map1 = StringMap.add "a" 1 map1 *)
let print_users key times =
	print_int times;
	print_endline(" " ^ key)

let() = StringMap.iter print_users map1

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

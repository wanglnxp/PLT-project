(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Mod | Equal | Neq | Less | Leq | Greater | Geq | And | Or

type uop = Neg | Not

type typ = Int | Float | Bool | Str | Void | ListTyp of typ | Pot | Lin | Objecttype of string

type pot = {
  x_ax: float;
  y_ax: float;
  form: string;
  color: string;
}

type line = {
  star_p: float * float;
  end_p: float * float;
  form: string;
  color: string;
}

type expr = 
    Literal of int
  | FloatLit of float
  | StringLit of string
  | BoolLit of bool
  | Id of string
  | Point of pot
  | Line of line
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of string * expr
  | Call of string * expr list (*function call*)
(*   | Objcall of string * string * expr list
  | Dotassign of string * string * expr
  | Lineassign of string * string * expr * expr *)
  | List of expr list
  | Mem of string * expr
  | ListAssign of string * expr * expr
  | StructAssign of string * string * expr
  | StructAccess of string * string
  | Noexpr


type stmt =
    Vdecl of typ * string
  | Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt * stmt
  | Elseif of expr * stmt
  | For of expr * expr * expr * stmt
  | Foreach of expr * expr * stmt
  | While of expr * stmt
  | Break
  | Continue

type formal = typ * string

type func_decl = {
    typ : typ;
    fname : string; (* Name of the function *) 
    formals : formal list; (* Formal argument names *) 
    body : stmt list;
  }

type s_decl = {
    sname : string;
    s_stmt_list : stmt list;
  }

type program = stmt list * func_decl list * s_decl list

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"

let rec string_of_expr = function
    Literal(l) -> string_of_int l
  | FloatLit(f) -> string_of_float f
  | StringLit(s) -> s
  | BoolLit(x) -> (if x then "true" else "false")
  | Id(s) -> s
(*   | Point of pot
  | Line of line *)
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
(*   | Objcall of string * string * expr list
  | Dotassign of string * string * expr
  | Lineassign of string * string * expr * expr *)
  (* | List of expr list *)
  (* | Mem of string * expr
  | ListAssign of string * expr * expr
  | StructAssign of string * string * expr
  | StructAccess of string * string *)
  | Noexpr -> ""

let string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Float -> "float"
  | Str -> "string"
  | Void -> "void"
  | ListTyp _ -> "list"
  | Objecttype _ -> "struct"

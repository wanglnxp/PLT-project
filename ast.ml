(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Mod | Equal | Neq | Less | Leq | Greater | Geq | And | Or

type uop = Neg | Not

type typ = Int | Float | Bool | Str | Void | ListTyp of typ | Pot | Lin

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
  | Objcall of string * string * expr list
  | Objmem of string * string
  | Dotassign of string * string * expr
  | Lineassign of string * string * expr * expr
  | List of expr list
  | Mem of string * expr
  | ListAssign of string * expr * expr
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

type program = stmt list * func_decl list


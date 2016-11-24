(* Ocamllex scanner for eGrahper *)

{ open Parser }

let digit = ['0'-'9']
let float = '-'?(digit+) ['.'] digit+
let bool = "True" | "False"

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "/*"     { comment lexbuf }           (* Comments *)
| '('      { LPAREN }
| ')'      { RPAREN }
| '['      { LBRACKET }
| ']'      { RBRACKET }
| '{'      { LBRACE }
| '}'      { RBRACE }
| ';'      { SEMI }
| ','      { COMMA }
| '+'      { PLUS }
| '-'      { MINUS }
| '*'      { TIMES }
| '/'      { DIVIDE }
| '%'      { MOD }
| '='      { ASSIGN }
| '.'      { DOT }
| "=="     { EQ }
| "!="     { NEQ }
| '<'      { LT }
| "<="     { LEQ }
| '>'      { GT }
| ">="     { GEQ }
| "&&"     { AND }
| "||"     { OR }
| '!'      { NOT }
| "if"     { IF }
| "else"   { ELSE }
| "elif"   { ELSEIF }
| "for"    { FOR }
| "in"     { IN }
| "while"  { WHILE }
| "return" { RETURN }
| "break"  { BREAK }
| "continue" { CONTINUE }
(*| "endelif"{ ENDELIF }*)

| "int"    { INT }
| "float"    { FLOAT }
| "bool"   { BOOL }
| "string" { STR }
| "void"   { VOID }
| "list"   { LIST }
| "point"    { POINT }
| "line"   { LINE }
(*| "class"  { CLASS }*)

| "NULL"   { NULL }

| bool as lxm { BOOLEAN_LITERAL (bool_of_string lxm) }
| ['0'-'9']+ as lxm { LITERAL(int_of_string lxm) }
| float as lxm { FLOAT_LITERAL(float_of_string lxm) }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { ID(lxm) }
| '"' {let buffer = Buffer.create 1 in STRING_LITERAL (stringl buffer lexbuf) }

| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and stringl buffer = parse
	| '"' { Buffer.contents buffer }
	| "\\t" { Buffer.add_char buffer '\t'; stringl buffer lexbuf }
	| "\\n" { Buffer.add_char buffer '\n'; stringl buffer lexbuf }
	| "\\\"" { Buffer.add_char buffer '"'; stringl buffer lexbuf }
	(*| "\\\\" { Buffer.add_char buffer '\\'; stringl buffer lexbuf }*)
	| _ as char { Buffer.add_char buffer char; stringl buffer lexbuf }

and comment = parse
  "*/" { token lexbuf }
| _    { comment lexbuf }

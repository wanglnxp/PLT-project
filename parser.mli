type token =
  | SEMI
  | LPAREN
  | RPAREN
  | LBRACKET
  | RBRACKET
  | LBRACE
  | RBRACE
  | COMMA
  | DOT
  | PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | MOD
  | ASSIGN
  | NOT
  | EQ
  | NEQ
  | LT
  | LEQ
  | GT
  | GEQ
  | TRUE
  | FALSE
  | AND
  | OR
  | RETURN
  | IF
  | ELSE
  | ELSEIF
  | FOR
  | IN
  | WHILE
  | BREAK
  | CONTINUE
  | NUM
  | STR
  | BOOL
  | VOID
  | ENDELIF
  | LIST
  | NULL
  | LITERAL of (float)
  | ID of (string)
  | STRING of (string)
  | EOF

val start :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program

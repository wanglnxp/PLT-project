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
  | INT
  | FLOAT
  | STR
  | BOOL
  | VOID
  | POINT
  | LINE
  | LIST
  | NULL
  | STRUCT
  | LITERAL of (int)
  | FLOAT_LITERAL of (float)
  | BOOLEAN_LITERAL of (bool)
  | ID of (string)
  | STRING_LITERAL of (string)
  | EOF

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program

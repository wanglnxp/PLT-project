%{
open Ast
%}

%token SEMI LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE COMMA DOT
%token PLUS MINUS TIMES DIVIDE MOD ASSIGN NOT
%token EQ NEQ LT LEQ GT GEQ TRUE FALSE AND OR
%token RETURN IF ELSE ELSEIF FOR IN WHILE BREAK CONTINUE 
%token INT FLOAT STR BOOL VOID POINT LINE
%token LIST NULL STRUCT /*CLASS*/
%token <int> LITERAL
%token <float> FLOAT_LITERAL
%token <bool> BOOLEAN_LITERAL
%token <string> ID
%token <string> STRING_LITERAL

%token EOF

%nonassoc NOELSE /*how to use*/
%nonassoc ELSE
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE
%left MOD
%right NOT NEG /*should we use nonassoc?*/

%start program
%type <Ast.program> program

%%

program: 
  decls EOF { let (a, b, c) = $1 in  (a, List.rev b, c) }

/*How to make sure stmt always before fedcl*/
decls:
    /* nothing */   { [], [], []}
  | decls stmt { let (a, b, c) = $1 in ($2 :: a), b,c }
  | decls fdecl { let (a, b, c) = $1 in a, ($2 :: b),c }
  | decls sdecl { let (a, b, c) = $1 in a,b, ($2 :: c) }

vdecl_list:
    /* nothing */    { [] }
  | vdecl_list typ ID SEMI { Vdecl($2, $3) :: $1 }

vdecl:
   typ ID SEMI             { Vdecl($1, $2) }
  |typ ID ASSIGN expr SEMI { Block([Vdecl($1, $2);Expr(Assign($2,$4))]) }

sdecl_list:
    /* nothing */    { [] }
  | sdecl_list sdecl { $2 :: $1 }

sdecl:
  STRUCT ID LBRACKET vdecl_list RBRACKET
      { {
      sname = $2;
      s_stmt_list = List.rev $4;
      } }


stmt_list:
    /* nothing */   { [] }
  | stmt_list stmt  { $2 :: $1 }


elseif_list:
  | elseif_list elseif  { $2 :: $1 }

elseif:
  ELSEIF LPAREN expr RPAREN stmt { Elseif($3, $5) }


stmt:
    expr SEMI                          { Expr $1 }
  | vdecl                              { $1 }
  | LBRACE stmt_list RBRACE            { Block(List.rev $2) }
  | RETURN expr SEMI          { Return($2) }

  | IF LPAREN expr RPAREN stmt %prec NOELSE  { If($3, $5, Block([]), Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt  { If($3, $5, Block([]), $7) }
  | IF LPAREN expr RPAREN stmt elseif_list ELSE stmt  { If($3, $5,  Block($6), $8) }
  
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt { For($3, $5, $7, $9) }
  | FOR LPAREN expr IN expr RPAREN stmt { Foreach($3, $5, $7)}
  | WHILE LPAREN expr RPAREN stmt  { While($3, $5) }
  | BREAK SEMI  { Break }
  | CONTINUE SEMI  { Continue }


fdecl:
   typ ID LPAREN formals_opt RPAREN LBRACE stmt_list RBRACE
     { { typ = $1;
	 fname = $2;
	 formals = $4;
	 body = List.rev $7 } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { List.rev $1 }

formal_list:
    typ ID                   { [($1,$2)] }
  | formal_list COMMA typ ID { ($3,$4) :: $1 }

typ:
    INT { Int }
  | FLOAT { Float }
  | BOOL { Bool }
  | STR  { Str }
  | VOID { Void }
  | LIST typ { ListTyp($2) }
  | POINT{ Pot } 
  | LINE { Lin }
  | STRUCT ID   { Objecttype($2) }

/*point:
    LPAREN LITERAL COMMA LITERAL COMMA STRING COMMA STRING RPAREN  { {x_ax=$2; y_ax=$4; form=$6 color=$8 } }*/
    /*LPAREN expr COMMA expr COMMA expr COMMA expr RPAREN  { ($2,$4,$6,$8) }*/


/*line:
    LPAREN LPAREN expr COMMA expr RPAREN COMMA LPAREN expr COMMA expr RPAREN COMMA expr COMMA expr RPAREN  { {star_p=($3,$5); end_p=($9,$11); form=$14 color=$16 } }*/
    /*LPAREN LPAREN expr COMMA expr RPAREN COMMA LPAREN expr COMMA expr RPAREN COMMA expr COMMA expr RPAREN  { ($3,$5,$9,$11,$14,$16) }*/

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    LITERAL          { Literal($1) }
  | FLOAT_LITERAL    { FloatLit($1) }
  | STRING_LITERAL   { StringLit($1) }
  | BOOLEAN_LITERAL  { BoolLit($1) }
  | ID               { Id($1) }
  /*| point            { $1 }*/
  /*| line             { Line($1) }*/
  /*| ID DOT ID ASSIGN expr { Dotassign($1, $3, $5) }
  | ID DOT ID ASSIGN LPAREN expr COMMA expr RPAREN { Lineassign($1, $3, $6, $8) }*/

  | NULL             { Noexpr }
  /*| LPAREN expr RPAREN { $2 } */
  | expr PLUS   expr { Binop($1, Add,   $3) }
  | expr MINUS  expr { Binop($1, Sub,   $3) }
  | expr TIMES  expr { Binop($1, Mult,  $3) }
  | expr DIVIDE expr { Binop($1, Div,   $3) }
  | expr MOD    expr { Binop($1, Mod,   $3) }
  | expr EQ     expr { Binop($1, Equal, $3) }
  | expr NEQ    expr { Binop($1, Neq,   $3) }
  | expr LT     expr { Binop($1, Less,  $3) }
  | expr LEQ    expr { Binop($1, Leq,   $3) }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3) }
  | expr AND    expr { Binop($1, And,   $3) }
  | expr OR     expr { Binop($1, Or,    $3) }
  | MINUS expr %prec NEG { Unop(Neg, $2) }
  | NOT expr         { Unop(Not, $2) }

  | ID ASSIGN expr   { Assign($1, $3) }

  | ID DOT ID ASSIGN expr {StructAssign($1, $3, $5)}
  | ID DOT ID        { StructAccess($1, $3) }
  | ID LBRACKET expr RBRACKET ASSIGN expr    { ListAssign($1, $3, $6) }
  | ID LBRACKET expr RBRACKET { Mem($1, $3) }
  | LBRACKET list_opt RBRACKET { List($2) }

  | ID LPAREN list_opt RPAREN { Call($1, $3) }
  | LPAREN expr RPAREN { $2 }

  /*| ID DOT ID LPAREN list_opt RPAREN { Objcall($1, $3, $5) }*/

list_opt:
    /*nothing*/  { [] }
  |list          { List.rev $1 }

list:
  | expr            { [$1] }
  | list COMMA expr { $3 :: $1 }


%{
open Ast
%}

%token SEMI LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE COMMA DOT
%token PLUS MINUS TIMES DIVIDE MOD ASSIGN NOT
%token EQ NEQ LT LEQ GT GEQ TRUE FALSE AND OR
%token RETURN IF ELSE ELSEIF FOR IN WHILE BREAK CONTINUE 
%token NUM STR BOOL VOID POINT LINE
%token LIST NULL /*CLASS*/
%token <float> LITERAL
%token <string> ID
%token <string> STRING
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

%start start
%type <Ast.program> start

%%

start: 
  program EOF { $1 }

program:
    /* nothing */   { [], [] }
  | program stmt { let (a, b) = $1 in ($2 :: a), b }
  | program fdecl { let (a, b) = $1 in a, ($2 :: b) }


vdecl:
  typ ID ASSIGN expr SEMI { Block([Vdecl($1, $2);Expr(Assign($2,$4))]) }

stmt_list:
    /* nothing */   { [] }
  | stmt_list stmt  { $2 :: $1 }


elseif_list:
  | elseif_list elseif  { $2 :: $1 }

elseif:
  ELSEIF LPAREN expr RPAREN stmt { Elseif($3, List.rev $5) }



stmt:
    expr SEMI                          { Expr $1 }
  | vdecl                              { Vdecl $1}
  | LBRACE stmt_list RBRACE            { Block(List.rev $2) }
  | RETURN expr SEMI          { Return($2) }

  | IF LPAREN expr RPAREN stmt %prec NOELSE  { If($3, $5, [Block([])], [Block([])]) }
  | IF LPAREN expr RPAREN stmt ELSE stmt  { If($3, $5, [Block([])], $7) }
  | IF LPAREN expr RPAREN stmt elseif_list ELSE stmt  { If($3, $5, $6, $8) }
  
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt { For($3, $5, $7, $9) }
  | FOR LPAREN expr IN expr RPAREN stmt { Foreach($3, $5, $7)}
  | WHILE LPAREN expr RPAREN stmt  { While($3, $5) }
  | BREAK SEMI  {Break}
  | CONTINUE SEMI  {Continue}


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
    NUM  { Num } /*dont understand*/
  | BOOL { Bool }
  | STR  { Str }
  | VOID { Void }
  | LIST { List }
  | POINT{ Pot } 
  | LINE { Lin }

point:
    LPAREN expr COMMA expr COMMA expr COMMA expr RPAREN  { {x_ax=$2; y_ax=$4; form=$6 color=$8 } }
    /*LPAREN expr COMMA expr COMMA expr COMMA expr RPAREN  { ($2,$4,$6,$8) }*/


line:
    LPAREN LPAREN expr COMMA expr RPAREN COMMA LPAREN expr COMMA expr RPAREN COMMA expr COMMA expr RPAREN  { {star_p=($3,$5); end_p=($9,$11); form=$14 color=$16 } }
    /*LPAREN LPAREN expr COMMA expr RPAREN COMMA LPAREN expr COMMA expr RPAREN COMMA expr COMMA expr RPAREN  { ($3,$5,$9,$11,$14,$16) }*/

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    LITERAL          { Number($1) }
  | STRING           { String($1) }
  | TRUE             { BoolLit(true) }
  | FALSE            { BoolLit(false) }
  | ID               { Id($1) }
  | point            { Point($1) }
  | line             { Line($1) }
  | ID DOT ID        { Objmem($1, $3) }  /*line.color*/
  | ID DOT ID ASSIGN expr { Dotassign($1, $3, $5) }
  | ID DOT ID ASSIGN LPAREN expr COMMA expr RPAREN { Lineassign($1, $3, $6, $8) }

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

  | ID LBRACKET expr RBRACKET ASSIGN expr    { ListAssign($1, $3, $6) }
  | ID LBRACKET expr RBRACKET { Mem($1, $3) }
  | LBRACKET list_opt RBRACKET { List($2) }

  | ID LPAREN list_opt RPAREN { Call($1, $3) }
  | LPAREN expr RPAREN { $2 }

  | ID DOT ID LPAREN list_opt RPAREN { Objcall($1, $3, $5) }

list_opt:
    /*nothing*/  { [] }
  |list          { List.rev $1 }

list:
  | expr            { [$1] }
  | list COMMA expr { $3 :: $1 }


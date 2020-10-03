

%{
#include <stdio.h>
%}

%union{
  int i;
}

%token INT UMINUS

%type<i> INT expr

%start calc

%%

calc: calc expr ';' { printf("%d\n", $2); }
    | expr      ';' { printf("%d\n", $1); }
    | error     ';' { printf("discarded input\n"); yyerrok;}
 	;
 	
expr: expr '+' expr  {$$ = $1 + $3;}
    | expr '-' expr  {$$ = $1 - $3;}
    | expr '*' expr  {$$ = $1 * $3;}
    | expr '/' expr  {$$ = $1 / $3;}
    | expr '%' expr  {$$ = $1 % $3;}
    | '(' expr ')'   {$$ = $2;}
    | '-' expr {$$ = - $2;}
    | '+' expr %prec UMINUS {$$ = $2;}
    | INT {$$ = $1;}
    ;
   
%%
int yyerror(char *e){
  fprintf(stderr, "ERROR:%s %d\n;",e, yychar); 
}

int main() {

  yyparse();
  return 0;
}
/*
*/

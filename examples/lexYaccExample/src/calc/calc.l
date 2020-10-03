%{
#include "calc.y.h"
%}

%%
"-"	return '-';
"+"	return '+';
"*"	return '*';
"/" 	return '/';
"%"	return '%';
";"	return ';';
"("	return '(';
")"	return ')';
[0-9]+    {yylval.i = atoi(yytext); return INT;}
[ \t\n]+			;
.				yyerror("unrecognised character");
%%
int yywrap(){ return 1; }

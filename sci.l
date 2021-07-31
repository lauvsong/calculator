%option noyywrap nodefault yylineno

%{
#include "sci.h"
#include "sci.tab.h"
%}

/* float exponent */
EXP ([Ee][-+]?[0-9]+)

%%

"+" |
"-" |
"*" |
"/" |
"=" |
"|" |
"," |
"(" |
")" { return yytext[0]; }

";" |
"\\\\\\" { return FEED; }

">" { yylval.fn = 1; return CMP; }
"<" { yylval.fn = 2; return CMP; }
"<>" { yylval.fn = 3; return CMP; }
"==" { yylval.fn = 4; return CMP; }
">=" { yylval.fn = 5; return CMP; }
"<=" { yylval.fn = 6; return CMP; }

"if" { return IF; }
"then" { return THEN; }
"else" { return ELSE; }
"while" { return WHILE; }
"do" { return DO; }
"let" { return LET;}
"function" { return UFUNC; }

"sqrt"  {yylval.fn = B_sqrt; return BFUNC;}
"exp" { yylval.fn = B_exp; return BFUNC; }
"log" { yylval.fn = B_log; return BFUNC; }
"print" { yylval.fn = B_print; return BFUNC; }
"run" {return RUN;}

[a-zA-Z][a-zA-Z0-9]* {yylval.s = lookup(yytext); return NAME;}

[0-9]+"."[0-9]*{EXP}? |
"."?[0-9]+{EXP}? { yylval.d = atof(yytext); return NUMBER; }

"//".*
[ \t] /* ignore whitespace */ 
\\\n { printf("c> "); } /* ignore line continuation */
\n { return EOL; }

.    { yyerror("Mystery character %c\n", *yytext); }
%%

int main(int argc, char **argv)
{
    if (argc > 1){
        FILE *f = fopen(argv[1], "r");
        if(!f) {
            perror(argv[1]);
            return 1;
        }
        yyin = f;
        printf(">");
        while (yyparse() != 0);
        fclose(f);
        return 0;
    }
    printf("> ");
    while (yyparse() != 0);
    return 0;
}
%{
#include <stdio.h>
#include <stdlib.h>
#include "sci.h"
%}

%define parse.error verbose
%union {
    struct ast *a;
    double d;
    struct symbol *s;   // which symbol
    struct symlist *sl;
    int fn; // which function
}

%token<d> NUMBER
%token<s> NAME
%token<fn> BFUNC
%token FEED
%token RUN
%token EOL

%token IF THEN ELSE WHILE DO LET UFUNC

%nonassoc<fn> CMP
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS

%type<a> exp stmt list explist
%type<sl> symlist

%start calclist

%%

stmt: IF exp THEN list  { $$ = newflow('I', $2, $4, NULL);}
| IF exp THEN list ELSE list    {$$ = newflow('I', $2, $4, $6);}
| WHILE exp DO list     { $$ = newflow('W', $2, $4, NULL);}
| exp FEED list
| exp
;

list: /* nothing */ {$$ = NULL;}
| stmt FEED list { 
    printf("= %4.4g\n>", eval($1));
    if($3 = NULL) $$ = $1;
    else $$=newast('L', $1, $3);
}
| stmt {
    printf("= %4.4g\n>", eval($1));
}
;

exp: exp CMP exp        { $$ = newcmp($2, $1, $3);}
| exp '+' exp           {$$ = newast('+', $1, $3);}
| exp '-' exp           {$$ = newast('-', $1, $3);}
| exp '*' exp           {$$ = newast('*', $1, $3);}
| exp '/' exp           {$$ = newast('/', $1, $3);}
| '|' exp               {$$ = newast('|', $2, NULL);}
| '(' exp ')'           {$$ = $2;}
| '-' exp %prec UMINUS  {$$ = newast('M', $2, NULL);}
| NUMBER                {$$ = newnum($1);}
| NAME                  {$$ = newref($1);}
| LET NAME '=' exp          {$$ = newasgn($2, $4);}
| BFUNC '(' explist ')'  {$$ = newfunc($1, $3);}
| NAME '(' explist ')'  {$$ = newcall($1, $3);}
;

explist: exp
| exp ',' explist       {$$ = newast('L', $1, $3);}
;
symlist: NAME           {$$ = newsymlist($1, NULL);}
| NAME ',' symlist      {$$ = newsymlist($1, $3);}
;

calclist:   /* nothing */
| calclist stmt EOL {
    printf("= %4.4g\n>", eval($2));
    treefree($2);
    }
| calclist UFUNC NAME '(' symlist ')' '=' list EOL {
    dodef($3, $5, $8);
    printf("Defined %s\n>", $3->name);
    }

%%
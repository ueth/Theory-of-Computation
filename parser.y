%{
	#include <stdio.h>
	#include <string.h>
  	#include "cgen.h"
	#include <math.h>

    #define MAX_VARS 100
    #define MAX_NAME_LEN 50
	
	extern int yylex(void);
	extern int line_num;
    char* compFuncHolder = "";
    char* compFuncNameHolder = "";

    char variableNames[MAX_VARS][MAX_NAME_LEN];
    int compVarCounter = 0;
    int funcVarCounter = 0;
%}

%union {
	char* str;
}

%token <str> TK_STRING
%token <str> TK_IDENT
%token <str> TK_REAL 
%token <str> TK_INT

%token KW_INT
%token KW_SCALAR
%token KW_STR
%token KW_BOOLEAN
%token KW_TRUE
%token KW_FALSE
%token KW_CONST
%token KW_IF
%token KW_ENDIF
%token KW_FOR
%token KW_IN
%token KW_ENDFOR
%token KW_WHILE
%token KW_ENDWHILE
%token KW_BREAK
%token KW_CONTINUE
%token KW_NOT
%token KW_AND
%token KW_OR
%token KW_DEF
%token KW_ENDDEF
%token KW_MAIN
%token KW_RETURN
%token KW_COMP
%token KW_ENDCOMP
%token KW_OF

%token ASSIGN LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET
%token SEMICOLON LEFT_PAREN RIGHT_PAREN COMMA LEFT_BRACKET RIGHT_BRACKET COLON DOT ARROW

%start input

%type <str> program_body const_init constant func_dec func_body parameters main_func assign_expr comp_func_dec comp_parameters compact_array
%type <str> identifier variables data_type func_call func_var instructions stmts combination comb_body comp_identifier comp_variables
%type <str> expr 

%right POWER
%right KW_NOT
%left KW_AND
%left KW_OR
%left EQ NEQ
%left LT GT LTE GTE
%left PLUS MINUS DOT LEFT_BRACKET RIGHT_BRACKET LEFT_PAREN RIGHT_PAREN
%left MULTIPLY DIVIDE MODULUS HASHTAG
%right ASSIGN DIV_ASSIGN MOD_ASSIGN MUL_ASSIGN PLUS_ASSIGN MINUS_ASSIGN COLON_ASSIGN
%nonassoc KW_ELSE

%%

input: 
	program_body  
	{
		if (yyerror_count == 0) {
      		puts(c_prologue); 
			printf("%s\n", $1);	
		}
	}
	;

identifier:
	TK_IDENT {$$ = $1;}
    | TK_IDENT COMMA identifier {$$ = template("%s , %s", $1, $3);}
    ;

variables:
    identifier COLON data_type SEMICOLON {$$ = template("%s %s;\n", $3, $1);}
    | TK_IDENT LEFT_BRACKET TK_INT RIGHT_BRACKET COLON data_type SEMICOLON  {$$ = template("%s %s[%s];\n", $6, $1, $3);}
    | TK_IDENT LEFT_BRACKET RIGHT_BRACKET COLON data_type SEMICOLON  {$$ = template("%s %s[];\n", $5, $1);}
	;

expr:
      TK_INT { $$ = $1; }
    | TK_REAL { $$ = $1; }
    | TK_IDENT { $$ = $1; }
    | TK_STRING { $$ = $1; }
    | KW_TRUE { $$ = "1"; }
    | KW_FALSE { $$ = "0"; }
	| func_call { $$ = $1; }
    | assign_expr { $$ = $1; }
    | TK_IDENT LEFT_BRACKET TK_IDENT RIGHT_BRACKET { $$ = template("%s[%s]", $1, $3); }
    | expr DOT TK_IDENT { $$ = template("%s.%s", $1, $3); }
    | expr DOT HASHTAG TK_IDENT { 
        int found = 0;
        for (int i = 0; i < compVarCounter; i++) {
            if (strcmp(variableNames[i], $4) == 0) {
                found = 1;
                break;
            }
        }
        if (found) {
            $$ = template("%s.self->%s", $1, $4);
        } else {
            $$ = template("%s.%s", $1, $4);
        }

    }
    | MODULUS expr { $$ = template("%%%s", $2); }
    | HASHTAG expr { $$ = template("self->%s", $2); }
    | MINUS expr %prec MINUS {$$ = template("-%s", $2);}
    | PLUS expr %prec PLUS {$$ = template("+%s", $2);}
    | KW_NOT expr { $$ = template("!%s", $2); } %prec KW_NOT
    | expr PLUS expr { $$ = template("%s + %s", $1, $3); }
    | expr MINUS expr { $$ = template("%s - %s", $1, $3); }
    | expr MULTIPLY expr { $$ = template("%s * %s", $1, $3); }
    | expr DIVIDE expr { $$ = template("%s / %s", $1, $3); }
    | expr POWER expr { $$ = template("pow(%s, %s)", $1, $3); }
    | expr MODULUS expr { $$ = template("%s %% %s", $1, $3); }
    | expr EQ expr { $$ = template("%s == %s", $1, $3); }
    | expr NEQ expr { $$ = template("%s != %s", $1, $3); }
    | expr GT expr { $$ = template("%s > %s", $1, $3); }
    | expr LT expr { $$ = template("%s < %s", $1, $3); }
    | expr GTE expr { $$ = template("%s >= %s", $1, $3); }
    | expr LTE expr { $$ = template("%s <= %s", $1, $3); }
    | expr KW_AND expr { $$ = template("%s && %s", $1, $3); }
    | expr KW_OR expr { $$ = template("%s || %s", $1, $3); }
    | LEFT_PAREN expr RIGHT_PAREN { $$ = template("(%s)", $2); }
    ;

assign_expr:
    TK_IDENT LEFT_BRACKET TK_IDENT RIGHT_BRACKET ASSIGN expr { $$ = template("%s[%s] = %s", $1, $3, $6); }
    | HASHTAG TK_IDENT LEFT_BRACKET HASHTAG TK_IDENT RIGHT_BRACKET ASSIGN expr { $$ = template("self->%s[self->%s] = %s", $2, $5, $8); } 
    | TK_IDENT ASSIGN expr {$$ = template("%s = %s", $1, $3);}
    | expr DOT HASHTAG TK_IDENT ASSIGN expr {$$ = template("%s.%s = %s", $1, $4, $6);}
    | expr DIV_ASSIGN expr { $$ = template("%s /= %s", $1, $3); }
    | expr MOD_ASSIGN expr { $$ = template("%s %%= %s", $1, $3); }
    | expr MUL_ASSIGN expr { $$ = template("%s *= %s", $1, $3); }
    | expr PLUS_ASSIGN expr { $$ = template("%s += %s", $1, $3); }
    | expr MINUS_ASSIGN expr { $$ = template("%s -= %s", $1, $3); }
    ;


const_init:
    TK_IDENT ASSIGN expr {$$ = template("%s = %s", $1, $3);}
    | TK_IDENT ASSIGN expr COMMA const_init {$$ = template("%s = %s , %s", $1, $3, $5);}
	;

constant:
    KW_CONST const_init COLON data_type SEMICOLON {$$ = template("const %s %s;\n", $4, $2);}
    ;

func_dec:
    KW_DEF TK_IDENT LEFT_PAREN parameters RIGHT_PAREN ARROW data_type COLON func_body KW_ENDDEF SEMICOLON {$$ = template("%s %s (%s) {\n%s\n}\n\n", $7, $2, $4, $9);}
    | KW_DEF TK_IDENT LEFT_PAREN parameters RIGHT_PAREN COLON func_body KW_ENDDEF SEMICOLON {$$ = template("void %s (%s) {\n%s\n}\n\n", $2, $4, $7);}
    ;

main_func:
    KW_DEF KW_MAIN LEFT_PAREN RIGHT_PAREN COLON func_body KW_ENDDEF SEMICOLON {$$ = template("int main() {\n%s}\n", $6);}
    ;

func_call:
    TK_IDENT LEFT_PAREN RIGHT_PAREN { $$ = template("%s()", $1); }
    | TK_IDENT LEFT_PAREN func_var RIGHT_PAREN { $$ = template("%s(%s)", $1, $3); }
    | expr DOT TK_IDENT LEFT_PAREN RIGHT_PAREN {
        if($1[0] == '#') {
            $$ = template("%s.%s(&%s)", $1, $3, $1); 
        } else {
           $$ = template("%s.%s()", $1, $3); 
        }    
    }
    | expr DOT TK_IDENT LEFT_PAREN func_var RIGHT_PAREN {
        if($1[0] == '#') {
            $$ = template("%s.%s(&%s, %s)", $1, $3, $1, $5); 
        } else {
           $$ = template("%s.%s(%s)", $1, $3, $5); 
        }
    }
    ;

func_var:
    expr                 	{$$ = $1;}
    |expr COMMA func_var	{$$ = template("%s , %s", $1, $3);}
    ;

func_body: 
    %empty                 		   {$$ = template("");}    
    | variables func_body          {$$ = template("\t%s%s", $1, $2);}
    | comp_variables func_body          {$$ = template("\t%s%s", $1, $2);}
    | constant func_body        	   {$$ = template("\t%s%s", $1, $2);}
    | instructions func_body              {$$ = template("\t%s%s", $1, $2);}
    | compact_array func_body  {$$ = template("\t%s%s", $1, $2);}
    ;

compact_array:
    TK_IDENT COLON_ASSIGN LEFT_BRACKET expr KW_FOR TK_IDENT COLON TK_INT RIGHT_BRACKET COLON data_type SEMICOLON {
        $$ = template("%s* %s=(%s*)malloc(%s * sizeof(%s)); \nfor (int %s = 0 ; %s <= %s ; %s++) {\n\t%s[%s]=%s;\n}\n", $11, $1, $11, $8, $11, $6, $6, $8, $6, $1, $6, $6);
    }
    | TK_IDENT COLON_ASSIGN LEFT_BRACKET expr KW_FOR TK_IDENT COLON data_type KW_IN TK_IDENT KW_OF TK_INT RIGHT_BRACKET COLON data_type SEMICOLON{
        $$ = template("%s* %s=(%s*)malloc(%s * sizeof(%s)); \nfor (int i = 0 ; i <= %s ; i++) {\n\t%s[i]=%s[i];\n}\n", $15, $1, $15, $12, $15, $12, $1, $10);
    }
    ;

combination:
    KW_COMP TK_IDENT COLON comb_body KW_ENDCOMP SEMICOLON 
    {
        $$ = template("#define SELF struct %s *self \n typedef struct %s {\n%s\n} %s; \n%s\n const %s ctor_%s = {%s};\n #undef SELF\n\n", $2, $2, $4, $2, compFuncHolder, $2, $2, compFuncNameHolder);
        compFuncHolder = "";
        compFuncNameHolder = "";
        for (int i = 0; i < MAX_VARS; i++) {
            variableNames[i][0] = '\0';
        }
        compVarCounter = 0;
    }
    ;

comb_body:
    %empty {$$ = template("\n");}
    | comp_variables comb_body {$$ = template("\t%s%s", $1, $2);}
    | comp_func_dec comb_body {$$ = template("\t%s%s", $1, $2);}
    | instructions comb_body {$$ = template("\t%s%s", $1, $2);}
    ;

comp_func_dec:
    KW_DEF TK_IDENT LEFT_PAREN comp_parameters RIGHT_PAREN ARROW data_type COLON func_body KW_ENDDEF SEMICOLON 
    {
        $$ = template("%s (*%s)(SELF, %s) \n", $7, $2, $4);
        compFuncHolder = template("%s\n%s %s(SELF, %s){\n\t %s} \n", compFuncHolder, $7, $2, $4, $9);
        
        if (compFuncNameHolder == "")
            compFuncNameHolder = template(".%s=%s", $2, $2);
        else 
            compFuncNameHolder = template("%s, .%s=%s", compFuncNameHolder, $2, $2);
    }
    | KW_DEF TK_IDENT LEFT_PAREN RIGHT_PAREN ARROW data_type COLON func_body KW_ENDDEF SEMICOLON 
    {
        $$ = template("%s (*%s)(SELF ) \n", $6, $2);
        compFuncHolder = template("%s\n%s %s(SELF ){\n\t %s} \n", compFuncHolder, $6, $2, $8);

        if (compFuncNameHolder == "")
            compFuncNameHolder = template(".%s=%s", $2, $2);
        else 
            compFuncNameHolder = template("%s, .%s=%s", compFuncNameHolder, $2, $2);
    }
    | KW_DEF TK_IDENT LEFT_PAREN comp_parameters RIGHT_PAREN COLON func_body KW_ENDDEF SEMICOLON 
    {
        $$ = template("void (*%s) (SELF, %s); \n", $2, $4);
        compFuncHolder = template("%s\n void %s(SELF, %s){\n\t %s} \n", compFuncHolder, $2, $4, $7);

        if (compFuncNameHolder == "")
            compFuncNameHolder = template(".%s=%s", $2, $2);
        else 
            compFuncNameHolder = template("%s, .%s=%s", compFuncNameHolder, $2, $2);
    }
    | KW_DEF TK_IDENT LEFT_PAREN RIGHT_PAREN COLON func_body KW_ENDDEF SEMICOLON 
    {
        $$ = template("void (*%s) (SELF ); \n", $2);
        compFuncHolder = template("%s\n void %s(SELF ){\n\t %s} \n", compFuncHolder, $2, $6);

        if (compFuncNameHolder == "")
            compFuncNameHolder = template(".%s=%s", $2, $2);
        else 
            compFuncNameHolder = template("%s, .%s=%s", compFuncNameHolder, $2, $2);
    }
    ;

comp_parameters:
     TK_IDENT COLON data_type {$$ = template("%s %s", $3, $1);}
    | TK_IDENT LEFT_BRACKET RIGHT_BRACKET COLON data_type {$$ = template("%s* %s", $5, $1);}
    | TK_IDENT COLON data_type COMMA comp_parameters {$$ = template("%s %s, %s", $3, $1, $5);}
    | TK_IDENT LEFT_BRACKET RIGHT_BRACKET COLON data_type COMMA comp_parameters {$$ = template("%s* %s, %s", $5, $1, $7);}
    ;

comp_identifier:
	HASHTAG TK_IDENT {
        $$ = template("%s", $2);
        strncpy(variableNames[compVarCounter], template("%s", $2), MAX_NAME_LEN);
        variableNames[compVarCounter++][MAX_NAME_LEN - 1] = '\0'; // Ensure null-termination
    }
	| HASHTAG TK_IDENT ASSIGN expr {
        $$ = template("%s = %s", $2, $4);
        strncpy(variableNames[compVarCounter], template("%s", $2), MAX_NAME_LEN);
        variableNames[compVarCounter++][MAX_NAME_LEN - 1] = '\0'; // Ensure null-termination
    }
    | HASHTAG TK_IDENT COMMA comp_identifier {
        $$ = template("%s , %s", $2, $4);
        strncpy(variableNames[compVarCounter], template("%s", $2), MAX_NAME_LEN);
        variableNames[compVarCounter++][MAX_NAME_LEN - 1] = '\0'; // Ensure null-termination
    }
    | HASHTAG TK_IDENT ASSIGN expr COMMA comp_identifier {
        $$ = template("%s = %s , %s", $2, $4, $6);
        strncpy(variableNames[compVarCounter], template("%s", $2), MAX_NAME_LEN);
        variableNames[compVarCounter++][MAX_NAME_LEN - 1] = '\0'; // Ensure null-termination
    }
    ;

comp_variables:
    comp_identifier COLON data_type SEMICOLON {$$ = template("%s %s;\n", $3, $1);}
    | HASHTAG TK_IDENT LEFT_BRACKET TK_INT RIGHT_BRACKET COLON data_type SEMICOLON  {$$ = template("%s %s[%s];\n", $7, $2, $4);}
    | HASHTAG TK_IDENT LEFT_BRACKET RIGHT_BRACKET COLON data_type SEMICOLON  {$$ = template("%s %s[];\n", $6, $2);}
	;

parameters:
    %empty                                  							{$$ = template("");}
    | TK_IDENT COLON data_type 											{$$ = template("%s %s", $3, $1);}
    | TK_IDENT LEFT_BRACKET RIGHT_BRACKET COLON data_type    					{$$ = template("%s* %s", $5, $1);}
    | TK_IDENT COLON data_type COMMA parameters        							{$$ = template("%s %s, %s", $3, $1, $5);}
    | TK_IDENT LEFT_BRACKET RIGHT_BRACKET COLON data_type COMMA parameters 		{$$ = template("%s* %s, %s", $5, $1, $7);}
    ;

instructions: 
    expr SEMICOLON {$$ = template("%s;\n", $1);}
	| KW_IF LEFT_PAREN expr RIGHT_PAREN COLON stmts KW_ENDIF SEMICOLON {$$ = template("if (%s) {\n\t%s\n}\n", $3, $6);}
    | KW_IF LEFT_PAREN expr RIGHT_PAREN COLON stmts KW_ELSE COLON stmts KW_ENDIF SEMICOLON {$$ = template("if (%s) {\n\t%s\n} else {\n\t%s\n}\n", $3, $6, $9);}
    | KW_FOR TK_IDENT KW_IN LEFT_BRACKET expr COLON expr RIGHT_BRACKET COLON stmts KW_ENDFOR SEMICOLON {$$ = template("for (int %s = %s ; %s <= %s ; %s++) {\n\t%s\n}\n", $2, $5, $2, $7, $2, $10);}
    | KW_FOR TK_IDENT KW_IN LEFT_BRACKET expr COLON expr COLON expr RIGHT_BRACKET COLON stmts KW_ENDFOR SEMICOLON {$$ = template("for  (int %s = %s ; %s <= %s ; %s += %s) {\n\t%s\n}\n", $2, $5, $2, $7, $2, $9, $12);}
    | KW_WHILE LEFT_PAREN expr RIGHT_PAREN COLON stmts KW_ENDWHILE SEMICOLON {$$ = template("while ( %s ) {\n\t%s\n}\n", $3, $6);}
    | KW_BREAK SEMICOLON {$$ = template("break;\n");}
    | KW_CONTINUE SEMICOLON {$$ = template("continue;\n");}
    | KW_RETURN SEMICOLON {$$ = template("return;\n");}
    | KW_RETURN expr SEMICOLON {$$ = template("return %s;\n", $2);}
    ;	

stmts:
	instructions           {$$ = $1;}
    | instructions stmts   {$$ = template("\t%s %s", $1, $2);}
    ;

program_body: 
    %empty              		{$$ = template("\n");}
    | program_body constant     {$$ = template("%s%s", $1, $2);}
    | program_body variables    {$$ = template("%s%s", $1, $2);}
    | program_body func_dec     {$$ = template("%s%s", $1, $2);}
	| program_body main_func    {$$ = template("%s%s", $1, $2);}
    | program_body combination  {$$ = template("%s%s", $1, $2);}
    ;

data_type:  
    KW_BOOLEAN      {$$ = template("int");}
    | KW_INT        {$$ = template("int");}
	| KW_STR        {$$ = template("char*");}
    | KW_SCALAR     {$$ = template("double");} 
    | TK_IDENT      {$$ = template("%s", $1);}
    ;
	
%%
int main ()
{
   if ( yyparse() == 0 )
		printf("/*Accepted*/");
	else
		printf("Rejected!\n");
}


%{
  #include <stdio.h>
	#include <string.h>
  #include "cgen.h"	
  #include <math.h>
  #include "parser.tab.h"
  
  int line_num = 1;
%}


ID      	[a-zA-Z][0-9a-zA-Z_]*
NUMBER    ([1-9][0-9]*)|0
DECIMAL   ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL      {DECIMAL}([eE][+-]?{NUMBER})?
CHARACTER [., a-zA-Z0-9\-+\*\/:_%$!#@&~^()]|[\\n]|[\\t]|[\\r]|[\\\\]
STRING 		\"{CHARACTER}*\"

%%

integer     return KW_INT;
scalar      return KW_SCALAR;
str         return KW_STR;
boolean     return KW_BOOLEAN;
True        return KW_TRUE;
False       return KW_FALSE;
const       return KW_CONST;
if          return KW_IF;
else		    return KW_ELSE;
endif		    return KW_ENDIF;
for		      return KW_FOR;
in		      return KW_IN;
endfor		  return KW_ENDFOR;
while		    return KW_WHILE;
endwhile		return KW_ENDWHILE;
break		    return KW_BREAK;
continue	  return KW_CONTINUE;
not		      return KW_NOT;
and		      return KW_AND;
or		      return KW_OR;
def		      return KW_DEF;
enddef		  return KW_ENDDEF;
main		    return KW_MAIN;
return		  return KW_RETURN;
comp		    return KW_COMP;
endcomp		  return KW_ENDCOMP;
of		      return KW_OF;


{ID}        { yylval.str = strdup(yytext); return TK_IDENT; }
{STRING}    { yylval.str = strdup(yytext); return TK_STRING; }
{NUMBER}    { yylval.str = strdup(yytext); return TK_INT; }
{REAL}      { yylval.str = strdup(yytext); return TK_REAL; }

"+"     { return PLUS; }
"-"     { return MINUS; }
"*"     { return MULTIPLY; }
"/"     { return DIVIDE; }
"%"     { return MODULUS; }
"**"    { return POWER; }
"=="    { return EQ; }
"!="    { return NEQ; }
"<"     { return LT; }
"<="    { return LTE; }
">"     { return GT; }
">="    { return GTE; }
"="     { return ASSIGN; }
"+="    { return PLUS_ASSIGN; }
"-="    { return MINUS_ASSIGN; }
"*="    { return MUL_ASSIGN; }
"/="    { return DIV_ASSIGN; }
"%="    { return MOD_ASSIGN; }

";"   { return SEMICOLON; }
"("   { return LEFT_PAREN; }
")"   { return RIGHT_PAREN; }
","   { return COMMA; }
"["   { return LEFT_BRACKET; }
"]"   { return RIGHT_BRACKET; }
":"   { return COLON; }
"."   { return DOT; }
"{"   { return LEFT_CURLY_BRACKET; }
"}"   { return RIGHT_CURLY_BRACKET; }
"->"  { return ARROW; }
":="  { return COLON_ASSIGN; }
"#"   { return HASHTAG; }


[ \t\r]+     /* Ignore whitespace */
"--"[^\n]*   /* Ignore anything after "--" until the end of the line */

\n 					 ++line_num;

<<EOF>> 	return EOF;
.         { yyerror("lexical error: unrecognized literal '%s'\n", yytext);}
%%
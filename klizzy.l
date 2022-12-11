%{
	#include<stdio.h>
	#include<stdlib.h>
    #include <string.h>
    #include "y.tab.h"
    int DEBUG = 0;
	int LINES = 1;
    int countChar(char* text, char search) {
        int i, count = 0;

        for (i = 0; i < strlen(text); i++){
            if (text[i] == search) {
                count++;
            }
        }
        return count;
    }
%}

INTEGER i
IN in
OUT out
KILL kill
IF if
AND and
OR or
NOT not
COMMA \,
OTHERWISE ow
SEND send
FUNCTION func
UNTIL until
IDENT [a-zA-Z][a-zA-Z0-9]*
NUMBER [0-9]+
L_SQUARE_BRACKET \[
R_SQUARE_BRACKET \]
SEMICOLON ;
EQUAL =
PLUS \+
MINUS \-
MULT \*
DIV \/
BOOL_EQUAL ==
BOOL_GREATER >
BOOL_LESSER <
BOOL_NOTEQUAL !=
L_SQUIG \{
R_SQUIG \}
L_PAREN \(
R_PAREN \)
LINE_COMMENT #[^\n]*
BLOCK_COMMENT \#-[^-\#]*-\#

%%

[ \t]+	            { }
{LINE_COMMENT}      { return LINE_COMMENT;}
{BLOCK_COMMENT}     { return BLOCK_COMMENT;}
{AND}		        { if(DEBUG) printf("AND\n"); return AND;}
{OR}                { if(DEBUG) printf("OR\n"); return OR;}
{NOT}               { if(DEBUG) printf("NOT\n"); return NOT;}
{INTEGER}           { if(DEBUG) printf("INTEGER\n"); return INTEGER;}
{IN}                { if(DEBUG) printf("IN\n"); return IN;}
{OUT}               { if(DEBUG) printf("OUT\n"); return OUT;}
{SEND}              { if(DEBUG) printf("SEND\n"); return SEND;}
{FUNCTION}          { if(DEBUG) printf("FUNCTION\n"); return FUNCTION;}
{UNTIL}             { if(DEBUG) printf("UNTIL\n"); return UNTIL;}
{KILL}              { if(DEBUG) printf("KILL\n"); return KILL;}
{IF}                { if(DEBUG) printf("if \n"); return IF;}
{OTHERWISE}         { if(DEBUG) printf("OTHERWISE\n"); return OTHERWISE;}
{NUMBER}	        { if(DEBUG) printf("NUMBER %s\n", yytext); yylval.strval = strdup(yytext); return NUMBER;}
{L_SQUARE_BRACKET}  { if(DEBUG) printf("L_SQUARE_BRACKET\n"); return L_SQUARE_BRACKET ;}
{R_SQUARE_BRACKET}  { if(DEBUG) printf("R_SQUARE_BRACKET\n"); return R_SQUARE_BRACKET ;}
{SEMICOLON}         { if(DEBUG) printf("SEMICOLON\n"); return SEMICOLON;}
{EQUAL}             { if(DEBUG) printf("EQUAL\n"); return EQUAL;}
{PLUS}	            { if(DEBUG) printf("PLUS\n"); return PLUS;}
{MINUS}	            { if(DEBUG) printf("MINUS\n"); return MINUS;}
{MULT}	            { if(DEBUG) printf("MULT\n"); return MULT;}
{DIV}               { if(DEBUG) printf("DIV\n"); return DIV;}
{BOOL_EQUAL}        { if(DEBUG) printf("BOOL_EQUAL\n"); return BOOL_EQUAL;}
{BOOL_GREATER}      { if(DEBUG) printf("BOOL_GREATER\n"); return BOOL_GREATER;}
{BOOL_LESSER}       { if(DEBUG) printf("BOOL_LESSER\n"); return BOOL_LESSER;}
{BOOL_NOTEQUAL}     { if(DEBUG) printf("BOOL_NOTEQUAL\n"); return BOOL_NOTEQUAL;}
{R_SQUIG}           { if(DEBUG) printf("R_SQUIG\n"); return R_SQUIG;}
{L_SQUIG}           { if(DEBUG) printf("L_SQUIG\n"); return L_SQUIG;}
{L_PAREN}	        { if(DEBUG) printf("L_PAREN\n"); return L_PAREN;}
{R_PAREN}	        { if(DEBUG) printf("R_PAREN\n"); return R_PAREN;}
{IDENT}             { if(DEBUG) printf("IDENT %s\n", yytext); yylval.strval = strdup(yytext); return IDENT;}
{COMMA}             { if(DEBUG) printf("COMMA\n"); return COMMA;}


.		            { if(DEBUG) printf("Error at line %d: (%s)\n", LINES, yytext); return 1; }
\n                  { if(DEBUG) printf("NEWLINE\n"); LINES++;}
<<EOF>>             { return 0;}


%%
%{

	#include "y.tab.h"

	using namespace std;

	#define RET(token_name, token) {  yylval.lex_val = strdup(yytext);return token;}


%}

%%
"if" 					RET("IF", IF)
"else" 					RET("ELSE", ELSE)
"while"					RET("WHILE", WHILE)
"do" 					RET("DO", DO)
"for" 					RET("FOR", FOR)
"main" 					RET("MAIN", MAIN)
"struct"				RET("STRUCT", STRUCT)
"return" 				RET("RETURN", RETURN)
"default" 				RET("DEFAULT", DEFAULT)
"const" 				RET("CONST", CONST)
"break" 				RET("BREAK", BREAK)
"continue" 				RET("CONTINUE", CONTINUE)
"goto" 					RET("GOTO", GOTO)
"void" 					RET("VOID", VOID)
"int" 					RET("INT", INT)
"float" 				RET("FLOAT", FLOAT)
"char" 					RET("CHAR", CHAR)
";" 					RET("SEMICOLON", SEMICOLON)
","		 				RET("COMMA", COMMA)
"["				 		RET("LEFT_SQ_BRACKET", LEFT_SQ_BRACKET)
"]" 					RET("RIGHT_SQ_BRACKET", RIGHT_SQ_BRACKET)
"{"					 	RET("LEFT_CURLY_BRACKET", LEFT_CURLY_BRACKET)
"}" 					RET("RIGHT_CURLY_BRACKET", RIGHT_CURLY_BRACKET)
"(" 					RET("LP", LP)
")" 					RET("RP", RP)
"->" 					RET("DEREFERENCE", DEREFERENCE)
"+"	 					RET("PLUS", PLUS)
"-"	 					RET("MINUS", MINUS)
"*" 					RET("ASTERISK", ASTERISK)
"/" 					RET("DIVIDE", DIVIDE)
"." 					RET("DOT", DOT)
"&&" 					RET("AND_EXP", AND_EXP)
"&" 					RET("AMP", AMP)
"%" 					RET("MODULO", MODULO)
"=" 					RET("ASSIGN_OP", ASSIGN_OP)
"||" 					RET("OR_EXP", OR_EXP)
"!" 					RET("NOT_EXP", NOT_EXP)
">>" 					RET("RIGHT_SHIFT", RIGHT_SHIFT)
"<<" 					RET("LEFT_SHIFT", LEFT_SHIFT)
"|" 					RET("OR_BIT", OR_BIT)
"<=" 					RET("LTE", LTE)
">=" 					RET("GTE", GTE)
"<" 					RET("LT", LT)
">" 					RET("GT", GT)
"==" 					RET("EQ", EQ)
[0-9]+					RET("INTEGER", INTEGER)
\'[a-zA-Z]\'	 		RET("CHARACTER", CHARACTER)
[0-9]+\.?[0-9]*			RET("REAL", REAL)
[a-zA-Z_][a-zA-Z0-9_]*	RET("ID", ID)
\"(\\.|''|[^'\n])*\"	RET("STRING",STRING)
[ \t\n]					;
.						{printf("Unexpected token : %s\n", yytext);}
%%

int yywrap() {return 1;}
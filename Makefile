c_parser: lex.yy.c y.tab.c 
	g++ lex.yy.c y.tab.c -o c_parser -g -w -fpermissive -std=c++11

lex.yy.c: y.tab.c c_parser.l
	lex c_parser.l

y.tab.c: c_parser.y
	yacc -d -v -Wconflicts-sr c_parser.y 

clean: 
	rm lex.yy.c y.tab.c y.tab.h c_parser


compiler: lexer
	gcc -o compiler lex.yy.c parser.tab.c cgen.c -lfl

lexer: parser
	flex lexer.l

parser: 
	bison -d -v -r all parser.y

test:
	./compiler < correct1.ka > correct1.c
	gcc correct1.c -o correct1

	./compiler < correct2.ka > correct2.c
	gcc correct2.c -o correct2

clean:
	rm -f lex.yy.c
	rm -f compiler
	rm -f parser.output
	rm -f parser.tab.c
	rm -f parser.tab.h
	rm -f correct1.c
	rm -f correct1
	rm -f correct2.c
	rm -f correct2
parser: klizzy.l
	bison -v -d --file-prefix=y klizzy.y
	flex klizzy.l
	g++ -std=c++11 -g -o parser y.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.mil ./parser
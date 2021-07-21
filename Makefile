sci: sci.l sci.y sci.h sci_funcs.c
	bison -d sci.y && \
	flex -osci.lex.c sci.l && \
	cc -g -o $@ sci.tab.c sci.lex.c sci_funcs.c -lm

clean:
	rm *.tab.*
	rm *lex.c
	rm *.lex.cs
	rm sci
	rm *.output
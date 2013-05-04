:- module(fib_3, [fib/2], [assertions, nativeprops, regtypes,
		ciaopp(tests(resources)),
		res_arith(res_arith)]).

:- entry fib(X, Y) : num * var.

fib(0, 0) :- !.
fib(1, 1) :- !.
fib(M, N) :-
	M1 is M-1,
	M2 is M-2,
	fib(M1, N1),
	fib(M2, N2),
	N is N1 + N2.

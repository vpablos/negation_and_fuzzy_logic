:- module(_,[permute/2],[assertions]).

:- entry permute([1,2,3,4,5,6],L).

permute([],[]).
permute(A,[U|V]):- 
	delete(U, A, Z),
	permute(Z, V).

delete(A, [A|L], L).
delete(X, [A,B|L], [A|R]):- 
	TM = [B|L],
	delete(X, TM, R).

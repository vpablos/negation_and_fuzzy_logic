:- module(mmatrix,[mmultiply/3],[assertions,nativeprops]).

% :- entry mmultiply(A,B,C) : (ground(A), ground(B), var(C)).

mmultiply([],_,[]).
mmultiply([V0|Rest], V1, [Result|Others]):-  
    	    multiply(V1,V0,Result),
            mmultiply(Rest, V1, Others).


multiply([],_,[]).
multiply([V0|Rest], V1, [Result|Others]):-  
    	    vmul(V0,V1,Result),
            multiply(Rest, V1, Others).

vmul([],[],0).
vmul([H1|T1], [H2|T2], Result):- 
	Product is H1*H2,
	vmul(T1,T2, Newresult), 
	Result is Product+Newresult.

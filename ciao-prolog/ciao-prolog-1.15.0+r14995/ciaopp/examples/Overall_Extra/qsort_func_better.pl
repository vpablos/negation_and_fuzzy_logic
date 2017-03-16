:- module(_, [qsort/2], [assertions,fsyntax]).

:- entry qsort(A,B) : (list(A,num), ground(A), var(B)).

qsort([])    := [].
qsort([X|L]) := ~append( ~qsort(L1), [X | ~qsort(L2)] )
	     :- partition(L,X,L1,L2).

%% Alt (but L1 unbound):
%% qsort([X|L]) := ~append( ~qsort(L1), [X | ~qsort(~partition(L,X,L1)) ] ).
%% Proper alt:
%% qsort([X|L]) := ~append( ~qsort(~partition(L,X,#,L2)), [X | ~qsort(L2) ] ).

append( []    , X) := X.
append( [H|X] , Y) := [ H | ~append(X,Y) ].

partition([],_B,[],[]).
partition([E|R],C,[E|Left1], Right):- 
	E < C, !,
	partition(R,C,Left1,Right).
partition([E|R],C,Left,[E|Right1]):-
	E >= C,
	partition(R,C,Left,Right1).
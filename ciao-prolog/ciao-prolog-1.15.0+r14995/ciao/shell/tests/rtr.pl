:- use_package([]).

:- use_module(library(dynamic)).

:- dynamic p/1.

p(X) :- display('M:'), retract(p(_)), display(X), nl.

main :- p(hola).
main :- p(adios).

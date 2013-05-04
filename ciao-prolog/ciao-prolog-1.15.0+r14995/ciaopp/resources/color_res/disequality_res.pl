:- module(disequality_res, [binary_disequality/4], [assertions]).

%
%  disequality.pl		Nai-Wei Lin			April, 1992
%
%  This file contains the procedures for testing the binary disequality.
%

:- use_module(library(lists), [length/2]).

:- use_module(resources(top_res(utility_res)), [list/1]).
:- use_module(resources(init_res(symtable_res)), [find_symbol_field/4]).

%
%  Test if a predicate is a GCP. If it is, also return the domain size.
%
binary_disequality(Pred, ST, Disequality, DomainSize) :-
%	write(Disequality),nl,
	find_symbol_field(ST, Pred, domain, Domain),
	nonvar(Domain),
	domain_sizes(Domain, DomainSize),
	disj_bi_disequality(Disequality).

%
disj_bi_disequality([]).
disj_bi_disequality([Disequality]) :-
	conj_bi_disequality(Disequality).

%
conj_bi_disequality([]).
conj_bi_disequality([D|Disequality]) :-
	( utility_res:list(D) ->
	    disj_bi_disequality(D) ;
	    atom_bi_disequality(D) ),
	conj_bi_disequality(Disequality).

%
atom_bi_disequality(true).
atom_bi_disequality(D) :-
	D \== true,
	functor(D, Op, A),
	( disequality(Op/A) ->
	    ( arg(1, D, LHS),
		var(LHS),
		arg(2, D, RHS),
		var(RHS),
		LHS \== RHS ) ).

%
%  Test if the domains for distinct variables are the same. If it does,
%  also return the size of the domain.
%
domain_sizes([D|Domain], DomainSize) :-
	domain_type(D, DomainType),
	domain_size(DomainType, D, CDomainSize),
	domain_sizes(Domain, DomainType, CDomainSize, DomainSize).


:- push_prolog_flag(multi_arity_warnings, off).

domain_sizes([],         _,          DomainSize,  DomainSize).
domain_sizes([D|Domain], DomainType, CDomainSize, DomainSize) :-
	domain_type(D, DomainType),
	domain_size(DomainType, D, CDomainSize),
	domain_sizes(Domain, DomainType, CDomainSize, DomainSize).

:- pop_prolog_flag(multi_arity_warnings).

%
%  Check the type of a domain.
%
domain_type(_-_, interval).
domain_type(D,   set) :- utility_res:list(D).

%
%  Compute the size of a domain according to its type.
%
domain_size(interval, L-U, Size) :-
	Size is U-L +1.
domain_size(set, S, Size) :-
	length(S, Size).

%
%  Test if a literal is a disequality.
%
disequality((=\=) /2).
disequality((\==) /2).

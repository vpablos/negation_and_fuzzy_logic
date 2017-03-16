:- module(build_ldg_res, [literal_dependency_graph/2],
	    [assertions, resources(inferres_decl)]).

%
%  build_ldg.pl			Nai-Wei Lin			November, 1991
%
%  This file contains the procedures for building literal dependency graphs.
%

:- use_module(resources(dependency_res(position_res)), 
	    [
		gen_clause_pos/2,
		pos_litnum/2
	    ]).
:- use_module(resources(dependency_res(adg_res)), [find_adg_field/4]).
:- use_module(resources(dependency_res(ldg_res)), 
	    [
		new_lit/2,
		insert_ldg_field/4,
		insert_ldg_entry/3
	    ]).

%
%  Build the literal dependency graph of a clause.
%

:- pred literal_dependency_graph/2 + (not_fails, is_det).

literal_dependency_graph(Adg, Ldg) :-
	gen_clause_pos(Adg, PosSet),
	literal_dependency_graph(PosSet, Adg, Ldg).

:- push_prolog_flag(multi_arity_warnings, off).

literal_dependency_graph([],          _,   _).
literal_dependency_graph([Pos|PList], Adg, Ldg) :-
	insert_ldg_node(Adg, Ldg, Pos),
	find_adg_field(Adg, Pos, pred, Pred),
	insert_ldg_arcs(Adg, Ldg, Pos, Pred),
	literal_dependency_graph(PList, Adg, Ldg).

:- pop_prolog_flag(multi_arity_warnings).

%
%  Insert a node Lit into the literal dependency graph.
%
insert_ldg_node(Adg, Ldg, Pos) :-
	pos_litnum(Pos, 0),
	!,
	find_adg_field(Adg, Pos, (mode), Mode),
	new_lit(Mode, Lit),
	insert_ldg_entry(Ldg, Lit, _).
insert_ldg_node(_, Ldg, Pos) :-
	pos_litnum(Pos, I),
	I > 0,
	new_lit(I, Lit),
	insert_ldg_entry(Ldg, Lit, _).

%
%  Insert the set of arcs to the predecessors of a node into
%  the literal dependency graph.
%
insert_ldg_arcs(_, _, _, Pred) :-
	var(Pred),
	!.
insert_ldg_arcs(Adg, Ldg, Pos, Pred) :-
	nonvar(Pred),
	Pred = [P|PList],
	insert_ldg_arc(Adg, Ldg, Pos, P),
	insert_ldg_arcs(Adg, Ldg, Pos, PList).

%
%  Insert an arc into the literal dependency graph.
%
insert_ldg_arc(Adg, Ldg, Pos1, Pos2) :-
	pos_litnum(Pos1, 0),
	pos_litnum(Pos2, 0),
	!,
	find_adg_field(Adg, Pos1, (mode), Mode1),
	new_lit(Mode1, Lit1),
	find_adg_field(Adg, Pos2, (mode), Mode2),
	new_lit(Mode2, Lit2),
	insert_ldg_field(Ldg, Lit1, pred, Lit2),
	insert_ldg_field(Ldg, Lit2, succ, Lit1).
insert_ldg_arc(Adg, Ldg, Pos1, Pos2) :-
	pos_litnum(Pos1, 0),
	pos_litnum(Pos2, J),
	J > 0,
	!,
	find_adg_field(Adg, Pos1, (mode), Mode1),
	new_lit(Mode1, Lit1),
	new_lit(J,     Lit2),
	insert_ldg_field(Ldg, Lit1, pred, Lit2),
	insert_ldg_field(Ldg, Lit2, succ, Lit1).
insert_ldg_arc(Adg, Ldg, Pos1, Pos2) :-
	pos_litnum(Pos1, I),
	I > 0,
	pos_litnum(Pos2, 0),
	!,
	new_lit(I, Lit1),
	find_adg_field(Adg, Pos2, (mode), Mode2),
	new_lit(Mode2, Lit2),
	insert_ldg_field(Ldg, Lit1, pred, Lit2),
	insert_ldg_field(Ldg, Lit2, succ, Lit1).
insert_ldg_arc(_, Ldg, Pos1, Pos2) :-
	pos_litnum(Pos1, I),
	I > 0,
	pos_litnum(Pos2, J),
	J > 0,
	I =\= J,
	!,
	new_lit(I, Lit1),
	new_lit(J, Lit2),
	insert_ldg_field(Ldg, Lit1, pred, Lit2),
	insert_ldg_field(Ldg, Lit2, succ, Lit1).
insert_ldg_arc(_, _, Pos1, Pos2) :-
	pos_litnum(Pos1, I),
	I > 0,
	pos_litnum(Pos2, J),
	J > 0,
	I =:= J.

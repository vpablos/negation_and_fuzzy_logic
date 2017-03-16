:- module(size_,
	    [
		explicit_output_size/8,
		implicit_output_size/8,
		remove_recursive_comps/4,
		size_analysis/7,
		up_low_approximation_expr/3,
		min_approximation/3,
		up_low_approximation_minmax/3,
		minimum_list/2
	    ], [assertions, infercost(infercost_decl)]).

%
%  size.pl			Nai-Wei Lin			December, 1991
%
%  This file contains the procedures for performing the argument size
%  analysis for the predicates in the program in topologically sorted order.
%

:- use_module(library(messages), [debug_message/2]).

:- use_module(infercost(algebraic(general_form)), 
	    [
		time_general_form/2,
		general_form/2
	    ]).
:- use_module(infercost(algebraic(maxmin)), [max_expr/3]).
:- use_module(infercost(init(symtable)), 
	    [
		find_symbol_field_clause/3,
		insert_symbol_field/4,
		find_symbol_field/4
	    ]).
:- use_module(infercost(cost_approx)).
:- use_module(infercost(top(utility)), 
	    [
		minimum/3,
		maximum/3,
		ith_list_element/3
	    ]).
:- use_module(infercost(algebraic(normal_form)), 
	    [
		normal_form/2,
		time_normal_form/2
	    ]).
:- use_module(infercost(algebraic(normal_form_basic)), [userfunc/1]).
:- use_module(infercost(algebraic(simpl_form)), 
	    [list_simplification/2]).
:- use_module(infercost(algebraic(arithm_opers)), [min/3, max/3]).
:- use_module(infercost(algebraic(algebraic_)), 
	    [
		time_add_expr/3,
		time_multiply_expr/3,
		time_add_expr/3,
		time_multiply_expr/3,
		exp_expr/3,
		log_expr/3,
		factorial_expr/2
	    ]).
:- use_module(infercost(size(size_diff_equ)), [solve_size_equs/5]).
:- use_module(infercost(init(initsystem_basic)), [clause_type/2]).
:- use_module(infercost(solution(relation)), [fail_clause/1]).
:- use_module(infercost(size(ground_size)), [ground_term_size/3]).
:- use_module(infercost(size(term_size)), [general_term_size/8]).
:- use_module(infercost(dependency(position)), 
	    [new_pos/3, gen_clause_pos/2]).
:- use_module(infercost(dependency(gvars)), [find_gvars_field/4]).
:- use_module(infercost(size(clause)), [clause_term_measure/6]).
:- use_module(infercost(dependency(adg)), [find_adg_field/4]).
:- use_module(infercost(size(normalize_)), 
	    [
		init_normalize_queue/3,
		normalize/13,
		substitute_literal_formal/4,
		substitute/4
	    ]).
:- use_module(infercost(algebraic(sumprod)), [sum_expr/5, prod_expr/5]).
:- use_module(infercost(size(implicit_size)), [implicit_var_size/6]).
% ground_term_depth/3 undefined in source

% See topdriver.pl for this: (NOW IMPORTED, PBC)
%% approximation(Approx):- ciao:approximation(Approx).

% Added by PLG (22-Mar-97)

up_low_approximation_expr(S1, S2, Sol) :-
	approximation(Approx),
	up_low_approximation_expr(Approx, S1, S2, Sol).

:- push_prolog_flag(multi_arity_warnings, off).

% up_low_approximation_expr(lower, S1, S2, Sol):- min_expr(S1, S2, Sol).

up_low_approximation_expr(lower, S1, S2, Sol) :-
	!,
	min_approximation(S1, S2, Sol).
up_low_approximation_expr(upper, S1, S2, Sol) :-
	max_expr(S1, S2, Sol).

min_approximation(S1, S2, Sol) :-
	max_expr(S1, S2, Sol1),
	(
	    (Sol1 == inf ; Sol1 == bot) ->
	    normal_form(0, Sol)
	;
	    (
		Sol1 == S1 ->
		Sol = S2
	    ;
		Sol = S1
	    )
	).

%% min_approximation(S1, S2, Sol):-  
%%    max_expr(S1, S2, Sol1),
%%    (Sol1 == inf -> 
%%           Sol = 0
%%           ;
%%           (Sol1 == S1 -> Sol = S2 ; Sol = S1)
%%    ).   


% Added by PLG (22-Mar-97)

up_low_approximation(S1, S2, Sol) :-
	approximation(Approx),
	up_low_approximation(Approx, S1, S2, Sol).

% Warning: check this!
up_low_approximation(lower, S1, S2, Sol) :- !, minimum(S1, S2, Sol).
%% up_low_approximation(lower, S1, S2, Sol):- !,
%%     minimum(S1, S2, Sol1),
%%     ((Sol1 == inf; Sol1 == bot) -> Sol = 0 ; Sol = Sol1).
% up_low_approximation(lower, S1, S2, Sol):- !, minimum_aproximation(S1, S2, Sol).
up_low_approximation(upper, S1, S2, Sol) :- maximum(S1, S2, Sol).

%% minimum_aproximation(S1, S2, Sol):-
%%    maximum(S1, S2, Sol1),
%%    (Sol1 == inf -> 
%%           Sol = 0
%%           ;
%%           (Sol1 == S1 -> Sol = S2 ; Sol = S1)
%%    ).   

% Added by PLG (22-Mar-97)
% Warning, check this! %chk2
% S1 and S2 are numbers.

up_low_approximation_minmax(S1, S2, Sol) :-
	approximation(Approx),
	up_low_approximation_minmax(Approx, S1, S2, Sol).

up_low_approximation_minmax(lower, S1, S2, Sol) :- !, min(S1, S2, Sol).
up_low_approximation_minmax(upper, S1, S2, Sol) :- max(S1, S2, Sol).

% Added by PLG (22-Mar-97)
%
%  Compute the minimum of a list of normal form expressions.
%
minimum_list([Size],   Size) :- !.
minimum_list([S|Size], Sol ) :-
	minimum_list(Size, Sols),
%general_form(Sols, GSol),
%write(GSol), nl,
	min_approximation(Sols, S, Sol).

% End added

%
%  Perform the argument size analysis for a strongly connected component.
%
size_analysis(Comp, BT, ST, Comp, Adg, Gvars, Size) :-
	size_analysis(Comp, BT, ST, Comp, Adg, Gvars, [], Size).

size_analysis([], _BT, _ST, _Comp, _AList, _GList, _RSize, []).
size_analysis([Pred|CompList], BT, ST, Comp, [Adg|AList], [Gvars|GList],
	    RSize, [Size|SList]) :-
	find_symbol_field_clause(ST, Pred, Clauses),
	size_clauses(Clauses, BT, ST, Comp, Adg, Gvars, RSize, Size),
	debug_message("SIZE (size equations):~q ~n", [Size]),
%write(Size), nl,
	solve_size_equs(Pred, ST, Comp, Size, Sol1),
	debug_message("SIZE (solved equations):~q ~n", [Sol1]),
%write(Sol1), nl,
	size_analysis(CompList, BT, ST, Comp, AList, GList,
	    [comp(Pred, Sol1)|RSize], SList),
	remove_recursive_comps(Sol1, ST, size, Sol2),
%write(Sol), nl,
        approximation(Approx),
	translate_bot(Sol2, Approx, Sol),
	insert_symbol_field(ST, Pred, size, Sol).


:- pop_prolog_flag(multi_arity_warnings).

%
%  Perform the argument size analysis for the set of clauses in a predicate.
%
size_clauses(Clauses, _BT, _ST, _Comp, _AList, _GList, _RSize, _SList) :-
	var(Clauses),
	!.
size_clauses(Clauses, BT, ST, Comp, [Adg|AList], [Gvars|GList], RSize,
	    [Size|SList]) :-
	nonvar(Clauses),
	Clauses = [Clause|CList],
	size_clause(Clause, BT, ST, Comp, Adg, Gvars, RSize, TSize),
	list_simplification(TSize, Size),
	size_clauses(CList, BT, ST, Comp, AList, GList, RSize, SList).

%
%  Perform the argument size analysis for a clause.
%
size_clause(Clause, BT, ST, Comp, Adg, Gvars, RSize, Size) :-
	clause_type(Clause, Type),
	size_function(Type, Clause, BT, ST, Comp, Adg, Gvars, RSize, Size).

%
%  Compute the size functions of a clause as difference equations.
%
size_function(2, Clause, BT, ST, Comp, Adg, Gvars, RSize, Size) :-
	Clause = (Head:-_),
	size_func(Head, Clause, BT, ST, Comp, Adg, Gvars, RSize, Size).
size_function(3, Fact, BT, ST, Comp, Adg, Gvars, RSize, Size) :-
	size_func(Fact, Fact, BT, ST, Comp, Adg, Gvars, RSize, Size).

size_func(Head, Clause, BT, ST, Comp, Adg, Gvars, RSize, Size) :-
	functor(Head, F, N),
	find_symbol_field(ST, F/N, (mode),  Mode   ),
	find_symbol_field(ST, F/N, measure, Measure),
	input_argument_size(1, Head, Mode, Measure, Clause, BT, ST, Adg,
	    Gvars, Size),
	(
	    fail_clause(Clause) ->
	    fail_output_size(Mode, Size)
	;
	    output_argument_size(1, Head, Mode, Measure, Clause, BT, ST, Comp,
		Adg, Gvars, Size, RSize, Size)
	).

%
%  Compute the size function for an input position in a clause as 
%  a difference equation.
%
input_argument_size(_, _, [], _, _, _, _, _, _, []).
input_argument_size(N, Head, [(+)|ModeList], [Measure|MeasureList], Clause,
	    BT, ST, Adg, Gvars, [Size2|Size]) :-
	arg(N, Head, Term),
	new_pos(0, N, Pos),
	(var(Term) ->
	    implicit_input_size(Measure, Term, Pos, Adg, Clause, Size1) ;
	    explicit_input_size(Measure, Term, Size1)),
	(Size1 == bot ->
	    Size2 = Pos;
	    Size2 = Size1),
%write(Size2), nl,
	N1 is N+1,
	input_argument_size(N1, Head, ModeList, MeasureList, Clause,
	    BT, ST, Adg, Gvars, Size).
input_argument_size(N, Head, [(-)|ModeList], [_|MeasureList], Clause,
	    BT, ST, Adg, Gvars, [_|Size]) :-
	N1 is N+1,
	input_argument_size(N1, Head, ModeList, MeasureList, Clause,
	    BT, ST, Adg, Gvars, Size).

%
%  Compute the size function for an output position in a clause as 
%  a difference equation.
%
output_argument_size(_N, _Head, [], _MeasureList, _Clause,
	    _BT, _ST, _Comp, _Adg, _Gvars, _ISize, _RSize, []) :-
	!.
output_argument_size(N, Head, [(+)|ModeList], [_Measure|MeasureList], Clause,
	    BT, ST, Comp, Adg, Gvars, ISize, RSize, [_|Size]) :-
	!,
	N1 is N + 1,
	output_argument_size(N1, Head, ModeList, MeasureList, Clause,
	    BT, ST, Comp, Adg, Gvars, ISize, RSize, Size).
output_argument_size(N, Head, [(-)|ModeList], [Measure|MeasureList], Clause,
	    BT, ST, Comp, Adg, Gvars, ISize, RSize, [Size3|Size]) :-
	arg(N, Head, Term),
	new_pos(0, N, Pos),
	(
	    var(Term) ->
	    implicit_output_size(Measure, Term, Adg, Clause, BT, ST,
		Gvars, Size1)
	;
	    Size1 = bot
	),
%write(Size1), nl,
	(
	    Size1 == bot ->
	    (
		explicit_output_size(Measure, Clause, BT, ST, Adg, Gvars,
		    Term, Size2),
%write(Size2), nl,
		normalize_size_function(Size2, Pos, BT, ST, Comp, Clause, Adg,
		    Gvars, ISize, RSize, Size3)
	    )
	;
	    Size3 = Size1
	),
%write(Size3), nl,
	N1 is N+1,
	output_argument_size(N1, Head, ModeList, MeasureList, Clause,
	    BT, ST, Comp, Adg, Gvars, ISize, RSize, Size).

%
%  Compute the implicit size of a head input.
%
implicit_input_size(Measure, Term, Pos, Adg, Clause, Size) :-
	implicit_var_size(Measure, Term, Pos, Adg, Clause, Size).

%
%  Compute the explicit size of a head input.
%
explicit_input_size(Measure, Term, Size) :-
	ground_term_size(Measure, Term, Size).

%
%  Compute the implicit size of a head output.
%
implicit_output_size(Measure, Term, Adg, Clause, BT, ST, Gvars, Size) :-
	find_gvars_field(Gvars, Term, def, PosList),
	implicit_output_sizes(PosList, BT, ST, Measure, Term, Adg, Clause,
	    Size).

implicit_output_sizes(PosList, _BT, _ST, _Measure, _Term, _Adg, _Clause,
	    bot) :-
	var(PosList),
	!.
implicit_output_sizes([], _BT, _ST, _Measure, _Term, _Adg, _Clause, bot) :-
	!.
implicit_output_sizes([Pos|PosList], BT, ST, Measure, Term, Adg, Clause,
	    Size) :-
	clause_term_measure(BT, ST, Clause, Pos, HTerm, _),
	(
	    HTerm == Term ->
	    implicit_var_size(Measure, Term, Pos, Adg, Clause, Size1) ;
	    Size1 = bot
	),
	implicit_output_sizes(PosList, BT, ST, Measure, Term, Adg, Clause,
	    Size2),
% Added by PLG (22-Mar-97)
	up_low_approximation(Size1, Size2, Size).
% End added
% Commented by PLG (22-Mar-97)
% maximum(Size1, Size2, Size).

%
%  Compute the explicit size of a head output.
%
explicit_output_size(Measure, Clause, BT, ST, Adg, Gvars, Term, Size) :-
	gen_clause_pos(Adg, PosSet),
	general_term_size(Measure, Clause, BT, ST, Gvars, PosSet, Term, Size).

%
%  Normalize the size function corresponding to an output position.
%
normalize_size_function(Size, Pos, BT, ST, Comp, Clause, Adg, Gvars, ISize,
	    RSize, NSize) :-
	gen_clause_pos(Adg, PosSet),
	find_adg_field(Adg, Pos, pred, PredPos),
	init_normalize_queue(PredPos, QHead, QTail),
	normalize(Size, QHead, QTail, BT, ST, Comp, Clause, Adg, Gvars, PosSet,
	    ISize, RSize, NSize).
%
fail_output_size([],       []      ).
fail_output_size([+|Mode], [_|Size]) :-
	!,
	fail_output_size(Mode, Size).
fail_output_size([-|Mode], [bot|Size]) :-
	fail_output_size(Mode, Size).

%
%

% Added and Modified by EMM
:- check comp remove_recursive_comps/4 + (not_fails, is_det).

remove_recursive_comps(S, ST, Type, R) :-
	remove_recursive_comps_(S, ST, Type, R),
	!.

remove_recursive_comps_([],        _ST, _Type, []     ).
remove_recursive_comps_([S1|Sol1], ST,  Type,  [S|Sol]) :-
	remove_recursive_general_comp(S1, ST, Type, S),
	remove_recursive_comps_(Sol1, ST, Type, Sol).

remove_recursive_general_comp(S1, ST, Type, S) :-
	normal_form(S1, N1),
	remove_recursive_comp(N1, ST, Type, N),
	time_general_form(N, S).
% End Added and Modified by EMM

%
remove_recursive_comp(top,        _,  _,    top).
remove_recursive_comp(bot,        _,  _,    bot).
remove_recursive_comp(inf,        _,  _,    inf).
remove_recursive_comp(expr(T, F), ST, Type, Sol) :-
	remove_recursive_comp1(T, ST, Type, Sols),
	Sol1 = expr([], F),
	time_add_expr(Sols, Sol1, Sol).

%
remove_recursive_comp1([], _ST, _Type, Zero) :-
	normal_form(0, Zero).
remove_recursive_comp1([term(T, F)|Ts], ST, Type, Sol) :-
	remove_recursive_comp2(T, ST, Type, Sol1),
	C = expr([], F),
	time_multiply_expr(Sol1, C, Sol2),
	remove_recursive_comp1(Ts, ST, Type, Sols),
	time_add_expr(Sol2, Sols, Sol).

%
remove_recursive_comp2([], _, _, One) :-
	normal_form(1, One).
remove_recursive_comp2([P|Ps], ST, Type, Sol) :-
	remove_recursive_comp3(P, ST, Type, Sol1),
	remove_recursive_comp2(Ps, ST, Type, Sols),
	time_multiply_expr(Sol1, Sols, Sol).

%
remove_recursive_comp3(P, ST, Type, Sol) :-
	userfunc(P),
	functor(P, F, _),
	arg(1, P, Arity),
	general_form(Arity, A),
	find_symbol_field(ST, F/A, Type, Size),
	arg(2, P, OPos),
	general_form(OPos, O),
	ith_list_element(O, Size, Osize),
	substitute_literal_formal(A, Osize, 1, NOsize),
	find_symbol_field(ST, F/A, (mode), Mode),
	substitute_actual(Mode, 1, 3, P, ST, NOsize, Type, Sol1),
	time_normal_form(Sol1, Sol).
remove_recursive_comp3(exp(E1, E2), ST, Type, Sol) :-
	remove_recursive_comp(E1, ST, Type, Sol1),
	remove_recursive_comp(E2, ST, Type, Sol2),
	exp_expr(Sol1, Sol2, Sol).
remove_recursive_comp3(log(E1, E2), ST, Type, Sol) :-
	remove_recursive_comp(E1, ST, Type, Sol1),
	remove_recursive_comp(E2, ST, Type, Sol2),
	log_expr(Sol1, Sol2, Sol).
remove_recursive_comp3(fact(E1), ST, Type, Sol) :-
	remove_recursive_comp(E1, ST, Type, Sol1),
	factorial_expr(Sol1, Sol).
remove_recursive_comp3(sum(E1, E2, E3, E4), ST, Type, Sol) :-
	remove_recursive_comp(E4, ST, Type, Expr),
	general_form(E1, Var),
	sum_expr(Var, E2, E3, Expr, Sol).
remove_recursive_comp3(prod(E1, E2, E3, E4), ST, Type, Sol) :-
	remove_recursive_comp(E4, ST, Type, Expr),
	general_form(E1, Var),
	prod_expr(Var, E2, E3, Expr, Sol).
remove_recursive_comp3(arg(E1, E2), ST, Type, Sol) :-
	remove_recursive_comp(E1, ST, Type, Sol1),
	remove_recursive_comp(E2, ST, Type, Sol2),
	Sol = expr([], [factor([arg(Sol1, Sol2)], 1)]).
remove_recursive_comp3(arity(E1), ST, Type, Sol) :-
	remove_recursive_comp(E1, ST, Type, Sol1),
	Sol = expr([], [factor([arity(Sol1)], 1)]).


%
%
substitute_actual([],       _M, _N, _P, _ST, Sol,   _Type, Sol).
substitute_actual([+|Mode], M,  N,  P,  ST,  Osize, Type,  Sol) :-
	!,
	arg(N, P, Arg),
	remove_recursive_comp(Arg, ST, Type, RArg),
	general_form(RArg, Rarg),
	new_pos(1, M, Pos),
	substitute(Osize, Pos, Rarg, NOsize),
	M1 is M+1,
	N1 is N+1,
	substitute_actual(Mode, M1, N1, P, ST, NOsize, Type, Sol).
substitute_actual([-|Mode], M, N, P, ST, Osize, Type, Sol) :-
	M1 is M+1,
	N1 is N+1,
	substitute_actual(Mode, M1, N1, P, ST, Osize, Type, Sol).

translate_bot([], _Approx, []).
translate_bot([Size1|R1], Approx, [Size2|R2]):-
	translate_bot_(Size1, Approx, Size2),
	translate_bot(R1, Approx, R2).

translate_bot_(bot, upper, inf):-!.
translate_bot_(bot, lower, 0):-!.
translate_bot_(X, _, X).


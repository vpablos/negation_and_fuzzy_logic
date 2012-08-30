:- module(rfuzzy_rt, [defined_aggregators/1, 
	inject/3, merge/4, prod/3, iprod/3, 
	min/3, luka/3, dprod/3, max/3, dluka/3, complement/3,
	mean/3, supreme/2,
	'=>'/4,
	print_msg/3, print_msg_nl/1, activate_rfuzzy_debug/0,
	rfuzzy_conversion_in/2, rfuzzy_conversion_out/2 ],[hiord]).

:- use_module(library(write),[write/1]).
:- use_package(clpr).
:- use_module(library(terms),[copy_args/3]).

% ---------------------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------------------

% REMOVED: preinject/3,postinject/4, id/2, id/3, id (in defined_aggregators), 

defined_aggregators([min, max, prod, iprod, dprod, luka, dluka, complement, mean]).

min(X,Y,Z):- X .=<. Y, X .=. Z .
min(X,Y,Z):- X .>. Y, Y .=. Z .

max(X,Y,Z):- X .>=. Y, X .=. Z .
max(X,Y,Z):- Y .>. X, Y .=. Z .

prod(X,Y,M):- M .=. X * Y.
iprod(X,Y,M):- M .=. 1 - (X * Y).
dprod(X,Y,M):- M .=. X + Y - (X * Y).

luka(X,Y,M):- 
	Temp .=. X + Y  - 1, 
	max(0, Temp, M).

dluka(X,Y,M):- 
	Temp .=. X + Y,
	min(1, Temp, M).

complement(X, C, Z) :-
	Temp1 .=. C - X,
	min(1, Temp1, Temp2),
	max(0, Temp2, Z).

mean(X, Y, Z) :- Z .=. (X + Y) / 2.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

supreme([], _Element) :- !, 
	print_msg('debug', 'supreme', 'list is empty. FAIL.'),
	!, fail.
supreme(List_In, Answer) :-
	functor(Answer, _Name, Arity), 
	Arguments_Arity is Arity -1,
	Truth_Value_Arity is Arity +1,
	
	print_msg('debug', 'supreme :: List_In', List_In),
	supreme_aux_1(List_In, List_Aux_1), !,
	print_msg('debug', 'supreme :: List_Aux_1', List_Aux_1),
	reorder_by_truth_value(List_Aux_1, [], List_Aux_2),
	print_msg('debug', 'supreme :: List_Aux_2', List_Aux_2),
	take_an_element(List_Aux_2, Element),
	print_msg('debug', 'supreme :: element_taken', Element),

	copy_args(Arguments_Arity, Element, Answer),
	arg(Truth_Value_Arity, Element, Truth_Value),
	arg(Arity, Answer, Truth_Value).
	

% Head is only kept if it is the supreme.
supreme_aux_1([], []) :- !.
supreme_aux_1([Head | Tail_In], [Head | List_Out]) :- 
	print_msg_nl('ultradebug'),
	print_msg('ultradebug', 'supreme_aux_1 :: Head', Head),
	supreme_aux_2(Head, Tail_In, Tail_Out), !,
	supreme_aux_1(Tail_Out, List_Out).
supreme_aux_1([_Head | Tail_In], List_Out) :-
	supreme_aux_1(Tail_In, List_Out).

supreme_aux_2(_Head, [], []) :- !.
supreme_aux_2(Head, [Next | Tail_In], Tail_Out) :-
	split_out_fuzzy_functor_args(Head, Prio_1, TV_1, Args_1),
	split_out_fuzzy_functor_args(Next, Prio_2, TV_2, Args_2),

	Args_1 = Args_2, !, % They are for the same fuzzy values.
	print_msg('ultradebug', 'supreme_aux_2', 'equal args'),
	(
	    (	Prio_1 .>. Prio_2  )
	;
	    (   Prio_1 .=. Prio_2, TV_1 .>=. TV_2  )
	), !,
	print_msg('ultradebug', 'supreme_aux_2', 'higher Prio or TV.'),
	supreme_aux_2(Head, Tail_In, Tail_Out).
supreme_aux_2(Head, [Next | Tail_In], [Next | Tail_Out]) :-
	supreme_aux_2(Head, Tail_In, Tail_Out).

reorder_by_truth_value([], List_In, List_In) :- !.
reorder_by_truth_value([Head_1 | Tail], List_In, List_Out) :-
	reorder_by_truth_value_aux(Head_1, List_In, List_Aux), !,
	reorder_by_truth_value(Tail, List_Aux, List_Out).
	
reorder_by_truth_value_aux(Head_1, [], [Head_1]) :- !.
reorder_by_truth_value_aux(Head_1, [ Head_2 | Tail_In ], [ Head_2 | Tail_Out ]) :-
	has_less_truth_value(Head_1, Head_2), !,
	reorder_by_truth_value_aux(Head_1, Tail_In, Tail_Out).
reorder_by_truth_value_aux(Head_1, [ Head_2 | Tail_In ], [ Head_1, Head_2 | Tail_In ]) :- !.

has_less_truth_value(Head_1, Head_2) :-
	functor(Head_1, _Name_1, Arity_1), 
	functor(Head_2, _Name_2, Arity_2), 
	arg(Arity_1, Head_1, TV_1),
	arg(Arity_2, Head_2, TV_2),
	TV_1 .<. TV_2.

split_out_fuzzy_functor_args(Head, Prio, TV, Other_Args) :-
%	print_msg('debug', 'split_out_fuzzy_functor_args(Head)', split_out_fuzzy_functor_args(Head)),
	copy_term(Head, Head_Copy),
	functor(Head_Copy, Name, _Arity), 
	Head_Copy=..[Name | Functor_Args],
	split_out_fuzzy_functor_args_aux(Functor_Args, Prio, TV, Other_Args), 
	print_msg('ultradebug', 'split_out_fuzzy_functor_args(Head, Prio, TV, Args)', split_out_fuzzy_functor_args(Head, Prio, TV, Other_Args)).

split_out_fuzzy_functor_args_aux([Prio, TV], Prio, TV, []) :- !.
split_out_fuzzy_functor_args_aux([Arg | Args_List_In], Prio, TV, [Arg | Args_List_Out]) :- 
	split_out_fuzzy_functor_args_aux(Args_List_In, Prio, TV, Args_List_Out).

take_an_element([Element|_List], Element).
take_an_element([_FirstElement|List], Element) :-
	take_an_element(List, Element).


% ---------------------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------------------
 
%:- meta_predicate preinject(?,pred(2),?).
%
%id(L,L).
%
%preinject([],_,[]):-!.
%preinject(L,P,T):- P(L,T).

:- meta_predicate inject(?,pred(3),?).

inject([],_,_).
inject([T],_,T).
inject([X,Y|Rest],P,T):-
	P(X,Y,T0),
	inject([T0|Rest],P,T).

%:- meta_predicate postinject(?,?,pred(3),?).
%
%id(_,V,V).
%postinject([],A,_,A):-!.
%postinject(L,V,P,T):- P(L,V,T).


:- meta_predicate merge(?,?,pred(3),?).

merge([],L,_,L).

merge(L,[],_,L).

merge(L1,L2,P,L):-
	list(L1),list(L2),!,
	mergeaux(L1,L2,P,L).

mergeaux([],[],_,[]).

mergeaux([X|L1],[Y|L2],P,[Z|L]):-
	P(X,Y,Z),
	mergeaux(L1,L2,P,L).

:- new_declaration(is_fuzzy/3,on).
:- is_fuzzy('=>',4,truth).

:- meta_predicate =>(pred(3),goal,goal,?).

=>(Formula,X,Y,M):- 
	functor(X,_,Ax),
	arg(Ax,X,Mx),
	functor(Y,_,Ay),
	arg(Ay,Y,My),
	call(X),
	call(Y),
	call(Formula,Mx,My,M).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

rfuzzy_conversion_in(X, Y) :-
	nonvar(X),
	X .=. Y.
rfuzzy_conversion_in(X, _Y) :-
	\+(nonvar(X)).

rfuzzy_conversion_out(rat(X, Y), Z) :-
	Z is X/Y.
rfuzzy_conversion_out(X, X) :-
	number(X).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

:- data print_msg_level/1.

activate_all_rfuzzy_print_msg_level :-
	assertz_fact(print_msg_level('info')), % An intermediate level
	assertz_fact(print_msg_level('warning')), % The level printing less	
	assertz_fact(print_msg_level('error')), % The level printing less
	assertz_fact(print_msg_level('configured')). % The level printing less

% This is to enable debug. Deactivated by default.
activate_rfuzzy_debug :-	
	assertz_fact(print_msg_level('debug')). % The lowest level

% Main predicate in charge of printing.
print_msg(Level, Msg1, Msg2) :- 
	\+(print_msg_level('configured')), !,
	activate_all_rfuzzy_print_msg_level,
	print_msg(Level, Msg1, Msg2).
print_msg(Level, Msg1, Msg2) :- 
	print_msg_level('configured'),
	print_msg_level(Level), !,
	translate_level_to_pre_msg1(Level, Pre_Msg1),
	print_msg_aux(Pre_Msg1, Msg1, [], Msg2),
	print_msg_nl(Level).
print_msg(_Level, _Msg1, _Msg2) :- 
	print_msg_level('configured'), !. 

translate_level_to_pre_msg1('debug', 'DEBUG: ') :- !.
translate_level_to_pre_msg1('info', 'INFO: ') :- !.
translate_level_to_pre_msg1('warning', 'WARNING: ') :- !.
translate_level_to_pre_msg1('error', 'ERROR: ') :- !.
translate_level_to_pre_msg1('', '') :- !.

% This gets rid of lists.
print_msg_aux(Pre_Msg1, Msg1, Msg1_Info, []) :- !,
	print_msg_real(Pre_Msg1, Msg1, [ ' (list)' | Msg1_Info ], ' (empty)').
print_msg_aux(Pre_Msg1, Msg1, Msg1_Info, [ Msg2_Head | Msg2_Tail ]) :- !,
	print_msg_aux(Pre_Msg1, Msg1, [ ' (list)' | Msg1_Info ], Msg2_Head),
	print_msg_nl('error'), % Print it always.
	print_msg_aux(Pre_Msg1, Msg1, Msg1_Info, Msg2_Tail).
print_msg_aux(Pre_Msg1, Msg1, Msg1_Info, Msg2) :- !,
	print_msg_real(Pre_Msg1, Msg1, Msg1_Info, Msg2).

% Predicate that really prints.
print_msg_real(Pre_Msg1, Msg1,  Msg1_Info, Msg2) :-
	write(Pre_Msg1), 
	write(Msg1), 
	print_msg1_info(Msg1_Info),
	write(':  '),  write(Msg2),
	write('    ').

% Print msg1 Info (in reverse order to show the structure).
print_msg1_info([]) :- !.
print_msg1_info([Head | Tail]) :- !,
	print_msg1_info(Tail),
	write(' '),
	write(Head).

print_msg_nl(Level) :- print_msg_level(Level), !, nl.
print_msg_nl(_Level) :- !.


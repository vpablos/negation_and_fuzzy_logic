%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Module for being loaded by cneg1 to add store_clauses/2 facts
% to flatten the structure of facts and clauses of a program
% that contains cneg/1 calls to be able to aply the try/2 
% technique for the constructive negation of the goals.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- module(cneg_tr,[trans_sent/3, trans_clause/3, cneg_main_and_aux_cl_names/3],[assertions]).

:- use_module(library(engine(data_facts)),[retract_fact/1]).
:- use_module(cneg_aux, _).
:- use_module(library(terms), _).

:- comment(title, "Contructive Negation Transformation").

:- comment(author, "V@'{i}ctor Pablos Ceruelo").

:- comment(summary, "This module does de transformation needed to evaluate 
	the constructive negation of any predicate in the original file.").

% dynamic predicate(s) 
:- data cneg_list_of_heads_and_bodies/1.
:- data cneg_list_of_predicates/1.

list_name_for_cneg_heads_and_bodies('cneg_list_of_heads_and_bodies').
list_name_for_cneg_predicates('cneg_list_of_predicates').

trans_clause(Whatever, Whatever, _) :-
	debug_msg(1, 'trans_clause', (Whatever)).

% trans_sent(Sentence,SentList,Module) sustitutes Sentence in 
% the program Module that is being compilated by the list of 
% sentences SentList. The result clauses are continous
trans_sent(Input, Output, SourceFileName) :-
	% debug_msg('trans_sent', trans_sent(Input)), 
	% debug_msg('trans_sent', source_file_name(Info)), 
	trans_sent_aux(Input, Output, SourceFileName), !.

trans_sent(Input, [Input, cneg_not_translated(Input)], _SourceFileName) :-
	debug_msg(2, 'ERROR :: Impossible to translate', (Input)), !.

trans_sent_aux(X, [], _SourceFileName):- 
	var(X), !, fail.

% (:- include(dist, _)), (:- include(cneg_lib)), 
trans_sent_aux(end_of_file, ClsFinal, SourceFileName):- !,
%	debug_msg(1, 'INFO: #################################################', ''), 
	debug_msg(1, 'INFO: #############  Now computing negation  ##############', ''), 
%	debug_msg(1, 'INFO: #################################################', ''), 
	trans_sent_eof(ClsFinal, SourceFileName).

trans_sent_aux(0, [], _SourceFileName) :- 	!.
%	debug_msg(2, 'INFO :: Use cneg_not_translated/1 to see errors in translation of ', SourceFileName).

% Do not modify module imports, declarations and so on.
trans_sent_aux((:- Whatever),[(:- Whatever)],_):- !.
%	msg('Warning: cneg does not work for imported predicates unless cneg\'s package is imported from each one. Problematic declaration:', Whatever).

% Aqui es donde da el warning porque no conoce a dist:dist aqui.
trans_sent_aux(Clause, [Clause], _SourceFileName) :-
	debug_msg(0, 'INFO :: save_sent_info(Clause) ', save_sent_info(Clause)),
	save_sent_info(Clause).

save_sent_info(Clause) :-
	functor_local(Clause, Name, 2, _Arguments),
	Name==':-', !,
	arg(1, Clause, Head),
	arg(2, Clause, Body),
	unifications_in_head_to_equality(Head, New_Head, Equality),
	split_disjunctions_in_bodies((Equality, Body), Bodies),
	store_head_and_bodies_info(New_Head, Bodies).

save_sent_info(Head) :-
	functor_local(Head, Name, Arity, _Arguments),
	(
	    Name\==':-' 
	; 
	    Arity\==2
	), !,
	unifications_in_head_to_equality(Head, New_Head, Equality),
	store_head_and_bodies_info(New_Head, [[Equality]]).

unifications_in_head_to_equality(Head, New_Head, Equality) :-
	% Take the unifications in the head and move them to the body.
	functor_local(Head, Name, Arity, Args), 
	functor_local(New_Head, Name, Arity, New_Args), 
	functor_local(Equality, '=', 2, [New_Args | [Args]]).

%split_disjunctions_in_bodies(Body, Bodies)
split_disjunctions_in_bodies(Body, Bodies) :- 
	debug_msg(0, 'INFO :: split_disjunctions_in_bodies :: Body ', Body), 
	split_disjunctions_in_bodies_aux(Body, Bodies),
	debug_msg(0, 'INFO :: split_disjunctions_in_bodies :: Bodies ', Bodies), 
	!.

split_disjunctions_in_bodies_aux(Body, Bodies) :- 
	goal_is_conjunction(Body, Body_Conj_1, Body_Conj_2), !,
	split_disjunctions_in_bodies_aux(Body_Conj_1, Bodies_Conj_1),
	split_disjunctions_in_bodies_aux(Body_Conj_2, Bodies_Conj_2),
	cartesian_product_of_lists(Bodies_Conj_1, Bodies_Conj_2, Bodies).

split_disjunctions_in_bodies_aux(Body, [Body_Result_1, Body_Result_2]) :- 
	goal_is_disjunction(Body, Body_Disj_1, Body_Disj_2), !,
	split_disjunctions_in_bodies_aux(Body_Disj_1, Body_Result_1),
	split_disjunctions_in_bodies_aux(Body_Disj_2, Body_Result_2).

split_disjunctions_in_bodies_aux(Body, [[Body]]). % Goal is something else.

cartesian_product_of_lists([], _List_2, []) :- !.
cartesian_product_of_lists([Elto | List_1], List_2, Result) :-
	cartesian_product_of_lists_aux(Elto, List_2, Result_1),
	cartesian_product_of_lists(List_1, List_2, Result_2),
	append(Result_1, Result_2, Result).

cartesian_product_of_lists_aux(_Elto_1, [], []) :- !.
cartesian_product_of_lists_aux(Elto_1, [Elto_2 | List], [Result | More_Results]) :-
	append(Elto_1, Elto_2, Result),
	cartesian_product_of_lists_aux(Elto_1, List, More_Results).

store_head_and_bodies_info(Head, Bodies) :-
	debug_msg(0, 'store_head_and_bodies_info(Head, Bodies) ', store_head_and_bodies_info(Head, Bodies)),
	store_head_and_bodies_info_aux(Head, Bodies).

store_head_and_bodies_info_aux(_Head, []) :-
	!. % Backtracking forbidden.
store_head_and_bodies_info_aux(Head, [Body | Bodies]) :-
	store_head_info(Head, Counter),
	store_body_info(Head, Body, Counter),
	store_head_and_bodies_info(Head, Bodies).

store_body_info(Head, Body, Counter) :-
	list_name_for_cneg_heads_and_bodies(List_Name),
	retrieve_list_of(List_Name, List),
	save_list_of(List_Name, [(Head, Body, Counter) | List]).

store_head_info(Head, NewCounter) :-
	functor_local(Head, Name, Arity, _Arguments),
	list_name_for_cneg_predicates(List_Name),
	retrieve_list_of(List_Name, List),
	remove_from_list_with_counter(List, (Name, Arity, Counter), NewList),
	NewCounter is Counter + 1,
	save_list_of(List_Name, [(Name, Arity, NewCounter) | NewList]).

remove_from_list_with_counter([], (_Name, _Arity, 0), []) :- !.
remove_from_list_with_counter([(Name, Arity, Counter) | List], (Name, Arity, Counter), List) :- !.
remove_from_list_with_counter([ Elto | List], (Name, Arity, Counter), [Elto | NewList]) :- !,
	remove_from_list_with_counter(List, (Name, Arity, Counter), NewList).

% Saves a list with name List_Name and argument List.
save_list_of(List_Name, List) :-
	functor_local(Functor, List_Name, 1, [List]),
	assertz_fact(Functor), !,
	debug_msg(0, 'assertz_fact ', assertz_fact(Functor)).

% Retrieves a list with name List_Name and argument List.
retrieve_list_of(List_Name, List) :-
	functor_local(Functor, List_Name, 1, [List]),
	retract_fact(Functor), !,
	debug_msg(0, 'retract_fact ', retract_fact(Functor)).
retrieve_list_of(_List_Name, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_auxiliary_code([ Multifile |[ end_of_file]]) :-
	Multifile = (:- multifile cneg_pre_frontier/6).
%	Multifile = (:- multifile cneg_pre_frontier/6, call_to/1),
%	Call_To_This_File_Pred = (call_to(Predicate) :- call(Predicate)).

trans_sent_eof(Cls_Out, SourceFileName) :-
	generate_auxiliary_code(Aux_Code),
	list_name_for_cneg_predicates(List_Name_1),
	retrieve_list_of(List_Name_1, List_Of_Preds),
	debug_msg_list(0, 'List_Of_Preds', List_Of_Preds),
	debug_msg(0, 'trans_sent_eof', generate_cneg_main_cls(List_Of_Preds, Aux_Code, Cls_1)),
	cneg_tr_generate_main_cls(List_Of_Preds, [end_of_file], Cls_1),
	debug_msg_list(0, 'Cls_1', Cls_1),
	!, %Backtracking forbiden.
	list_name_for_cneg_heads_and_bodies(List_Name_2),
	retrieve_list_of(List_Name_2, List_Of_H_and_B),
	debug_msg_list(0, 'List_Of_H_and_B', List_Of_H_and_B),
	cneg_tr_generate_cls_bodies(List_Of_H_and_B, Cls_1, Cls_2),
	debug_msg_list(0, 'Cls_2', Cls_2),
	!, %Backtracking forbiden.
	generate_double_negation_main_cls(List_Of_Preds, Cls_2, Cls_3),
	debug_msg_list(0, 'Cls_3', Cls_3),
	!, %Backtracking forbiden.
	generate_double_negation_clauses(List_Of_H_and_B, Cls_3, Cls_4),
	debug_msg_list(0, 'Cls_4', Cls_4),
	generate_pre_frontiers(List_Of_H_and_B, SourceFileName, Cls_4, Cls_Out),
	debug_msg_nl(0), debug_msg_nl(0),
	debug_msg_list(0, 'Cls_Out', Cls_Out),
	debug_msg_nl(0), debug_msg_nl(0), 
	!. %Backtracking forbiden.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%generate_main_cls(List_Of_Preds, Cls_1).
cneg_tr_generate_main_cls([], Cls, Cls) :- !.
cneg_tr_generate_main_cls([(Name, Arity, Counter) | List_Of_Preds], Cls_In, Cls_Out) :- !,
	debug_msg(0, 'generate_cneg_main_cls :: (Name, Arity, Counter)', (Name, Arity, Counter)),
	cneg_tr_generate_main_cl(Name, Arity, Counter, Main_Cl, Aux_Cl),
	debug_msg(0, 'generate_cneg_main_cls :: (Main_Cl, Aux_Cl)', (Main_Cl, Aux_Cl)),
	!, %Backtracking forbiden.
	cneg_tr_generate_main_cls(List_Of_Preds, [Main_Cl |[Aux_Cl | Cls_In]], Cls_Out).

cneg_tr_generate_main_cl(Name, Arity, Counter, Main_Cl, Aux_Cl) :-
	cneg_main_and_aux_cl_names(Name, Main_Cl_Name, Aux_Cl_Name),	
	generate_double_negation_name(Name, Main_DN_Name),

	New_Arity is Arity + 2, % Arity + GoalVars + Result

	% Generate the main clause.
	functor_local(Main_Cl, ':-', 2, [Main_Cl_Head |[Main_Cl_Body]]), 

	Main_Cl_Body = (goalvars(Main_Cl_Head, GoalVars), Aux_Cl_Call),
	functor(Main_Cl_Head, Main_Cl_Name, Arity),
	functor(Aux_Cl_Call, Aux_Cl_Name, New_Arity), 
	copy_args(Arity, Main_Cl_Head, Aux_Cl_Call),
	args_for_cneg_tr(New_Arity, Aux_Cl_Call, GoalVars, 'true'),

	% Generate the auxiliary clause.
	functor_local(Aux_Cl, ':-', 2, [Aux_Cl_Head |[ Aux_Cl_Body ]]), 
	functor(Aux_Cl_Head, Aux_Cl_Name, New_Arity),
	args_for_cneg_tr(New_Arity, Aux_Cl_Head, GoalVars, Result),
	Aux_Cl_Body = (Aux_Cl_Body_1 ; Aux_Cl_Body_2),

	% We need to copy the args from the aux functor to the aux_i functors.
	auxiliary_info(Info_1, Counter, Aux_Cl_Head, Aux_Cl_Name, New_Arity, Arity),
	generate_auxiliary_conj(1, Info_1, Aux_Cl_Body_1, GoalVars, Result),

	auxiliary_info(Info_2, Counter, Aux_Cl_Head, Main_DN_Name, New_Arity, Arity),
	generate_auxiliary_disj(1, Info_2, Aux_Cl_Body_2, GoalVars, Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

auxiliary_info(head_aux_cl_info_aux(Counter, Head_Aux_Cl, Aux_Cl_Name, New_Arity, Arity), 
	Counter, Head_Aux_Cl, Aux_Cl_Name, New_Arity, Arity).

args_for_cneg_tr(Arity, Functor, GoalVars, Result) :-
	arg(Arity, Functor, Result), 
	Arity_2 is Arity -1,
	arg(Arity_2, Functor, GoalVars).

cneg_main_and_aux_cl_names(Name, Main_Cl_Name, Aux_Cl_Name) :-
	name(Name, Name_String),
	append("cneg_", Name_String, Main_Cl_String),
	name(Main_Cl_Name, Main_Cl_String),
	
	append(Main_Cl_String, "_aux", Aux_Cl_String),
	name(Aux_Cl_Name, Aux_Cl_String).

generate_name_from_counter(Counter, Aux_Cl_Name, New_Name) :-
	name(Aux_Cl_Name, String_1),
	name(Counter, String_2), 
	append("_", String_2, String_3),
	append(String_1, String_3, String), 
	name(New_Name, String).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_auxiliary_conj(Index, Aux_Info, 'fail', _GoalVars, 'fail') :- 
	auxiliary_info(Aux_Info, Counter, _Head_Aux_Cl, _Aux_Cl_Name, _New_Arity, _Arity),
	Index > Counter, !.

generate_auxiliary_conj(Index, Aux_Info, Body, GoalVars, Result) :-
	auxiliary_info(Aux_Info, Counter, Aux_Cl_Head, Aux_Cl_Name, New_Arity, Arity),
	generate_name_from_counter(Index, Aux_Cl_Name, SubCall_Name),

	functor(SubCall, SubCall_Name, New_Arity),
	copy_args(Arity, Aux_Cl_Head, SubCall),
	args_for_cneg_tr(New_Arity, SubCall, GoalVars, Result_Aux),
	test_for_true(Test_For_True, Result_Aux),

	(
	    (   % Optimizations for the last one.
		Index == Counter,
		test_for_true(Result_Is_True, Result),
		Body = ((SubCall, Test_For_True), Result_Is_True)
	    )
	;
	    (
		Index < Counter,
		Body = (SubCall, (Test_For_True, MoreBody)),
		NewIndex is Index + 1,
		generate_auxiliary_conj(NewIndex, Aux_Info, MoreBody, GoalVars, Result)
	    )
	).

generate_auxiliary_disj(Index, Aux_Info, 'fail', _GoalVars, 'fail') :- 
	auxiliary_info(Aux_Info, Counter, _Head_Aux_Cl, _Aux_Cl_Name, _New_Arity, _Arity),
	Index > Counter, !.

generate_auxiliary_disj(Index, Aux_Info, Body, GoalVars, Result) :-
	auxiliary_info(Aux_Info, Counter, Aux_Cl_Head, Aux_Cl_Name, New_Arity, Arity),
	generate_name_from_counter(Index, Aux_Cl_Name, SubCall_Name),

	functor(SubCall, SubCall_Name, New_Arity),
	copy_args(Arity, Aux_Cl_Head, SubCall),
	args_for_cneg_tr(New_Arity, SubCall, GoalVars, Result_Aux),

	% Prepare tests.
	test_for_true(Test_For_True, Result_Aux),

	(
	    (   % Optimizations for the last one.
		Index == Counter,
		test_for_fail(Result_Is_Fail, Result),
		Body = ((SubCall, Test_For_True), Result_Is_Fail)
	    )
	;
	    (
		Index < Counter,
		Body = ((SubCall, Test_For_True) ; MoreBody),
		NewIndex is Index + 1,
		generate_auxiliary_disj(NewIndex, Aux_Info, MoreBody, GoalVars, Result)
	    )
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1- We translate the names of the predicates by using the respective counters, 
%     and we add 5 variables for UQV_In, UQV_Out, Allowed_To_Fail, Results_In, Results_Out.
% 2- We convert:
%      2.1- the unifications in heads in equalities in the bodies.
%      2.2- the subcalls to other predicates are translated into prodicates we've translated.
%      2.3- vars for freevars and continuation vars are inserted at this point.

%cneg_tr_generate_cls_bodies(List_Of_H_and_B, Cls_2).
cneg_tr_generate_cls_bodies([], Cls_In, Cls_In).
cneg_tr_generate_cls_bodies([(Head, Body, Counter) | List_Of_H_and_B], Cls_In, Cls_Out) :-
	debug_msg(0, 'generate_cneg_disjs_aux :: (Head, Body, Counter)', (Head, Body, Counter)),
	cneg_tr_generate_cl_body(Head, Body, Counter, New_Cl), !,
	debug_msg(0, 'generate_cneg_disjs_aux :: New_Cl', New_Cl),
	% Recursive create the other clauses.
	cneg_tr_generate_cls_bodies(List_Of_H_and_B, [New_Cl | Cls_In], Cls_Out).

cneg_tr_generate_cl_body(Head, Body, Counter, New_Cl) :-
	% We suppose the head has no unifications (we've removed them before).
	functor(Head, Name, Arity), 
	% New head (new name, new arity, new args).
	New_Arity is Arity + 2, % GoalVars + Result
	cneg_main_and_aux_cl_names(Name, _Main_Cl_Name, Aux_Cl_Name),
	generate_name_from_counter(Counter, Aux_Cl_Name, New_Name),
	functor(New_Head, New_Name, New_Arity),
	copy_args(Arity, Head, New_Head),
	args_for_cneg_tr(New_Arity, New_Head, GoalVars, Result),

	% Build new clause.
	functor(New_Cl, ':-', 2),
	arg(1, New_Cl, New_Head),
	arg(2, New_Cl, New_Body),

	% Aqui es donde se sabe si hara falta la negacion de Chan o no.
	% El problema es q las variables de la cabecera no la necesitan, 
	% por lo que hay que distinguir entre cabecera y cuerpo. 

	functor(Test_Cneg_RT, 'test_if_cneg_rt_needed', 2),
	arg(1, Test_Cneg_RT, GoalVars), 
	arg(3, Test_Cneg_RT, Body_Unifications), 
	arg(4, Test_Cneg_RT, Body_Conj),
	arg(4, Test_Cneg_RT, Result_Aux),

	list_head(Body, Body_Unifications),
	convert_list_to_conjunction(Body, Body_Conj),
	test_for_true(Test_For_True, Result_Aux),
	test_for_fail(Test_For_Fail, Result_Aux),
	New_Body = (Test_Cneg_RT, (Test_For_True ; (Test_For_Fail, Neg_Body))),

	% negate_body_conjunction
	negate_body_conj(Body, GoalVars, Result, Neg_Body).


negate_body_conj([], _GoalVars, Result, Test_For_Fail) :- !,
	test_for_fail(Test_For_Fail, Result).

negate_body_conj([Atom | Body], GoalVars, Result, Negated_Body) :-
	debug_msg(0, 'negate_atom :: Atom ', Atom),
	negate_atom(Atom, GoalVars, Result, Negated_Atom),  
	debug_msg(0, 'negate_atom :: Negated_Atom ', Negated_Atom),

	test_for_true(Test_For_True, Result_Aux),
	test_for_fail(Test_For_Fail, Result_Aux),
	generate_equality(Op, Result, Result_Aux),

	Ops_When_True = (Test_For_True, Op),
	Ops_When_Fail = (Test_For_Fail, New_Negated_Body),
	Negated_Body = (Negated_Atom, (Ops_When_True ; Ops_When_Fail)),

	negate_body_conj(Body, GoalVars, Result, New_Negated_Body).

% negate_atom(Atom, Negated_Atom, UQV_In, UQV_Out, Results_In, Results_Out).
negate_atom(Atom, GoalVars, Result, Neg_Atom) :-
	goal_is_equality(Atom, A_Left, A_Right, _Unconfigured_UQV), !,
	functor_local(Neg_Atom, 'cneg_diseq_eqv', 4, [A_Left |[A_Right |[ GoalVars |[Result]]]]).

negate_atom(Atom, _GoalVars, Result, Neg_Atom) :-
	goal_is_disequality(Atom, A_Left, A_Right, _FreeVars), !,
	functor_local(Neg_Atom, 'cneg_eq_uqv', 4, [A_Left |[A_Right |[ [] |[Result]]]]). % UQV = []

negate_atom(Atom, GoalVars, Result, Neg_Atom) :-
	functor_local(Atom, 'cneg', 2, [UQV |[ Arg ]]), !,
	functor_local(Op_Append, 'append', 3, [UQV |[ GoalVars |[New_GoalVars]]]),
	Neg_Atom = (Op_Append, Neg_Atom_Aux),
	double_negation_atom(Arg, New_GoalVars, Result, Neg_Atom_Aux).

negate_atom(Atom, GoalVars, Result, Neg_Atom) :-
	functor(Atom, Name, Arity), !,
	cneg_main_and_aux_cl_names(Name, _Main_Cl_Name, Aux_Cl_Name),
	New_Arity is Arity + 2, 
	functor(Neg_Atom, Aux_Cl_Name, New_Arity),
	args_for_cneg_tr(New_Arity, Neg_Atom, GoalVars, Result),
	copy_args(Arity, Atom, Neg_Atom).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

double_negation_atom(Atom, GoalVars, Result, DN_Atom) :-
	goal_is_conjunction(Atom, Conj_1, Conj_2), !,

	test_for_true(Test_For_True, Result_Aux),
	test_for_fail(Test_For_Fail, Result_Aux),
	generate_equality(Op, Result, Result_Aux),

	Ops_When_True = (Test_For_True, DN_Conj_2),
	Ops_When_Fail = (Test_For_Fail, Op),
	DN_Atom = (DN_Conj_1, (Ops_When_Fail ; Ops_When_True)),

	double_negation_atom(Conj_1, GoalVars, Result_Aux, DN_Conj_1),
	double_negation_atom(Conj_2, GoalVars, Result, DN_Conj_2).

double_negation_atom(Atom, GoalVars, Result, DN_Atom) :-
	goal_is_disjunction(Atom, Disj_1, Disj_2), !,

	test_for_true(Test_For_True, Result_Aux),
	test_for_fail(Test_For_Fail, Result_Aux),
	generate_equality(Op, Result, Result_Aux),

	Ops_When_True = (Test_For_True, Op),
	Ops_When_Fail = (Test_For_Fail, DN_Disj_2),
	DN_Atom = (DN_Disj_1, (Ops_When_True ; Ops_When_Fail)),

	double_negation_atom(Disj_1, GoalVars, Result_Aux, DN_Disj_1),
	double_negation_atom(Disj_2, GoalVars, Result, DN_Disj_2). 

double_negation_atom(Atom, GoalVars, Result, DN_Atom) :-
	functor_local(Atom, 'cneg', 2, [_Unconfigured_UQV |[ Arg ]]), !,
	negate_atom(Arg, GoalVars, Result, DN_Atom). % Problematic

double_negation_atom(Atom, GoalVars, Result, DN_Atom) :-
	goal_is_disequality(Atom, A_Left, A_Right, _Unconfigured_UQV), !,
	functor_local(DN_Atom, 'cneg_diseq_eqv', 4, [A_Left |[A_Right |[GoalVars |[Result ]]]]).

double_negation_atom(Atom, GoalVars, Result, DN_Atom) :-
	goal_is_equality(Atom, A_Left, A_Right, _Unconfigured_UQV), !,
	functor_local(DN_Atom, 'cneg_eq_eqv', 4, [A_Left |[A_Right |[GoalVars |[Result ]]]]).	

double_negation_atom(Atom, GoalVars, Result, DN_Atom) :-
	functor(Atom, Name, Arity), !,
	New_Arity is Arity + 2,
	generate_double_negation_name(Name, New_Name),
	functor(DN_Atom, New_Name, New_Arity),
	args_for_cneg_tr(New_Arity, DN_Atom, GoalVars, Result),
	copy_args(Arity, Atom, DN_Atom).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_double_negation_name(Name, New_Name) :-
	name(Name, String_Name),
	append("double_negation_", String_Name, String_New_Name),
	name(New_Name, String_New_Name).

generate_name_with_counter(Name, Counter, New_Name) :-
	name(Name, String_Name),
	name(Counter, String_Counter),
	append(String_Name, "_", String_Name_Tmp),
	append(String_Name_Tmp, String_Counter, String_New_Name),
	name(New_Name, String_New_Name).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_double_negation_clauses(List_Of_H_and_B, Cls_In, Cls_Out) :-
	debug_msg(0, 'generate_double_negation_clauses :: List_Of_H_and_B, Cls_In', (List_Of_H_and_B, Cls_In)),
	generate_dn_cls(List_Of_H_and_B, Cls_In, Cls_Out).

% generate_dnb(List_Of_H_and_B, Cls_In, Cls_Out) :-
generate_dn_cls([], Cls_In, Cls_In).
generate_dn_cls([(Head, Body, Counter) | List_Of_H_and_B], Cls_In, Cls_Out) :-
	debug_msg(0, 'generate_dn_cls :: (Head, Body, Counter)', (Head, Body, Counter)),
	generate_dn_cl(Head, Body, Counter, New_Cl), !,
	debug_msg(0, 'generate_dn_cls :: New_Cl', New_Cl),
	% Recursive create the other clauses.
	generate_dn_cls(List_Of_H_and_B, [New_Cl | Cls_In], Cls_Out).

generate_dn_cl(Head, Body, Counter, New_Cl) :-
	functor_local(Head, Name, Arity, _Args),
	generate_double_negation_name(Name, Aux_Name),
	generate_name_with_counter(Aux_Name, Counter, New_Name),
	New_Arity is Arity + 4,
	functor_local(New_Head, New_Name, New_Arity, _New_Args),
	copy_args(Arity, Head, New_Head),
	adjust_args_for_status(New_Arity, New_Head, Status),
	generate_dn_body(Body, Head, Counter, Status, New_Body),
	functor_local(New_Cl, ':-', 2, [New_Head |[New_Body]]).

generate_dn_body([], _Head, _Counter, Status_In, (Op_1, Op_2)) :-
	status_operation(Status_In, UQV_In, UQV_Out, _Allowed_To_Fail, Result_In),
	generate_equality(Op_1, UQV_In, UQV_Out),
	generate_equality(Op_2, Result_In, 'true').

generate_dn_body([Conj_1 | Body], Head, Counter, Status_In, DN_Conjunction) :-
	status_operation(Status_In, UQV_In, UQV_Out, Allowed_To_Fail, Result_In),

	test_for_true(Test_For_True, Result_Aux),
	test_for_fail(Test_For_Fail, Result_Aux),
	generate_equality(Op_1, UQV_Out, UQV_Aux),
	generate_equality(Op_2, Result_In, Result_Aux),

	Ops_When_True = (Test_For_True, DN_Body),
	Ops_When_Fail = (Test_For_Fail, (Op_1, Op_2)),
	DN_Conjunction = (DN_Conj_1, (Ops_When_Fail ; Ops_When_True)),

	status_operation(Status_C1, UQV_In, UQV_Aux, Allowed_To_Fail, Result_Aux),
	double_negation_atom(Conj_1, DN_Conj_1, Status_C1),
	status_operation(Status_C2, UQV_Aux, UQV_Out, Allowed_To_Fail, Result_In),
%	double_negation_atom(Conj_2, DN_Conj_2, Status_C2).
	generate_dn_body(Body, Head, Counter, Status_C2, DN_Body).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_double_negation_main_cls([], Cls, Cls) :- !.
generate_double_negation_main_cls([(Name, Arity, Counter) | List_Of_Preds], Cls_In, Cls_Out) :-
	debug_msg(0, 'generate_double_negation_main_cls :: (Name, Arity, Counter)', (Name, Arity, Counter)),
	generate_double_negation_main_cl(Name, Arity, Counter, DN_Main_Cl),
	debug_msg(0, 'generate_double_negation_main_cls :: Main_Cl', DN_Main_Cl),
	!, %Backtracking forbiden.
	generate_double_negation_main_cls(List_Of_Preds, [DN_Main_Cl | Cls_In], Cls_Out).

generate_double_negation_main_cl(Head_Name, Arity, Counter, Main_Cl) :-
	generate_double_negation_name(Head_Name, New_Head_Name),
	functor_local(Main_Cl, ':-', 2, [Head |[ SubCalls ]]),
	New_Arity is Arity + 4,
	functor_local(Head, New_Head_Name, New_Arity, _Args_Head),
%	status_operation(Status, UQV_In, UQV_Out, Results_In, Results_Out),
	adjust_args_for_status(New_Arity, Head, Status),

	generate_double_negation_subcalls(Head, Arity, Status, 1, Counter, SubCalls).

generate_double_negation_subcalls(_Head, _Arity, _Status, Index, Counter, 'fail') :-
	Counter < Index, !. % Security check.

generate_double_negation_subcalls(Head, Arity, Status_In, Index, Counter, Ops) :-
	status_operation(Status_In, UQV_In, UQV_Out, Allowed_To_Fail, Result_In),
	Ops = (SubCall, (Ops_When_True ; Ops_When_Fail)), 

	Ops_When_True = (Test_For_True, (Op_1, Op_2)),
	Ops_When_Fail = (Test_For_Fail, More_Ops),

	test_for_true(Test_For_True, Result_Aux),
	test_for_fail(Test_For_Fail, Result_Aux),
	generate_equality(Op_1, UQV_Aux, UQV_Out),
	generate_equality(Op_2, Result_Aux, Result_In),

	% Obtain New_Arity and Head_Name of new Head.
	functor_local(Head, Head_Name, New_Arity, _Head_Args),

	% Generate SubCall.
	generate_name_with_counter(Head_Name, Index, New_Name),
	functor_local(SubCall, New_Name, New_Arity, _SubCall_Args),
	copy_args(Arity, Head, SubCall),
	status_operation(Status_Aux, UQV_In, UQV_Aux, Allowed_To_Fail, Result_Aux),
	adjust_args_for_status(New_Arity, SubCall, Status_Aux),

	status_operation(Status_Out, UQV_Aux, UQV_Out, Allowed_To_Fail, Result_In),
	New_Index is Index + 1,
	generate_double_negation_subcalls(Head, Arity, Status_Out, New_Index, Counter, More_Ops).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_pre_frontiers([], _SourceFileName, Cls, Cls) :- !.
generate_pre_frontiers([(Head, Body, _Counter) | List_Of_Preds], SourceFileName, Cls_In, Cls_Out) :-
	functor(Head, Head_Name, Head_Arity),
	list_head(Body, Test),
	convert_list_to_conjunction(Body, Body_Conj),
	CL = (cneg_pre_frontier(Head_Name, Head_Arity, SourceFileName, Head, Body_Conj, Test)),
	generate_pre_frontiers(List_Of_Preds, SourceFileName, [CL | Cls_In], Cls_Out).

convert_list_to_conjunction([], 'true') :- !.
convert_list_to_conjunction([Body_Last], Body_Last) :- !.
convert_list_to_conjunction([Body|MoreBodyList], (Body, MoreBodyConj)) :- !,
	convert_list_to_conjunction(MoreBodyList, MoreBodyConj).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_for_true(Test_For_True, Var) :-
	generate_equality(Test_For_True, Var, 'true').

test_for_fail(Test_For_True, Var) :-
	generate_equality(Test_For_True, Var, 'fail').

generate_equality(Equality, Term_1, Term_2) :-
	functor_local(Equality, '=', 2, [Term_1 |[Term_2]]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%status_operation([UQV_In |[UQV_Out |[Allowed_To_Fail |[Results]]]], 
%	UQV_In, UQV_Out, Allowed_To_Fail, Results).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- module(rfuzzy_tr,[trans_fuzzy_sent/3,trans_fuzzy_cl/3],[]).

:- use_module(library(aggregates), [findall/3]).
:- use_module(library(terms),[copy_args/3]).
:- use_module(library(messages),[error_message/2]).
:- use_module(library(write),[write/1]).

:- use_module(library('compiler/c_itf')).

%:- data fpred/1.
%:- data fclause/2.
%:- data frule/3.
%:- data fnegclause/3.
%:- data faggr/4.
:- data sentence/2.
:- data aggregators/1.

% Important info to be saved.
:- data rfuzzy_predicate_info/5.

% :- data func_arguments/2.

:- use_module(library('rfuzzy/rfuzzy_rt')).
:- include(library('rfuzzy/rfuzzy_ops')).
% :- include(library('clpr/ops')).
:- include(library('clpqr-common/ops')).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% trans_fuzzy_cl(Arg1, Arg2, Arg3) :- 
trans_fuzzy_cl(Arg1, Arg1, _Arg3) :- 
	debug_msg('trans_fuzzy_clause: arg1', Arg1).
%	original_fuzzy_clause_trans(Arg1, Arg2, Arg3),
%	debug_msg('clause: arg2', Arg2),
%	debug_msg('clause: arg3', Arg3),
%	debug_nl.

trans_fuzzy_sent(Arg1, Arg2, Arg3) :- 
	debug_msg('trans_fuzzy_sent: arg1', Arg1),
	trans_fuzzy_sent_aux(Arg1, Arg2, Arg3), !,
	debug_msg_list('trans_fuzzy_sent: arg2', Arg2),
	debug_msg('trans_fuzzy_sent: arg3', Arg3),
	debug_nl.

trans_fuzzy_sent(Arg, Arg, FileName) :- 
	debug_msg('trans_fuzzy_sent: ERROR: Input: ', Arg),
	debug_msg('trans_fuzzy_sent: ERROR: FileName: ', FileName),
	debug_nl.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% We need to evaluate the whole program at the same time.
% Note that eat_2 uses info supplied by eat_1 and 
% eat_3 uses info supplied by eat_1 and eat_2.	
trans_fuzzy_sent_aux(end_of_file, Sentences_Out, FileName):-
	!,
	findall(Cl,(retract_fact(sentence(Cl, FileName))), Sentences_In),
	eat_lists(1, Sentences_In, [], Sent_Tmp_1, [(end_of_file)], Converted_1),
	eat_lists(2, Sent_Tmp_1, [], Sent_Tmp_2, Converted_1, Converted_2),
	eat_lists(3, Sent_Tmp_2, [], Sent_Tmp_3, Converted_2, Converted_3),
	eat_lists(4, Sent_Tmp_3, [], Sent_Tmp_4, Converted_3, Converted_4),
	eat_lists(5, Sent_Tmp_4, [], Sent_Tmp_5, Converted_4, Converted_5),
	debug_msg_list('Converted_5', Converted_5),
	debug_msg_list('Sent_Tmp_5', Sent_Tmp_5),

	retrieve_all_predicate_info('defined', To_Build_Fuzzy_Aux_Predicates),
	debug_msg_list('To_Build_Fuzzy', To_Build_Fuzzy_Aux_Predicates),
	build_auxiliary_clauses(To_Build_Fuzzy_Aux_Predicates, Fuzzy_Aux_Predicates),  

	append_local(Sent_Tmp_5, Converted_5, Sentences_Out_Tmp),
	append_local(Fuzzy_Aux_Predicates, Sentences_Out_Tmp, Sentences_Out),
	debug_msg_list('Sentences_Out', Sentences_Out).

trans_fuzzy_sent_aux(0, [], _FileName) :- !, nl, nl, nl.

trans_fuzzy_sent_aux(Sentence, [Sentence], _FileName) :-
	do_not_translate(Sentence), !.

trans_fuzzy_sent_aux(Sentence, [], FileName) :-
	assertz_fact(sentence(Sentence, FileName)).

% Some sentences that do not need to be translated ...
do_not_translate((:-add_goal_trans(_Whatever))) :- !.
do_not_translate((:-add_clause_trans(_Whatever))) :- !.
do_not_translate((:-add_sentence_trans(_Whatever))) :- !. % 
do_not_translate((:-load_compilation_module(_Whatever))) :- !.
do_not_translate((:-use_module(_Whatever))) :- !.
do_not_translate((:-include(_Whatever))) :- !.
do_not_translate((:-multifile _Whatever)) :- !.
do_not_translate((:-new_declaration(_Whatever_1, _Whatever_2))) :- !.
do_not_translate((:-op(_Priority, _Position, _Op_Names))) :- !.


% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% Extract and Transform (Lists).
eat_lists(_Index, [], Invalid, Invalid, Conv_Out, Conv_Out) :- !.	
eat_lists(Index, [Sent_In | Sents_In], Invalid_In, Invalid_Out, Conv_In, Conv_Out) :-
	debug_msg('eat(Index, Sent_In)', (Index, Sent_In)),
	eat(Index, Sent_In, Sent_Out), !,
	debug_msg('eat(Index, Sent_In, Sent_Out)', (Index, Sent_In, Sent_Out)),
	debug_nl,
	eat_lists(Index, Sents_In, Invalid_In, Invalid_Out, [Sent_Out | Conv_In], Conv_Out).
eat_lists(Index, [Sent_In | Sents_In], Invalid_In, Invalid_Out, Conv_In, Conv_Out) :-
	eat_lists(Index, Sents_In, [Sent_In | Invalid_In], Invalid_Out, Conv_In, Conv_Out).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% Unconditional default
eat(1, (:- default(Name/Arity,X)),(Fuzzy_H)) :- 
	!, % If patter matching, backtracking forbiden.
	number(X), % X must be a number.
	number(Arity), % A must be a number.
	nonvar(Name), % Name can not be a variable.

	functor(H, Name, Arity),
	fuzzify_functor(H, 'default_with_no_cond', Fuzzy_H, Fuzzy_Arg_1, Fuzzy_Arg_2),
	Fuzzy_Arg_1 is X, 
	Fuzzy_Arg_2 is 0,
	!. % Backtracking forbidden.

% Conditional default
eat(1, (:- default(Name/Arity,X) => H_Cond_Name/Arity),(Fuzzy_H :- H_Cond)) :-
	!, % If patter matching, backtracking forbiden.
	number(X), % X must be a number.
	number(Arity), % A must be a number.
	nonvar(Name), % Name cannot be a variable.
	nonvar(H_Cond_Name), % Cond_Name cannot be a variable.

	functor(H, Name, Arity),
	fuzzify_functor(H, 'default_with_cond', Fuzzy_H, Fuzzy_Arg_1, Fuzzy_Arg_2),
	Fuzzy_Arg_1 is X, 
	Fuzzy_Arg_2 is 0,

	functor(H_Cond, H_Cond_Name, Arity),
	copy_args(Arity, H_Cond, H),    % Copy args from main functor.
	!. % Backtracking forbidden.

% Fuzzy facts.
eat(1, (Head value X), Fuzzy_Head):-
	!, % If patter matching, backtracking forbiden.
	number(X),                    % X must be a number.

	fuzzify_functor(Head, 'fact', Fuzzy_Head, Fuzzy_Arg_1, Fuzzy_Arg_2),
	Fuzzy_Arg_1 is X,
	Fuzzy_Arg_2 is 1,
	debug_msg('fact',((Head value X) => Fuzzy_Head)),
	!. % Backtracking forbidden.

eat(1, Aggregator_Definition, Aggregator_Def_Translated) :-
	trans_fuzzy_aggregator_def(Aggregator_Definition, Aggregator_Def_Translated), !.

% function definition.
eat(1, (Head :# List), (Fuzzy_H :- Body)) :-
	!, % If patter matching, backtracking forbiden.
	% list(Lista),
	debug_msg('(Head :# List) ', (Head :# List)),

	functor(Head, Name, 0),
	functor(H, Name, 1),
	fuzzify_functor(H, 'function', Fuzzy_H, Fuzzy_Arg_1, Fuzzy_Arg_2),
	Fuzzy_Arg_2 is 1,

	arg(1, Fuzzy_H, X),
	build_straight_lines(X, Fuzzy_Arg_1, List, Body).

% Predicate's type(s) definition.
eat(1, (:- set_prop Name/Arity => Properties_Decl),(Fuzzy_H :- Cls)):-
	!, % If patter matching, backtracking forbiden.
	(
	    (
		number(Arity), % A must be a number.
		nonvar(Name), % Can not be a variable.
		
		functor(H, Name, Arity),
		fuzzify_functor(H, 'type', Fuzzy_H, _Fuzzy_Arg_1, _Fuzzy_Arg_2),
		trans_each_property(Fuzzy_H, Arity, 1, Properties_Decl, Cls)
	    )
	;
	    (
		rfuzzy_error_msg('translate_types', 'Error in', (:- set_prop Name/Arity => Properties_Decl)),
		rfuzzy_error_msg('translate_types', 'Syntax for types is', '(:- set_prop Name/Arity => Predicate/1, ..., Predicate/1)')
	    )
	),
	!, % Backtracking forbidden.
	debug_msg('(:- set_prop Name/Arity => Properties_Decl) ', (:- set_prop Name/Arity => Properties_Decl)).

% crisp predicates (non-facts).
eat(2, Other, Other) :-
	debug_msg('Test-1 if crisp pred', Other),
	nonvar(Other), 
	functor(Other, ':-', 2), !,
	arg(1, Other, Arg_1), 
	nonvar(Arg_1), 
	functor(Arg_1, Name, Arity),
	save_predicate_info('crisp', Name, Arity, Name, Arity).

% crisp facts.
eat(2, Other, Other) :-
	debug_msg('Test-2 if crisp fact', Other),
	nonvar(Other), 
	functor(Other, Name, Arity), 
	not_a_known_predicate_name(Name),	!,
	save_predicate_info('crisp', Name, Arity, Name, Arity).

% rules:
eat(3, (Head :~ Body), (Fuzzy_H :- Fuzzy_Body)):-
	!, % If patter matching, backtracking forbiden.
	debug_nl,
	debug_msg('eat(Head :~ Body) ', (Head :~ Body)),
	(
	    trans_rule(Head, Body, Fuzzy_H, Fuzzy_Body)
	;
	    (
		rfuzzy_error_msg('translate_rule_syntax', 'Error in', (Head :~ Body)),
		rfuzzy_error_msg('translate_rule_syntax', 'Syntax for rules is', '(predicate cred(Op1, Number) :~ Op2(( Body ))'),
		rfuzzy_error_msg('translate_rule_syntax', 'Please note there are 2 parenthesis around the variable Body', ' '),
		!, fail
	    )
	).

% fuzzification:
eat(3, Head, (Fuzzy_H :- Fuzzy_Body)):-
	functor(Head, 'fuzzify', 3),
	!, % If patter matching, backtracking forbiden.
	debug_nl,
	debug_msg('eat(Head) ', (Head)),
	(
	    trans_fuzzification(Head, Fuzzy_H, Fuzzy_Body)
	;
	    (
		rfuzzy_error_msg('fuzzify_syntax', 'Cannot understand syntax for', (Head)),
		rfuzzy_error_msg('fuzzify_syntax', 'Syntax is', 'fuzzify(low_distance/2, distance/2, low_distance_function/2'),
		!, fail
	    )
	).

eat(4, Whatever, rfuzzy_error_msg('translate_syntax', 'failed for', Whatever)) :-
	has_rfuzzy_symbol(Whatever), !.

has_rfuzzy_symbol(( A :~ B )) :- syntax_error(( A :~ B )).
has_rfuzzy_symbol(( A :# B )) :- syntax_error(( A :# B )).
has_rfuzzy_symbol(( A value B )) :- syntax_error(( A value B )).
has_rfuzzy_symbol(( :- set_prop A )) :- syntax_error(( :- set_prop A )).
has_rfuzzy_symbol(( :- default(A,B) )) :- syntax_error(( :- default(A,B) )).
has_rfuzzy_symbol(( :- default(A,B) => C )) :- syntax_error(( :- default(A,B) => C )).

syntax_error(Whatever) :-
	rfuzzy_error_msg('translate_rule_syntax', 'Not recognized syntax in: ', Whatever),
	rfuzzy_error_msg('translate_rule_syntax', 'Use \"rfuzzy_error(Whatever)\" to see which predicates have syntax errors', '').

not_a_known_predicate_name(Name) :-
	Name \== ':-',
	Name \== ':~',
	Name \== ':#',
	Name \== 'value',
	Name \== 'fuzzify'.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

trans_rule(Head, Body, Fuzzy_Head, (Fuzzy_Body, Fuzzy_Operations)) :-
	extract_credibility(Head, H, Op1, Credibility),
	debug_nl,
	debug_msg('trans_rule(H, Op1, Credibility, Body) ', (trans_rule(H, Op1, Credibility, Body))),
	nonvar(H), nonvar(Credibility), nonvar(Body),

	% Change head's name.
	fuzzify_functor(H, 'rule', Fuzzy_Head, Fuzzy_Arg_1, Fuzzy_Arg_2),

	% Translate all predicates in the body.
	extract_op2(Body, Op2, Tmp_Body),

	debug_msg('add_auxiliar_parameters(Tmp_Body)',Tmp_Body),
	add_auxiliar_parameters(Tmp_Body, Fuzzy_Body, [], Fuzzy_Vars_1, [], Fuzzy_Vars_2),

	% Add the capability to compute the rule's truth value.
	retrieve_aggregator_info(Op1, Operator_1),
	retrieve_aggregator_info(Op2, Operator_2),
	Fuzzy_Operations = (
			       inject(Fuzzy_Vars_1,  Operator_2, Aggregated_V),
			       Mu .>=. 0, Mu .=<. 1,
			       inject([Aggregated_V, Credibility], Operator_1, Fuzzy_Arg_1),
			       Fuzzy_Arg_1  .>=. 0, Fuzzy_Arg_1  .=<. 1,
			       inject(Fuzzy_Vars_2, 'mean', Fuzzy_Arg_2)
	      ).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% aggregator definition:
trans_fuzzy_aggregator_def((:- aggr A <# I ## M #> F ),(:- op(1190,fx,A))):-
	save_aggregator(faggr(A,I,M,F)), !.

trans_fuzzy_aggregator_def((:- aggr A ## M #> F ),(:- op(1190,fx,A))):-
	save_aggregator(faggr(A,id,M,F)), !.

trans_fuzzy_aggregator_def((:- aggr A <# I ## M ),(:- op(1190,fx,A))):-
	save_aggregator(faggr(A,I,M,id)), !.

trans_fuzzy_aggregator_def((:- aggr A <# I ),(:- op(1190,fx,A))):-
	save_aggregator(faggr(A,I,A,id)), !.

trans_fuzzy_aggregator_def((:- aggr A #> F ),(:- op(1190,fx,A))):-
	save_aggregator(faggr(A,id,A,F)), !.

trans_fuzzy_aggregator_def((:- aggr A ## M ),(:- op(1190,fx,A))):-
	save_aggregator(faggr(A,id,M,id)), !.

trans_fuzzy_aggregator_def((:- aggr A),(:- op(1190,fx,A))):-
	save_aggregator(faggr(A,id,A,id)), !.

save_aggregator(Aggregator) :-
        retract_fact(aggregators(List)), !,
	assertz_fact(aggregators([Aggregator|List])).
save_aggregator(Aggregator) :-
	assertz_fact(aggregators([Aggregator])).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% extract credibility
extract_credibility((H cred (Op, D)), H, Op, D) :- !.
extract_credibility(H, H, 'prod', 1) :- !.

extract_op2(Body, Op2, Tmp_Body) :-
	functor(Body, Op2, 1),
	arg(1, Body, Tmp_Body).
extract_op2(Body, _Op2, 'fail') :-
	debug_msg('Cannot understand syntax for', (Body)).	

retrieve_aggregator_info(Op, Operator) :-
%	faggr(Op1, _IAny,  Operator, _FAny),
	nonvar(Op),
	aggregators(Aggregators),
	debug_msg('retrieve_aggregator_info :: Op', Op),
	debug_msg('retrieve_aggregator_info :: Aggregators', Aggregators),
	member(faggr(Op, _IAny,  Operator, _FAny), Aggregators), !.
retrieve_aggregator_info(Op, Op) :-
	rfuzzy_rt:defined_aggregators(Aggregators), !,
	member(Op, Aggregators).
retrieve_aggregator_info(Op, 'id') :-
	rfuzzy_error_msg('retrieve_aggregator_info', Op, ' is not a valid agregator operator.').


add_auxiliar_parameters(Body, (Fuzzy_Body_1, Fuzzy_Body_2), Vars_1_In, Vars_1_Out, Vars_2_In, Vars_2_Out) :-
	functor(Body, ',', 2), !,
	arg(1, Body, Body_1),
	arg(2, Body, Body_2),
	add_auxiliar_parameters(Body_1, Fuzzy_Body_1, Vars_1_In, Vars_1_Tmp, Vars_2_In, Vars_2_Tmp),
	add_auxiliar_parameters(Body_2, Fuzzy_Body_2, Vars_1_Tmp, Vars_1_Out, Vars_2_Tmp, Vars_2_Out).

% add_auxiliar_parameters(H, Argument, Ret_Cls)
add_auxiliar_parameters(Body, Fuzzy_Body, Vars_1, [V|Vars_1], Vars_2, [C|Vars_2]) :-
	functor(Body, Body_Name, Arity),
	real_name_and_arity(Body_Name, Arity, Fuzzy_Body_Name),
	V_Arity is Arity +1,
	C_Arity is Arity +2,
	functor(Fuzzy_Body, Fuzzy_Body_Name, C_Arity),
	copy_args(Arity, Fuzzy_Body, Body),
	arg(V_Arity, Fuzzy_Body, V),
	arg(C_Arity, Fuzzy_Body, C).

add_auxiliar_parameters(Body, Body, Vars_1, Vars_1, Vars_2, Vars_2) :-
	debug_msg('ERROR: add_auxiliar_parameters(Body, Cls, Vars) ', (add_auxiliar_parameters(Body,
	Vars_1, Vars_2))),
	!, fail.

real_name_and_arity(Body_Name, Arity, Body_Name) :-
	retrieve_predicate_info('crisp', Body_Name, Arity, Body_Name, _Fuzzy_Arity), !.

real_name_and_arity(Body_Name, _Arity, Fuzzy_Body_Name) :-
	change_name('auxiliar', Body_Name, Fuzzy_Body_Name).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

trans_each_property(H, Arity, Actual, Current_P/1, Current_PF) :-
	debug_msg('trans_each_property', trans_each_property(H, Arity, Actual) ),
	Actual = Arity, !, % Security conditions.
	trans_each_property_aux(H, Actual, Current_P, Current_PF).

trans_each_property(H, Arity, Actual, (Current_P/1, More_P), (Current_PF, More_PF)) :-
	Actual < Arity, !, 
	debug_msg('trans_each_property', trans_each_property(H, Arity, Actual) ),
	trans_each_property_aux(H, Actual, Current_P, Current_PF),
	NewActual is Actual + 1, % Next values.
	trans_each_property(H, Arity, NewActual, More_P, More_PF),
	!. % Backtracking not allowed here.

trans_each_property_aux(H, Actual, Current_P, Current_PF) :-

	functor(Current_PF, Current_P, 1), % Build functor.
	arg(1, Current_PF, X),       % Argument of functor is X.
	arg(Actual, H, X). % Unify with Argument of functor.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

build_straight_lines(X, V, [(X1,V1),(X2,V2)], (Point1 ; Line ; Point2)) :-
	debug_msg('build_straight_lines', (build_straight_lines(X, V, [(X1,V1),(X2,V2)], (Point1, Line, Point2)))),
	build_point(X, V, X1, V1, Point1),
	build_line(X, V, X1, V1, X2, V2, Line),
	build_point(X, V, X2, V2, Point2).

build_straight_lines(X, V, [(X1,V1),(X2,V2)|List], (Point ; Line ; More)) :-
	debug_msg('build_straight_lines', (build_straight_lines(X, V, [(X1,V1),(X2,V2)|List], (Point, Line, More)))),
	build_point(X, V, X1, V1, Point),
	build_line(X, V, X1, V1, X2, V2, Line),
	build_straight_lines(X, V, [(X2,V2)|List], More).

build_point(X, V, X1, V1, (X .=. X1, V .=. V1)) :-
	debug_msg('build_point', build_point(X, V, X, V, (H :- (H :- X1 .=. X, V1 .=. V)))).

build_line(X, V, X1, V1, X2, V2, (X .>. X1, X .<. X2, Calculate_V)) :-
	debug_msg('build_line', (build_line(X, V, X1, V1, X2, V2, (X .>. X1, X .<. X2, Calculate_V)))),

	number(X1), number(X2),
	number(V1), number(V2),
	X1 < X2, 

	!, % Backtracking is not allowed here.
	evaluate_V(X, V, X1, V1, X2, V2, Calculate_V).

evaluate_V(_X, V, _X1, Vf, _X2, Vf, (V .=. Vf)) :- !.

evaluate_V(X, V, X1, V1, X2, V2, (Pend .=. ((V2-V1)/(X2-X1)), V .=. V1+Pend*(X-X1))) :-
	X2 - X1 > 0,
	V1 \= V2.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

trans_fuzzification(Head, Fuzzy_H, (Crisp_Predicate, Auxiliar_Fuzzy_Function)) :-
	functor(Head, 'fuzzify', 3),
	arg(1, Head, Fuzzy_Head_Name/2),
	arg(2, Head, Crisp_Predicate_Name/2),
	arg(3, Head, Fuzzy_Function_Name/2),

	test_predicate_has_been_defined('crisp', Crisp_Predicate_Name, 2),
	test_predicate_has_been_defined('function', Fuzzy_Function_Name, 3), % Here arity is 3
	functor(H, Fuzzy_Head_Name, 1),
	fuzzify_functor(H, 'fuzzification', Fuzzy_H, Fuzzy_Arg_1, Fuzzy_Arg_2),

	% We need to do here as in other translations, so 
	% it generates aux and main predicates for fuzzifications too.
	functor(Crisp_Predicate, Crisp_Predicate_Name, 2),
	change_name('auxiliar', Fuzzy_Function_Name, Auxiliar_Fuzzy_Function_Name),
	functor(Auxiliar_Fuzzy_Function, Auxiliar_Fuzzy_Function_Name, 3),

	arg(1, Fuzzy_H, Input),
	arg(1, Crisp_Predicate, Input),
	arg(2, Crisp_Predicate, Crisp_Value),
	arg(1, Auxiliar_Fuzzy_Function, Crisp_Value),
	arg(2, Auxiliar_Fuzzy_Function, Fuzzy_Arg_1),
	arg(3, Auxiliar_Fuzzy_Function, Fuzzy_Arg_2),

	!.

test_predicate_has_been_defined(Kind, Name, FuzzyArity) :-
	% retrieve_predicate_info(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity)
	retrieve_predicate_info(Kind, Name, _Arity, _FuzzyName, FuzzyArity), 
	% rfuzzy_predicate_info_contents(Pred_Info, 'defined', Name, Arity, Name, Arity),
	!.
test_predicate_has_been_defined(Kind, Name, FuzzyArity) :-
	rfuzzy_warning_msg('fuzzify: Cannot find predicate ', Kind, (Name/FuzzyArity)),
	retrieve_predicate_info(Kind_A, Name_A, Arity_A, _FuzzyName_A, FuzzyArity_A), 
	debug_msg('retrieve_predicate_info(Kind, Name, _Arity, _FuzzyName, FuzzyArity)', 
	retrieve_predicate_info(Kind_A, Name_A, Arity_A, _FuzzyName_A, FuzzyArity_A)), 
	fail, !.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

save_predicate_info(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity) :-
	save_predicate_info_aux(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity),
	save_predicate_info_aux('defined', Name, Arity, Name, Arity), % Predicate MUST be defined.
	debug_msg('save_predicate_info out', save_predicate_info(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity)).

save_predicate_info_aux(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity) :-
	rfuzzy_predicate_info_contents(Pred_Info, Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity),
	retract_fact(Pred_Info), !, % Retract last
	assertz_fact(Pred_Info).
save_predicate_info_aux(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity) :-
	rfuzzy_predicate_info_contents(Pred_Info, Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity),
	assertz_fact(Pred_Info).

retrieve_predicate_info(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity) :-
	rfuzzy_predicate_info(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity).

retrieve_all_predicate_info(Kind, Retrieved) :-
	findall((rfuzzy_predicate_info(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity)),
	(retract_fact(rfuzzy_predicate_info(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity))), Retrieved),
	 !.

remove_predicate_info(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity) :-
	rfuzzy_predicate_info_contents(Pred_Info, Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity),
	retract_fact(Pred_Info), !. % Retract 

rfuzzy_predicate_info_contents(rfuzzy_predicate_info(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity), 
	Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity) :- !.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

fuzzify_functor(H, Preffix, Fuzzy_H, Fuzzy_Arg_1, Fuzzy_Arg_2) :-
	functor(H, Name, Arity),
	Fuzzy_Arity_1 is Arity + 1, % For truth value.
	Fuzzy_Arity_2 is Fuzzy_Arity_1 + 1, % For preference.
	change_name(Preffix, Name, Fuzzy_Name), % Change name
	save_predicate_info(Preffix, Name, Arity, Fuzzy_Name, Fuzzy_Arity_2),
	functor(Fuzzy_H, Fuzzy_Name, Fuzzy_Arity_2),
	copy_args(Arity, Fuzzy_H, H),
	arg(Fuzzy_Arity_1, Fuzzy_H, Fuzzy_Arg_1),
	arg(Fuzzy_Arity_2, Fuzzy_H, Fuzzy_Arg_2).

change_name(Prefix, Input, Output) :-
	atom(Input),
	translate_prefix(Prefix, Real_Prefix),
	atom_codes(Input, Input_Chars),
	append_local(Real_Prefix, Input_Chars, Output_Chars),
	atom_codes(Output, Output_Chars), 
	atom(Output), !.
%	debug_msg('change_name', change_name(Prefix, Input, Output)).

append_local([], N2, N2).
append_local([Elto|N1], N2, [Elto|Res]) :-
	append_local(N1, N2, Res).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

translate_prefix('type', "rfuzzy_type_").
translate_prefix('default_with_no_cond', "rfuzzy_default_with_no_cond_").
translate_prefix('default_with_cond', "rfuzzy_default_with_cond_").
translate_prefix('fact', "rfuzzy_fact_").
translate_prefix('rule', "rfuzzy_rule_").
translate_prefix('function', "rfuzzy_function_").
translate_prefix('fuzzification', "rfuzzy_fuzzification_").
translate_prefix('auxiliar', "rfuzzy_aux_").
translate_prefix(_X, "rfuzzy_error_error_error_").

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

build_auxiliary_clauses([], []) :- !.
build_auxiliary_clauses([Def_Pred|Def_Preds], [Pred_Main, Pred_Aux | Clauses]) :-
	debug_msg('build_auxiliary_clause(Def_Pred, Pred_Main, Pred_Aux)', (Def_Pred, Pred_Main, Pred_Aux)),
	build_auxiliary_clause(Def_Pred, Pred_Main, Pred_Aux),
	build_auxiliary_clauses(Def_Preds, Clauses).

% For crisp predicates we only generate Aux :- Crisp.
build_auxiliary_clause(Pred_Info, Fuzzy_Cl_Main, Fuzzy_Cl_Aux) :-
	rfuzzy_predicate_info_contents(Pred_Info, 'defined', Name, Arity, Name, Arity),
	retrieve_predicate_info('crisp', Name, Arity, Name, Arity), !, 

	change_name('auxiliar', Name, Fuzzy_Pred_Aux_Name),
	functor(Fuzzy_Pred_Aux, Fuzzy_Pred_Aux_Name, Arity),
        functor(Pred_Main, Name, Arity),
	copy_args(Arity, Pred_Main, Fuzzy_Pred_Aux),

	Fuzzy_Cl_Main = (Fuzzy_Pred_Aux :- Pred_Main),
	Fuzzy_Cl_Aux = (Fuzzy_Pred_Aux :- fail).

build_auxiliary_clause(Pred_Info, Fuzzy_Cl_Main, Fuzzy_Cl_Aux) :-
	rfuzzy_predicate_info_contents(Pred_Info, 'defined', Name, Arity, Name, Arity),

	% Build MAIN functors.
	Main_Pred_Fuzzy_Arity is Arity + 1,
	Aux_Pred_Fuzzy_Arity is Arity +2,
	functor(Fuzzy_Pred_Main, Name, Main_Pred_Fuzzy_Arity),

	change_name('auxiliar', Name, Fuzzy_Pred_Aux_Name),
	functor(Fuzzy_Pred_Aux, Fuzzy_Pred_Aux_Name, Aux_Pred_Fuzzy_Arity),
	copy_args(Arity, Fuzzy_Pred_Main, Fuzzy_Pred_Aux),
	
	build_functors(Name, Arity, 'type', 'true', Fuzzy_Pred_Aux, Fuzzy_Pred_Types),
	build_functors(Name, Arity, 'fact', 'fail', Fuzzy_Pred_Aux, Fuzzy_Pred_Fact),
	build_functors(Name, Arity, 'function', 'fail', Fuzzy_Pred_Aux, Fuzzy_Pred_Function),
	build_functors(Name, Arity, 'fuzzification', 'fail', Fuzzy_Pred_Aux, Fuzzy_Pred_Fuzzification),
	build_functors(Name, Arity, 'rule', 'fail', Fuzzy_Pred_Aux, Fuzzy_Pred_Rule),
	build_functors(Name, Arity, 'default_with_cond', 'fail', Fuzzy_Pred_Aux, Fuzzy_Pred_Default_With_Cond),
	build_functors(Name, Arity, 'default_with_no_cond', 'fail', Fuzzy_Pred_Aux, Fuzzy_Pred_Default_Without_Cond),

	% Argument's places and values.
	Arity_Fuzzy_Arg_1 is Arity + 1,
	% Arity_Fuzzy_Arg_2 is Arity + 2,
	arg(Arity_Fuzzy_Arg_1, Fuzzy_Pred_Main, Fuzzy_Arg_1),
	% arg(Arity_Fuzzy_Arg_2, Fuzzy_Pred_Main, Fuzzy_Arg_2),

	(Fuzzy_Cl_Main = (
			     (
				 Fuzzy_Pred_Main :- (
							findall(Fuzzy_Pred_Aux, Fuzzy_Pred_Aux, Results), 
							supreme(Results, Result),
							copy_args(Arity, Fuzzy_Pred_Main, Result),
							arg(Arity_Fuzzy_Arg_1, Result, Fuzzy_Arg_1_Tmp),
							Fuzzy_Arg_1 .>=. Fuzzy_Arg_1_Tmp
						    )		     
			     ) % Main Fuzzy Pred
			 )
	),
	(Fuzzy_Cl_Aux = ( 
			    ( 
				Fuzzy_Pred_Aux :- ( 
						      (   Fuzzy_Pred_Fact ; 
							  Fuzzy_Pred_Function ;
							  Fuzzy_Pred_Fuzzification ;
							  Fuzzy_Pred_Rule ;
							  Fuzzy_Pred_Default_With_Cond ; 
							  Fuzzy_Pred_Default_Without_Cond
						      ),
						      Fuzzy_Pred_Types
						  )
			    )
			)
	).

build_auxiliary_clause(Pred_Info, (true), (true)) :-
	rfuzzy_warning_msg(Pred_Info, 'it is impossible to build the auxiliary clause', ' ').
	
build_functors(Name, Arity, Kind, _On_Error, Functor_In, Functor) :-

	% Do we have saved facts ??
	remove_predicate_info(Kind, Name, Arity, Fuzzy_Name, Fuzzy_Arity),
	!, % Backtracking not allowed.

	% Main functor.
	functor(Functor, Fuzzy_Name, Fuzzy_Arity),           % Create functor
	copy_args(Fuzzy_Arity, Functor_In, Functor).  % Copy arguments.

build_functors(_Name, _Arity, Kind, On_Error, _Functor_In, On_Error) :- 
	(   % Do not show warnings if the following are missing.
	    Kind == 'fact' ;
	    Kind == 'function' ;
	    Kind == 'fuzzification' ;
	    Kind == 'rule' ;
	    Kind == 'default_with_cond'
	), !.

build_functors(Name, _Arity, Kind, On_Error, _Functor_In, On_Error) :- !,
	rfuzzy_warning_msg(Name, Kind, 'has not been defined.').

%build_fail_functor(H) :-
%	functor(H, 'fail', 0).    % Create functor


% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

:- module(cneg_diseq, 
	[
	    equality/3, disequality/3,
	    diseq_uqv/3, eq_uqv/3, 
	    diseq_eqv/3, eq_eqv/3, 
	    cneg_diseq_eqv_uqv/5, cneg_eq_eqv_uqv/5,
	    portray_attributes_in_term/1
	], 
	[assertions]).

:- use_module(cneg_aux,_).

%:- use_package(debug).
%:- use_package(trace).
%:- use_package(nodebug).

% For Ciao Prolog:
:- multifile 
        verify_attribute/2,
        combine_attributes/2,
	portray_attribute/2,
	portray/1.

:- comment(title, "Disequality Management Library").

:- comment(author, "V@'{i}ctor Pablos Ceruelo").

:- comment(summary, "This module is capable of evaluating any disequality between terms 
	generated by the program transformation.").


% For XSB:
%:- import put_attr/3, get_attr/3, del_attr/2,
%	install_verify_attribute_handler/4,
%	install_attribute_portray_hook/3 % -- Do not use !!!
%	install_constraint_portray_hook/4
%	from machine.

% For XSB to verify attributes.
% :- install verify attribute handler(+Mod, −AttrValue, −Target, +Handler).
% :- install_verify_attribute_handler(dist, AttrValue, Target, verify_attribute(AttrValue, Target)).

% For XSB to portray results.
%:- install_constraint_portray_hook(dist,Contents,Vars,portray_constraints(Vars, Contents)).

% For XSB to portray results (at a very low level) :: Do not use !!!
% :- install attribute portray hook(Module,Attribute,Handler)
% :- install_attribute_portray_hook(dist,Attribute,portray_attribute(Attribute)).


% Local predicates used to easy migration between prologs. 
remove_attribute_local(Var) :- 
	debug_msg_aux(1, '', '% cneg :: '),
	debug_msg_aux(1, 'remove_attribute_local :: Var :: ', Var),
	detach_attribute(Var),
	debug_msg_aux(1, '  -->> Var :: ', Var),
	debug_msg_nl(1).
% XSB:	del_attr(Var, dist).

get_attribute_local(Var, Attribute) :-
	get_attribute(Var, Attribute).
% XSB:	get_attr(Var, dist, Attribute),
%	debug_msg(0, 'get_attribute_local :: (Var, Attribute)', (Var, Attribute)).

put_attribute_local(Var, Attribute) :-
	debug_msg_aux(1, '', '% cneg :: '),
	debug_msg_aux(1, 'put_attribute_local :: Attribute :: ', Attribute),
	debug_msg_aux(1, '  Var :: ', Var), 
%	get_attribute_if_any(Var), !,
	attach_attribute(Var, Attribute),
	debug_msg_aux(1, '  -->> Var :: ', Var),
	debug_msg_nl(1).
%	put_attr(Var, dist, Attribute).

%get_attribute_if_any(Var) :-
%	debug_msg(0, 'Testing if var has any attribute. Var: '),
%	debug_msg(0, Var),
%	get_attribute_local(Var, _Attribute), !.
%get_attribute_if_any(Var) :-
%	debug_msg(0, 'Testing if var has any attribute. Var: '),
%	debug_msg(0, Var),
%	debug_msg(0, ' has NO attribute').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Attributes contents are encapsulated via the following structure.

%:- dynamic var_attribute/2.
attribute_contents(var_attribute(Target, Disequalities, UQV), Target, Disequalities, UQV).
disequality_contents(disequality(Diseq_1, Diseq_2, EQ_Vars, UQ_Vars), Diseq_1, Diseq_2, EQ_Vars, UQ_Vars).
equality_contents(equality(T1, T2), T1, T2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% FROM: ../ciao/ciao-1.13/library/clpqr-common/clp_attr.pl
%
% :- multifile portray_attribute/2, portray/1.
% 
% portray_attribute(float(F),_) :- print(F).
% portray_attribute(term_wrap(_,T), _) :-
%         normalize(T, I, H),
%         H = [],                   % only if ground
%         print(I).
%
% portray(rat(N,D)) :- print(N/D).
% portray(eqn_var(Self,A,B,R,Nl)) :- print(eqn_var(Self,A,B,R,Nl)).


portray_attribute(Attr, Var) :-
	debug_msg(2, 'portray_attribute :: (Attr, Var)', (Attr, Var)).

portray(Attribute) :-
	attribute_contents(Attribute, _Target, Disequalities, UQV), !,
	portray_disequalities(Disequalities,UQV).

portray(Anything) :- 
	debug_msg_aux(2, '', Anything).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

portray_attributes_in_term(T) :-
	cneg_aux:varsbag(T, [], [], Variables),
	debug_msg(0, 'Attributes for the variables in term', T),
	portray_attributes_in_variables(Variables).

portray_attributes_in_variables([]) :- !.
portray_attributes_in_variables([Var|Vars]) :-
	portray_attributes_in_variable(Var),
	portray_attributes_in_variables(Vars).

portray_attributes_in_variable(Var) :-
	get_attribute_local(Var, Attribute),
	debug_msg_logo(2),
	debug_msg_aux(2, 'variable :: ', Var), 
	debug_msg_aux(2, ' has attribute', ' :: '),
	portray(Attribute),
	debug_msg_nl(2).
portray_attributes_in_variable(Var) :-
	debug_msg_logo(2),
	debug_msg_aux(2, 'variable :: ', Var), 
	debug_msg_aux(2, ' has NO attribute', ' '),
	debug_msg_nl(2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

portray_disequalities(Disequalities, UQV) :-
	portray_disequalities_aux_1(Disequalities),
	portray_disequalities_aux_3(UQV).

portray_disequalities_aux_1([]) :- !.
portray_disequalities_aux_1([Diseq_1]) :- !,
	portray_disequalities_aux_2(Diseq_1).
portray_disequalities_aux_1([Diseq_1|Diseqs]) :- !,
	portray_disequalities_aux_2(Diseq_1), 
	debug_msg_aux(2, ' AND ', ''),
	portray_disequalities_aux_1(Diseqs).

portray_disequalities_aux_2(Diseq) :-
	disequality_contents(Diseq, Diseq_1, Diseq_2, _EQ_Vars, _UQ_Vars),
	debug_msg_aux(2, '[ ', Diseq_1),
	debug_msg_aux(2, ' =/= ', Diseq_2),
	debug_msg_aux(2, '', ' ]').

portray_disequalities_aux_3([]).
portray_disequalities_aux_3(UnivVars) :-
	UnivVars \== [], !,
	debug_msg_aux(2, ', Universally quantified: [', ''), 
	portray_disequalities_aux_4(UnivVars),
	debug_msg_aux(2, '', ' ]').

portray_disequalities_aux_4([]) :- !.
portray_disequalities_aux_4([FreeVar | FreeVars]) :-
	debug_msg_aux(2, ' ', FreeVar),
	portray_disequalities_aux_4(FreeVars).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% CONSTRAINT VERIFICATION %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

verify_attribute(Attribute, Target) :-
	debug_msg(1, 'verify_attribute :: (Attribute, Target)', (Attribute, Target)), 
	verify_attribute_aux(Attribute, Target).

verify_attribute_aux(Attribute, NewTarget) :-
	attribute_contents(Attribute, OldTarget, Disequalities, _UQV), 
	terms_are_equal(NewTarget, OldTarget), !, % If not, a substitution is needed.
	remove_attribute_local(OldTarget), 
	test_and_update_vars_attributes(Disequalities, 'fail', 'true').

% Only for Ciao prolog 
verify_attribute_aux(Attribute, NewTarget) :-
	attribute_contents(Attribute, OldTarget, Diseqs, _Old_UQV), 
	NewTarget \== OldTarget, % A substitution is needed.
	remove_attribute_local(OldTarget), 
	get_and_remove_eqv_and_uqv_from_diseqs(Diseqs, [], EQV, [], UQV, _Unused_Ts),
	perform_substitutions([(OldTarget, NewTarget)], EQV, UQV),
	test_and_update_vars_attributes(Diseqs, 'fail', 'true').

combine_attributes(Attribute_Var_1, Attribute_Var_2) :-
	debug_msg(1, 'combine_attributes :: Attr_Var1 :: (Attr, Target, Diseqs, UQV)', Attribute_Var_1),
	debug_msg(1, 'combine_attributes :: Attr_Var2 :: (Attr, Target, Diseqs, UQV)', Attribute_Var_2),
	attribute_contents(Attribute_Var_1, OldTarget_Var_1, Diseqs_Var_1, _UQV_Var_1), !,
	attribute_contents(Attribute_Var_2, OldTarget_Var_2, Diseqs_Var_2, _UQV_Var_2), !,
	remove_attribute_local(OldTarget_Var_1), 
	remove_attribute_local(OldTarget_Var_2), 

	cneg_aux:append(Diseqs_Var_1, Diseqs_Var_2, Diseqs),
	get_and_remove_eqv_and_uqv_from_diseqs(Diseqs, [], EQV, [], UQV, _Unused_Ts),
	perform_substitutions([(OldTarget_Var_1, OldTarget_Var_2)], EQV, UQV),
	
	debug_msg(1, 'test_and_update_vars_attributes :: (Disequalities)', (Diseqs)), 
	test_and_update_vars_attributes(Diseqs, 'fail', 'true').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

perform_substitutions([], _EQV, _UQV) :- !.
perform_substitutions([(OldTarget, NewTarget) | MoreSubst], EQV, UQV) :-
	varsbag(UQV, [], [], UQV_Aux), !, % Only vars, please.
	varsbag(EQV, UQV_Aux, [], EQV_Aux), !, % Only vars, please.
	varsbag((OldTarget, NewTarget), [], [], Vars_Targets), !,
	varsbag_intersection(Vars_Targets, UQV_Aux, Intersection), !,
	(
	    (
		Intersection == [], !,
		OldTarget = NewTarget,
		perform_substitutions(MoreSubst, EQV_Aux, UQV_Aux)
	    )
	;
	    (
		Intersection \== [], !,
		debug_msg(1, 'perform_substitutions :: Impossible :: (OldTarget, NewTarget, EQV, UQV)', (OldTarget, NewTarget, EQV_Aux, UQV_Aux)),
		!, fail
	    )
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_and_remove_eqv_and_uqv_from_diseqs([], EQV_In, EQV_In, UQV_In, UQV_In, []) :- !.
get_and_remove_eqv_and_uqv_from_diseqs([Diseq | Diseqs], EQV_In, EQV_Out, UQV_In, UQV_Out, [(T1, T2) | More_Ts]) :-
	disequality_contents(Diseq, T1, T2, Diseq_EQV, Diseq_UQV),
	varsbag(Diseq_EQV, [], EQV_In, EQV_Aux),
	varsbag(Diseq_UQV, [], UQV_In, UQV_Aux),
	get_and_remove_eqv_and_uqv_from_diseqs(Diseqs, EQV_Aux, EQV_Out, UQV_Aux, UQV_Out, More_Ts).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% An~ade la formula al atributo de las variables implicadas
% Por q tendriamos q tener en cuenta otros atributos?
% Como cada uno tiene su manejador, tratar de mezclar los atributos no aporta nada.

test_and_update_vars_attributes(New_Diseqs, Can_Fail, Result) :-
%	debug_msg(1, 'test_and_update_vars_attributes :: New_Diseqs', New_Diseqs),  

	cneg_aux:varsbag(New_Diseqs, [], [], New_Diseq_Vars), !,
	retrieve_affected_disequalities(New_Diseq_Vars, [], [], Old_Diseqs), !,
%	debug_msg(1, 'test_and_update_vars_attributes :: Old_Diseqs', Old_Diseqs),

	% Get which variables are EQV so we distinguish them from UQV.
	get_and_remove_eqv_and_uqv_from_diseqs(New_Diseqs, [], EQV_Tmp, [], UQV_Tmp, New_Diseqs_Aux),
	get_and_remove_eqv_and_uqv_from_diseqs(Old_Diseqs, EQV_Tmp, All_EQV_Aux, UQV_Tmp, All_UQV, Old_Diseqs_Aux),
	varsbag(All_EQV_Aux, All_UQV, [], All_EQV), % The sets must be exclusive.
%	debug_msg(1, 'test_and_update_vars_attributes :: (All_EQV, All_UQV)', (All_EQV, All_UQV)),

	% At first we check that the new disequalities can be added to the old ones.
	simplify_disequations(New_Diseqs_Aux, [], Simplified_Diseqs_1, All_EQV, Can_Fail, Result),
	% At last we check that the old disequalities are still valid.
	simplify_disequations(Old_Diseqs_Aux, [], Simplified_Diseqs_2, All_EQV, 'fail', 'true'),

	% Now we aggregate all of them.
	accumulate_disequations(Simplified_Diseqs_1, Simplified_Diseqs_2, Simplified_Diseqs),

%	debug_msg(1, 'test_and_update_vars_attributes :: Simplified_Diseqs', Simplified_Diseqs),
	restore_attributes(Simplified_Diseqs, All_EQV, All_UQV).

retrieve_affected_disequalities([], _Visited_Vars, Diseq_Acc_Out, Diseq_Acc_Out) :- !. % Loop over vars list.
retrieve_affected_disequalities([Var|Vars], Visited_Vars, Diseq_Acc_In, Diseq_Acc_Out):- 
	var(Var), % It cannot be other things ...
	get_attribute_local(Var, Attribute), !,
	attribute_contents(Attribute, Var, Disequalities, _UQV), 
	remove_attribute_local(Var), 

	cneg_aux:varsbag(Disequalities, [Var|Visited_Vars], Vars, New_Vars),
	accumulate_disequations(Disequalities, Diseq_Acc_In, Diseq_Acc_Aux),
        retrieve_affected_disequalities(New_Vars, [Var|Visited_Vars], Diseq_Acc_Aux, Diseq_Acc_Out).

retrieve_affected_disequalities([Var|Vars_In], Visited_Vars, Diseq_Acc_In, Diseq_Acc_Out) :- 
        retrieve_affected_disequalities(Vars_In, [Var|Visited_Vars], Diseq_Acc_In, Diseq_Acc_Out).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

restore_attributes(Diseqs_In, All_EQV, All_UQV) :- 
	cneg_aux:varsbag(All_EQV, [], [], EQV),
	cneg_aux:varsbag(All_UQV, EQV, [], UQV), % Exhaustive sets, please.
	prepare_diseqs_for_restore(Diseqs_In, Diseqs, EQV, UQV, [], Affected_Vars),
%	debug_msg(1, 'restore_attributes_vars(Affected_Vars, Diseqs)', (Affected_Vars, Diseqs)),
	restore_attributes_vars(Affected_Vars, Diseqs).

prepare_diseqs_for_restore([], [], _EQV, _UQV, Affected_Vars, Affected_Vars) :- !.
prepare_diseqs_for_restore([(T1, T2) | Diseqs_In], [(Diseq, Vars) | Diseqs_Out], EQV, UQV, Aff_Vars_In, Aff_Vars_Out) :-
	cneg_aux:varsbag((T1, T2), [], [], Vars), 
	cneg_aux:varsbag(Vars, [], Aff_Vars_In, Aff_Vars_Aux), !,
	disequality_contents(Diseq, T1, T2, EQV, UQV),
	prepare_diseqs_for_restore(Diseqs_In, Diseqs_Out, EQV, UQV, Aff_Vars_Aux, Aff_Vars_Out).

restore_attributes_vars([], _Diseqs) :- !.
restore_attributes_vars([Var | Affected_Vars], Diseqs) :-
	affected_diseqs(Var, Diseqs, Affected_Diseqs, [], Diseqs_UQV),
	restore_attributes_var(Var, Affected_Diseqs, Diseqs_UQV),
	restore_attributes_vars(Affected_Vars, Diseqs).

affected_diseqs(_Var, [], [], Diseqs_UQV_In, Diseqs_UQV_In) :- !.
affected_diseqs(Var, [(Diseq, Diseq_Vars) | Diseqs], [Diseq | Affected_Diseqs], Diseqs_UQV_In, Diseqs_UQV_Out) :-
	cneg_aux:memberchk(Var, Diseq_Vars), !,
	disequality_contents(Diseq, T1, T2, EQV, _Unused_UQV),
	cneg_aux:varsbag((T1, T2), EQV, Diseqs_UQV_In, Diseqs_UQV_Aux), !,
	affected_diseqs(Var, Diseqs, Affected_Diseqs, Diseqs_UQV_Aux, Diseqs_UQV_Out).
affected_diseqs(Var, [_Diseq | Diseqs], Affected_Diseqs, Diseqs_UQV_In, Diseqs_UQV_Out) :-
	affected_diseqs(Var, Diseqs, Affected_Diseqs, Diseqs_UQV_In, Diseqs_UQV_Out).

restore_attributes_var(Var, _Diseqs, _Diseqs_UQV) :-
	var(Var),
	get_attribute_local(Var, Attribute), !,
	debug_msg_nl(0),
	debug_msg(0, 'ERROR: var has an attribute. Attribute: ', Attribute),
	debug_msg_nl(0),
	fail.

restore_attributes_var(Var, Diseqs, _Diseqs_UQV) :-
	var(Var),
	Diseqs == [],
	!, % We do not want empty attributes.
	fail.

restore_attributes_var(Var, Diseqs, Diseqs_UQV) :-
	Diseqs \== [],
	var(Var),

	attribute_contents(Attribute, Var, Diseqs, Diseqs_UQV),
	put_attribute_local(Var, Attribute).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

accumulate_disequations(Diseqs_In, Diseqs_Acc, Diseqs_Out) :-
	debug_msg(0, 'accumulate_disequations :: Diseqs_In', Diseqs_In),
	debug_msg(0, 'accumulate_disequations :: Diseqs_Acc', Diseqs_Acc),
	accumulate_disequations_aux(Diseqs_In, Diseqs_Acc, Diseqs_Out),
	debug_msg(0, 'accumulate_disequations :: Diseqs_Out', Diseqs_Out).

accumulate_disequations_aux([], Diseq_Acc_Out, Diseq_Acc_Out) :- !.
accumulate_disequations_aux([Diseq | Diseq_List], Diseq_Acc_In, Diseq_Acc_Out) :-
	cneg_aux:memberchk(Diseq, Diseq_Acc_In), !, % It is there.
	accumulate_disequations_aux(Diseq_List, Diseq_Acc_In, Diseq_Acc_Out).
accumulate_disequations_aux([(T1, T2) | Diseq_List], Diseq_Acc_In, Diseq_Acc_Out) :-
%	disequality_contents(Diseq, T1, T2, EQV, UQV),
%	disequality_contents(Diseq_Aux, T2, T1, EQV, UQV), % Order inversion.
	cneg_aux:memberchk((T2, T1), Diseq_Acc_In), !, % It is there.
	accumulate_disequations_aux(Diseq_List, Diseq_Acc_In, Diseq_Acc_Out).
accumulate_disequations_aux([Diseq | Diseq_List], Diseq_Acc_In, Diseq_Acc_Out) :-
	accumulate_disequations_aux(Diseq_List, [Diseq | Diseq_Acc_In], Diseq_Acc_Out).

% Note that each disequality analized gets a clean status on its Result variable.
% This is because all of them need to be satisfied, we should not override the status of
% a previous disequality with the status of the current one.
simplify_disequations([], Diseq_Acc_In, Diseq_Acc_In, _EQV, _Can_Fail, 'true') :- !.

simplify_disequations([Diseq|Diseq_List], Diseq_Acc_In, Diseq_Acc_Out, EQV, Can_Fail, Result_In) :- !,
	simplify_disequation([Diseq], Simplified_Diseq, EQV, Can_Fail, Result_Aux),
	and_between_statuses(Result_Aux, Result_Out, Result_In),
	accumulate_disequations(Simplified_Diseq, Diseq_Acc_In, Diseq_Acc_Aux),
	simplify_disequations(Diseq_List, Diseq_Acc_Aux, Diseq_Acc_Out, EQV, Can_Fail, Result_Out).

and_between_statuses('true', 'true', 'true').
and_between_statuses('fail', 'true', 'fail').
and_between_statuses('true', 'fail', 'fail').
and_between_statuses('fail', 'fail', 'fail').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% just for debug.
simplify_disequation(Diseqs, Answer, EQV, Can_Fail, Result) :-
	debug_msg_nl(0),
	debug_msg(0, 'simplify_disequation :: (Diseqs, ---, EQV, Can_Fail)', (Diseqs, '---', EQV, Can_Fail)),
	simplify_disequation_aux(Diseqs, Answer, EQV, Can_Fail, Result),
	debug_msg(0, 'simplify_disequation :: (Result, Answer)', (Result, Answer)),
	debug_msg_nl(0).

% For the case we do not have a disequality to simplify.
% The answer is obviously empty, but we might fail because of Can_Fail = fail.
simplify_disequation_aux([], [], _EQV, Can_Fail, Result) :- 
	!,
%	debug_msg(1, 'simplify_disequation_aux :: Diseqs = []', ''),
	check_if_allowed_to_fail(Can_Fail),
	Result = 'fail'. % We have failed.

simplify_disequation_aux([(T1, T2) | More_Diseqs], Answer, EQV, Can_Fail, Result) :- % Same var.
        var(T1),
        var(T2), % Both are variables.
        T1==T2, !, % Both are the same variable.
%	debug_msg(1, 'simplify_disequation_aux :: SAME VAR, T1 == T2', (T1, T2)),
	check_if_allowed_to_fail(Can_Fail),
	simplify_disequation_aux(More_Diseqs, Answer, EQV, Can_Fail, Result).

simplify_disequation_aux([(T1, T2) | More_Diseqs], Answer, EQV_In, Can_Fail, Result) :- % Different vars.
        var(T1),
        var(T2), !, % Both are variables, but not the same one.
	T1 \== T2, % Not the same variable.
	varsbag(EQV_In, [], [], EQV), % Remove anything there not a variable.
	varsbag((T1, T2), EQV, [], UQV), % Compute UQ vars.
%	debug_msg(1, 'simplify_disequation_aux :: var(T1) and var(T2)', (T1, T2)),
	(
	    (   % Both are UQ vars.
		cneg_aux:memberchk(T1, UQV), 
		cneg_aux:memberchk(T2, UQV), !,
%		debug_msg(1, 'simplify_disequation_aux :: UNIFY UQV(T1) and UQV(T2)', (T1, T2)),
		check_if_allowed_to_fail(Can_Fail),
		diseq_eq(T1, T2), % They can not be disunified, and they are still UQ vars.
		simplify_disequation_aux(More_Diseqs, Answer, EQV, Can_Fail, Result)
	    )
	;
	    (   % T1 is a UQ var, T2 is not a UQ var.
		cneg_aux:memberchk(T1, UQV), !,
%		cneg_aux:memberchk(T2, EQV), 
%		debug_msg(1, 'simplify_disequation_aux :: UQV(T1) and var(T2)', (T1, T2)),
		simplify_disequation_aux_uqvar_t1_var_t2([(T1, T2) | More_Diseqs], Answer, EQV, Can_Fail, Result)
	    )
	;
	    (   % T2 is a UQ var, T1 is not a UQ var.
%		cneg_aux:memberchk(T1, EQV),
		cneg_aux:memberchk(T2, UQV), !,
%		debug_msg(1, 'simplify_disequation_aux :: UQV(T2) and var(T1)', (T1, T2)),
		simplify_disequation_aux_uqvar_t1_var_t2([(T2, T1) | More_Diseqs], Answer, EQV, Can_Fail, Result)
	    )
	;
	    (   % T1 and T2 are NOT UQ vars. 2 solutions. 
		cneg_aux:memberchk(T1, EQV),
		cneg_aux:memberchk(T2, EQV), !,
		( 
		    (   % First solution: T1 =/= T2.
%			debug_msg(1, 'simplify_disequation_aux :: var(T1) =/= var(T2)', (T1, T2)),
			diseq_eq('true', Result), % The solution is completely valid.
			Answer = [(T1, T2)]
		    )
		;
		    (   % T1 and T2 can not be disunified. We test if we can fail.
%			debug_msg(1, 'simplify_disequation_aux :: UNIFY var(T1) and var(T2)', (T1, T2)),
			check_if_allowed_to_fail(Can_Fail),
			diseq_eq(T1, T2), % Since they can not be disunified, unify them.
			simplify_disequation_aux(More_Diseqs, Answer, EQV, Can_Fail, Result)
		    )
		)
	    )	
	).

simplify_disequation_aux([(T1, T2) | More_Diseqs], Answer, EQV, Can_Fail, Result) :- % var and nonvar.
	(
	    (   % T1 is a VAR. T2 is not a var.
		var(T1), 
		nonvar(T2), !,
%		debug_msg(1, 'simplify_disequation_aux :: var(T1) and nonvar(T2) ', (T1, T2)),
		simplify_disequation_aux_var_nonvar([(T1, T2) | More_Diseqs], Answer, EQV, Can_Fail, Result)
	    )
	;
	    (   % T2 is a VAR. T1 is not a var.
		var(T2), 
		nonvar(T1), !,
%		debug_msg(1, 'simplify_disequation_aux :: var(T2) and nonvar(T1) ', (T1, T2)),
		simplify_disequation_aux_var_nonvar([(T2, T1) | More_Diseqs], Answer, EQV, Can_Fail, Result)
	    )
	).

simplify_disequation_aux([(T1, T2) | More_Diseqs], Answer, EQV, Can_Fail, Result):- 
	nonvar(T1), 
	nonvar(T2), !,
 	functor_local(T1, Name_1, Arity_1, Args_1),
	functor_local(T2, Name_2, Arity_2, Args_2), 
	(
	    (   % Functors that unify.
		Name_1 == Name_2, 
		Arity_1 == Arity_2, !,
%		debug_msg(1, 'simplify_disequation_aux :: functor(T1) == functor(T2)', (T1, T2)),
		disequalities_lists_product(Args_1, Args_2, Diseq_List),
		cneg_aux:append(Diseq_List, More_Diseqs, New_More_Diseqs),
		simplify_disequation_aux(New_More_Diseqs, Answer, EQV, Can_Fail, Result)
	    )
	;
	    (   % Functors that do not unify.
		(
		    (Name_1 \== Name_2) ; (Arity_1 \== Arity_2)
		), !,
%		debug_msg(1, 'simplify_disequation_aux :: functor(T1) =/= functor(T2)', (T1, T2)),
		Result = 'true', % Result is completely valid.
		Answer = [] % Answer is True.
	    )
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Esto NO es producto cartesiano.
disequalities_lists_product([], [], []) :- !.
disequalities_lists_product([T1], [T2], [(T1, T2)]) :- !.
disequalities_lists_product([T1 | Args_1], [T2 | Args_2], [(T1, T2) | More_Diseqs]) :- !,
	disequalities_lists_product(Args_1, Args_2, More_Diseqs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

simplify_disequation_aux_uqvar_t1_var_t2([(T1, T2) | More_Diseqs], Answer, EQV_In, Can_Fail, Result) :-
        var(T1),
        var(T2), 
	varsbag(EQV_In, [], [], EQV), % Remove anything there not a variable.
	varsbag((T1, T2), EQV, [], UQV), % Compute UQ vars.
	cneg_aux:memberchk(T1, UQV), % T1 is a uq var, T2 is not a uqvar.
	cneg_aux:memberchk(T2, EQV), !,
%	debug_msg(1, 'simplify_disequation_aux :: UQV(T1) and var(T2) ', (T1, T2)),

	% T1 can not be different from T2. We unify them (failing) and continue.
	check_if_allowed_to_fail(Can_Fail),
	cneg_unify(T1, T2),
	simplify_disequation_aux(More_Diseqs, Answer, EQV, Can_Fail, Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

simplify_disequation_aux_var_nonvar([(T1, T2) | More_Diseqs], Answer, EQV_In, Can_Fail, Result):- 
        var(T1),
	nonvar(T2),
        functor_local(T2, Name, Arity, _Args_T2), 
	varsbag(EQV_In, [], [], EQV), % Remove anything there not a variable.
	varsbag((T1, T2), EQV, [], UQV), % Compute UQ vars.
	(
	    (   % A variable is always different from a functor making use of it.
		cneg_aux:varsbag(T2, [], [], Vars_T2),
		cneg_aux:memberchk(T1, Vars_T2), !, % e.g. X =/= s(s(X)).
%		debug_msg(1, 'simplify_disequation_aux :: var(T1) and functor(T2) and T1 in vars(T2)', (T1, T2)),
		cneg_unify('true', Result), % Result is completely valid.
		Answer = [] % Answer is True.
	    )
	;
	    (   % T1 is a UQ var. Impossible to disunify.
		cneg_aux:memberchk(T1, UQV), !,
%		debug_msg(1, 'simplify_disequation_aux :: UQV(T1) and functor(T2)', (T1, T2)),
		check_if_allowed_to_fail(Can_Fail),
		cneg_unify(T1, T2),
		simplify_disequation_aux(More_Diseqs, Answer, EQV, Can_Fail, Result)
	    )
	;
	    (   % The variable must not be the functor (use attributed variables).
		cneg_aux:memberchk(T1, EQV), !,
%		debug_msg(1, 'simplify_disequation_aux :: var(T1) =/= functor(T2)', (T1, T2)),
		(
		    (
			functor_local(New_T2, Name, Arity, _UQ_Vars_New_T2), 
			cneg_unify(Result, 'true'), % Correct result if attr. var. satisfied.
			Answer = [(T1, New_T2)] % Answer is (T1, T2).
		    )
		;
		    (   % Keep the functor but diseq between the arguments.
			% We need to say that we have failed because if we are playing with attributed
			% variables we have no way to get more information on the disequality.
%			debug_msg(1, 'simplify_disequation_aux :: UNIFY var(T1) and functor(T2)', (T1, T2)),
			check_if_allowed_to_fail(Can_Fail),
			functor_local(T1, Name, Arity, _Args_T1), % T1 = functor 
			simplify_disequation_aux([(T1, T2) | More_Diseqs], Answer, EQV, Can_Fail, Result)
		    )
		)
	    )
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

remove_vars_with_attributes([], []) :- !.
remove_vars_with_attributes([Var|List_In], List_Out) :-   % If variables have attributes, remove them from the bag.
	get_attribute_local(Var, _Attribute), !,
	remove_vars_with_attributes(List_In, List_Out).
remove_vars_with_attributes([Var|List_In], [Var|List_Out]) :- % Keep only vars without attributes.
	remove_vars_with_attributes(List_In, List_Out).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

check_if_allowed_to_fail(Can_Fail) :-
	(   
	    ( 
		Can_Fail == 'fail', 
%		debug_msg(1, 'Not allowed to return fail.', ''), 
		fail 
	    )
	;   
	    (	Can_Fail == 'true'
%		debug_msg(1, 'No return value yet.', '')
	    )
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

compute_eqv_or_uqv(_T1, _T2, EQV_In, UQV_In, _EQV_Out, _UQV_Out) :-
	EQV_In = 'compute',
	UQV_In = 'compute',
	!, 
	debug_msg(1, 'ERROR: Can not compute both EQV and UQV. (EQV, UQV)', (EQV_In, UQV_In)),
	!,
	fail.
compute_eqv_or_uqv(T1, T2, EQV_In, UQV_In, EQV_Out, UQV_Out) :-
	EQV_In = 'compute', !,
	varsbag(UQV_In, [], [], UQV_Aux), % Only variables, please.	
	varsbag((T1, T2), UQV_Aux, [], EQV_Aux), % Determine EQV.
	compute_eqv_or_uqv(T1, T2, EQV_Aux, UQV_Aux, EQV_Out, UQV_Out). % Test empty intersection.
compute_eqv_or_uqv(T1, T2, EQV_In, UQV_In, EQV_Out, UQV_Out) :-
	UQV_In = 'compute', !,
	varsbag(EQV_In, [], [], EQV_Aux), % Only variables, please.
	varsbag((T1, T2), EQV_Aux, [], UQV_Aux), % Determine UQV.
	compute_eqv_or_uqv(T1, T2, EQV_Aux, UQV_Aux, EQV_Out, UQV_Out). % Test empty intersection.
compute_eqv_or_uqv(T1, T2, EQV_In, UQV_In, EQV_Out, UQV_Out) :-
	varsbag(EQV_In, [], [], EQV_Aux), % Only variables, please.	
	varsbag(UQV_In, [], [], UQV_Aux), % Only variables, please.
	varsbag((T1, T2), [], [], Affected_Vars), % Affected variables.
	varsbag_intersection(Affected_Vars, EQV_Aux, EQV_Out), % Only EQV affected variables.
	varsbag_intersection(Affected_Vars, UQV_Aux, UQV_Out), % Only UQV affected variables.

	varsbag_intersection(EQV_Out, UQV_Out, Intersection), % Compute intersection between EQV and UQV.
	!,
	(
	    (
		Intersection = [], ! % Test empty intersection.
	    )
	;
	    (
		!,
		debug_msg(1, 'ERROR: Intersection between EQV and UQV is not empty. (EQV, UQV, Intersection)', (EQV_Out, UQV_Out, Intersection)),
		!, fail
	    )
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     PREDICADO   DISTINTO                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Predicado que implementa mediante variables con atributo
% la desigualdad entre terminos y como expresarlo a
% traves de disyuncion de conjunciones de desigualdades
% entre terminos que debe satisfacer cada variable.
% Esta implementacion sirve para variables con dominios
% de valores finitos.

% Incluye una desigualdad en las formulas de las 
% variables implicadas

disequality(T1,T2, UQV) :- diseq_uqv(T1,T2, UQV).
diseq_uqv(T1,T2, UQV_In) :- 
	cneg_diseq_eqv_uqv(T1, T2, 'compute', UQV_In, 'true').

diseq_eqv(T1,T2, EQV_In) :- 
	cneg_diseq_eqv_uqv(T1, T2, EQV_In, 'compute', 'true').

cneg_diseq_eqv_uqv(T1,T2, EQV_In, UQV_In, Result) :- 
	Can_Fail = true,
	compute_eqv_or_uqv(T1, T2, EQV_In, UQV_In, EQV, UQV),
	debug_msg(1, 'cneg_diseq_eqv_uqv [in] :: ((T1, =/=, T2), ---, (EQV, UQV))', ((T1, '=/=', T2), '---', (EQV, UQV))),
	disequality_contents(Disequality, T1, T2, EQV, UQV),
        test_and_update_vars_attributes([Disequality], Can_Fail, Result).
%	debug_msg(1, 'cneg_diseq_eqv_uqv [out] :: ((T1, =/=, T2), Result)', ((T1, '=/=', T2), Result)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

equality(T1,T2, UQV) :- eq_uqv(T1,T2, UQV).
eq_uqv(T1, T2, UQV) :-
	cneg_eq_eqv_uqv(T1, T2, 'compute', UQV, 'true').

eq_eqv(T1, T2, EQV) :-
	cneg_eq_eqv_uqv(T1, T2, EQV, 'compute', 'true').

cneg_eq_eqv_uqv(T1, T2, EQV_In, UQV_In, Result) :- 
	Can_Fail = 'true',
	compute_eqv_or_uqv(T1, T2, EQV_In, UQV_In, EQV, UQV),
	debug_msg(1, 'cneg_eq_eqv_uqv [in] :: (T1, =, T2), ---, (EQV, UQV)', ((T1, '=', T2), '---', (EQV, UQV))),
	!,
	(
	    ( 
		UQV == [], !, 
		diseq_eq(T1, T2),
		Result = 'true'
	    )
	;
	    (
		UQV \== [], !, 
		check_if_allowed_to_fail(Can_Fail),
		Result = 'fail',
		cneg_aux:varsbag((T1, T2), [], [], Disequality_EQV), % Mark all vars as EQV
		% cneg_diseq(T1,T2, EQV, Can_Fail, Result)
		cneg_diseq_eqv_uqv(T1, T2, [], Disequality_EQV, 'true') 
	    )
	).

cneg_unify(T, T).

% diseq_eq(X,Y) unify X and Y
diseq_eq(X, X).
% eq(X,Y):-
 %       X=Y.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

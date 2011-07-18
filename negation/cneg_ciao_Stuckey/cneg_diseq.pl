:- module(cneg_diseq, 
	[
	    diseq/3, cneg_diseq/6, cneg_eq/6,
	    portray_attributes_in_term/1, 
	    put_universal_quantification/1,
	    remove_universal_quantification/2,
	    keep_universal_quantification/3
	], 
	[assertions]).

:- use_module(cneg_aux,_).

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

put_universal_quantification(Vars) :-
	debug_msg(0, 'put_universal_quantification :: Vars', Vars),
	put_universal_quantification_vars(Vars).

put_universal_quantification_vars([]) :- !.
put_universal_quantification_vars([Var|Vars]) :-
	put_universal_quantification_var(Var),
	put_universal_quantification_vars(Vars).

put_universal_quantification_var(Var) :-
	var(Var), !,
	test_and_update_vars_attributes([Var], [], []).
put_universal_quantification_var(_Var) :- !. % NonVar

remove_universal_quantification(Vars, Vars_Previously_UQ) :-
	debug_msg(1, 'remove_universal_quantification :: Vars', Vars),
	retrieve_affected_disequalities(Vars, [], [], UV_Diseqs, [], Disequalities), !,
	debug_msg(1, 'remove_universal_quantification :: UV_Diseqs', UV_Diseqs),
	varsbag_difference(UV_Diseqs, Vars, New_UV_Diseqs),
	debug_msg(1, 'remove_universal_quantification :: New_UV_Diseqs', New_UV_Diseqs),
	varsbag_local(Disequalities, New_UV_Diseqs, [], NO_UV_Diseqs),
	restore_attributes(NO_UV_Diseqs, New_UV_Diseqs, Disequalities),

	varsbag_intersection(Vars, UV_Diseqs, Vars_Previously_UQ),
	debug_msg(1, 'remove_universal_quantification :: Vars_Previously_UQ', Vars_Previously_UQ).


split_vars_into_universally_quantified_and_not([], [], []) :- !. 
split_vars_into_universally_quantified_and_not([Var | Vars], Vars_NUQ, [Var | Vars_UQ]) :-
	var_is_universally_quantified(Var), !,
	split_vars_into_universally_quantified_and_not(Vars, Vars_NUQ, Vars_UQ).
split_vars_into_universally_quantified_and_not([Var | Vars], [Var | Vars_NUQ], Vars_UQ) :-
	split_vars_into_universally_quantified_and_not(Vars, Vars_NUQ, Vars_UQ).

var_is_universally_quantified(Var) :-
	var(Var), 
	get_attribute_local(Var, Old_Attribute), 
	attribute_contents(Old_Attribute, Var, _Disequalities, UnivVars),
	cneg_aux:memberchk(Var, UnivVars), !.

%% To keep universal quantification both the structure in Ci_Vars and the variables
%% inside the structure must belong to the universally quantified set of variables.
%% If one of them does not belong, the vars involved should not be universally
%% quantified.

keep_universal_quantification(Ci_Vars, New_UQ, Previously_UQ) :-
	debug_msg(1, 'keep_universal_quantification(Ci_Vars)', Ci_Vars),
	debug_msg(1, 'keep_universal_quantification(New_UQ)', New_UQ),
	debug_msg(1, 'keep_universal_quantification(Previously_UQ)', Previously_UQ),
	varsbag_addition(New_UQ, Previously_UQ, Vars_UQ),
	keep_universal_quantification_aux_1(Ci_Vars, Vars_UQ).

keep_universal_quantification_aux_1([], _Vars_UQ) :- !.
keep_universal_quantification_aux_1([Ci_Var | Ci_Vars], Vars_UQ) :-
	cneg_aux:memberchk(Ci_Var, Vars_UQ), !,
	varsbag_local(Ci_Var, [], [], Real_Ci_Vars),
	keep_universal_quantification_aux_2(Real_Ci_Vars, Vars_UQ, Real_Ci_Vars),
	keep_universal_quantification_aux_1(Ci_Vars, Vars_UQ).
keep_universal_quantification_aux_1([_Ci_Var | Ci_Vars], Vars_UQ) :-
	keep_universal_quantification_aux_1(Ci_Vars, Vars_UQ).

keep_universal_quantification_aux_2([], _Vars_UQ, Real_Ci_Vars) :- !,
	put_universal_quantification(Real_Ci_Vars).
keep_universal_quantification_aux_2([Ci_Var | Ci_Vars], Vars_UQ, Real_Ci_Vars) :-
	cneg_aux:memberchk(Ci_Var, Vars_UQ), !,
	keep_universal_quantification_aux_2(Ci_Vars, Vars_UQ, Real_Ci_Vars).
keep_universal_quantification_aux_2([_Ci_Var | _Ci_Vars], _Vars_UQ, _Real_Ci_Vars) :- !.

test_universal_quantified(T1, T2) :-
	varsbag_local((T1, T2), [], [], Vars),
	test_universal_quantified_vars(Vars).

test_universal_quantified_vars([]).
test_universal_quantified_vars([Var | Vars]) :-
	get_attribute_local(Var, Old_Attribute), !,
	debug_msg(1, 'test_universal_quantified_vars', Old_Attribute),
	test_universal_quantified_vars(Vars).
test_universal_quantified_vars([Var | Vars]) :-
	debug_msg(1, 'test_universal_quantified_vars :: no attribute for Var', Var),
	test_universal_quantified_vars(Vars).

quantify_universally_new_vars(Ci_Conj, GoalVars) :-
	varsbag_local(GoalVars, [], [], Real_GoalVars),
	split_vars_into_universally_quantified_and_not(Real_GoalVars, GoalVars_NUQ, GoalVars_UQ), 
	varsbag_local(Ci_Conj, GoalVars_NUQ, GoalVars_UQ, New_Vars),
	put_universal_quantification(New_Vars).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Attributes contents are encapsulated via the following structure.

%:- dynamic var_attribute/2.
attribute_contents(var_attribute(Target, Disequalities, UnivVars), Target, Disequalities, UnivVars).
disequality_contents(disequality(Diseq_1, Diseq_2), Diseq_1, Diseq_2).
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
	attribute_contents(Attribute, _Target, Disequalities, UnivVars), !,
	portray_disequalities(Disequalities, UnivVars).

portray(Anything) :- 
	debug_msg_aux(2, '', Anything).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

portray_attributes_in_term(T) :-
	varsbag_local(T, [], [], Variables),
	debug_msg(0, 'Attributes for the variables in term', T),
	portray_attributes_in_variables(Variables).

portray_attributes_in_variables([]) :- !.
portray_attributes_in_variables([Var|Vars]) :-
	portray_attributes_in_variable(Var),
	portray_attributes_in_variables(Vars).

portray_attributes_in_variable(Var) :-
	get_attribute_local(Var, Attribute),
	debug_msg(2, 'variable', Var), 
	portray(Attribute).
portray_attributes_in_variable(Var) :-
	debug_msg(2, Var, ' has NO attribute').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

portray_disequalities(Disequalities, UnivVars) :-
	portray_disequalities_aux_1(Disequalities), 
	portray_disequalities_aux_3(UnivVars).

portray_disequalities_aux_1([]) :- !.
portray_disequalities_aux_1([Diseq_1]) :- !,
	portray_disequalities_aux_2(Diseq_1).
portray_disequalities_aux_1([Diseq_1|Diseqs]) :- !,
	portray_disequalities_aux_2(Diseq_1), 
	debug_msg_aux(2, ' AND ', ''),
	portray_disequalities_aux_1(Diseqs).

portray_disequalities_aux_2(Diseq) :-
	disequality_contents(Diseq, Diseq_1, Diseq_2),
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

verify_attribute(Attribute, Target):-
%	debug_msg(0, verify_attribute(Attribute, Target)), 
	attribute_contents(Attribute, NewTarget, Disequalities, UnivVars), 
	terms_are_equal(Target, NewTarget), !,
	test_and_update_vars_attributes(UnivVars, [], Disequalities).


% Only for Ciao prolog 
verify_attribute(Attribute, NewTarget):-
%	debug_msg(0, 'Only for Ciao Prolog: '),
%	debug_msg(0, verify_attribute(Attribute, NewTarget)), 
	attribute_contents(Attribute, OldTarget, Disequalities, UnivVars), !,
	(
%         --->> I do not know if this is semantically correct ... :-(
%	    (
%		var(OldTarget),
%		cneg_aux:memberchk(OldTarget, UnivVars), !, 
%		fail % An universally quantified variable is not unifiable.
%	    )
%	;
	    (
		substitution_contents(Subst, OldTarget, NewTarget),
		test_and_update_vars_attributes(UnivVars, [Subst], Disequalities)
	    )
	).

substitution_contents(substitute(Var, T), Var, T).

combine_attributes(Attribute_Var_1, Attribute_Var_2) :-
	debug_msg(0, 'combine_attributes :: Attr_Var1 :: (Attr, Target, Diseqs, UV)', Attribute_Var_1),
	debug_msg(0, 'combine_attributes :: Attr_Var2 :: (Attr, Target, Diseqs, UV)', Attribute_Var_2),
	attribute_contents(Attribute_Var_1, OldTarget_Var_1, Disequalities_Var_1, UnivVars_Var_1), !,
	attribute_contents(Attribute_Var_2, OldTarget_Var_2, Disequalities_Var_2, UnivVars_Var_2), !,
	(
	    (
%             Not really sure they must be variables ... it's a very strong restriction.
%		var(OldTarget_Var_1), var(OldTarget_Var_1), !,
		cneg_aux:append(Disequalities_Var_1, Disequalities_Var_2, Disequalities),
		cneg_aux:append(UnivVars_Var_1, UnivVars_Var_2, UnivVars),
		substitution_contents(Subst, OldTarget_Var_1, OldTarget_Var_2),
		test_and_update_vars_attributes(UnivVars, [Subst], Disequalities)
	    )
	;
	    (
		debug_msg(2, 'combine_attributes', 'they should be variables but they are not. FAIL.'),
		!, fail
	    )
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% An~ade la formula al atributo de las variables implicadas
% Por q tendriamos q tener en cuenta otros atributos?
% Como cada uno tiene su manejador, tratar de mezclar los atributos no aporta nada.

test_and_update_vars_attributes(UV_In, Substitutions, New_Disequalities) :-
	debug_msg(1, 'test_and_update_vars_attributes(UV_In, Substitutions, New_Disequalities)', (UV_In, Substitutions, New_Disequalities)), 

	varsbag_local(New_Disequalities, [], UV_In, Vars_In), !,
	retrieve_affected_disequalities(Vars_In, [], UV_In, UV_Diseqs, New_Disequalities, Disequalities), !,
	debug_msg(0, '', retrieve_affected_disequalities(Vars_In, [], UV_In, UV_Diseqs, New_Disequalities, Disequalities)),

	perform_substitutions(Substitutions, UV_Diseqs, UV_Subst), !,
	varsbag_local(Disequalities, UV_Subst, [], NO_UV_In), % Not universally quantified.
	debug_msg(1, 'Affected Disequalities', Disequalities),
	debug_msg(1, 'Vars in Disequalities NOT universally quantified', NO_UV_In),

	simplify_disequations(Disequalities, NO_UV_In, NO_UV_Out, [], Simplified_Disequalities),
	debug_msg(0, 'test_and_update_vars_attributes(Simplified_Disequalities, NO_UV_Out)', (Simplified_Disequalities, NO_UV_Out)),
	varsbag_difference(Vars_In, NO_UV_Out, UV_Out),
	restore_attributes(NO_UV_Out, UV_Out, Simplified_Disequalities).

retrieve_affected_disequalities([], _Vars_Examined, UV_Out, UV_Out, Diseq_Acc_Out, Diseq_Acc_Out) :- !. % Loop over vars list.
retrieve_affected_disequalities([Var|Vars], Vars_Examined, UV_In, UV_Out, Diseq_Acc_In, Diseq_Acc_Out):- 
	var(Var), % It cannot be other things ...
	get_attribute_local(Var, Attribute), !,
	attribute_contents(Attribute, Var, ThisVar_Disequalities, Attribute_UnivVars), 
	remove_attribute_local(Var), 

	% Store info.
	filter_out_nonvars(Attribute_UnivVars, UnivVars),
	varsbag_addition(UnivVars, UV_In, UV_Aux),
	varsbag_local((ThisVar_Disequalities, Attribute_UnivVars), [Var|Vars_Examined], Vars, New_Vars), !,
	accumulate_disequations(ThisVar_Disequalities, Diseq_Acc_In, Diseq_Acc_Aux),
        retrieve_affected_disequalities(New_Vars, [Var|Vars_Examined], UV_Aux, UV_Out, Diseq_Acc_Aux, Diseq_Acc_Out).

retrieve_affected_disequalities([Var|Vars_In], Vars_Examined, UV_In, UV_Out, Diseq_Acc_In, Diseq_Acc_Out) :- 
        retrieve_affected_disequalities(Vars_In, [Var|Vars_Examined], UV_In, UV_Out, Diseq_Acc_In, Diseq_Acc_Out).


perform_substitutions([], UV_In, UV_In) :- !.
perform_substitutions([Subst | MoreSubst], UV_In, UV_Out) :-
	debug_msg(1, 'perform_substitutions :: Subst', Subst),
	substitution_contents(Subst, OldTarget, NewTarget),
	(
	    (
		var(OldTarget),
		var(NewTarget), !, % Both are vars.
		perform_substitution_vars(OldTarget, NewTarget, UV_In, UV_Aux)
	    )
	;
	    (
		var(OldTarget), !, % Only OldTarget is var.
		perform_substitution_var_nonvar(OldTarget, NewTarget, UV_In, UV_Aux)
	    )
	;
	    (
		var(NewTarget), !, % Only NewTarget is var.
		perform_substitution_var_nonvar(NewTarget, OldTarget, UV_In, UV_Aux)
	    )
	;
	    (
		perform_substitution_nonvars(OldTarget, NewTarget, UV_In, UV_Aux)
	    )
	),
	perform_substitutions(MoreSubst, UV_Aux, UV_Out).	

perform_substitution_vars(OldTarget, NewTarget, UV_In, UV_Out) :-
	var(OldTarget),
	var(NewTarget), % Be sure both are vars.
	(
	    (
		cneg_aux:memberchk(OldTarget, UV_In),
		cneg_aux:memberchk(NewTarget, UV_In), % Both are universally quantified.
		diseq_eq(UV_In, UV_Out), ! % Keep universal quantification.
	    )
	;
	    (
		varsbag_remove_var(OldTarget, UV_In, UV_Aux),
		varsbag_remove_var(NewTarget, UV_Aux, UV_Out)
	    )
	),
	diseq_eq(OldTarget, NewTarget), !.

perform_substitution_var_nonvar(OldTarget, NewTarget, UV_In, UV_Out) :-
	var(OldTarget), % Be sure OldTarget is a var.
	varsbag_remove_var(OldTarget, UV_In, UV_Out),
	diseq_eq(OldTarget, NewTarget), !.

perform_substitution_nonvars(OldTarget, NewTarget, UV_In, UV_Out) :-
	functor_local(OldTarget, Name, Arity, Args_1),
	functor_local(NewTarget, Name, Arity, Args_2), !,
	substitutions_cartesian_product(Args_1, Args_2, Subst_List),
	perform_substitutions(Subst_List, UV_In, UV_Out).

% Esto NO es producto cartesiano.
substitutions_cartesian_product([], [], []) :- !.
substitutions_cartesian_product([T1], [T2], [Diseq]) :- !,
	 substitution_contents(Diseq, T1, T2).
substitutions_cartesian_product([T1 | Args_1], [T2 | Args_2], [Diseq | Args]) :- !,
	substitution_contents(Diseq, T1, T2),
	substitutions_cartesian_product(Args_1, Args_2, Args).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Need old vars to play with them too.
restore_attributes(NO_UV_In, UV_In, Diseqs) :- 
	varsbag_addition(NO_UV_In, UV_In, Affected_Vars),
	debug_msg(0, 'restore_attributes_vars(Affected_Vars, UV_In, Diseqs)', (Affected_Vars, UV_In, Diseqs)),
	restore_attributes_vars(Affected_Vars, UV_In, Diseqs).

restore_attributes_vars([], _UV_In, _Diseqs) :- !.
restore_attributes_vars([Var | Affected_Vars], UV_In, Diseqs) :-
	affected_diseqs(Var, Diseqs, Affected_Diseqs),
	restore_attributes_var(Var, UV_In, Affected_Diseqs),
	restore_attributes_vars(Affected_Vars, UV_In, Diseqs).

affected_diseqs(_Var, [], []) :- !.
affected_diseqs(Var, [Diseq | Diseqs], [Diseq | Affected_Diseqs]) :-
	varsbag_local(Diseq, [], [], Diseq_Vars),
	cneg_aux:memberchk(Var, Diseq_Vars), !,
	affected_diseqs(Var, Diseqs, Affected_Diseqs).
affected_diseqs(Var, [_Diseq | Diseqs], Affected_Diseqs) :-
	affected_diseqs(Var, Diseqs, Affected_Diseqs).

restore_attributes_var(Var, _UV_In, _Affected_Diseqs) :-
	var(Var),
	get_attribute_local(Var, Attribute), !,
	debug_msg_nl(0),
	debug_msg(0, 'ERROR: var has an attribute. Attribute: ', Attribute),
	debug_msg_nl(0),
	fail.

restore_attributes_var(Var, UV_In, Affected_Diseqs) :-
	var(Var),
	varsbag_local((Var, Affected_Diseqs), [], [], Affected_Vars),
	varsbag_intersection(Affected_Vars, UV_In, UV_Affected),
	!,
	(
	    (
		UV_Affected == [],
		Affected_Diseqs == [],
		! % We do not want empty attributes.
	    )
	;
	    (
		attribute_contents(Attribute, Var, Affected_Diseqs, UV_Affected),
		put_attribute_local(Var, Attribute)
	    )
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

accumulate_disequations([], Diseq_Acc_Out, Diseq_Acc_Out) :- !.
accumulate_disequations([Diseq | Diseq_List], Diseq_Acc_In, Diseq_Acc_Out) :-
	cneg_aux:memberchk(Diseq, Diseq_Acc_In), !, % It is there.
	accumulate_disequations(Diseq_List, Diseq_Acc_In, Diseq_Acc_Out).
accumulate_disequations([Diseq | Diseq_List], Diseq_Acc_In, Diseq_Acc_Out) :-
	disequality_contents(Diseq, T1, T2),
	disequality_contents(Diseq_Aux, T2, T1), % Order inversion.
	cneg_aux:memberchk(Diseq_Aux, Diseq_Acc_In), !, % It is there.
	accumulate_disequations(Diseq_List, Diseq_Acc_In, Diseq_Acc_Out).
accumulate_disequations([Diseq | Diseq_List], Diseq_Acc_In, Diseq_Acc_Out) :-
	accumulate_disequations(Diseq_List, [Diseq | Diseq_Acc_In], Diseq_Acc_Out).

simplify_disequations([], No_FV_Out, No_FV_Out, Diseq_Acc_Out, Diseq_Acc_Out) :- !.
simplify_disequations([Diseq|Diseq_List], No_FV_In, No_FV_Out, Diseq_Acc_In, Diseq_Acc_Out) :- !,
	simplify_1_diseq(Diseq, [], No_FV_In, No_FV_Aux, Simplified_Diseq),
	debug_msg(0, 'simplify_disequations :: Simplified_Diseq', Simplified_Diseq), 
	accumulate_disequations(Simplified_Diseq, Diseq_Acc_In, Diseq_Acc_Aux),
	simplify_disequations(Diseq_List, No_FV_Aux, No_FV_Out, Diseq_Acc_Aux, Diseq_Acc_Out).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

simplify_1_diseq(Diseq, More_Diseq, No_FV_In, _No_FV_Out, _Answer) :-
%	debug_msg(0, '', ''),
	debug_msg(0, 'simplify_1_diseq :: (Diseq, More_Diseq, No_FV_In)', (Diseq, More_Diseq, No_FV_In)), 
	fail.
		
simplify_1_diseq(fail, [], _No_FV_In, _No_FV_Out, _Answer) :- !, fail.
simplify_1_diseq(fail, [First_Diseq | More_Diseq], No_FV_In, No_FV_Out, Answer) :- !,
	simplify_1_diseq(First_Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer).

simplify_1_diseq(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer) :- % Same var.
	disequality_contents(Diseq, T1, T2),
        var(T1),      
        var(T2), % Both are variables.
        T1==T2, !,
	simplify_1_diseq(fail, More_Diseq, No_FV_In, No_FV_Out, Answer).

simplify_1_diseq(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer) :- % Different vars.
	disequality_contents(Diseq, T1, T2),
        var(T1),
        var(T2), % Both are variables.
	varsbag_local(Diseq, No_FV_In, [], Real_FreeVars),
	cneg_aux:memberchk(T1, Real_FreeVars), % Both are free vars.
	cneg_aux:memberchk(T2, Real_FreeVars), !,
	simplify_1_diseq(fail, More_Diseq, No_FV_In, No_FV_Out, Answer).

simplify_1_diseq(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer) :- % Different vars.
	disequality_contents(Diseq, T1, T2),
        var(T1),
        var(T2), !, % Both are variables.
	varsbag_local(Diseq, No_FV_In, [], Real_FreeVars),
	(
	    (   % T1 is a free var, T2 is not a free var.
		cneg_aux:memberchk(T1, Real_FreeVars), !,
		simplify_1_diseq_freevar_t1_var_t2(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	;
	    (   % T2 is a free var, T1 is not a free var.
		cneg_aux:memberchk(T2, Real_FreeVars), !,
		disequality_contents(Diseq_Aux, T2, T1),
		simplify_1_diseq_freevar_t1_var_t2(Diseq_Aux, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	;
	    (   % T1 and T2 are NOT free vars. 2 solutions. First: T1 =/= T2.
		No_FV_In = No_FV_Out,
		diseq_eq(Answer, [Diseq])
	    )
	;
	    (   % Answer is T1 = T2 but needs more information.
		diseq_eq(T1, T2), % Answer is T1 = T2 and more
		simplify_1_diseq(fail, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )	
	).

simplify_1_diseq(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer) :- % var and nonvar.
	disequality_contents(Diseq, T1, T2),
	(
	    (
		var(T1), !,
		simplify_1_diseq_var_nonvar(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	;
	    (
		var(T2), !,
		disequality_contents(Diseq_Aux, T2, T1),
		simplify_1_diseq_var_nonvar(Diseq_Aux, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	).

simplify_1_diseq(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer):-  % Functors that unify.
	disequality_contents(Diseq, T1, T2),
 	functor_local(T1, Name, Arity, Args_1),
	functor_local(T2, Name, Arity, Args_2), !,
	disequalities_cartesian_product(Args_1, Args_2, Diseq_List),
	cneg_aux:append(Diseq_List, More_Diseq, New_More_Diseq),
	simplify_1_diseq(fail, New_More_Diseq, No_FV_In, No_FV_Out, Answer).

simplify_1_diseq(Diseq, _More_Diseq, No_FV_Out, No_FV_Out, Answer):-  % Functors that do not unify.
	disequality_contents(Diseq, T1, T2),
	functor_local(T1, Name1, Arity1, _Args1),
	functor_local(T2, Name2, Arity2, _Args2),
	(
	    (Name1 \== Name2) 
	; 
	    (Arity1 \== Arity2)
	), !,
	diseq_eq(Answer, []). % Answer is True.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Esto NO es producto cartesiano.
disequalities_cartesian_product([], [], []) :- !.
disequalities_cartesian_product([T1], [T2], [Diseq]) :- !,
	 disequality_contents(Diseq, T1, T2).
disequalities_cartesian_product([T1 | Args_1], [T2 | Args_2], [Diseq | Args]) :- !,
	disequality_contents(Diseq, T1, T2),
	disequalities_cartesian_product(Args_1, Args_2, Args).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

simplify_1_diseq_freevar_t1_var_t2(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer) :-
	disequality_contents(Diseq, T1, T2),
        var(T1),
        var(T2), 
	varsbag_local(Diseq, No_FV_In, [], Real_FreeVars),
	cneg_aux:memberchk(T1, Real_FreeVars), !, % T1 is a free var, T2 is not a freevar.
	(
	    (   % T1 is going to be processed hereafter (appears in More_Diseq).
		varsbag_local(More_Diseq, No_FV_In, [], More_Diseq_Vars),
		cneg_aux:memberchk(T1, More_Diseq_Vars), !,
		simplify_1_diseq_hereafter_t1(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	;
	    (   % T1 appears only once, so it is not different from T2. Just fail.
		simplify_1_diseq(fail, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

simplify_1_diseq_var_nonvar(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer):- 
	disequality_contents(Diseq, T1, T2),
        var(T1),
        functor_local(T2, Name, Arity, _Args_T2), 
	varsbag_local(Diseq, No_FV_In, [], Real_FreeVars),
	(
	    (
		(
		    varsbag_local(T2, [], [], Vars_T2),
		    cneg_aux:memberchk(T1, Vars_T2), !, % e.g. X =/= s(s(X)).
		    No_FV_In = No_FV_Out,
		    diseq_eq(Answer, []) % Answer is True.
		)
	    ;
		(   % T1 is a free var.
		    cneg_aux:memberchk(T1, Real_FreeVars), !,
		    simplify_1_diseq_freevar_t1_functor_t2(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer)
		)
	    ;
		(   % Not possible to solve it yet. 2 solutions.
		    No_FV_In = No_FV_Out,
		    diseq_eq(Answer, [Diseq]) % Answer is Diseq.
		)
	    ;
		(   % Keep the functor but diseq between the arguments.
		    varsbag_local(No_FV_In, [T1], [], No_FV_Aux_1),
		    functor_local(T1, Name, Arity, Args_T1), % Answer is T1 = functor and more.
		    varsbag_local(Args_T1, [T1], No_FV_Aux_1, No_FV_Aux_2),
		    simplify_1_diseq(Diseq, More_Diseq, No_FV_Aux_2, No_FV_Out, Answer)
		)
	    )
	).

simplify_1_diseq_freevar_t1_functor_t2(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer) :-
	disequality_contents(Diseq, T1, T2),
        var(T1),
	varsbag_local(Diseq, No_FV_In, [], Real_FreeVars),
	cneg_aux:memberchk(T1, Real_FreeVars), 
        functor_local(T2, _Name, _Arity, _Args_T2), !,
	(
	    (   % T1 is going to be processed (appears in More_Diseq).
		varsbag_local(More_Diseq, No_FV_In, [], More_Diseq_FreeVars),
		cneg_aux:memberchk(T1, More_Diseq_FreeVars), !,
		simplify_1_diseq_hereafter_t1(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	;
	    (   % T1 appears only once, so it is not different from T2. Just fail.
		simplify_1_diseq(fail, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

simplify_1_diseq_hereafter_t1(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer) :-

	disequality_contents(Diseq, T1, T2),
        var(T1),
	varsbag_local(Diseq, No_FV_In, [], Real_FreeVars),
	cneg_aux:memberchk(T1, Real_FreeVars), !, % T1 is an universal quantified var.

	varsbag_local(More_Diseq, No_FV_In, [], More_Diseq_FreeVars),
	cneg_aux:memberchk(T1, More_Diseq_FreeVars), !, % T1 is used hereafter.

	varsbag_local((Diseq, More_Diseq), [T1], [], All_Vars),
	copy_term((Diseq, More_Diseq, T1, All_Vars), (_Diseq_Copy, More_Diseq_Copy, T1_Copy, All_Vars_Copy)),
	diseq_eq(All_Vars, All_Vars_Copy), !,

	diseq_eq(T1_Copy, T2), % Answer is T1 = T2 and more. 
	simplify_1_diseq(fail, More_Diseq_Copy, No_FV_In, No_FV_Out, Answer).


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

diseq(T1,T2, UnivVars):- 
	cneg_diseq(T1, T2, UnivVars, UnivVars_Out, true, true).

cneg_diseq(T1,T2, FV_In, FV_Out, Cont_In, Cont_Out):- 
	debug_msg(1, 'cneg_diseq :: T1', T1), 
	debug_msg(1, 'cneg_diseq :: T2', T2),
%	debug_msg(1, 'cneg_diseq :: UnivVars', UnivVars),
	debug_msg(1, 'cneg_eq :: FreeVars_In', FV_In),
	debug_msg(1, 'cneg_eq :: Cont_In', Cont_In),

%	test_universal_quantified(T1, T2),
%	disequality_contents(Disequality, T1, T2),
%        test_and_update_vars_attributes(UnivVars, [], [Disequality]),

	debug_msg(1, 'cneg_eq :: FreeVars_Out', FV_Out),
	debug_msg(1, 'cneg_eq :: Cont_Out', Cont_Out).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cneg_eq(T1, T2, FV_In, FV_Out, Cont_In, Cont_Out) :- 
	debug_msg(1, 'cneg_eq :: T1', T1),
	debug_msg(1, 'cneg_eq :: T2', T2),
	debug_msg(1, 'cneg_eq :: FreeVars_In', FV_In),
	debug_msg(1, 'cneg_eq :: Cont_In', Cont_In),
	test_universal_quantified(T1, T2),

	debug_msg(1, 'cneg_eq :: FreeVars_Out', FV_Out),
	debug_msg(1, 'cneg_eq :: Cont_Out', Cont_Out).
%	fail.
% cneg_eq(T, T).

% diseq_eq(X,Y) unify X and Y
diseq_eq(X, X).
% eq(X,Y):-
 %       X=Y.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

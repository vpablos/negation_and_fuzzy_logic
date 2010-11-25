:- module(cneg_diseq, [cneg_diseq/3,
			portray_attributes_in_term/1, 
			put_universal_quantification/1,
			remove_universal_quantification/1]).

:- use_module(cneg_aux,_).

% For Ciao Prolog:
:- multifile 
        verify_attribute/2,
        combine_attributes/2,
	portray_attribute/2,
	portray/1.

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


% Local predicates used to easy migration between 
% prologs. 
remove_attribute_local(Var) :- 
%	debug('remove_attribute_local :: Var', Var),
	detach_attribute(Var).

% XSB:	del_attr(Var, dist).
get_attribute_local(Var, Attribute) :-
	get_attribute(Var, Attribute).
% XSB:	get_attr(Var, dist, Attribute),
%	debug('get_attribute_local :: (Var, Attribute)', (Var, Attribute)).
put_attribute_local(Var, Attribute) :-
%	debug('put_attribute_local :: (Var, Attribute)', (Var, Attribute)),
%	get_attribute_if_any(Var), !,
	attach_attribute(Var, Attribute).
%	put_attr(Var, dist, Attribute).

%get_attribute_if_any(Var) :-
%	debug('Testing if var has any attribute. Var: '),
%	debug(Var),
%	get_attribute_local(Var, _Attribute), !.
%get_attribute_if_any(Var) :-
%	debug('Testing if var has any attribute. Var: '),
%	debug(Var),
%	debug(' has NO attribute').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

put_universal_quantification(_X).
remove_universal_quantification(_X).	

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
	msg('portray_attribute :: (Attr, Var)', (Attr, Var)).

portray(Attribute) :-
	attribute_contents(Attribute, _Target, Disequalities, UnivVars), !,
	portray_disequalities(Disequalities, UnivVars).

portray(Anything) :- 
	msg_aux('', Anything).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

portray_attributes_in_term(T) :-
	varsbag_local(T, [], [], Variables),
	debug('Attributes for the variables in term', T),
	portray_attributes_in_variables(Variables).

portray_attributes_in_variables([]) :- !.
portray_attributes_in_variables([Var|Vars]) :-
	portray_attributes_in_variable(Var),
	portray_attributes_in_variables(Vars).

portray_attributes_in_variable(Var) :-
	get_attribute_local(Var, Attribute),
	msg('variable', Var), 
	portray(Attribute).
portray_attributes_in_variable(Var) :-
	msg(Var, ' has NO attribute').

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
	msg_aux(' AND ', ''),
	portray_disequalities_aux_1(Diseqs).

portray_disequalities_aux_2(Diseq) :-
	disequality_contents(Diseq, Diseq_1, Diseq_2),
	msg_aux('[ ', Diseq_1),
	msg_aux(' =/= ', Diseq_2),
	msg_aux('', ' ]').

portray_disequalities_aux_3([]).
portray_disequalities_aux_3(UnivVars) :-
	UnivVars \== [], !,
	msg_aux(', Universally quantified: [', ''), 
	portray_disequalities_aux_4(UnivVars),
	msg_aux('', ' ]').

portray_disequalities_aux_4([]) :- !.
portray_disequalities_aux_4([FreeVar | FreeVars]) :-
	msg_aux(' ', FreeVar),
	portray_disequalities_aux_4(FreeVars).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% CONSTRAINT VERIFICATION %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

verify_attribute(Attribute, Target):-
%	debug(verify_attribute(Attribute, Target)), 
	attribute_contents(Attribute, NewTarget, _Is_UnivVar, Disequalities), 
	terms_are_equal(Target, NewTarget), !,
	update_var_attributes(Disequalities, [], []).

% Only for Ciao prolog 
verify_attribute(Attribute, NewTarget):-
%	debug('Only for Ciao Prolog: '),
%	debug(verify_attribute(Attribute, NewTarget)), 
	attribute_contents(Attribute, OldTarget, Is_UnivVar, Disequalities), !,
	(
	    (
		Is_UnivVar == true, % An universally quantified variable
		fail                          % is not unifiable.
	    )
	;
	    (
		Is_UnivVar == false, 
		substitution_contents(Subst, OldTarget, NewTarget),
		update_var_attributes(Disequalities, [], [Subst])
	    )
	).

substitution_contents(substitute(Var, T), Var, T).

combine_attributes(Attribute_Var_1, Attribute_Var_2) :-
	debug('combine_attributes(Attr_Var1, Attr_Var2)', (Attribute_Var_1, Attribute_Var_2)),
	attribute_contents(Attribute_Var_1, OldTarget_Var_1, Is_UnivVar_Var_1, Disequalities_Var_1), !,
	attribute_contents(Attribute_Var_2, OldTarget_Var_2, Is_UnivVar_Var_2, Disequalities_Var_2), !,
	(
	    (
		(
		    Is_UnivVar_Var_1 == true ;  % Universally quantified variables can not be unified.
		    Is_UnivVar_Var_2 == true
		),
		fail
	    )
	;
	    (
		Is_UnivVar_Var_1 == false, 
		Is_UnivVar_Var_2 == false, 
		cneg_aux:append(Disequalities_Var_1, Disequalities_Var_2, Disequalities),
		substitution_contents(Subst, OldTarget_Var_1, OldTarget_Var_2),
		update_var_attributes(Disequalities, [], [Subst])
	    )
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% An~ade la formula al atributo de las variables implicadas
% Por q tendriamos q tener en cuenta otros atributos?
% Como cada uno tiene su manejador, tratar de mezclar los atributos no aporta nada.

update_var_attributes(New_Disequalities, UV_In, Substitutions):-
	debug('update_var_attributes(New_Disequalities, UV_In, Substitutions)', (New_Disequalities, UV_In, Substitutions)), 
	varsbag_local(New_Disequalities, [], [], Vars), !,
	retrieve_affected_disequalities(Vars, [], UV_In, UV_Out, New_Disequalities, Disequalities_Tmp), !,
%	debug(retrieve_affected_disequalities(Vars, [], New_Disequalities, Disequalities_Tmp)),
	perform_substitutions(Substitutions, UV_Out, Disequalities_Tmp, Disequalities), !,
%	debug(perform_substitutions(Substitutions, Disequalities_Tmp, Disequalities)),

	varsbag_local(Disequalities, UV_Out, [], No_FV_In),
	simplify_disequations(Disequalities, No_FV_In, No_FV_Out, [], Simplified_Disequalities),
	debug('update_var_attributes(Simplified_Disequalities, No_FV_Out)', (Simplified_Disequalities, No_FV_Out)),
	restore_attributes(Simplified_Disequalities, No_FV_Out).

retrieve_affected_disequalities([], _Vars_Examined, UV_Out, UV_Out, Diseq_Acc_Out, Diseq_Acc_Out) :- !. % Loop over vars list.
retrieve_affected_disequalities([Var|Vars], Vars_Examined, UV_In, UV_Out, Diseq_Acc_In, Diseq_Acc_Out):- 
	var(Var), % It cannot be other things ...
	get_attribute_local(Var, Attribute), !,
	attribute_contents(Attribute, Var, Is_UnivVar, ThisVar_Disequalities), 
	remove_attribute_local(Var), 

	% Store info.
	add_to_univvars_if_it_is(Var, Is_UnivVar, UV_In, UV_Aux),
	varsbag_local(ThisVar_Disequalities, [Var|Vars_Examined], Vars, New_Vars), !,
	accumulate_disequations(ThisVar_Disequalities, Diseq_Acc_In, Diseq_Acc_Aux),
        retrieve_affected_disequalities(New_Vars, [Var|Vars_Examined], UV_Aux, UV_Out, Diseq_Acc_Aux, Diseq_Acc_Out).

retrieve_affected_disequalities([Var|Vars_In], Vars_Examined, UV_In, UV_Out, Diseq_Acc_In, Diseq_Acc_Out) :- 
        retrieve_affected_disequalities(Vars_In, [Var|Vars_Examined], UV_In, UV_Out, Diseq_Acc_In, Diseq_Acc_Out).

add_to_univvars_if_it_is(Var, true, UnivVars, [Var | UnivVars]).
add_to_univvars_if_it_is(_Var, false, UnivVars, UnivVars).

perform_substitutions([], _UnivVars, Disequalities_Out, Disequalities_Out) :- !.
perform_substitutions([Subst | MoreSubst], UnivVars, Disequalities_In, Disequalities_Out) :-
	substitution_contents(Subst, OldTarget, NewTarget),
	(
	    (
		(
		    memberchk_local(OldTarget, UnivVars);
		    memberchk_local(NewTarget, UnivVars)
		),
		msg('perform_substitutions', 'cannot substitute a universaly quantified variable.'),
		!, fail
	    )
	;
	    (
		diseq_eq(OldTarget, NewTarget), !,
		perform_substitutions(MoreSubst, UnivVars, Disequalities_In, Disequalities_Out)
	    )
	).

% diseq_eq(X,Y) unify X and Y
diseq_eq(X, X).
% eq(X,Y):-
 %       X=Y.


% Need old vars to play with them too.
restore_attributes([], _No_FV) :- !.
restore_attributes([Diseq | Diseq_List], No_FV) :-
	disequality_contents(Diseq, T_1, T_2),
	varsbag_local((T_1, T_2), No_FV, [], Affected_FreeVars),
	varsbag_local((T_1, T_2), [], [], Affected_Vars),
	!,
	restore_attributes_aux(Affected_Vars, Affected_FreeVars, Diseq),
	restore_attributes(Diseq_List, No_FV).

restore_attributes_aux([], _Affected_FreeVars, _Diseq) :- !.
restore_attributes_aux([Var|Vars], Affected_FreeVars, Diseq) :-
	restore_attributes_var(Var, Affected_FreeVars, Diseq),
	restore_attributes_aux(Vars, Affected_FreeVars, Diseq).

restore_attributes_var(Var, Affected_FreeVars, Diseq) :-
	var(Var),
	get_attribute_local(Var, Old_Attribute), !,
	remove_attribute_local(Var),
	generate_new_attribute(Var, Affected_FreeVars, Diseq, Old_Attribute, New_Attribute),
	put_attribute_local(Var, New_Attribute).

restore_attributes_var(Var, Affected_FreeVars, Diseq) :-
	var(Var),
	attribute_contents(Old_Attribute, Var, [], []),
	generate_new_attribute(Var, Affected_FreeVars, Diseq, Old_Attribute, New_Attribute),
	put_attribute_local(Var, New_Attribute).

generate_new_attribute(Var, Affected_FreeVars, Diseq, Old_Attribute, New_Attribute) :-
	attribute_contents(Old_Attribute, Var, Old_Diseq, Old_UnivVars),
	(
	    (
		memberchk_local(Var, Affected_FreeVars), !, 
		New_UnivVars = [Var],
		New_Diseq = []
	    )
	;
	    (
		varsbag_local(Old_UnivVars, [], Affected_FreeVars, New_UnivVars),
		New_Diseq = [Diseq | Old_Diseq]
	    )
	),
	attribute_contents(New_Attribute, Var, New_Diseq, New_UnivVars).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

accumulate_disequations([], Diseq_Acc_Out, Diseq_Acc_Out) :- !.
accumulate_disequations([Diseq | Diseq_List], Diseq_Acc_In, Diseq_Acc_Out) :-
	memberchk_local(Diseq, Diseq_Acc_In), !, % It is there.
	accumulate_disequations(Diseq_List, Diseq_Acc_In, Diseq_Acc_Out).
accumulate_disequations([Diseq | Diseq_List], Diseq_Acc_In, Diseq_Acc_Out) :-
	disequality_contents(Diseq, T1, T2),
	disequality_contents(Diseq_Aux, T2, T1), % Order inversion.
	memberchk_local(Diseq_Aux, Diseq_Acc_In), !, % It is there.
	accumulate_disequations(Diseq_List, Diseq_Acc_In, Diseq_Acc_Out).
accumulate_disequations([Diseq | Diseq_List], Diseq_Acc_In, Diseq_Acc_Out) :-
	accumulate_disequations(Diseq_List, [Diseq | Diseq_Acc_In], Diseq_Acc_Out).

simplify_disequations([], No_FV_Out, No_FV_Out, Diseq_Acc_Out, Diseq_Acc_Out) :- !.
simplify_disequations([Diseq|Diseq_List], No_FV_In, No_FV_Out, Diseq_Acc_In, Diseq_Acc_Out) :- !,
	simplify_1_diseq(Diseq, [], No_FV_In, No_FV_Aux, Simplified_Diseq),
	debug('simplify_disequations :: Simplified_Diseq', Simplified_Diseq), 
	accumulate_disequations(Simplified_Diseq, Diseq_Acc_In, Diseq_Acc_Aux),
	simplify_disequations(Diseq_List, No_FV_Aux, No_FV_Out, Diseq_Acc_Aux, Diseq_Acc_Out).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

simplify_1_diseq(Diseq, More_Diseq, No_FV_In, _No_FV_Out, _Answer) :-
%	debug('', ''),
	debug('simplify_1_diseq :: (Diseq, More_Diseq, No_FV_In)', (Diseq, More_Diseq, No_FV_In)), 
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
	memberchk_local(T1, Real_FreeVars), % Both are free vars.
	memberchk_local(T2, Real_FreeVars), !,
	simplify_1_diseq(fail, More_Diseq, No_FV_In, No_FV_Out, Answer).

simplify_1_diseq(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer) :- % Different vars.
	disequality_contents(Diseq, T1, T2),
        var(T1),
        var(T2), !, % Both are variables.
	varsbag_local(Diseq, No_FV_In, [], Real_FreeVars),
	(
	    (   % T1 is a free var, T2 is not a free var.
		memberchk_local(T1, Real_FreeVars), !,
		simplify_1_diseq_freevar_t1_var_t2(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	;
	    (   % T2 is a free var, T1 is not a free var.
		memberchk_local(T2, Real_FreeVars), !,
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
	cartesian_product_between_arguments(Args_1, Args_2, Diseq_List),
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

simplify_1_diseq_freevar_t1_var_t2(Diseq, More_Diseq, No_FV_In, No_FV_Out, Answer) :-
	disequality_contents(Diseq, T1, T2),
        var(T1),
        var(T2), 
	varsbag_local(Diseq, No_FV_In, [], Real_FreeVars),
	memberchk_local(T1, Real_FreeVars), !, % T1 is a free var, T2 is not a freevar.
	(
	    (   % T1 is going to be processed hereafter (appears in More_Diseq).
		varsbag_local(More_Diseq, No_FV_In, [], More_Diseq_Vars),
		memberchk_local(T1, More_Diseq_Vars), !,
		diseq_eq(T1, T2), % Answer is T1 = T2 and more
		simplify_1_diseq(fail, More_Diseq, [T1 | No_FV_In], No_FV_Out, Answer)
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
		    memberchk_local(T1, Vars_T2), !, % e.g. X =/= s(s(X)).
		    No_FV_In = No_FV_Out,
		    diseq_eq(Answer, []) % Answer is True.
		)
	    ;
		(   % T1 is a free var.
		    memberchk_local(T1, Real_FreeVars), !,
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
	memberchk_local(T1, Real_FreeVars), 
        functor_local(T2, _Name, _Arity, _Args_T2), !,
	(
	    (   % T1 is going to be processed (appears in More_Diseq).
		varsbag_local(More_Diseq, No_FV_In, [], More_Diseq_FreeVars),
		memberchk_local(T1, More_Diseq_FreeVars), !,
		diseq_eq(T1, T2), % Answer is T1 = T2 and more. T1 is NO more a variable.
		simplify_1_diseq(fail, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	;
	    (   % T1 appears only once, so it is not different from T2. Just fail.
		simplify_1_diseq(fail, More_Diseq, No_FV_In, No_FV_Out, Answer)
	    )
	).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
cartesian_product_between_arguments([], [], []) :- !.
cartesian_product_between_arguments([T1], [T2], [Diseq]) :- !,
	 disequality_contents(Diseq, T1, T2).
cartesian_product_between_arguments([T1 | Args_1], [T2 | Args_2], [Diseq | Args]) :- !,
	disequality_contents(Diseq, T1, T2),
	cartesian_product_between_arguments(Args_1, Args_2, Args).

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

cneg_diseq(T1,T2, FreeVars):- 
	debug('cneg_diseq(T1,T2)', cneg_diseq(T1,T2)), 
	disequality_contents(Disequality, T1, T2),
        update_var_attributes([Disequality], FreeVars, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


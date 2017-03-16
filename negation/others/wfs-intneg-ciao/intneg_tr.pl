%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Module for being loaded by intneg to add the complemented
% predicates to the predicates of the module that is being
% compiled. It uses intensional negation to obtain them.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- module(intneg_tr,[comp_pred/3]).
%:- export(comp_pred/3).

% :- import append/3 from basics.
:- use_module(library(lists),[append/3]).

% member/2, ground/1
% :- import unifiable/3 from constraintLib.
:- use_module(intneg_aux,[term_is_forall/1, term_is_not_forall/1,
	list_length/2, list_to_conj/2, mgu/3, clause_head/4,
	convert_clauses_format/3, revert_clauses_format/2,
	obtain_clause_cj/2, obtain_clause_body/2, 
%	obtain_clause_head/2, obtain_clause_arity/2,
	joint_bodies_with_op_and/3, joint_bodies_with_op_or/3,
	debug_cls/2, debug_formatted_cls/2, debug_separation/0,
	head_and_tail/3,
%	memberchk/2,
	find_equal_head_name_cls/4]).
%:- import term_is_forall/1, term_is_not_forall/1,
%	list_length/2, list_to_conj/2, mgu/3, clause_head/4,
%	convert_clauses_format/3, revert_clauses_format/2,
%	obtain_clause_cj/2, obtain_clause_body/2, 
%%	obtain_clause_head/2, obtain_clause_arity/2,
%	joint_bodies_with_op_and/3, joint_bodies_with_op_or/3,
%	debug_formatted_cls/2, debug_separation/0,
%	head_and_tail/3,
%%	memberchk/2,
%	find_equal_head_name_cls/4 from intneg_aux.

% :- import debug_intneg/2, debug_intneg_clauses/2 from intneg_io.
% write_sentence/3, write_sentences_list/3, 

% :- module(intneg_tr,_,[]).
% :- module(intneg_tr,[comp_pred/3],[]).

:- use_module(library(dynamic)).

% :- use_module(library(data_facts),[retract_fact/1]).
% :- use_module(library(lists),[append/3]).
% :- use_module(library(aggregates),[findall/4]).
% :- use_module(library(metaterms),[ask/2]). %Para Susana
% :- use_module(library(terms_check),[ask/2]).  %Para versiones posteriores
% :- use_module(library(idlists),[memberchk/2]).
%:- use_module(library(term_basic),[functor/3]).

% :- use_module(library(write),[write/1,write/2]). % For debugging

% dynamic predicates to store clauses that are going to be
% expanded. It is used to expand them in a continous way
% :- data pre_intneg/1.
:- dynamic pre_intneg/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% deep_forall(D) returns the level of deep that we are going to
% consider for expanding the coverings of the forall
% deep_forall(7).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Falta a�adir:
%intneg(G,fail):- ground(G), call(G), !.
%intneg(G,true):- ground(G), \+ call(G), !.


% intneg_impl(L) returns L that is the list of additional 
% clauses that complete the implementation of intneg/2
%intneg_impl([
%	(intneg((G1;G2)):- intneg(G1),intneg(G2)),
%	 (intneg((G1,G2)):- intneg(G1)),
%	  (intneg((G1,G2)):- intneg(G2)),
%	   (intneg(intneg(G)):- call(G)),
%	    end_of_file]).

% comp_pred(Sentence,SentList,Module) sustitutes Sentence in
% the program Module that is being compilated by the list of
% sentences SentList. The result clauses are continous
comp_pred(end_of_file, OutCls, _):- !,
	findall(CL,(retract(pre_intneg(CL))),Cls), !, 
	debug_cls('comp_pred Cls: ', Cls),
	convert_clauses_format(Cls, F_Cls, Invalid_Clauses),
	debug_formatted_cls('comp_pred F_Cls: ', F_Cls),
	!, % Backtracking not allowed.
	remove_overlapping_clauses(F_Cls, F_NonOvCls),
	!, % Backtracking not allowed.
	debug_formatted_cls('comp_pred (F_Cls -> F_NonOvCls) F_NonOvCls: ', F_NonOvCls),
	intensional_negation(F_NonOvCls, F_Intneg_Cls),
	!, % Backtracking not allowed.
	debug_formatted_cls('comp_pred (F_NonOvCls -> F_Intneg_Cls) F_Intneg_Cls: ', F_Intneg_Cls),
	convert_cls_nocjs_to_dist(F_NonOvCls, F_Positive_Cls),
	!, % Backtracking not allowed.
	debug_formatted_cls('comp_pred (F_NonOvCls -> F_Positive_Cls) F_Positive_Cls: ', F_Positive_Cls),
	convert_cls_nocjs_to_dist(F_Intneg_Cls, F_Negative_Cls),
	!, % Backtracking not allowed.
	debug_formatted_cls('comp_pred (F_Intneg_Cls -> F_Negative_Cls) F_Negative_Cls: ', F_Negative_Cls),
	include_wfs_behaviour(F_Positive_Cls, F_Negative_Cls, F_WFS_Positive_Cls, F_WFS_Intneg_Cls),
	!, % Backtracking not allowed.
	debug_formatted_cls('comp_pred (F_Positive_Cls -> F_WFS_Positive_Cls) F_WFS_Positive_Cls: ', F_WFS_Positive_Cls),
	debug_formatted_cls('comp_pred (F_Negative_Cls -> F_WFS_Intneg_Cls) F_WFS_Intneg_Cls: ', F_WFS_Intneg_Cls),
	append(F_WFS_Positive_Cls, F_WFS_Intneg_Cls, F_OutCls),
	!, % Backtracking not allowed.
	debug_formatted_cls('comp_pred (F_WFS_Positive_Cls + F_WFS_Intneg_Cls -> F_OutCls) F_OutCls: ', F_OutCls),
	revert_clauses_format(F_OutCls, All_Cls),
	!, % Backtracking not allowed.
	
% Add auxiliar clauses.
	wfs_intneg_impl(WFS_Intneg_Cls),
%	intneg_impl(Intneg_Cls),
	forall_impl(Forall_Cls),
%
%	append(WFS_Intneg_Cls, Intneg_Cls, Aux_Cls_1),
%	append(Forall_Cls, Aux_Cls_1, Aux_Cls_2),
	append(Forall_Cls, WFS_Intneg_Cls, Aux_Cls_2),
	append(Aux_Cls_2, Invalid_Clauses, Aux_Cls_3),
	append(Aux_Cls_3, All_Cls, OutCls_Aux),
	append(OutCls_Aux, [end_of_file], OutCls),
%
	!, % Backtracking not allowed.
	debug_formatted_cls('comp_pred (F_OutCls + Aux Preds -> OutCls) OutCls: ', OutCls), nl.

comp_pred(Fact_Cl, [], _):-  % As facts as clauses
	assertz(pre_intneg(Fact_Cl)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

convert_cls_nocjs_to_dist([], []).
convert_cls_nocjs_to_dist([Cl], [Dist_Cl]) :-
	convert_cl_nocjs_to_dist_body(Cl, Cl_Without_NoCj, Dist_Body),
	add_body_to_clause(Dist_Body, Cl_Without_NoCj, Dist_Cl).
convert_cls_nocjs_to_dist([Cl|Others_Cl], [Dist_Cl|Others_Dist_Cl]) :-
	convert_cl_nocjs_to_dist_body(Cl, Cl_Without_NoCj, Dist_Body),
	add_body_to_clause(Dist_Body, Cl_Without_NoCj, Dist_Cl),
	convert_cls_nocjs_to_dist(Others_Cl, Others_Dist_Cl).

convert_cl_nocjs_to_dist_body(cl(Name, Arity, Cjs, NoCjs, Body1, N),
			      cl(Name, Arity, Cjs, [], Body1, N),
			      Body2) :-
	nocjs_to_dist_body(Arity, Cjs, NoCjs, Body2), !.
convert_cl_nocjs_to_dist_body(Cl, Cl, error) :-
	write('% DBG % ERROR % convert_cl_nocjs_to_dist_body fails. Cl: '), 
	write(Cl), nl.

nocjs_to_dist_body(Arity, [], _NoCjs, body([])) :-
	Arity == 0, !.
nocjs_to_dist_body(Arity, Cjs, NoCjs, Body) :-
	Arity > 0,
	Cjs \== [], !,
	nocjs_to_dist_body_aux_1(Cjs, NoCjs, body([]), Body).

nocjs_to_dist_body_aux_1(_Cjs, [], Body1, Body1) :- !.
nocjs_to_dist_body_aux_1(Cjs, [NoCj], Body1, Body2) :- !,
	nocjs_to_dist_body_aux_2(Cjs, NoCj, Body1, Body2).
nocjs_to_dist_body_aux_1(Cjs, [NoCj|NoCjs], Body1, Body3) :- !,
	nocjs_to_dist_body_aux_2(Cjs, NoCj, Body1, Body2),
	nocjs_to_dist_body_aux_1(Cjs, NoCjs, Body2, Body3).

nocjs_to_dist_body_aux_2(Cj, NoCj, Body1, Body2) :-
	list_to_conj(Cj, Conj_Cj),
	list_to_conj(NoCj, Conj_NoCj),
	change_free_vars_by_fA(Conj_NoCj),
	joint_bodies_with_op_and(body(intneg_dist(Conj_Cj, Conj_NoCj)), Body1, Body2),
	!. % Backtracking not allowed.

add_body_to_clause(Dist_Body,
		   cl(Name, Arity, Cjs, [], Body1, N),
		   cl(Name, Arity, Cjs, [], Body2, N)) :-
	joint_bodies_with_op_and(Dist_Body, Body1, Body2).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

remove_overlapping_clauses(F_Cls, F_NonOvCls) :-
	debug_separation,
	write('% DBG % ----------------- REMOVE OVERLAPPINGS -----------------'), nl,
	debug_separation, nl,
	remove_overlappings(F_Cls, F_NonOvCls).

remove_overlappings([], []) :- !.
remove_overlappings([Cl], [Cl]) :- !. % 1 cl has not overlappings.
remove_overlappings([Cl | F_Cls], F_NonOvCls) :-
	find_equal_head_name_cls(Cl, [Cl | F_Cls], EqName_Cls, NotEqName_Cls),
%	debug_formatted_cls('remove_overlappings: find_equal_head_name_cls', EqName_Cls), 
	remove_overlappings_aux(EqName_Cls, EqName_NonOvCls),
%	debug_formatted_cls('remove_overlappings: remove_overlappings_aux: Final NonOv Cls: ', EqName_NonOvCls), nl,
%	debug_separation,
	remove_overlappings(NotEqName_Cls, NotEqName_NonOvCls),
	append(EqName_NonOvCls, NotEqName_NonOvCls, F_NonOvCls).
remove_overlappings(F_Cls, []) :-
	debug_separation,
	write('% DBG % ERROR % remove_overlappings fails. '), 
	debug_formatted_cls('F_Cls: ', F_Cls).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% It finds overlappings and non-overlappings and
% changes overlappings by non-overlappings.
remove_overlappings_aux(Cls, NonOv_Cls) :-
	
	% Find overlappings
	find_overlappings(Cls, Ov_Cls_Aux), !, 
%	debug_formatted_cls('remove_overlappings_aux: Ov_Cls_Aux:', Ov_Cls_Aux),
	remove_overlappings_with_common_mgu(Ov_Cls_Aux, Ov_Cls), !,
%	debug_formatted_cls('remove_overlappings_aux Ov_Cls:', Ov_Cls),

	% Buid mgu clauses.
	build_mgu_nonov_cls(Ov_Cls, Mgu_NonOv_Cls), !,
%	debug_formatted_cls('remove_overlappings_aux Mgu_NonOv_Cls:', Mgu_NonOv_Cls), 

	% Sustract mgu from original clauses.
	sustract_mgus_from_clauses(Cls, Ov_Cls, NonOv_Cls_Aux), !,
%	debug_formatted_cls('remove_overlappings_aux NonOv_Cls:', NonOv_Cls_Aux), 
	append(Mgu_NonOv_Cls, NonOv_Cls_Aux, NonOv_Cls).

remove_overlappings_aux(Cls, []) :-
	debug_separation,
	nl, write('% DBG % ERROR % remove_overlappings_aux fails. '), 
	debug_formatted_cls('F_Cls: ', Cls).
	

find_fcls_mgu(cl(Name, Arity, Cj1, _NoCj1, _B1, _N1),
	      cl(Name, Arity, Cj2, _NoCj2, _B2, _N2),
	      cl(Name, Arity, Mgu, [], body([]), 0)) :-
	mgu(Cj1, Cj2, Mgu), !.	% Hay MGU entre ellos.


%find_overlappings(Cls, []) :- 
%	debug_formatted_cls('find_overlappings: Cls: ', Cls),
%	fail.
find_overlappings([], [] ) :- !.
find_overlappings([_Cl], [] ) :- !.
find_overlappings([Cl|Cls], Ov ) :- find_ov_aux_1(Cl, Cls, Ov).


find_ov_aux_1(_Cl1, [], [] ) :- !.
find_ov_aux_1(Cl1, [Cl2|Cls], Ovs) :- !,
	find_ov_aux_2(Cl1, Cl2, Cls, Ov_1),
	find_ov_aux_1(Cl2, Cls, Ov_2),
	append(Ov_1, Ov_2, Ovs).

find_ov_aux_2(Cl1, Cl2, Cls, Ovs) :-
	find_fcls_mgu(Cl1, Cl2, Mgu), !,
	find_ov_aux_3(Mgu, Cls, [Cl1, Cl2], Ovs). % With mgu

find_ov_aux_2(_Cl1, _Cl2, _Cls, []) :- !. % No mgu

find_ov_aux_3(Mgu, [],        Ov,  [[Mgu | Ov]]) :- !. % End
find_ov_aux_3(Mgu, [Cl1|Cls], Ov_In, Ov_Out) :- % Mgu
	find_ov_aux_4(Mgu, Cl1, Cls, Ov_In, Ov_Out_1),
	find_ov_aux_3(Mgu, Cls, Ov_In, Ov_Out_2),
	append(Ov_Out_1, Ov_Out_2, Ov_Out).

find_ov_aux_4(Mgu, Cl1, Cls, Ov_In, Ov_Out) :-
	find_fcls_mgu(Mgu, Cl1, Mgu2), !,
	append(Ov_In, [Cl1], Ov_Aux),
	find_ov_aux_3(Mgu2, Cls, Ov_Aux, Ov_Out).
find_ov_aux_4(_Mgu, _Cl1, _Cls, _Ov_In, []) :- !.


% remove_overlappings_with_common_mgu(Ov_Cls, Ov_Cls_Diff_Mgu)
remove_overlappings_with_common_mgu([], []) :- !.
remove_overlappings_with_common_mgu([Ov_Cl], [Ov_Cl]) :- !.
remove_overlappings_with_common_mgu([Ov_Cl|Ov_Cls], Ov_Cls_Diff_Mgu) :- !,
	remove_ovs_same_mgu([Ov_Cl|Ov_Cls],
			    [Ov_Cl|Ov_Cls],
			    Ov_Cls_Diff_Mgu).

remove_ovs_same_mgu([], _Cls2, []).
remove_ovs_same_mgu([Cl1], Cls2, Cls3) :-
	remove_ovs_same_mgu_aux_1(Cl1, Cls2, [], Cls3).
remove_ovs_same_mgu([Cl1|Cls1], Cls2, Cls3) :-
	remove_ovs_same_mgu_aux_1(Cl1, Cls2, [], Cls3_1),
	remove_ovs_same_mgu(Cls1, Cls2, Cls3_2),
	append(Cls3_1, Cls3_2, Cls3).

remove_ovs_same_mgu_aux_1(Cl1,  [],  [],   [Cl1]) :- !. % Best mgu
remove_ovs_same_mgu_aux_1(_Cl1, [], _Cls3, []) :- !. % Remove mgu

remove_ovs_same_mgu_aux_1(Cl1, [Cl2], Cls3, Cls5) :-
	remove_ovs_same_mgu_aux_2(Cl1, Cl2, Cls3, Cls4),
	remove_ovs_same_mgu_aux_1(Cl1, [], Cls4, Cls5).
remove_ovs_same_mgu_aux_1(Cl1, [Cl2|Cls2], Cls3, Cls5) :-
	remove_ovs_same_mgu_aux_2(Cl1, Cl2, Cls3, Cls4),
	remove_ovs_same_mgu_aux_1(Cl1, Cls2, Cls4, Cls5).

remove_ovs_same_mgu_aux_2(Cl1, Cl2, Cls3, Cls3) :-
	head_and_tail(Cl1, Mgu1, _Tail1),
	head_and_tail(Cl2, Mgu2, _Tail2),
	obtain_clause_cj(Mgu1, Cj1),
	obtain_clause_cj(Mgu2, Cj2),
	mgu(Cj1, Cj2, _Common_Mgu),
	list_length(Cl1, L1),
	list_length(Cl2, L2),
	L1 >= L2, !.
remove_ovs_same_mgu_aux_2(Cl1, Cl2, Cls3, [Cl2|Cls3]) :-
	head_and_tail(Cl1, Mgu1, _Tail1),
	head_and_tail(Cl2, Mgu2, _Tail2),
	obtain_clause_cj(Mgu1, Cj1),
	obtain_clause_cj(Mgu2, Cj2),
	mgu(Cj1, Cj2, _Common_Mgu),
	list_length(Cl1, L1),
	list_length(Cl2, L2),
	L1 < L2, !.
remove_ovs_same_mgu_aux_2(_Cl1, _Cl2, Cls3, Cls3) :- !. % No mgu between them.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

build_mgu_nonov_cls(Ov_Cls, Mgu_NonOv_Cls) :-
%	debug_formatted_cls('build_mgu_nonov_cls Mgu_NonOv_Cls:', Mgu_NonOv_Cls), !,
	build_mgu_nonov_cls_aux(Ov_Cls, Mgu_NonOv_Cls), !.

build_mgu_nonov_cls(Ov_Cls, []) :-
	debug_separation,
	nl, write('% DBG % ERROR % build_mgu_nonov_cls fails. '), 
	debug_formatted_cls('Ov_Cls: ', Ov_Cls).


build_mgu_nonov_cls_aux([], []) :- !.
build_mgu_nonov_cls_aux([Ov_Cls|More_Ov_Cls], [Mgu_NonOv_1_Cl|Mgu_NonOv_Cls]) :-
	build_mgu_nonov_1_mgu_cls(Ov_Cls, Mgu_NonOv_1_Cl),
	build_mgu_nonov_cls_aux(More_Ov_Cls, Mgu_NonOv_Cls).

build_mgu_nonov_1_mgu_cls([Mgu|Ov_Cls], Mgu_NonOv_1_Cl) :-
	include_cls_bodies_in_mgu_cl(Mgu, Ov_Cls, Mgu_NonOv_1_Cl).

% Includes the bodies of Cls_Copy into the body of Mgu_Copy.
include_cls_bodies_in_mgu_cl(Mgu_Copy, [], Mgu_Copy).
include_cls_bodies_in_mgu_cl(Mgu_Copy1, [Cl_Copy], Mgu_Copy2) :-
	include_cl_body_in_mgu_cl(Mgu_Copy1, Cl_Copy, Mgu_Copy2).
include_cls_bodies_in_mgu_cl(Mgu_Copy1, [Cl_Copy|Cls_Copy], Mgu_Copy3) :-
	include_cl_body_in_mgu_cl(Mgu_Copy1, Cl_Copy, Mgu_Copy2),
	include_cls_bodies_in_mgu_cl(Mgu_Copy2, Cls_Copy, Mgu_Copy3).


include_cl_body_in_mgu_cl(Mgu1, Cl, Mgu2) :-
	copy_term(Cl, Cl_Copy),
	unificate_cl_with_mgu(Mgu1, Cl_Copy),
	% write(unificate_cl_with_mgu(Mgu1, Cl_Copy)), nl, 
	include_cl_body_in_mgu_cl_aux(Mgu1, Cl_Copy, Mgu2).

include_cl_body_in_mgu_cl_aux(cl(Name, Arity,  Cj,  NoCjs, Body1, N),
			      Clause,
			      cl(Name, Arity,  Cj,  NoCjs, Body, N)) :-
	obtain_clause_body(Clause, Body2),
	joint_bodies_with_op_or(Body1, Body2, Body).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sustract_mgus_from_clauses(Cls, Ov_Cls_2, NonOv_Cls) :-
	sustract_mgus_from_clauses_aux(Cls, Ov_Cls_2, NonOv_Cls), !.

sustract_mgus_from_clauses(Cls, Ov_Cls_2, []) :-
	debug_separation,
	nl, write('% DBG % ERROR % sustract_mgus_from_clauses fails. '), 
	debug_formatted_cls('Cls: ', Cls),
	debug_formatted_cls('Ov_Cls_2: ', Ov_Cls_2).


sustract_mgus_from_clauses_aux(Any, [], Any) :- !. % Nothing to sustract
sustract_mgus_from_clauses_aux([], _Ov_Cls, []) :- !.
sustract_mgus_from_clauses_aux([Cl|Cls], Ov_Cls, NonOv_Cls) :-
	sustract_mgus_from_1_clause(Cl, Ov_Cls, NonOv_Cl), 
	sustract_mgus_from_clauses_aux(Cls, Ov_Cls, NonOv_Cls_Aux),
	append(NonOv_Cl, NonOv_Cls_Aux, NonOv_Cls).

sustract_mgus_from_1_clause(Cl, Ov_Cls, NonOv_Cl) :-
	obtain_mgus_to_sustract(Cl, Ov_Cls, Mgus),
%	debug_formatted_cls('obtain_mgus_to_sustract Cl: ', Cl), 
%	debug_formatted_cls('obtain_mgus_to_sustract Mgus: ', Mgus), 
	sustract_mgus_from_1_clause_aux_1([Cl], Mgus, NonOv_Cl),
	!.
sustract_mgus_from_1_clause(Cl, Ov_Cls, []) :-
	debug_separation,
	nl, write('% DBG % ERROR % sustract_mgus_from_1_clause fails. '), 
	debug_formatted_cls('Cl: ', Cl),
	debug_formatted_cls('Ov_Cls: ', Ov_Cls).

obtain_mgus_to_sustract(_Cl, [], []) :- !.
obtain_mgus_to_sustract( Cl, [[Mgu|Ov_Cls]|Other_Ov_Cls], [Mgu|Mgus]) :-
	cl_is_in_ovs_list(Cl, Ov_Cls), !,
	obtain_mgus_to_sustract(Cl, Other_Ov_Cls, Mgus).
obtain_mgus_to_sustract( Cl, [[_Mgu|_Ov_Cls]|Other_Ov_Cls], Mgus) :-
	obtain_mgus_to_sustract(Cl, Other_Ov_Cls, Mgus).

cl_is_in_ovs_list(Cl1, [Cl2|_Others_Cls]) :-
	cls_have_same_number(Cl1, Cl2), !.
cl_is_in_ovs_list(Cl1, [_Cl2|Others_Cls]) :-
	cl_is_in_ovs_list(Cl1, Others_Cls).

cls_have_same_number(cl(_Name1, _Arity1, _Cj1, _NoCjs1, _Body1, N),
		     cl(_Name2, _Arity2, _Cj2, _NoCjs2, _Body2, N)).

sustract_mgus_from_1_clause_aux_1(Cl_In, Mgus, Cl_Out) :-
	sustract_mgus_from_1_clause_aux_2(Cl_In, Mgus, Cl_Out), !.
sustract_mgus_from_1_clause_aux_1(Cl_In, Mgus, Cl_In) :-
	debug_separation,
	nl, write('% DBG % ERROR % sustract_mgus_from_1_clause_aux_1 fails. '), 
	debug_formatted_cls('Cl: ', Cl_In),
	debug_formatted_cls('Mgus: ', Mgus).

sustract_mgus_from_1_clause_aux_2(Cl, [], Cl) :- !.
sustract_mgus_from_1_clause_aux_2(Cl_In, [Mgu|Mgus], Cl_Out) :- !,
	sustract_mgus_from_1_clause_aux_3(Cl_In, Mgu, Cl_Aux),
	sustract_mgus_from_1_clause_aux_2(Cl_Aux, Mgus, Cl_Out).

%sustract_mgus_from_1_clause_aux_3(Cl, Mgu, _Any) :-
%	debug_formatted_cls('sustract_mgus_from_1_clause_aux_3 Cl: ', Cl),
%	debug_formatted_cls('sustract_mgus_from_1_clause_aux_3 Mgu: ', Mgu),
%	fail.
sustract_mgus_from_1_clause_aux_3([],  _Mgu, []) :- !.
sustract_mgus_from_1_clause_aux_3([Cl], Mgu, NonOv_Cl) :-
	obtain_clause_cj(Mgu, Mgu_Cj),
	apply_impositions_from_mgu(Mgu_Cj, Cl, NonOv_Cl).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Includes in NoCj of each clause the Mgu's Cj.
apply_impositions_from_mgu(Mgu_Cj, Cl, NonOv_Cl) :-
	apply_impositions_from_mgu_aux(Mgu_Cj, Cl, NonOv_Cl), !.
apply_impositions_from_mgu(Mgu_Cj, Cl, []) :-
	debug_separation,
	nl, write('% DBG % ERROR % apply_impositions_from_mgu fails. '), 
	debug_formatted_cls('Mgu_Cj: ', Mgu_Cj),
	debug_formatted_cls('Cl: ', Cl).

apply_impositions_from_mgu_aux(Mgu_Cj, Cl, []) :-
	obtain_clause_cj(Cl, Cl_Cj),
	mgu_imposes_nothing(Mgu_Cj, Cl_Cj), !.

apply_impositions_from_mgu_aux(Mgu_Cj, Cl, [NonOv_Cl]) :-
	copy_term(Mgu_Cj, Mgu_Cj_Copy),
	include_in_NoCj(Mgu_Cj_Copy, Cl, NonOv_Cl).


% mgu_imposes_something(Mgu_Cj, Cl_Cj) :-
mgu_imposes_nothing(Mgu_Cj, Cl_Cj) :-
	write('% DBG % mgu_imposes_nothing: (Mgu_Cj, Cl_Cj): '), 
	write((Mgu_Cj, Cl_Cj)), 
	mgu_imposes_nothing_list(Mgu_Cj, Cl_Cj, [], _VE),
	write(' ---> YES '), nl,
	!.
mgu_imposes_nothing(_Mgu_Cj, _Cl_Cj) :-
	write(' ---> NO '), nl,
	!, fail. % End

mgu_imposes_nothing_list([], [], VE, VE) :- !.
mgu_imposes_nothing_list([T1_1 | T1_Others], [T2_1 | T2_Others], VE_In, VE_Out) :-
	mgu_imposes_nothing_1_term(T1_1, T2_1, VE_In, VE_Aux), !,
	mgu_imposes_nothing_list(T1_Others, T2_Others, VE_Aux, VE_Out).

mgu_imposes_nothing_1_term(T1, T2, VE_In, VE_Out) :- 
	var(T1), var(T2), !,
	mgu_imposes_nothing_vars(T1, T2, VE_In, VE_Out).

mgu_imposes_nothing_1_term(T1, _T2, VE_In, VE_In) :- 
	var(T1), !.
mgu_imposes_nothing_1_term(_T1, T2, VE_In, VE_In) :- 
	var(T2), !, fail.

mgu_imposes_nothing_1_term(T1, T2, VE_In, VE_Out) :-
	clause_head(T1, Name, Arity, Args_1),
	clause_head(T2, Name, Arity, Args_2), !,
	mgu_imposes_nothing_list(Args_1, Args_2, VE_In, VE_Out).

mgu_imposes_nothing_vars(V1, V2, VE_In, VE_In) :-
	var(V1), var(V2),
	memberchk_slash_1(V1/V2, VE_In), !.
mgu_imposes_nothing_vars(V1, V2, VE_In, VE_In) :-
	var(V1), var(V2),
	memberchk_slash_2(V1/_V3, VE_In), !, fail.
% mgu_imposes_nothing_vars(V1, V2, VE_In, VE_In) :-
%	var(V1), var(V2),
%	memberchk_slash_3(_V3/V2, VE_In), !, fail.
mgu_imposes_nothing_vars(V1, V2, VE_In, [V1/V2|VE_In]) :-
	var(V1), var(V2), !.

memberchk_slash_1(T1/T2, [ T3/ T4|_Others]) :- T1 == T3, T2 == T4, !.
memberchk_slash_1(T1/T2, [_T3/_T4| Others]) :- memberchk_slash_1(T1/T2, Others).
memberchk_slash_2(T1/T2, [ T3/ T2|_Others]) :- T1 == T3, !.
memberchk_slash_2(T1/T2, [_T3/_T4| Others]) :- memberchk_slash_2(T1/T2, Others).
% memberchk_slash_3(T1/T2, [ T1/ T4|_Others]) :- T2 == T4, !.
% memberchk_slash_3(T1/T2, [_T3/_T4| Others]) :- memberchk_slash_2(T1/T2, Others).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

include_in_NoCj(NewNoCj,
		cl(Name, Arity, Cjs, NoCjs, Body, N),
		cl(Name, Arity, Cjs, [NewNoCj|NoCjs], Body, N)).

%unificate_cls_with_mgu(_Mgu, []) :- !.
%unificate_cls_with_mgu(Mgu,  [Cl]) :- !,
%	unificate_cl_with_mgu(Mgu, Cl).
%unificate_cls_with_mgu(Mgu,  [Cl|Cls]) :- !,
%	unificate_cl_with_mgu(Mgu, Cl),
%	unificate_cls_with_mgu(Mgu, Cls).

unificate_cl_with_mgu(cl(Name, Arity, Cj1, _NoCjs1, _Body1, _N1),
		      cl(Name, Arity, Cj2, _NoCjs2, _Body2, _N2)) :-
	unificate_cjs(Cj1, Cj2).
%	write(unificate_cjs(Cjs1, Cjs2)),
%	write(' --> OK'), nl.

unificate_cjs([],[]) :- !.
unificate_cjs([Cj1], [Cj2]) :- !,
	Cj1=Cj2.
unificate_cjs([Cj1|Cjs1],[Cj2|Cjs2]):-
	Cj1=Cj2,
        unificate_cjs(Cjs1,Cjs2).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

intensional_negation(NonOv_Clauses, Negated_Clauses) :-
	debug_separation,
	write('% DBG % ------------ INTENSIONAL NEGATION ------------'), nl,
	debug_separation, nl, 
	intensional_negation_aux(NonOv_Clauses, Negated_Clauses), !.
intensional_negation(NonOv_Clauses, []) :-
	nl, nl, 
	write('% DBG % ERROR % Intensional negation fails !!! '), nl,
	debug_formatted_cls('intensional_negation: NonOv_Clauses: ', NonOv_Clauses), nl,
	debug_separation, !.


% Separa las Cls por nombre.
intensional_negation_aux([], []) :- !.
intensional_negation_aux([Cl], EqName_Neg_Cls) :- !, 
	intensional_negation_aux_2([Cl], EqName_Neg_Cls).
intensional_negation_aux([Cl|Cls], Neg_Cls) :- !,
	find_equal_head_name_cls(Cl, [Cl|Cls], EqName_Cls, NotEqName_Cls),
%	debug_formatted_cls('intensional_negation_aux: find_equal_head_name_cls: EqName_Cls: ',
%			    EqName_Cls),
	!, % Do not do backtracking !!!
	intensional_negation_aux_2(EqName_Cls, EqName_Neg_Cls),
	!, % Do not do backtracking !!!
%	debug_formatted_cls('intensional_negation_aux: EqName_Neg_Cls: ', EqName_Neg_Cls), 
%	debug_separation, 
	intensional_negation_aux(NotEqName_Cls, NotEqName_Neg_Cls),
	append(EqName_Neg_Cls, NotEqName_Neg_Cls, Neg_Cls).

intensional_negation_aux_2(Cls, Neg_Cls) :-
%	debug_formatted_cls('intensional_negation_aux_2: Cls: ', Cls), 
	negate_cjs(Cls, Neg_Cjs_Cl),
%	debug_formatted_cls('intensional_negation_aux_2: Neg_Cjs_Cls: ', [Neg_Cjs_Cl]), 
	negate_cls(Cls, Neg_Bodies_Cls),
%	debug_formatted_cls('intensional_negation_aux_2: Neg_Bodies_Cls: ', Neg_Bodies_Cls), 
	append(Neg_Cjs_Cl, Neg_Bodies_Cls, Neg_Cls).
intensional_negation_aux_2(Cls, []) :-
	nl, nl, 
	write('% DBG % ERROR % Intensional negation fails !!! '), nl,
	debug_formatted_cls('intensional_negation_aux_2: Cls: ', Cls), nl,
	debug_separation, !.

negate_cjs([Cl], Neg_Cjs_Cl) :-
	collect_cls_cjs([Cl], [], Cls_Cjs),
	negate_cjs_aux(Cl, Cls_Cjs, Neg_Cjs_Cl), !.
negate_cjs([Cl|Cls], Neg_Cjs_Cl) :-
	collect_cls_cjs([Cl|Cls], [], Cls_Cjs),
	negate_cjs_aux(Cl, Cls_Cjs, Neg_Cjs_Cl), !.

collect_cls_cjs([], Cjs_In, Cjs_In) :- !.
collect_cls_cjs([Cl], Cjs_In, Cjs_Out) :- !,
	collect_cls_cjs_aux(Cl, Cjs_In, Cjs_Out).
collect_cls_cjs([Cl|Cls], Cjs_In, Cjs_Out) :- !,
	collect_cls_cjs_aux(Cl, Cjs_In, Cjs_In2),
	collect_cls_cjs(Cls, Cjs_In2, Cjs_Out).

collect_cls_cjs_aux(cl(_Name, Arity, _Cj, _NoCjs, _Body, _N),
		    Cjs_In, Cjs_In) :-
	Arity == 0, !. % No Cjs.
collect_cls_cjs_aux(cl(_Name, Arity, Cj, _NoCjs, _Body, _N),
		    Cjs_In, [Cj_Copy|Cjs_In]) :-
	Arity \== 0, !,
	copy_term(Cj, Cj_Copy).


negate_cjs_aux(_Cl, [], []) :- !. % Clauses of arity 0.

negate_cjs_aux(cl(Name, Arity, _Cj, _NoCjs, _Body,   _N),
	       Cls_Cjs,
	       [cl('intneg', 1, [New_Cj], [], Intneg_Body, 0)]) :-
	Cls_Cjs \== [], !,

	clause_head(New_Cj, Name, Arity, Old_Cj),
%%	nocjs_to_dist_body(Arity, Cjs, NoCjs, Body)
	nocjs_to_dist_body(Arity, Old_Cj, Cls_Cjs, Intneg_Body).

% Old way ...
%negate_cjs_aux_4(0, _Cjs1, _Args, Body2, Body3) :- !,
%	joint_bodies_with_op_and(body(fail), Body2, Body3).
%negate_cjs_aux_4(Arity1, Cjs1, Args, Body2, Body3) :-
%	Arity1 > 0, !, 
%	copy_term(Cjs1, Cjs1_Copy),
%	debug_formatted_cls('negate_cjs_aux_4: Cjs1: ', Cjs1),
%	debug_formatted_cls('negate_cjs_aux_4: Cjs1_Copy: ', Cjs1_Copy),
%	change_free_vars_by_fA(Cjs1_Copy),
%	write(change_free_vars_by_fA(Cjs1_Copy, Cjs1_fA)), nl,

%	list_to_conj(Args, Conj_Args),
%	list_to_conj(Cjs1_Copy, Conj_Cjs1_fA),
	
%	write('joint_bodies_with_op_and '), nl,
%	write(Body2), nl,
%	write(joint_bodies_with_op_and(body(dist(Conj_Args, Conj_Cjs1_fA)), Body2)), nl, !,
%	joint_bodies_with_op_and(body(dist(Conj_Args, Conj_Cjs1_fA)), Body2, Body3).
%	write(joint_bodies_with_op_and(body(dist(Conj_Args, Conj_Cjs1_fA)), Body2, Body3)), nl.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Receives a head and returns the variables that appear once in it
% changed by fA(_). Those vars have a universal quantification.
% Repeated vars do not need to be changed by fA(_).

change_free_vars_by_fA(Terms) :-
%	debug_formatted_cls('change_free_vars_by_fA: Terms IN: ', Terms),
	get_variables_from_term(Terms, [], ListVars),
%	debug_formatted_cls('change_free_vars_by_fA: ListVars: ', ListVars),
	get_variables_that_appear_once(ListVars, [], [], ListVars_Once, _ListVars_Repeated),
%	debug_formatted_cls('change_free_vars_by_fA: ListVars_Once: ', ListVars_Once),
	unify_variables_with_fA(ListVars_Once),
%	debug_formatted_cls('change_free_vars_by_fA: Terms OUT: ', Terms),
%	debug_separation,
	!. % Backtracking is not allowed.

change_free_vars_by_fA(Terms) :-
	debug_formatted_cls('change_free_vars_by_fA fails. Terms: ',
			    Terms), !.

% Lo is List of vars that appear once.
% Lr is List of vars that appear more than once.
get_variables_from_term(Term, ListVars, [Term|ListVars]) :-
	var(Term), !.

get_variables_from_term(Term, ListVars_In, ListVars_Out):-
	clause_head(Term, _Name, _Arity, Args),
	term_is_not_forall(Term),
	get_variables_from_term_list(Args, ListVars_In, ListVars_Out).

get_variables_from_term(Term, ListVars_In, ListVars_In):-
	clause_head(Term, _Name, _Arity, _Args),
	term_is_forall(Term).

get_variables_from_term_list([], ListVars, ListVars).
get_variables_from_term_list([X], ListVars_In, ListVars_Out):-
	get_variables_from_term(X, ListVars_In, ListVars_Out).
get_variables_from_term_list([X|Xs], ListVars_In, ListVars_Out_2):-
	get_variables_from_term(X, ListVars_In, ListVars_Out_1),
	get_variables_from_term_list(Xs, ListVars_Out_1, ListVars_Out_2).

% get_variables_that_appear_once(ListVars, Lo_In, Lr_In, Lo_Out, Lr_Out)
get_variables_that_appear_once([], Lo_In, Lr_In, Lo_In, Lr_In) :- !.
get_variables_that_appear_once([Var], Lo_In, Lr_In, Lo_Out, Lr_Out) :- !,
	get_variables_that_appear_once_aux(Var, Lo_In, Lr_In, Lo_Out, Lr_Out).
get_variables_that_appear_once([Var|Others], Lo_In, Lr_In, Lo_Out, Lr_Out) :- !,
	get_variables_that_appear_once_aux(Var, Lo_In, Lr_In, Lo_Out_1, Lr_Out_1),
	get_variables_that_appear_once(Others, Lo_Out_1, Lr_Out_1, Lo_Out, Lr_Out).

get_variables_that_appear_once_aux(Var, Lo_In, Lr_In, Lo_Out, [Var|Lr_In]) :-
	variable_is_in_list(Var, Lo_In), !,
 	remove_variable_from_list(Var, Lo_In, Lo_Out).
get_variables_that_appear_once_aux(Var, Lo_In, Lr_In, Lo_In, Lr_In) :-
	variable_is_in_list(Var, Lr_In), !.
get_variables_that_appear_once_aux(Var, Lo_In, Lr_In, [Var|Lo_In], Lr_In) :-
	(\+(variable_is_in_list(Var, Lo_In))), 
	(\+(variable_is_in_list(Var, Lr_In))), !.

remove_variable_from_list(Var,  [],     []) :-
	write('% DBG % ERROR % remove_variable_from_list: '),
	write(Var), write(' is not in the list of variables.'), nl, !.
remove_variable_from_list(Var1, [Var2],  []) :-
	Var1 == Var2, !.
remove_variable_from_list(Var1, [Var2], [Var2]) :- 
	write('% DBG % ERROR % remove_variable_from_list: '),
	write(Var1), write(' is not in the list of variables.'), nl, !.
remove_variable_from_list(Var1, [Var2|Others], Others) :-
	Var1 == Var2, !.
remove_variable_from_list(Var1, [Var2|Others1], [Var2|Others2]) :- !,
	remove_variable_from_list(Var1, Others1, Others2).

unify_variables_with_fA([]) :- !.
unify_variables_with_fA([Var]) :- !,
	Var = fA(_).
unify_variables_with_fA([Var|Others]) :- !,
	Var = fA(_),
	unify_variables_with_fA(Others).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

negate_cls(Cls, NegCls) :-
%	debug_formatted_cls('negate_cls: Cls: ', Cls),
	negate_cls_aux(Cls, NegCls).
negate_cls(Cls, []) :-
	nl, nl, 
	write('% DBG % ERROR % negate_cls fails !!! '), nl,
	debug_formatted_cls('negate_cls: Cls: ', Cls), nl,
	debug_separation, !.

negate_cls_aux([], []) :- !.
negate_cls_aux([Cl], NegCls) :- !,
	negate_cl(Cl, NegCls).
%	write(negate_cl(Cl, NegCl)), nl.
negate_cls_aux([Cl|Cls], NegCls) :- !,
	negate_cl(Cl, NegCls_1),
%	write(negate_cl(Cl, NegCl)), nl,
	negate_cls_aux(Cls, NegCls_2),
	append(NegCls_1, NegCls_2, NegCls).

negate_cl(Cl_In, Neg_Cl_With_Dist) :-
	convert_cl_nocjs_to_dist_body(Cl_In, Cl_Without_NoCjs, Dist_Body),
%	debug_formatted_cls('negate_cl: Cl_In: ', [Cl_In]), !,
	negate_cl_aux_1(Cl_Without_NoCjs, Neg_Cl),
%	debug_formatted_cls('negate_cl: Cl_In, Cl_Without_NoCjs, Dist_Body, Neg_Cl: ',
%			    [Cl_In, Cl_Without_NoCjs, Dist_Body, Neg_Cl]),
	negate_cl_aux_2(Dist_Body, Neg_Cl, Neg_Cl_With_Dist).

negate_cl_aux_1(cl(_Name, _Arity, _Cjs, [], body([]), _N), []) :-
	!. % intneg is not good for empty bodies.
negate_cl_aux_1(cl(_Name, _Arity, _Cjs, [], body(true), _N), []) :-
	!. % intneg is not good for empty bodies.
negate_cl_aux_1(cl(Name, Arity, Cjs1, [], Body1, N),
	  [cl('intneg', 1,  [Cjs2], [], Body3, N)]) :-
	Body1\==body([]),
	Body1\==body(true), !,
	clause_head(Cjs2, Name, Arity, Cjs1),
	include_intneg_in_body(Body1, Body2),
	test_to_include_forall(Cjs2, Body2, Body3).

negate_cl_aux_2(_Dist_Body, [], []) :- !.
negate_cl_aux_2(Dist_Body, [Neg_Cl], [Neg_Cl_With_Dist]) :- !,
	add_body_to_clause(Dist_Body, Neg_Cl, Neg_Cl_With_Dist).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

include_intneg_in_body(body(true), body(fail)).
include_intneg_in_body(body(Body), body(intneg((Body)))).

include_forall_in_body(body(Body), ForallVars, body(intneg_forall(ForallVars, (( Body ))))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_to_include_forall(Head, Body1, Body2) :-
	test_to_include_forall_aux_1(Head, Body1, ForallVars),
	!, % Backtracking not allowed.
	test_to_include_forall_aux_2(Body1, ForallVars, Body2),	
	!. % Backtracking not allowed.

test_to_include_forall_aux_1(Head, Body, ForallVars) :-
	get_variables_from_clause(Head, [], HeadVars),
%	write(get_variables_from_clause(Head, HeadVars)), nl, !,
	get_variables_from_clause(Body, [], BodyVars),
%	write(get_variables_from_clause(Body, BodyVars)), nl, !,
	list_of_vars_difference(BodyVars, HeadVars, ForallVars),
%	write(list_of_vars_difference(BodyVars, HeadVars, ForallVars)), nl, 
	!. % Backtracking forbidden.

test_to_include_forall_aux_2(Body1, [], Body1) :- !.
test_to_include_forall_aux_2(Body1, ForallVars, Body2) :- !,
	include_forall_in_body(Body1, ForallVars, Body2).
	

list_of_vars_difference(L1, L2, L3) :-
	list_of_vars_difference_aux_1(L1, L2, [], L3).

list_of_vars_difference_aux_1([],  _L2, L3, L3) :- !.
list_of_vars_difference_aux_1([V],  L2, L3, L4) :- !,
	list_of_vars_difference_aux_2(V, L2, L3, L4).
list_of_vars_difference_aux_1([V|Others], L2, L3, L5) :- !,
	list_of_vars_difference_aux_2(V, L2, L3, L4),
	list_of_vars_difference_aux_1(Others, L2, L4, L5).

list_of_vars_difference_aux_2(V, L2, L3, L3) :-
	variable_is_in_list(V, L2),
	!. % Backtracking forbidden.
list_of_vars_difference_aux_2(V, _L2, L3, [V|L3]) :- !.


get_variables_from_clause(Cl, List1, List2) :-
	var(Cl), !,
	include_variable(Cl, List1, List2).
get_variables_from_clause(Cl, List1, List2) :-
	clause_head(Cl, _Name, _Arity, Args),
	get_variables_from_clauses_list(Args, List1, List2).
get_variables_from_clause((Cl), List1, List2) :- !,
	get_variables_from_clause(Cl, List1, List2).
get_variables_from_clause(Cl, List, List) :-
	write('% DBG % ERROR: get_variables_from_clause: unknown term: '),
	write(Cl), nl.

get_variables_from_clauses_list([], List, List) :- !.
get_variables_from_clauses_list([Cl], List1, List2) :- !,
	get_variables_from_clause(Cl, List1, List2).
get_variables_from_clauses_list([Cl|Cls], List1, List3) :- !,
	get_variables_from_clause(Cl, List1, List2),
	get_variables_from_clauses_list(Cls, List2, List3).

include_variable(Var, List, List) :-
	variable_is_in_list(Var, List), !.
include_variable(Var, List, [Var|List]).

variable_is_in_list(Var1, [Var2]) :- !,
	Var1 == Var2.
variable_is_in_list(Var1, [Var2|_Others]) :-
	Var1 == Var2, !.
variable_is_in_list(Var1, [_Var2|Others]) :- !,
	variable_is_in_list(Var1, Others).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% wfs_behaviour(F_NonOvCls, F_Intneg_Cls,
%               F_WFS_NonOvCls, F_WFS_Intneg_Cls).

include_wfs_behaviour(Cls, Intneg_Cls, Cls_Out, Intneg_Cls_Out) :-
	debug_separation,
	write('% DBG % ----------------- WFS BEHAVIOUR -----------------'), nl,
	debug_separation, nl,
%	debug_formatted_cls('include_wfs_behaviour: Cls: ', Cls),
%	debug_formatted_cls('include_wfs_behaviour: Intneg_Cls: ', Intneg_Cls),
	include_wfs_behaviour_aux(Cls, Intneg_Cls, Cls_Out, Intneg_Cls_Out),
	!.
include_wfs_behaviour(Cls, Intneg_Cls, [], []) :-
	nl, write('include_wfs_behaviour fails !!!'), nl, nl,
	debug_formatted_cls('include_wfs_behaviour: Cls: ', Cls),
	debug_formatted_cls('include_wfs_behaviour: Intneg_Cls: ', Intneg_Cls).

include_wfs_behaviour_aux([], [], [], []).
include_wfs_behaviour_aux(Cls, Intneg_Cls, Cls_Out, Intneg_Cls_Out) :-
	% Convert positive predicates.
%	debug_formatted_cls('include_wfs_behaviour_aux: Cls: ', Cls),
	include_wfs_behaviour_pos(Cls, Cls_Positive, Cls_Calls),
	!,
%	debug_formatted_cls('include_wfs_behaviour_aux: Cls_Positive: ', Cls_Positive),
%	debug_formatted_cls('include_wfs_behaviour_aux: Cls_Calls: ', Cls_Calls),
	% Convert negative predicates.
%	debug_formatted_cls('include_wfs_behaviour_aux: Intneg_Cls: ', Intneg_Cls),
	include_wfs_behaviour_neg(Intneg_Cls, Intneg_Cls_Out),
	!,
%	debug_formatted_cls('include_wfs_behaviour_aux: Intneg_Cls_Out: ', Intneg_Cls_Out),
	append(Cls_Calls, Cls_Positive, Cls_Out).
	
% include_wfs_behaviour_pos(Cls, Cls_Out, Cls_Call).
include_wfs_behaviour_pos([], [], []) :- !.
include_wfs_behaviour_pos([Cl], Cls_Out, [Cl_Call]) :-
	include_wfs_behaviour_pos_aux(Cl, [Cl], Cls_Out, Cl_Call).
include_wfs_behaviour_pos([Cl|Cls], Cls_Out, [Cl_Call|Cls_Call]) :-
	find_equal_head_name_cls(Cl, [Cl | Cls], EqName_Cls, NotEqName_Cls),
	include_wfs_behaviour_pos_aux(Cl, EqName_Cls, Cls_Out_1, Cl_Call),
	include_wfs_behaviour_pos(NotEqName_Cls, Cls_Out_2, Cls_Call),
	append(Cls_Out_1, Cls_Out_2, Cls_Out).
			 
include_wfs_behaviour_pos_aux(Cl, Cls, Cls_Out, Cl_Call) :-
	include_wfs_positive_call(Cl, Cl_Call),
	include_wfs_positive_subcall(Cls, Cls_Out).
include_wfs_behaviour_pos_aux(Cl, Cls, [], Cl) :-
	nl, nl, 
	write('% DBG % ERROR % include_wfs_behaviour_pos_aux fails !!! '), nl,
	debug_formatted_cls('include_wfs_behaviour_pos_aux: Cls: ', Cls), nl,
	debug_separation, !.

include_wfs_positive_call(cl(Name, Arity, _Cj1, [], _Body, N),
			  cl(Name, Arity,  Cj2, [], body(intneg_pred(pos, F, [])), N)) :-
	clause_head(F, Name, Arity, Cj2).

include_wfs_positive_subcall([], []) :- !.
include_wfs_positive_subcall([Cl_1], [Cl_2]) :- !,
	include_wfs_positive_subcall_aux(Cl_1, Cl_2).
include_wfs_positive_subcall([Cl_1|Others_1], [Cl_2|Others_2]) :- !,
	include_wfs_positive_subcall_aux(Cl_1, Cl_2),
	include_wfs_positive_subcall(Others_1, Others_2).

% This needs to be fixed ... Cj ??
include_wfs_positive_subcall_aux(cl(Name, Arity, Cj1, [], Body1, N),
				 cl('intneg_pred_pos', 2, Cj3, [], Body2, N)) :-
	clause_head(Cj2, Name, Arity, Cj1),
	append([Cj2], [List], Cj3),
	include_wfs_positive_subcall_aux_2(Body1, List, Body2).

include_wfs_positive_subcall_aux_2(body(true), _List, body(true)).
include_wfs_positive_subcall_aux_2(body(Body), List, body(intneg_pred(pos, Body, List))).
	
include_wfs_behaviour_neg(Intneg_Cls, Intneg_Cls_Out) :-
	include_wfs_negative_subcall(Intneg_Cls, Intneg_Cls_Out), !.
include_wfs_behaviour_neg(Intneg_Cls, []) :-
	nl, nl, 
	write('% DBG % ERROR % include_wfs_behaviour_neg fails !!! '), nl,
	debug_formatted_cls('include_wfs_behaviour_neg: Intneg_Cls: ', Intneg_Cls), nl,
	debug_separation, !.

include_wfs_negative_subcall([], []) :- !.
include_wfs_negative_subcall([Cl_1], [Cl_2]) :- !,
	include_wfs_negative_subcall_aux(Cl_1, Cl_2).
include_wfs_negative_subcall([Cl_1|Others_1], [Cl_2|Others_2]) :- !,
	include_wfs_negative_subcall_aux(Cl_1, Cl_2),
	include_wfs_negative_subcall(Others_1, Others_2).

% This needs to be fixed ... Cj ??
include_wfs_negative_subcall_aux(cl('intneg',          1, Cj1, NoCjs, Body1, N),
				 cl('intneg_pred_neg', 2, Cj2, NoCjs, Body2, N)) :-
	append(Cj1, [List], Cj2),
	include_wfs_negative_subcall_aux_2(Body1, List, Body2).

include_wfs_negative_subcall_aux_2(body(Body), List, body(intneg_pred(neg, Body, List))).

%		 (:- import get_calls/3, get_returns/2, table_state/2 from tables),
%		 (:- table intneg_tabled_pred_pos/1),
%		 (:- table intneg_tabled_pred_neg/1),
%		 (intneg(X) :- intneg_get_tabled_solutions(X), !),
%		 % , write('tabled - complete'), nl
%		 (intneg(X) :- intneg_pred_is_tabled_but_incomplete(X), !),
%		 % write('tabled - incomplete'), nl, 
%		 (intneg(X) :- intneg_tabled_pred_neg(X)),
%		 (intneg_get_tabled_solutions(G) :- copy_term(G, S), 
%		     get_calls(intneg_tabled_pred_neg(G), Ent, Ret),
%		     subsumes_chk(S, G),
%		     table_state(intneg_tabled_pred_neg(G), complete),
%		     get_returns(Ent, Ret)),
%		 (intneg_pred_is_tabled_but_incomplete(G) :- copy_term(G,S),
%		     get_calls(intneg_tabled_pred_neg(S), Ent, Ret),
%		     subsumes_chk(S,G),
%		     table_state(intneg_tabled_pred_neg(S), incomplete))

wfs_intneg_impl([
%		 (:- import subsumes_chk/2 from subsumes),
	         (:- use_module(library(write))),
		 (:- use_module(intneg_dist,[intneg_dist/2, intneg_forall_aux/4])),
		 (:- use_module(intneg_aux, [intneg_or/3, intneg_and/3, intneg_chk/2, intneg_special/3,
		     intneg_deMorgan/3, wfs_memberchk/3, wfs_memberchk_for_pos/1,
		     term_vars/2, remove_vars_in_2nd_list/3,
		     adequate_forall_results/3, new_counter_index/1])),
	         ( :- meta_predicate(intneg) ),
	         ( :- meta_predicate(intneg_aux) ),
	         ( :- meta_predicate(intneg_pred) ),
	         ( :- meta_predicate(intneg_pred_pos) ),
	         ( :- meta_predicate(intneg_pred_neg) ),
		 % Intneg
		 (intneg(X) :- intneg_aux(X, [])),
		 (intneg_aux(X, L) :- intneg_deMorgan(X, Y, Sign), intneg_pred(Sign, Y, L)),
		 % Pred evaluation
%		 (intneg_pred(Any, X, L) :- write(intneg_pred), write(Any), nl, write(X), nl, write(L), nl, fail),
		 (intneg_pred(Any, X, L) :- intneg_or(X, Arg1, Arg2), !, (intneg_pred(Any, Arg1, L); intneg_pred(Any, Arg2, L))),
		 (intneg_pred(Any, X, L) :- intneg_and(X, Arg1, Arg2), !, intneg_pred(Any, Arg1, L), intneg_pred(Any, Arg2, L)),
		 (intneg_pred(Any, X, L) :- intneg_chk(X, Y), !, intneg_aux(Y, L)),
		 (intneg_pred(Any, X, L) :- intneg_special(X, Y, L), !, call(Y)),
		 % WFS and subcalls.
		 (intneg_pred(pos, X, L) :- wfs_memberchk(pos(X), L, _OL), !, fail),
		 (intneg_pred(pos, X, L) :- intneg_pred_pos(X, [pos(X)|L])),
		 %
		 (intneg_pred(neg, X, L) :- wfs_memberchk(neg(X), L, OL), wfs_memberchk_for_pos(OL), !, fail),
		 (intneg_pred(neg, X, L) :- wfs_memberchk(neg(X), L, OL), !),
		 (intneg_pred(neg, X, L) :- intneg_pred_neg(X, [neg(X)|L]))
		 ]).

% Info: subsumes_chk(T1,T2) -> T1 subsumes T2, T2 is already an instance of T1.

forall_impl([
	     ( :- meta_predicate(intneg_forall) ),
	     ( :- meta_predicate(findall_forall) ),
	     (   
		 intneg_forall(ForAll_Vars, Pred, L) :-
	         term_vars(Pred, Pred_Vars),
		 remove_vars_in_2nd_list(Pred_Vars, ForAll_Vars, Not_ForAll_Vars),
		 findall_forall(   (ForAll_Vars, Not_ForAll_Vars, expl(Pred)),
				   intneg_pred(pos, Pred, L), Combined_In), !,
		 intneg_forall_aux(ForAll_Vars, Not_ForAll_Vars, Combined_In, _Expl)
	     ),
	     (
	         findall_forall(Result_Format, Predicate, Results) :-
	         copy_term((Result_Format, Predicate), (Result_Format_Copy, Predicate_Copy)),
	         new_counter_index(Cte), !, 
	         call(Predicate_Copy),
		 write('We are calling: '), write(Predicate_Copy), nl,
	         adequate_forall_results(Cte, Result_Format_Copy, Results)
	     )
	    ]).

% copy_term((Vars, Pred), (Vars_Copy, _Pred_Copy))),
% get_returns(CS,Ret)),
% get_returns/2, get_returns_for_call/2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

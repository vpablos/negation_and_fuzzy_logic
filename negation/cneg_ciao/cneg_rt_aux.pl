

:- module(cneg_rt_aux, [cneg_rt_Aux/4], [assertions]).

:- comment(title, "Contructive Negation Runtime Library - auxiliary predicate").

:- comment(author, "V@'{i}ctor Pablos Ceruelo").

:- comment(summary, "This module implements negation predicates for runtime evaluation.").


:- use_module(cneg_aux, _).
:- use_module(cneg_diseq, _).

:- use_module(cneg_rt_aux_frontiers, _).
:- use_module(cneg_rt_New, _).
:- use_module(cneg_rt_Chan, _).
:- use_module(cneg_rt_Stuckey, _).

% To access pre-frontiers from anywhere.
:- multifile cneg_pre_frontier/6.

cneg_rt_Aux(Goal, GoalVars, Proposal, Result_List) :-
	echo_msg(2, 'separation', 'cneg_rt', '', ''),
	echo_msg(2, 'nl', 'cneg_rt', '', ''),
	echo_msg(2, '', 'cneg_rt', 'cneg_rt_Aux :: Proposal', Proposal),
	echo_msg(2, '', 'cneg_rt', 'cneg_rt_Aux :: GoalVars', GoalVars),
	echo_msg(2, '', 'cneg_rt', 'cneg_rt_Aux :: Goal', Goal),
	echo_msg(2, 'nl', 'cneg_rt', '', ''),
	echo_msg(2, 'statistics', 'statistics', '', (cneg_rt_Aux(Goal, GoalVars, Proposal))),
	echo_msg(2, 'nl', 'cneg_rt', '', ''),
	echo_msg(2, '', 'cneg_rt', 'cneg_rt_Aux :: (Goal, GoalVars, Proposal)', (Goal, GoalVars, Proposal)),
	varsbag(GoalVars, [], [], Real_GoalVars), % Clean up non-vars
	echo_msg(2, '', 'cneg_rt', 'cneg_rt_Aux :: Real_GoalVars', Real_GoalVars),
	cneg_diseq_echo(2, '', 'cneg_rt', Goal),
	!, % Reduce the stack's memory by forbidding backtracking.
	compute_frontier(Goal, Real_GoalVars, Proposal, Frontier),
	!, % Reduce the stack's memory by forbidding backtracking.
	echo_msg(2, 'nl', 'cneg_rt', '', ''),
	echo_msg(2, 'list', 'cneg_rt', 'cneg_rt_Aux :: Frontier', Frontier),
	!,
	negate_frontier(Frontier, GoalVars, Proposal, Result_List),
	!, % Reduce the stack's memory by forbidding backtracking.
	echo_msg(2, 'separation', 'cneg_rt', '', ''),
	echo_msg(2, 'nl', 'cneg_rt', '', ''),
	echo_msg(2, '', 'cneg_rt', 'cneg_rt_Aux :: Summary for Proposal', Proposal),
	echo_msg(2, '', 'cneg_rt', 'cneg_rt_Aux :: Goal', Goal),
	echo_msg(2, '', 'cneg_rt', 'cneg_rt_Aux :: Real_GoalVars', Real_GoalVars),
	echo_msg(2, 'nl', 'cneg_rt', '', ''),
	echo_msg(2, 'list', 'cneg_rt', 'cneg_rt_Aux :: Frontier', Frontier),
	echo_msg(2, 'nl', 'cneg_rt', '', ''),
	echo_msg(2, 'list', 'cneg_rt', 'cneg_rt_Aux :: Result (conj)', Result_List),
	echo_msg(2, 'separation', 'cneg_rt', '', ''),
	echo_msg(2, 'nl', 'cneg_rt', '', '').

%by_pass_universallity_of_variables(UQV_In, UQV_Aux) :-
%	varsbag(UQV_In, [], [], UQV_Aux). % All vars in UQV_In are now UQV.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% negate_frontier_list(Frontier, GoalVars, Proposal, Result_List),
% returns in Result_List a list with the negation of each subfrontier in Frontier.

negate_frontier([], _GoalVars, _Proposal, [true]) :- !. % Optimization.
negate_frontier(Frontier, GoalVars, Proposal, Negated_Frontier) :- 
	Frontier \== [], !,
	negate_each_subfrontier(Frontier, GoalVars, Proposal, Negated_Frontier),
	!.

negate_each_subfrontier([], _GoalVars, _Proposal, []) :- !.
negate_each_subfrontier([Frontier | More_Frontiers], GoalVars, Proposal, [Result_Frontier | Result_More_Frontiers]) :-
%	echo_msg(2, '', 'cneg_rt', 'negate_subfrontier: (Frontier, GoalVars)', (Frontier, GoalVars)),
	(
	    (
		Proposal = 'cneg_rt_New',
		negate_subfrontier_new(Frontier, GoalVars, Proposal, Result_Frontier)
	    )
	;
	    (
		Proposal = 'cneg_rt_Chan',
		negate_subfrontier_chan(Frontier, GoalVars, Proposal, Result_Frontier)
	    )
	),
%	echo_msg(2, '', 'cneg_rt', 'negate_subfrontier: Result_Frontier', Result_Frontier),
	!, % Reduce the stack's memory by forbidding backtracking.
	negate_each_subfrontier(More_Frontiers, GoalVars, Proposal, Result_More_Frontiers).
%	combine_negated_frontiers(Result_Frontier, Result_More_Frontiers, Result), 
%	!. % Reduce the stack's memory by forbidding backtracking.
	

% combine_negated_subfrontiers(Result_Subfr, Result_More_Subfr, Result_Tmp),
%combine_negated_frontiers(fail, _Result_More_Subfr, fail) :- !.
%combine_negated_frontiers(_Result_Subfr, fail, fail) :- !.
%combine_negated_frontiers(true, Result_More_Subfr, Result_More_Subfr) :- !.
%combine_negated_frontiers(Result_Subfr, true, Result_Subfr) :- !.
%combine_negated_frontiers(Result_Subfr, Result_More_Subfr, (Result_Subfr, Result_More_Subfr)) :- !.

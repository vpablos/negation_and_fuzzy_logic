:- module(
	det_rt_nd,
        [
	    '&!'/2,
	    '&!>'/2,
	    '<&!'/1,
	    '&!'/1,
	    '&&!'/2,
	    '&&!'/1,
	    '&&!>'/2,
	    '<&&!'/1
	],
	[assertions, isomodes]
	 ).

:- include(library(andprolog_nd(andprolog_nd_ops))).
:- use_module(library(andprolog_nd(andprolog_nd_sched))).
:- use_module(library(andprolog_nd(andprolog_nd_props))).

:- use_module(library(andprolog_nd(agents_rt_nd))).
:- use_module(library(andprolog_nd(callh_rt_nd))).

:- use_module(library(andprolog_nd(apll_nd))).
:- use_module(library(odd)).


%%**********************************************************************
%% HIGH-LEVEL PRIMITIVES
%%**********************************************************************


:- pred '&!>'(+callable,-handler).

:- comment('&!>'(Goal,Handler), "Sends out the deterministic goal
   @var{Goal} to be executed potentially by another agent, returning
   in @var{Handler} a handler of the goal sent. It performs cleaning
   in backtracking.").

:- meta_predicate((goal'&!>'_)).
Goal '&!>' Handler :-
 %% 	undo(cancellation(Handler)),
	(true;fail),
	push_goal(Goal,det,Handler),
	release_some_suspended_thread(Handler).


:- pred '&&!>'(+callable,-handler).

:- comment('&&!>'(Goal,Handler), "Fair version of the '&!>'/2
   operator. If there is no idle agent, one is created to execute the
   goal @var{Goal}.").

:- meta_predicate((goal&&>_)).
Goal '&&!>' Handler :-
	create_agent,
	Goal '&!>' Handler.


:- pred '&!'(+callable).

:- comment('&!'(Goal), "Sends out the deterministic goal @var{Goal} to
   be executed potentially by another agent. No waiting for its return
   is performed.").

:- meta_predicate((goal'&!')).
Goal '&!' :-
	Goal '&!>' _.


:- pred '&&!'(+callable).

:- comment('&&!'(Goal), "Fair version of the '&!'/1 operator.").

:- meta_predicate((goal'&&!')).
Goal '&&!' :-
	Goal '&&!>' _.


:- pred '<&!'(+handler). 

:- comment('<&!'(Handler), "Reads the bindings made to the output
   variables of the deterministic goal associated to @var{Handler}, or
   executes it if that goal has not been executed yet.").

Handler '<&!' :-
	Handler '<&&!' .


:- pred '<&&!'(+handler).

:- comment('<&&!'(Handler), "Fair version of the '<&!'/1 operator.").

Handler '<&&!' :-
 %% 	undo(release_all_for_unwinding),
	enter_mutex_self,
	(
	    goal_available(Handler) ->
	    exit_mutex_self,
	    retrieve_goal(Handler,Goal),
	    call(Goal)
	;
	    perform_some_other_det_work(Handler)
	).


:- pred '&!'(+callable,+callable).

:- comment('&!'(Goal1,Goal2), "Performs a parallel fork of the
   deterministic goals @var{Goal1} and @var{Goal2} involved and waits
   for the execution of both to finish. If some of the goals has not
   been picked up by another agent then it will be executed by the
   publishing agent.").

:- meta_predicate((goal'&!'goal)).
GoalA '&!' GoalB :-
	GoalA '&!>' H,
	GoalB,
	H '<&!' .


:- pred '&&!'(+callable,+callable).

:- comment('&&!'(Goal1,Goal2), "Fair version of the '&!'/2 operator.").

:- meta_predicate((goal'&&!'goal)).
GoalA '&&!' GoalB :-
	GoalA '&&!>' H,
	GoalB,
	H '<&&!' .


%%**********************************************************************
%% AUXILIARY DEFINITIONS
%%**********************************************************************


:- pred perform_some_other_det_work(+handler).

:- comment(perform_some_other_det_work(+Handler), "Checks whether the
   execution of the deterministic goal associated to the handler
   @var{Handler}, which has been picked up by another agent, has
   already finished or failed, and searches for other deterministic
   goal to execute otherwise.").

perform_some_other_det_work(Handler) :-
	goal_scheduling(GS),
	!,
	perform_some_other_det_work_(Handler,GS).

perform_some_other_det_work_(Handler,GS) :-
	(
	    goal_finished(Handler) ->
	    exit_mutex_self
	;
	    (
		goal_failed(Handler) ->
		exit_mutex_self,
		fail
	    ;
		suspend,
		perform_some_other_det_work_(Handler,GS)
	    )
	).


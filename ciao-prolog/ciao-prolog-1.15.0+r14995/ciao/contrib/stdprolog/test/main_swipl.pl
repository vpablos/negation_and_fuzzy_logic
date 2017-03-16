%%%% pts %%%% Testing with SWI-Prolog 5.4.7

% Consult the named files
% vvv !! Dat: moved utils_ into front
:- ensure_loaded([utils_swipl,iso_test,testbed,test_cases,isosec,format,regexp,show_clause]).

% ---------------------------------------------------------------------------
% Specify the behaviour of unification on STO terms. 

% sto_behaviour(STO): STO describes the behaviour of unification on STO terms.
% Possible values for STO:
% plain         - Create cyclic trees, unification may loop
%                 if two cyclic terms are unified. (The test
%                 suite will avoid unifying STO terms.)
% cyclic        - Create cyclic trees, with proper unification for these. 
% occurs_check  - Unification does perform occurs check.
sto_behaviour(cyclic).

% ---------------------------------------------------------------------------
% Specify whether the Prolog system has modules, and what is the module
% qualified form of a goal

% module_qualified(Term, Mod, MTerm):
% MTerm is the module qualified form of goal Term in module Mod (fail if
% there is no module qualification).
%module_qualified(_, _, _) :- fail. % !! why doesn't it work?
module_qualified(Term, M, M:Term).

% ---------------------------------------------------------------------------
% Specify if there is a time-out predicate available.

% time_out_predicate(Goal, Time, Res, TimeOutGoal):
% TimeOutGoal is a goal which will run Goal for at most Time milliseconds
% and will instantiate Res to `success' if the Goal completes within the
% prescribed time, and to `time_out' if not.
time_out_predicate(_, _, _, _) :- fail. % !! fix this

% ---------------------------------------------------------------------------
% Specify whether the implementation has a limited range of integer values.

% integer_domain(IntDom): IntDom describes the domain of integers allowed by
% the implementation.  Possible values for IntDom:
% limited     - The integer domain is limited
%               (i.e. prolog_flag(max_integer, _) succeeds)
% unlimited   - The integer domain is unlimited
%               (the implementation uses bignums,
%               i.e. prolog_flag(max_integer, _) fails)
integer_domain(limited).

% ---------------------------------------------------------------------------
% Specify if the architecture has two-s complement representation for
% negative ints.

% negative_integer_representation(Repr): Repr specifies the representation
% of negative integers. Possible values for Repr:
% compl2      - two's complement representation
% other       - other representation
negative_integer_representation(compl2).


% ---------------------------------------------------------------------------
% Specify if there are any exceptions which should be propagated.

% exception_to_propagate(ExceptionTerm): ExceptionTerm is an exception which
% should re-thrown when caught.
% E.g. SICStus requires that the exception time_out is not caught,
% for time_out/3 to work. 
%!! exception_to_propagate(time_out).
%!! exception_to_propagate(error(_,time_out)).
exception_to_propagate(_) :- fail.

% ---------------------------------------------------------------------------
% Specify print options to be used when displaying messages

% print_options(Opts): Opts is a list of non-standard options to be passed
% to write_term, used for printing diagnostics . This can be used e.g. to limit
% the print depth.
print_options([]).

% ---------------------------------------------------------------------------
% Specify how to abolish a possibly static predicate.
% This is crucial to be able to run all tests in a single Prolog invocation,
% which is the present setup

% abolish_static(Func): abolish possibly static predicate Func.
abolish_static(Mod:NPerA) :-
	%current_prolog_flag(gc, GC), write(user_error, GC), % Dat: false
	% Dat: abolish/1 can abolish static predicates in non-ISO mode
	%write(user_error,abolish_static(Mod:NPerA)), nl(user_error),
	NPerA = N/A,
	functor(Head, N, A),
	%( predicate_property(Mod:Head, P),
	%  write(user_error, Mod:Head=P), nl(user_error), fail
	%; true
	%),
	%( predicate_property(Mod:NPerA) -> true ; true), % !! why does 
	( %NPerA = read/1 -> true % !! ugly hack
	  predicate_property(Mod:Head, built_in) -> true % !! ugly hack -- make sure the caller doesn't pass such predicates to us
	; current_prolog_flag(iso, ISO),
	  set_prolog_flag(iso, false),
	  call_cleanup(Mod:abolish(NPerA), set_prolog_flag(iso, ISO))
	).
	%functor(Head, N, A),
	%abolish(Head). /* example: abolish(prefix(_,_)). */
	%abolish(N/A). %%%% pts %%%% !! tries to abolish nl/0.

% ---------------------------------------------------------------------------
% Specify how to load a Prolog program.

% load_program_file(Name): load the test program contained in file Name
% and afterwards remove this file (if possible).
load_program_file(Name) :-
	consult(Name).

% ---------------------------------------------------------------------------
% Specify initializations, if any

% init_tests_special: Perform any initialisation necessary for the specific
% Prolog system. E.g. set up and/or clean a directory in which the
% tests are run.
init_tests_special.

% ---------------------------------------------------------------------------
% Specify how to check if a predicate is dynamic.

% is_dynamic(Mod:Name/Arity): Mod:Name/Arity is a dynamic predicate.
%is_dynamic(N/A) :-
%	functor(Head, N, A),
%	'$pred_info'(Head, pred_dynamic, _).
is_dynamic(Mod:N/A) :-
	functor(Head, N, A),
	predicate_property(Mod:Head, dynamic).

% ---------------------------------------------------------------------------
% Specify how to remove a file

% clean_file(Name): Delete file named Name.
% Can be a no-op, if not available in this Prolog.
clean_file(_Name). % !! etc.

% ---------------------------------------------------------------------------
% Specify contextual variants 

context_info(caret,                def). % def: ^/2 is defined as X^Goal :- Goal.; otherwise undef
context_info(max_arity,            255). % !! how much? !! unbounded, autodetect
context_info(max_char_code,        255).
context_info(max_atom_length,      65535). % ! how much ? !! unbounded
context_info(non_callable_culprit, first).
  % the culprit of a type_error(callable) is not the whole goal, but its first
  % non-callable subgoal.
context_info(postfix_and_infix_op,  allowed).
  % The same atom can be a postfix and an infix operator at the same time.

% ---------------------------------------------------------------------------
% Specify testing options

% spec_options(Opts): Opts is the list of options to be used for testing
% the given Prolog system
spec_options([]).

%:- halt(42).
%:- init_tests([], []), current_preds(Z), write(Z), nl, halt. !! still not working properly
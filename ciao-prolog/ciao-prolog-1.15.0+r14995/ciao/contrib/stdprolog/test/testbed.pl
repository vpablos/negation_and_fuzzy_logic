% ----------------------------------------------------------------------
% iso_main/{0,1}:  main entry points for a combined test.
%

iso_main :-
	iso_main([]).

iso_main(Opts0) :-
	init_main(Opts0, Opts),
	my_format(        '-------- Starting tests.~n', []),
	catch(my_format(user_error, '~n-------- Starting tests.~n', []), E, true), % Dat: gprolog doesn't have user_error !! make test
	run_all(tests, Opts),
	my_format(      '~n-------- Tests completed.~n', []),
	catch(my_format(user_error, '~n-------- Tests completed (see results on STDOUT).~n', []), E, true), % Dat: gprolog doesn't have user_error !! make test
	true.

single(Test) :-
	unmake(Test),
	iso_main([single(Test)]).

dsingle(Test) :-
	unmake(Test),
	iso_main([single(Test),debug]).

%
% ----------------------------------------------------------------------
% Other useful entry points

quiet :-
	make([]).

verbose :-
	make([debug]).

make(Opts0) :-
	init_main(Opts0, Opts),
	run_all(_, Opts).

make1(Name) :-
	make1(Name, []).

make1(Name, Opts0) :-
	init_main(Opts0, Opts),
	run1(Name, Opts).

init_main(Opts0, Opts) :-
	init_make,
	init_tests(Opts0, Opts),
	%%%% pts %%%% Dat: abort on SWI-Prolog non-empty current_preds/1 madness
	% !! doesn't test properly
	current_preds(Preds),
	( Preds=[] -> true
	; throw(initial_current_preds(nonempty,Preds))
	).

init_make :-
	ensure_dynamic(test_ok(_)).

make_clean :-
	retractall(test_ok(_)).

unmake(L) :-
	retractall(test_ok(L)),
	memberchk(X, L),
	retractall(test_ok(X)),
	fail.
unmake(_).

% ---------------------------------------------------------------------- 
% Utilities 

list_of(A, N, [A|L]) :-
	N>0, !, N1 is N-1,
	list_of(A, N1, L).
list_of(_A, 0, []).

% Dat: we define between/3 in utils_*.pl

val_of(Key, Val, Assoc) :-
	memberchk(Key-Val, Assoc).

ensure_dynamic(Head) :-
	functor(Head, N, A),
	current_predicate(N/A), !.
ensure_dynamic(Head) :-
	asserta(Head),
	retractall(Head).

my_print_message(T, X) :-
	write(T), write(': '), call(X), nl.

% ----------------------------------------------------------------------
% Test organisation

:- dynamic(test_ok/1).
%:- dynamic(test_ok/0).
:- dynamic(test_failed/0).

% !! why don't we use this now?
run_all(Phase, Opts) :-
	option(phases(PhList), Opts, true),
	memberchk(Phase, PhList), !, 
	(   debug_print(any, Opts, ' Starting tests, ~n    options: ~w~n', [Opts]),
	    run1(_Name, Opts),
	    fail
	;   debug_print(any, Opts,
			' Tests completed, ~n    options: ~w~n--------------------~n',
			[Opts])
	).
run_all(_, _).

run1(Name, Opts0) :-
	option(group(Type), Opts0, true /* Type stays variable */),
	option(single(Name), Opts0, true /* Name not affected */),
	Opts1 = [test_name(Name)|Opts0],
	test(Name, Opts1, Opts2, Test, Type, Cleanup),
	debug_print(any, Opts2, '  Running ~w ...~n', [Name]),
	(   catch(run_body(Name, Test, Opts2), E, warn_exc(E, Opts2)) -> true
	;   warn_failure(Name),
	    ( test_failed -> true ; asserta(test_failed))
	),
	% ( test_ok -> portray_ok(Opts) ; portray_not_ok(Opts) ), %%%% pts %%%%
	( test_failed -> portray_not_ok(Opts2) ; portray_ok(Opts2) ), %%%% pts %%%%
	call(Cleanup).

run_body(Name, Test, Opts) :-
	%write(user_output, zABR), nl(user_output),
	option(time_out(Time), Opts, Time0=200), % Dat: default timeout is 0.2 sec
	%write(user_output, zABS), nl(user_output),
	Time is Time0*3,
	%write(user_output, zABT), nl(user_output),
	retractall(test_failed),
	% retractall(test_ok), %%%% pts %%%%
	%write(user_output, zABU(Test)), nl(user_output),
	my_time_out(Test, Time, Res),
	%write(user_output, zABV), nl(user_output),
	(   Res = success ->
	    (	test_failed -> true
	    ;	asserta(test_ok(Name))
	        % , asserta(test_ok)
	        % Dat: we delay portray_ok(Opts) here
	    )
	;   %write(user_output, zABE), nl(user_output),
	    expected(run, to_terminate, Res, Opts)
	).

my_time_out(Test, Time, Res) :-
	time_out_predicate(Test, Time, Res, Goal), !, Goal.
my_time_out(Test, _, success) :-
	call(Test).

warn_exc(E, Opts) :-
	propagate_exception(E),
	expected(run, to_complete_without_error, E, Opts).

warn_failure(Name) :-
	my_print_message(warning, my_format('Exception while evaluating test: ~w',[Name])).
	% portray_not_ok([test_name(Name)]). %%%% pts %%%%

expected(What, Expected, Got, Opts) :-
	expect(What, Expected, Got, Opts, fail).

expect(What, Expected, Got, Opts) :-
	expect(What, Expected, Got, Opts, Expected = Got).

expect(_What, _, _, _, Check) :-
	call(Check), !.
expect(_, _, _, Opts, _) :-
	option(fail, Opts), !, fail. % !! why `fail' here? %`
expect(What, Expected, Got, Opts, _) :-
	( test_failed -> true ; asserta(test_failed)), %%%% pts %%%%
	%asserta(test_failed), % !!
	%write(user_output, zABC), nl(user_output),
	portray_expect(What, Expected, Got, Opts), !.
expect(What, Expected, Got, Opts, _) :-	
	% Dat: a fallback, in case portray_expect/4 failed
	option(test_name(Name), Opts, Name=''),
	(   numbervars(Expected+Got, 26, _),
	    print_options(PrOpt0),
	    PrOpt = [numbervars(true)|PrOpt0],
	    my_print_message(warning,
			  my_format('******* Expected ~w: `~@'', got `~@'', in test "~w".',
				[What, write_term(Expected, PrOpt),
				 write_term(Got, PrOpt), Name])), fail
	;   true
	).

expect_exception(timed, Goal, Result, Opts) :-
	(   time_out_predicate(Goal, Time, Res, TimedGoal) ->
	    option(time_out(Time), Opts, Time=200), % default timeout is 0.2 sec
	    expect_exception(TimedGoal, Result0),
	    (	Res = success ->	Result = Result0
	    ;	Result = time_out
	    )
	;   Result = time_out
	).
expect_exception(untimed, Goal, Result, _Opts) :-
	expect_exception(Goal, Result).
	
expect_exception(Goal, Result) :-
	catch((Goal, Result = success),
	      E,
	      (propagate_exception(E), Result = exception(E))), !.
expect_exception(_, failure).

propagate_exception(X) :-
	exception_to_propagate(X),		       
	!, throw(X).
propagate_exception(_).

debug_print(Level, Opts, Txt, L) :-
	option(debug(Level), Opts), !, my_format(user_output, Txt, L).
debug_print(_, Opts, _Txt, _L) :-
	option(debug(quiet), Opts), !.
debug_print(any, Opts, Txt, L) :-
	option(debug, Opts), !, my_format(user_output, Txt, L).
debug_print(_, _, _, _) :-
	write(.), flush_output.

debug_seq_number(N, Doing, Opts) :-
	option(freq(Freq), Opts, Freq=100),
	N mod Freq =:= 0,
	debug_print(all, Opts, '   ~w ~w...\n', [Doing, N]).
debug_seq_number(_, _, _).

option(Opt, Opts) :-
	memberchk(Opt, Opts), !.
option(Opt, Opts) :-
	atom(Opt),
	member(E, Opts), functor(E, Opt, _), !.

option(Opt, Opts, _IfNot) :-
	option(Opt, Opts), !.
option(_, _, IfNot) :-
	call(IfNot).

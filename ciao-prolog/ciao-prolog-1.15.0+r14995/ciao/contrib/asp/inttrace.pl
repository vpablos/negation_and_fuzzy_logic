:- module(inttrace, [create_trc_class/1]).
:- use_module(library(filenames)).
% -----------------------------------------------
% Create Tracer Class
% -----------------------------------------------
create_trc_class(PFJustClass) :-
	name(PFJustClass, PFJustClassString),
	no_path_file_name(PFJustClassString, FJustClassString),
	name(FJustClass, FJustClassString),

	open(PFJustClass, write, S), 

	write(S, ':- class('), 
	write(S, FJustClass), 
	write(S, ').'), nl(S), nl(S), 
	write(S,':- use_package([objects]).\n\n'),
	write(S,':- use_module(library(system)).\n'),
	write(S,':- use_module(library(strings)).\n'),
	write(S,':- use_module(library(read_from_string)).\n'),
	write(S,':- use_module(library(aggregates)). \n'),
	write(S,':- use_module(library(lists)).\n'),
	write(S,':- use_module(library(write)).\n'),
	write(S,':- use_module(library(read)).\n'),


	nl(S),
	write(S, ':- use_module('''),
	write(S, FullAlias), write(S, ''').\n\n'),

	write(S, ':- use_class('''),
	write(S,Name_no_ext), write(S,'_class'').\n\n'),
	
write(S,'% smodels_stream/2: stores stream to access smodels\n'),
write(S,':- data smodels_stream/2, bk/1, state/1.\n'),
write(S,':- data exe_code/1, smodels_status/1.\n'),
write(S,':- data curr_data/1, old_data/1.\n'),
nl(S),
write(S,'smodels_status(0).\n'),
write(S,':- export(step/0).\n'),
write(S,':- export(step/1).\n'),
write(S,':- export(next/0).\n'),
write(S,':- export(restart/0).\n'),
write(S,':- export(break/1).\n'),
write(S,':- export(rem_break/1).\n'),
write(S,':- export(list_break/1).\n'),
write(S,':- export(quit/0).\n'),
nl(S),

write(S,'smodels_tracer :-'''),
write(S,FullAlias),
write(S,''':aspFileName(ASP_NAME),\n'),
write(S,''''),
write(S,FullAlias),
write(S,''':lparse_set(C1,C2),\n'),
write(S,''''),
write(S,FullAlias),
write(S,''':lparse_parm(LP_PARM),\n'),
write(S,'append(LP_PARM,C1,LPARSE_PARM1),\n'),
write(S,'append(LPARSE_PARM1,[ASP_NAME],LPARSE_PARM),\n'),
write(S,'    exec(''lparse'', LPARSE_PARM, IP, OP, EP, true, _, _),\n'),
write(S,'    close(IP),\n'),
write(S,'    close(EP),\n'),

write(S,''''),
write(S,FullAlias),
write(S,''':trace_parm(SM_PARM),\n'),
write(S,'append(SM_PARM,C2,SMODELS_PARM),\n'),
%write(S,'append(SMODELS_PARM1,[ASP_NAME],SMODELS_PARM),\n'),
write(S,'    exec(''smodels'',SMODELS_PARM,I,O,E,true,_,_),\n'),
write(S,'    close(E),\n'),
write(S,'    assertz(smodels_stream(I,O)),\n'),
write(S,'    read_lparse(OP),\n'),
write(S,'    close(OP).\n'),
nl(S),

write(S,'read_lparse(OP) :-\n'),
write(S,'    repeat,\n'),
write(S,'    get_line(OP,X),\n'),
write(S,'    lparse_input(X).\n'),
nl(S),
write(S,'lparse_input(end_of_file) :- \n'),
write(S,'    smodels_stream(I,_), \n'),
write(S,'    flush_output(I),\n'),
write(S,'    !.\n'),
write(S,'lparse_input(X) :-\n'),
write(S,'    name(A,X),\n'),
write(S,'    smodels_stream(I,_),\n'),
write(S,'    write(I,A), nl(I),\n'),
write(S,'%    display(''A=''), display(A), nl,\n'),
write(S,'    !, fail.\n'),    
    
write(S,'get_smodels_data :-\n'),
write(S,'    smodels_stream(_,O),\n'),
write(S,'    repeat,\n'),
write(S,'    get_line(O,T),\n'),
write(S,'    prt_data(T).\n'),
nl(S),
write(S,'prt_data(end_of_file) :- !.\n'),
write(S,'prt_data("done_read.") :-\n'),
write(S,'    display(''done_read''), nl,\n'),
%    smodels_stream(I,_),
%    write(I,'omar'), nl(I), 
write(S,'    !, fail.\n'),
write(S,'prt_data(T) :- name(A,T), display(A), nl,\n'),
write(S,'    !, fail.\n'),
nl(S),

write(S,'% ---------------------------------\n'),
write(S,'%Break-Point handler:\n'),
write(S,'% ---------------------------------\n'),
write(S,'break(X) :-\n'),
write(S,'    list(X),\n'),
write(S,'    add_breakpoint(X),\n'),
write(S,'    assertz(bk(X)).\n'),
nl(S),
write(S,'rem_break(X) :-\n'),
write(S,'    list(X),\n'),
write(S,'    rem_list_breakpoint(X).\n'),
nl(S),
write(S,'rem_list_breakpoint([]).\n'),
write(S,'rem_list_breakpoint([H|_]) :-\n'),
write(S,'    bk(L),\n'),
write(S,'    member(H,L),\n'),
write(S,'    rem_one_breakpoint(H,L,L1),\n'),
write(S,'    retract(bk(L)),\n'),
write(S,'    assertz(bk(L1)),\n'),
write(S,'    fail.\n'),
write(S,'rem_list_breakpoint([_|T]) :-\n'),
write(S,'    rem_list_breakpoint(T).\n'),
nl(S),
write(S,'rem_one_breakpoint(_,[], []).\n'),
write(S,'rem_one_breakpoint(X,[X|T], T1) :-\n'),
write(S,'    rem_one_breakpoint(X,T,T1), !.\n'),
write(S,'rem_one_breakpoint(X,[Y|T], [Y|T1]) :-\n'),
write(S,'    rem_one_breakpoint(X,T,T1).\n'),
nl(S),
write(S,'list_break(L) :- !,\n'),
write(S,'    var(L),\n'),
write(S,'    findall(X, bk(X), L).\n'),
nl(S),
write(S,'add_breakpoint([]).\n'),
write(S,'add_breakpoint([H|T]) :-\n'),
write(S,'    valid_breakpoint(H),\n'),
write(S,'    add_breakpoint(T).\n'),
nl(S),  
write(S,'valid_brk_value(t).\n'),
write(S,'valid_brk_value(f).\n'),
write(S,'valid_brk_value(a).\n'),
nl(S),
write(S,'valid_breakpoint(atom(_,V)) :- valid_brk_value(V),!.\n'),
write(S,'valid_breakpoint(conflict(_)) :- !.\n'),
write(S,'valid_breakpoint(conflict) :- !.\n'),
write(S,'valid_breakpoint(ans(N)) :- number(N) ; N=a.\n'),
write(S,'valid_breakpoint(level(N)) :- number(N) ; N=a.\n'),
write(S,'valid_breakpoint(step).\n'),
nl(S),
write(S,'send_smodels_breakpoints :-\n'),
write(S,'    smodels_stream(I,_),\n'),
write(S,'    send_breakpoints(I).\n'),
nl(S),
write(S,'send_breakpoints(I) :-\n'),
write(S,'    bk(L),\n'),
write(S,'    write(I, ''break(''), \n'),
write(S,'    write(I,L), write(I,'')''),nl,\n'),
write(S,'    fail.\n'),
write(S,'send_breakpoints(_).\n'),
write(S,'% -------------------------------------------------\n'),
write(S,'send_smodels_code :-\n'),
write(S,'    smodels_stream(I,_),\n'),
write(S,'    state(code(C)),\n'),
write(S,'    write(I,C), nl(I).\n'),
write(S,'send_smodels_code :-\n'),
write(S,'    smodels_stream(I,_),\n'),
write(S,'    write(I,0), nl(I).\n'),
write(S,'%-------------------------------------------------\n'),
write(S,'next :-\n'),
write(S,'    display(''smodels_tracer''),nl,\n'),
write(S,'    smodels_status(0),\n'),
write(S,'    smodels_tracer,\n'),
write(S,'%   display(''end_smodels_breakpoints.''),nl,\n'),
write(S,'    send_smodels_breakpoints,\n'),
write(S,'%    display(''send_exe_code''),nl,\n'),
write(S,'    smodels_stream(I,_),\n'),
write(S,'    send_exe_code(I),\n'),
write(S,'%    display(''run''),nl,\n'),
write(S,'    write(I,''run''),nl(I),\n'),
write(S,'%    display(''wait_for_smodels''),nl,\n'),
write(S,'    wait_for_smodels,\n'),
write(S,'    cleanup_connection.\n'),
write(S,'% ---------------------------------------------------\n'),
write(S,'step :-\n'),
write(S,'%    display(''smodels_tracer''),nl,\n'),
write(S,'    smodels_status(0),\n'),
write(S,'    smodels_tracer,\n'),
write(S,'    smodels_stream(I,O),\n'),
write(S,'    wait_for_smodels_permission(O),\n'),
write(S,'%    display(''send_smodels_breakpoints.''),nl,\n'),
write(S,'    send_smodels_breakpoints,\n'),
write(S,'%    display(''send: step''),nl,\n'),
write(S,'    write(I,''step''),nl(I),\n'),
write(S,'    display(''send_exe_code''),nl,\n'),
write(S,'    send_exe_code(I),\n'),
write(S,'    display(''run''),nl,\n'),
write(S,'    write(I,''run''),nl(I),\n'),
write(S,'    flush_output(I),\n'),
write(S,'    display(''wait_for_smodels''),nl,!,\n'),
write(S,'    wait_for_smodels,\n'),
write(S,'    cleanup_connection.\n'),
write(S,'step(N) :-\n'),
write(S,'%    display(''smodels_tracer''),nl,\n'),
write(S,'    smodels_status(0),\n'),
write(S,'    smodels_tracer,\n'),
write(S,'%    display(''send_smodels_breakpoints.''),nl,\n'),
write(S,'    send_smodels_breakpoints,\n'),
write(S,'    smodels_stream(I,_),\n'),
write(S,'%    display(''send: step''),nl,\n'),
write(S,'    write(I,''step(''), write(I,N), write(I,'')\n''),\n'),
write(S,'%    display(''send_exe_code''),nl,\n'),
write(S,'    send_exe_code(I),\n'),
write(S,'%    display(''run''),nl,\n'),
write(S,'    write(I,''run''),nl(I),\n'),
write(S,'%   display(''wait_for_smodels''),nl,\n'),
write(S,'    wait_for_smodels,\n'),
write(S,'    cleanup_connection.\n'),
write(S,'% ----------------------------------------------------\n'),
write(S,'wait_for_smodels :-\n'),
write(S,'    smodels_stream(I,O),\n'),
write(S,'    '),
write(S,'     Q new '),
write(S,Name_no_ext), write(S,'_class,\n'),
write(S,'    repeat,\n'),
write(S,'%    display(''SmodelsWait ''),\n'),
write(S,'    get_one_line(O,String1),\n'),
write(S,'%    display(''String1=''), write_string(String1),\n'),
write(S,'%    display('' ''),\n'),
write(S,'%    display(''string1=''), display(String1), nl,\n'),
write(S,'%    display(String1), nl,\n'),
write(S,'    append(String,".",String1),\n'),
write(S,' %   display(''String=''), write_string(String),  nl,\n'),
write(S,'    name(T1,String),\n'),
write(S,'    atom2term(T1,T),\n'),
write(S,'%    read(O,T),\n'),
write(S,'%    display(''T=''),\n'),
write(S,'%    display(T), nl,\n'),
write(S,'    read_smodels_command(Q,I,T),\n'),
write(S,'    empty_class(Q).\n'),
write(S,'%    write(I,''term_smodels''),nl.\n'),
nl(S),

write(S,'empty_class(Q) :- \\+Q:atom(_,_), !, display(''empty''),nl, release(Q),!,fail.\n'),
write(S,'empty_class(Q) :- display(''class exist''), nl, save_curr_class(Q).\n\n'),

write(S,'save_curr_class(Q) :- assertz_fact(old_data(Q)), \n'),
write(S,'    retractall(curr_data(_)), assertz_fact(curr_data(Q)),!.\n\n'),

write(S,'% release a model name ASP_Name....\n'),
write(S,'release(Q) :-\n'),
write(S,'	retractall(bk(_)),\n'),
write(S,'	retractall(state(_)),\n'),
write(S,'	retractall(exe_code(_)),\n'),
write(S,'	retractall(smodels_status(_)),\n'),
write(S,'       cleanup_connection,\n'),
write(S,'	retractall(old_data(_)),\n'),
write(S,'	retractall(curr_data(_)),!,\n'),
write(S,'	destroy(Q).\n'),
write(S,'release(_).\n'),
write(S,'% -----------------------------------------------------------\n'),

write(S,'read_smodels_command(_,I,''get_state'') :-\n'),
write(S,'    send_smodels_state(I), \n'),
write(S,'    retractall(state(_)), \n'),
write(S,'    retractall(curr_data(_)),!, fail.\n'),
write(S,'read_smodels_command(_,I,''get_code'') :-\n'),
write(S,'    send_exe_code(I), !, fail.\n'),
write(S,'read_smodels_command(_,_,''send_state'') :-\n'),
write(S,'    get_smodels_state, !, fail.\n'),
write(S,'read_smodels_command(Q,_,''send_data'') :-\n'),
write(S,'    get_data(Q), !, fail.\n'),
write(S,'read_smodels_command(_,_,r(X)) :-\n'),
write(S,'    display(r), display(X), nl,\n'),
write(S,'    smodels_term_status(X), !,fail.\n'),
write(S,'read_smodels_command(_,_,r(0)) :-\n'),
write(S,'    display(r), display(X), nl,\n'),
write(S,'    smodels_term_status(X), !,fail.\n'),
write(S,'read_smodels_command(_,_,end):-!.\n'),
write(S,'read_smodels_command(_,_,_) :- \n'),
write(S,'%   display(''unknown''),nl,\n'),
write(S,'!, fail.\n'),
write(S,'% --------------------------------------------------\n'),
write(S,'send_smodels_state(I) :-\n'),
write(S,'    state(X),\n'),
write(S,'    add_reason(X,Y),\n'),
write(S,'%    display(X), display('' ''), display(Y), nl,\n'),
write(S,'    write(I,Y), nl(I),\n'),
write(S,'    fail.\n'),
write(S,'send_smodels_state(I) :-\n'),
write(S,'    \\+state(_),\n'),
write(S,'%    display(''no_state''),nl,\n'),
write(S,'    write(I,0), nl(I).\n'),
write(S,'send_smodels_state(I) :- \n'),
write(S,'%    display(''end_send_state''),nl,\n'),
write(S,'    write(I,''end_state''),nl(I),\n'),
write(S,'    flush_output(I).\n'),
write(S,'% --------------------------------------------------\n'),
write(S,'get_data(Q) :-\n'),
write(S,'    display(''get_data''),nl,\n'),
write(S,'    smodels_stream(_,O),\n'),
write(S,'    repeat,\n'),
write(S,'    read(O,T),\n'),
write(S,'%    display(''T=''), display(T), display('',''), nl,\n'),
write(S,'    parse_data(Q,T), nl.\n'),
write(S,'%    write(I,''state_done.''), nl(I).\n'),
nl(S),
write(S,'parse_data(_,end_data) :- !.\n'),
write(S,'parse_data(Q,atom(AtomNo,Name)) :- \n'),
write(S,'    Q:data_add(atom(AtomNo,Name)),!, fail.\n'),
write(S,'parse_data(Q,rule(RNO,Head,Body)) :- \n'),
write(S,'    Q:data_add(rule(RNO,Head,Body)),!,fail.\n'),
write(S,'parse_data(Q,just(AtomNo,Value,Reason)) :- \n'),
write(S,'    Q:data_add(just(AtomNo,Value,Reason)),!, fail.\n'),
write(S,'parse_date(_,_):-!,fail.\n'),
write(S,'%----------------------------------------------------\n'),
nl(S),
write(S,'send_exe_code(I) :-\n'),
write(S,'    exe_code(X),\n'),
write(S,'%    display(''send exe_code(''),display(X),display('').''),nl,\n'),
write(S,'    write(I,''exe_code(''),\n'),
write(S,'    write(I,X), write(I,'')\n''),\n'),
write(S,'    retractall(exe_code(_)).\n'),
write(S,'send_exe_code(I) :-\n'),
write(S,'    display(''exe_code(0)''),nl,\n'),
write(S,'    write(I,''exe_code(0)''),nl(I).\n'),
write(S,'% ---------------------------------------------------\n'),
write(S,'cleanup_connection :-\n'),
write(S,'%    display(''clearup.''),nl,\n'),
write(S,'    smodels_stream(I,O),\n'),
write(S,'    retractall(smodels_stream(_,_)),\n'),
write(S,'%    display(''closing_ports''),nl,\n'),
write(S,'    close(I),\n'),
write(S,'    close(O).\n'),
write(S,'%    display(''prt_state''),nl,\n'),
write(S,'%    prt_state.\n'),
nl(S),
write(S,'% --------------------------------------------------\n'),
write(S,'get_smodels_state :-\n'),
write(S,'    smodels_stream(_,O),\n'),
write(S,'    repeat,\n'),
write(S,'    read(O,T),\n'),
write(S,'%    display(T), nl,\n'),
write(S,'    end_of_state(T), \n'),
write(S,'%    write(I,''state_done.''),nl(I),\n'),
write(S,'    clearerr(O).\n'),
nl(S),
write(S,'end_of_state(end_state):-!.\n'),
write(S,'end_of_state(exe_code(X)) :- assertz(exe_code(X)),\n'),
write(S,'!, fail.\n'),
write(S,'end_of_state(state(T)) :-\n'),
write(S,'    assertz(state(T)), !, fail.\n'),
write(S,'end_of_state(X) :- display(X),nl, !, fail.\n'),
nl(S),
write(S,'prt_state :-\n'),
write(S,'    state(X),\n'),
write(S,'    display(X),\n'),
write(S,'    nl,\n'),
write(S,'    fail.\n'),
write(S,'prt_state.\n'),
nl(S),
write(S,'prt_exe_code :- \n'),
write(S,'    exe_code(X), display(''exe_code=''), display(X), nl,!.\n'),
write(S,'prt_exe_code :- \n'),
write(S,'    display(''exe_code=0''),nl.\n'),
nl(S),
write(S,'% ---------------------------------------------------\n'),
write(S,'smodels_term_status(0) :- \n'),
write(S,'%    display(''smdodels_term_status is set to 1''),nl,\n'),
write(S,'    retractall(smodels_status(_)),\n'),
write(S,'    assertz(smodels_status(1)).\n'),
write(S,'smodels_term_status(1).\n'),
write(S,'smodels_term_status(2).\n'),
nl(S),
write(S,'% -------------------------------------------------------\n'),
write(S,'restart :- retractall(exe_code(_)),\n'),
write(S,'    retractall(state(_)), \n'),
write(S,'    retractall(smodels_status(_)),\n'), 
write(S,'    retractall(curr_data(_)),\n'),
write(S,'    assertz(smodels_status(0)).\n'),
nl(S),
write(S,'% --------------------------------------------------------\n'),
write(S,'add_reason(atom(L),atom(L1)) :-\n'),
write(S,'    L=[AtomNo|_],\n'),
write(S,'    curr_data(Q),\n'),
write(S,'    Q:just(AtomNo, 1, True_Reason),\n'),
write(S,'%    nl,display(''Reason=''), display(True_Reason),nl,\n'),
write(S,'    replace_reason(True_Reason, NewTReason),\n'),
write(S,'    append(L, NewTReason, L1),!.\n'),
write(S,'add_reason(L,L).\n'),
nl(S),
write(S,'replace_reason([],[]):-!.\n'),
write(S,'replace_reason([compute_true],[]):-!.\n'),
write(S,'replace_reason([compute_false], []) :-!.\n'),
write(S,'replace_reason([user_forced], []) :- !.\n'),
write(S,'replace_reason([assume],[]) :- !.\n'),
write(S,'replace_reason(R,R).\n'),
write(S,'% ----------------------------------------------------\n'),
write(S,'get_one_line(O,String) :-\n'),
write(S,'    catch(get_line(O,String), _, String="end.").\n\n'),
write(S,'wait_for_smodels_permission(O) :-\n'),
write(S,'    repeat,\n'),
write(S,'    read(O, T),\n'),
write(S,'    get_command(T).\n\n'),

write(S,'get_command(''get_command'') :- !.\n'),
write(S,'get_command(_) :- !, fail.\n'),
write(S,'quit :-\n'),
write(S,'    display(''trace quit''),nl,\n'),
write(S,'    smodels_stream(I,O),\n'),
write(S,'    retractall(smodels_stream(_,_)),\n'),
write(S,'    display(''close I & O''),nl,\n'),
write(S,'    close(I),\n'),
write(S,'    close(O).\n'),
write(S,'quit.\n'),
nl(S).


:- module(fitness_pcpe,
	[
	    all_fitness/2,
	    original_score/2,
	    score/3,
	    balance/3
	],[assertions, isomodes]).


:- doc(title,"Fitness Functions").

:- doc(author, "Claudio Ochoa").

:- doc(module," This module implements the different fitness
	functions used to evaluate all solutions generated by PCPE.").



:- use_module(benchmarking).
:- use_module(db_pcpe).
:- use_module(filenames_pcpe).
:- use_module(spec(mem_usage), 
	[reset_mem_usage/0, ask_mem_usage/2]).
:- use_module(ciaopp(preprocess_flags), [current_pp_flag/2]).
:- use_module(library(compiler), [make_po/1]).
:- use_module(library(lists),    [append/3]).
:- use_module(library(terms),    [atom_concat/2]).
:- use_module(library(system),
	[file_exists/1, file_property/2, delete_file/1]).

:- pred empty_prog_size(-) # "returns the bytecode size of an empty .po".

empty_prog_size(3918).

:- push_prolog_flag(multi_arity_warnings,off).

:- pred all_fitness(+Scores, -Fits) # "It returns a list @var{Fits} of
	fitness values calculated from a list @var{Scores} of raw
	scores. Each fitness is calculated based on the value of
	poly_fitness flag".


all_fitness(Scores, Fits):-
	current_pp_flag(poly_fitness,Fitness),
	original_score(Fitness,Orig_Score),
	all_fitness(Scores,Fitness, Orig_Score,Fits).

all_fitness([],_,_,[]).
all_fitness([(F,L)|T],Fitness,Orig,[(F,NL)|NT]):-
	fitness(Fitness,Orig,L,Fit),
	append(L,[fitness(Fit)],NL),
	all_fitness(T,Fitness,Orig,NT).

:- pop_prolog_flag(multi_arity_warnings).


:- pred original_score(+F,-Score) #"Evaluates the original program
	based on the current fitness function @var{F}".

original_score(speedup,[exec_time(Speed)]):-
	get_src_name(Orig),
	create_driver_file(Orig,RT),
	speed(RT,Speed).

original_score(bytecode,[size(Orig_Size)]):-
	get_src_name(Orig),
	po_size(Orig,Orig_Size).

original_score(memory,[mem(Orig_Size)]):-
	get_src_name(Orig),
	create_driver_file(Orig,RT),
	memory(RT,Orig_Size).

original_score(bounded_size,Score):-
	original_score(speedup,Score).

original_score(balance,[exec_time(Speed),size(Orig_Size)]):-
	get_src_name(Orig),
	create_driver_file(Orig,RT),
	speed(RT,Speed),
	po_size(Orig,Orig_Size).


:- pred fitness(+Fitness ,+Orig_score, +Spec_Score, -Value) # "It
	estimates a fitness value for a candidate, based on its
	@var{Speedup} and @var{Reduction} of compile code
	w.r.t. original program".

fitness(speedup,Orig_score, Spec_score,Fit):-
	member(exec_time(Orig_Speed),Orig_score),
	member(exec_time(Spec_Speed),Spec_score),
	Fit is Orig_Speed/Spec_Speed.

fitness(bytecode,Orig_score, Spec_score,Fit):-
	member(size(Orig_Size),Orig_score),
	member(size(Spec_Size),Spec_score),
	empty_prog_size(Empty),
	Fit is (Orig_Size-Empty)/(Spec_Size-Empty).

fitness(memory,Orig_score, Spec_score,Fit):-
	member(mem(Orig_Mem),Orig_score),
	member(mem(Spec_Mem),Spec_score),
	Fit is Orig_Mem/Spec_Mem.

fitness(bounded_size,Orig_score, Spec_score,Fit):-
	member(exec_time(Spec_Speed),Spec_score),
	(Spec_Speed == -1 ->
	    Fit = 0
	;
	    fitness(speedup,Orig_score, Spec_score,Fit)).

fitness(balance,Orig_score, Spec_score,Fit):-
	fitness(speedup,Orig_score, Spec_score,Speedup),
	fitness(bytecode,Orig_score, Spec_score,Size),
	balance(Speedup,Size,Fit).


:- pred balance(+Sp,+Red,-Bal) #"Based on a speedup value @var{Sp} and
	a reduction value @var{Red} it applies the balance fitness
	function".

balance(Sp,Size,Bal):-
	Bal is Sp * Size.


:- pred score(+F,+Counter,-Info) # "Based on the current fitness
	function @var{F}, it estimates a score for current solution,
	@var{Counter} is the suffix of the specialized program, and
	its usually a number, or tmp for an intermediate
	configuration".

score(speedup,Counter,[exec_time(Speed)]):-
	get_src_name(Orig),
	get_spec_name(Orig,Counter,Spec),
	create_driver_file(Spec,RT),
	speed(RT,Speed).

score(bytecode,Counter,[size(Spec_Size)]):-
	get_src_name(Orig),
	get_spec_name(Orig,Counter,Spec),
	po_size(Spec,Spec_Size).

score(memory,Counter,[mem(Spec_Mem)]):-
	get_src_name(Orig),
	get_spec_name(Orig,Counter,Spec),
	create_driver_file(Spec,RT),
	memory(RT,Spec_Mem).

score(bounded_size,Counter,[exec_time(Speed)]):-
	get_src_name(Orig),
	get_spec_name(Orig,Counter,Spec),
	po_size(Spec,Size),
	bound_residual(Max),
	(Size < Max ->
	    Speed = -1
	 ;
	    create_driver_file(Spec,RT),
	    speed(RT,Speed)).

score(balance,Counter,[size(Size),exec_time(Speed)]):-
	get_src_name(Orig),
	get_spec_name(Orig,Counter,Spec),
	create_driver_file(Spec,RT),
	speed(RT,Speed),
	po_size(Spec,Size).





% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %       Compiled Size

:- pred po_size(+File, -Size ) # "It obtains the compiled @var{Size}
	of @var{File}".

po_size(Base,Size):-
	atom_concat([Base,'.pl'],F),
	atom_concat([Base,'.po'],POFile),
	(file_exists(POFile)->
	    delete_file(POFile)
	;
	    true),
	make_po(F),	    
	file_property(POFile,size(Size)).

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %       Speed

:- pred speed(+RT, -Time ) 
	# "It evaluates a given benchmark using a runtime query
          defined in @var{RT} and returning the execution time in
          @var{Time}".

speed(RT,Time):-
	push_prolog_flag(gc,off),
	do_bench(RT,T1),
	do_dummy(RT,T2),
	Time is T1 - T2,
	pop_prolog_flag(gc).


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %       Memory_consumption

:- pred memory(+Prog, -Delta ) # "It obtains a rough approximation of
	the size @var{Delta} that a given program @var{Prog} will take
	in memory, by loading it in memory and running it once (in
	order to consider both code and data)".

memory(Prog,Delta):-
	reset_mem_usage,
	push_prolog_flag(gc,off),
	do_bench(Prog,_T1),
	pop_prolog_flag(gc),
 	ask_mem_usage(Delta,_Details),
	display(Prog),display(':'),display(Delta),nl.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



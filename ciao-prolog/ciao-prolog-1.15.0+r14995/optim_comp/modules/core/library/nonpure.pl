:- package(nonpure).

% These are the modules automatically imported by non-pure modules
:- use_module(engine(arithmetic)).
:- use_module(engine(atomic_basic)).
:- use_module(engine(basic_props)).
:- use_module(engine(basiccontrol)).
:- use_module(engine(interpreter)).
:- use_module(engine(data_facts)).
:- use_module(engine(exceptions)).
:- use_module(engine(io_aux)).
:- use_module(engine(io_basic)).
:- use_module(engine(prolog_flags)).
:- use_module(engine(streams_basic)).
:- use_module(engine(system_info)).
:- use_module(engine(term_basic)).
:- use_module(engine(term_compare)).
:- use_module(engine(term_typing)).
:- use_module(engine(hiord_rt), [call/1]).
:- use_module(engine(rt_exp), [rt_pgcall/2, rt_modexp/4, rt_exp/6]). % TODO: put a $ in the name

%% :- doc(version_maintenance,on).

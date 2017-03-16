%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Package  CNEG for including constructive in a program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% To be able to call Pred from cneg
:- meta_predicate
        intneg(goal,goal). 
:- meta_predicate
        stored_pred(goal,_). 

% :- use_module(dist,[dist/2]).  <-- Do not use.
% :- use_module(forall,[forall/2]).  <-- Do not use.
:- use_module(library('intneg/dist'),[dist/2]). 
:- use_module(library('intneg/forall'),[forall/2]). 


% stored_pred/2 is going to be a dynamic predicate in the
% programs that are going to include this package
:- data stored_pred/2.

% intneg/1 is going to be a dynamic predicate in the programs that
% are going to load this package. It contains the code of the
% intensional negation of the code of the predicate that is its
% argument
:- data intneg1/2.


% intneg_tr contains predicate comp_pred/3 to obtain the complementary
% predicates to the predicates of the modhle that is being compiled.
:- load_compilation_module(library('intneg/intneg_tr')). 
% :- load_compilation_module(.('intneg_tr')). <-- Do not use.

% comp_pred/3 adds to the compiling module the code of the complemented
% predicate to each predicate of the module.
:- add_sentence_trans(comp_pred/3).


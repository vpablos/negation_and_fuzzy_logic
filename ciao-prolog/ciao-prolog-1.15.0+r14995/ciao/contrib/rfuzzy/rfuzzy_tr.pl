:- module(rfuzzy_tr,[rfuzzy_trans_sentence/3, rfuzzy_trans_clause/3],[]).

:- use_module(library(aggregates), [findall/3]).
:- use_module(library(terms),[copy_args/3]).
:- use_module(library('rfuzzy/rfuzzy_rt')).
:- include(library('clpqr-common/ops')).
:- include(library('rfuzzy/rfuzzy_ops')).

% Important info to be saved.
:- data predicate_definition/4.
:- data aggregators/1.
:- data sentences/2.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% translation_info(Category, Sub_Category_Of, Add_Args, Fix_Priority, Priority, Preffix_String)

translation_info('aggregator',         '', 0, 'no', 0, "").
translation_info('defuzzification',   '', 0, 'no', 0, "").
translation_info('crisp',                   '', 0, 'no', 0, "").
translation_info('function',              '', 1, 'no', 0, "").
translation_info('quantifier',           '', 1, 'no', 0, "").
translation_info('fuzzy_rule',         '', 1, 'no', 0, "").
% translation_info('auxiliar',           '', 2, 'no', 0, "rfuzzy_aux_").
% translation_info('normal',           '', 1, 'yes', 0, "").

translation_info('type',                               'fuzzy_rule', 2, 'no', 0,          "rfuzzy_type_").
translation_info('default_without_cond',   'fuzzy_rule', 2, 'yes', 0,        "rfuzzy_default_without_cond_").
translation_info('default_with_cond',        'fuzzy_rule', 2, 'yes', 0.25,   "rfuzzy_default_with_cond_"). 
translation_info('rule',                                'fuzzy_rule', 2, 'yes', 0.5,     "rfuzzy_rule_").
translation_info('fuzzification',                   'fuzzy_rule', 2, 'yes', 0.75,  "rfuzzy_fuzzification_").
translation_info('fact',                                 'fuzzy_rule', 2, 'yes', 1,       "rfuzzy_fact_").
translation_info('synonym',                        'fuzzy_rule', 2, 'no', 0,         "rfuzzy_sinonym_").
translation_info('antonym',                         'fuzzy_rule', 2, 'no', 0,         "rfuzzy_antonym_").
translation_info('non_rfuzzy_fuzzy_rule',  'fuzzy_rule', 0, 'no', 0,         "non_rfuzzy_fuzzy_rule").

% This produces unexpected results.
% translation_info(_X,                             _Y,               0, 0, 'no', 0,          "rfuzzy_error_error_error_").

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

save_predicate_definition(Category, Pred_Name, Pred_Arity, Sub_Category, Sub_Pred_Name, Sub_Pred_Arity) :-
	print_msg('debug', 'save_predicate_definition(Category, Pred_Name, Pred_Arity, Sub_Category, Sub_Pred_Name, Sub_Pred_Arity)', save_predicate_definition(Category, Pred_Name, Pred_Arity, Sub_Category, Sub_Pred_Name, Sub_Pred_Arity)),
	save_predicate_definition_test_categories(Category, Sub_Category), % Only valid values, please.
	
	(
	    (	 
		retract_fact(predicate_definition(Category, Pred_Name, Pred_Arity, List)), !, % Retract last
		assertz_fact(predicate_definition(Category, Pred_Name, Pred_Arity, [(Sub_Category, Sub_Pred_Name, Sub_Pred_Arity)|List]))
	    )
% Just try to explain me why it is not allowed ...
%	;
%	    (
%		predicate_definition(_Category_Aux, Pred_Name, Pred_Arity, List), !, % Retract last
%		print_msg('error', 'It is not allowed to define again the predicate', (Pred_Name/Pred_Arity)),
%		fail
%	    )
	;
	    (
		assertz_fact(predicate_definition(Category, Pred_Name, Pred_Arity, [(Sub_Category, Sub_Pred_Name, Sub_Pred_Arity)]))
	    )
	), 
	print_msg('debug', 'saved', save_predicate_definition(Category, Pred_Name, Pred_Arity, Sub_Category, Sub_Pred_Name, Sub_Pred_Arity)),
	!.		 

retrieve_predicate_info(Category, Name, Arity, List, Show_Error) :-
	print_msg('debug', 'retrieve_predicate_info(Category, Name, Arity, List, Show_Error)', retrieve_predicate_info(Category, Name, Arity, List, Show_Error)),
	save_predicate_definition_test_categories(_AnyValidCategory, Category),
	(
	    (   
		predicate_definition(Category, Name, Arity, List), !   
	    )
	;
	    (  
		translation_info(Category, '', _Add_Args, _Fix_Priority, _Priority, _Preffix_String),
		Show_Error = 'yes', !,
		print_msg('error', 'Predicate must be defined before use. Predicate ', Name/Arity), !, 
		fail
	    )
	;
	    (  
		translation_info(Category, '', _Add_Args, _Fix_Priority, _Priority, _Preffix_String),
		Show_Error = 'no', !, fail
	    )
	;
	    (
		print_msg('error', 'Requested category does not exist. Category ', Category), !, 
		fail
	    )
	).

retrieve_all_predicate_info_with_category(Category, Retrieved) :-
	findall((predicate_definition(Category, Name, Arity, List)),
	(retract_fact(predicate_definition(Category, Name, Arity, List))), Retrieved),
	 !.
	
save_predicate_definition_test_categories(Category, Sub_Category) :-
	(
	    save_predicate_definition_test_categories_aux(Category, Sub_Category)
	;
	    (
		print_msg('error', 'Unknown Category or Sub_Category. (Category, Sub_Category)', (Category, Sub_Category)),
		!, fail
	    )
	), !.

save_predicate_definition_test_categories_aux(Category, Sub_Category) :-
	(
	    (	var(Category), var(Sub_Category), !, fail  )
	;
	    (   var(Category), nonvar(Sub_Category), !,
		save_predicate_definition_test_categories_aux(Sub_Category, Sub_Category)
	    )
	;
	    (   nonvar(Category), var(Sub_Category), !, 
		save_predicate_definition_test_categories_aux(Category, Category)
	    )
	).

save_predicate_definition_test_categories_aux(Category, Sub_Category) :-
	nonvar(Category), nonvar(Sub_Category),
	Category = Sub_Category, % This case is impossible because it is an infinite loop.
	translation_info(Sub_Category, _Any_Category, _Add_Args, _Fix_Priority, _Priority, _Preffix_String), 
	!.

save_predicate_definition_test_categories_aux(Category, Sub_Category) :-
	nonvar(Category), nonvar(Sub_Category),
	% translation_info(Category, Sub_Category_Of, Add_Args, Fix_Priority, Priority, Preffix_String)
	translation_info(Sub_Category, Category, _Add_Args, _Fix_Priority, _Priority, _Preffix_String), !.

%remove_predicate_info(Category, Name, Arity, Fuzzy_Name, Fuzzy_Arity) :-
%	predicate_definition_contents(Pred_Info, Category, Name, Arity, Fuzzy_Name, Fuzzy_Arity),
%	retract_fact(Pred_Info), !. % Retract 


% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

rfuzzy_trans_clause(Arg1, Arg1, _Arg3) :- 
	print_msg('debug', 'trans_fuzzy_clause: arg1', Arg1).

rfuzzy_trans_sentence(Arg1, Arg2, Arg3) :- 
	print_msg('debug', 'rfuzzy_trans_sent: arg1', Arg1),
	rfuzzy_trans_sent_aux(Arg1, Arg2), !,
	print_msg('debug', 'rfuzzy_trans_sent: arg2', Arg2),
	print_msg('debug', 'rfuzzy_trans_sent: arg3', Arg3),
	print_msg_nl('debug').

rfuzzy_trans_sentence(Arg, Arg, FileName) :- 
	print_msg('warning', 'rfuzzy_trans_sent: ERROR: Input: ', Arg),
	print_msg('warning', 'rfuzzy_trans_sent: ERROR: FileName: ', FileName),
	print_msg_nl('debug'),
	print_info('debug', Arg), 
	print_msg_nl('debug'),
	print_msg_nl('debug').

print_info(Level, Sentence) :-
	print_msg(Level, 'print_info', Sentence),
	functor(Sentence, Name, Arity),
	print_msg(Level, 'print_info: (Name, Arity)', (Name, Arity)),
	Sentence=..[Name|Args],
	print_list_info(Level, Args).
print_list_info(Level, []) :- !,
	print_msg(Level, 'print_list_info', 'empty list').
print_list_info(Level, [Arg | Args]) :- !,
	print_info(Level, Arg),
	print_list_info(Level, Args).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% We need to evaluate the whole program at the same time.
% Note that eat_2 uses info supplied by eat_1 and 
% eat_3 uses info supplied by eat_1 and eat_2.	
rfuzzy_trans_sent_aux(end_of_file, Fuzzy_Rules_3):-
	!,
	retrieve_all_predicate_info_with_category('fuzzy_rule', Fuzzy_Rules_To_Build),
	print_msg('debug', 'fuzzy rules to build', Fuzzy_Rules_To_Build),
	build_auxiliary_clauses(Fuzzy_Rules_To_Build, Fuzzy_Rules_1),
	generate_introspection_predicate(Fuzzy_Rules_To_Build, Fuzzy_Rules_1, Fuzzy_Rules_2),
	add_auxiliar_code(Fuzzy_Rules_2, Fuzzy_Rules_3).

rfuzzy_trans_sent_aux(0, []) :- !, 
	print_msg_nl('info'), print_msg_nl('info'), 
	print_msg('info', 'Rfuzzy (Ciao Prolog package to compile Rfuzzy programs into a pure Prolog programs)', 'compiling ...'),
	print_msg_nl('info').
rfuzzy_trans_sent_aux((:-activate_rfuzzy_debug), []) :- !,
	activate_rfuzzy_debug.
rfuzzy_trans_sent_aux((:-Whatever), [(:-Whatever)]) :- !.
rfuzzy_trans_sent_aux(Sentence, Translation) :-
	translate(Sentence, Translation).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% Unconditional default
translate((rfuzzy_default_value_for(Pred_Name/Pred_Arity, Value)), (Fuzzy_H)) :- 
	!, % If patter matching, backtracking forbiden.
	number(Value), % Value must be a number.
	number(Pred_Arity), % A must be a number.
	nonvar(Pred_Name), % Name can not be a variable.

	functor(H, Pred_Name, Pred_Arity),
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(H, 'default_without_cond', 'yes', Fuzzy_H, Value),
	!. % Backtracking forbidden.

% Conditional default
translate((rfuzzy_default_value_for(Pred_Name/Pred_Arity, Value) if Pred2_Name/Pred2_Arity), (Fuzzy_H :- H_Cond)) :-
	print_msg('debug', 'translate', 'if detected'),
	!, % If patter matching, backtracking forbiden.
	Pred_Arity = Pred2_Arity,
	number(Value), % Value must be a number.
	number(Pred_Arity), % Pred_Arity must be a number.
	number(Pred2_Arity), % Pred2_Arity must be a number.
	nonvar(Pred_Name), % Pred_Name cannot be a variable.
	nonvar(Pred2_Name), % Pred2_Name cannot be a variable.
	
	functor(H, Pred_Name, Pred_Arity),
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(H, 'default_with_cond', 'yes', Fuzzy_H, Value),
	
	functor(H_Cond, Pred2_Name, Pred2_Arity),
	copy_args(Pred_Arity, H_Cond, H), !.   % Copy args from main functor.

translate((rfuzzy_default_value_for(Pred_Name/Pred_Arity, Value) if thershold(Pred2_Name/Pred2_Arity, Cond, Thershold_Value)), (Pred_Functor :- Pred2_Functor, Pred3_Functor)) :-
	print_msg('debug', 'translate :: (rfuzzy_default_value_for(Pred_Name/Pred_Arity, Value) if thershold(Pred2_Name/Pred2_Arity, Cond, Thershold_Value))', (rfuzzy_default_value_for(Pred_Name/Pred_Arity, Value) if thershold(Pred2_Name/Pred2_Arity, Cond, Thershold_Value))),
	!, % If patter matching, backtracking forbiden.
	Pred_Arity = Pred2_Arity,
	number(Value), number(Pred_Arity), number(Pred2_Arity), % They must be numbers.
	nonvar(Pred_Name), nonvar(Pred2_Name), % They cannot be variables.
	
	functor(Aux_Pred_Functor, Pred_Name, Pred_Arity),
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(Aux_Pred_Functor, 'default_with_cond', 'yes', Pred_Functor, Value),
	functor(Aux_Pred2_Functor, Pred2_Name, Pred2_Arity),
	copy_args(Pred2_Arity, Aux_Pred_Functor, Aux_Pred2_Functor),

	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(Aux_Pred2_Functor, 'fuzzy_rule', 'no', Pred2_Functor, Truth_Value_For_Thershold),
	functor(Pred2_Functor, Pred2_Functor_Name, Pred2_Functor_Arity),
	retrieve_predicate_info('fuzzy_rule', Pred2_Functor_Name, Pred2_Functor_Arity, _List, 'yes'), !,	
	print_msg('debug', 'translate', 'condition (over | under)'),
	(
	    (
		Cond = 'over',
		functor(H_Pred3, '.>.', 2),
		Pred3_Functor=..['.>.', Truth_Value_For_Thershold, Thershold_Value]
	    )
	;
	    (
		Cond = 'under',
		functor(H_Pred3, '.<.', 2),
		Pred3_Functor=..['.<.', Truth_Value_For_Thershold, Thershold_Value]
	    )
	), !.

% Fuzzy facts.
translate((Head value Value), (Fuzzy_Head :- Fuzzy_Body)):-
	!, % If patter matching, backtracking forbiden.
	print_msg('debug', 'fact conversion :: IN ',(Head value Value)),
	number(Value),                    % Value must be a number.

	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(Head, 'fact', 'yes', Fuzzy_Head, Truth_Value),
	functor(Fuzzy_Body, '.=.', 2),
	arg(1, Fuzzy_Body, Truth_Value),
	arg(2, Fuzzy_Body, Value),
	print_msg('debug', 'fact conversion :: OUT ',(Fuzzy_Head)),
	!. % Backtracking forbidden.

% Although aggregators are just crisp predicates of arity 3, 
% we use the following to ensure programmers do not use as aggregators
% fuzzy predicates (of arity 3 too). An error like that is very difficult to find.
translate((rfuzzy_aggregator(Aggregator_Name/Aggregator_Arity)), []) :-
	!, % If patter matching, backtracking forbiden.
	nonvar(Aggregator_Name), number(Aggregator_Arity), Aggregator_Arity = 3,

	% retrieve_predicate_info(Category, Name, Arity, List, Show_Error)
	retrieve_predicate_info('crisp', Aggregator_Name, Aggregator_Arity, _List, 'yes'),

	% save_predicate_definition(Category, Pred_Name, Pred_Arity, SubCategory, Fuzzy_Name, Fuzzy_Arity), !.
	save_predicate_definition('aggregator', Aggregator_Name, Aggregator_Arity, 'aggregator', Aggregator_Name, Aggregator_Arity),
	!.

% function definition.
translate((Head :# List), (Fuzzy_H :- (Body, print_msg('debug', 'function_call', Fuzzy_H)))) :-
	!, % If patter matching, backtracking forbiden.
	% list(Lista),
	print_msg('debug', '(Head :# List) ', (Head :# List)),

	functor(Head, Name, 0),
	functor(H, Name, 1),
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(H, 'function', 'yes', Fuzzy_H, Truth_Value),

	arg(1, Fuzzy_H, X),
	build_straight_lines(X, Truth_Value, List, Body).

% Predicate's type(s) definition.
translate(rfuzzy_type_for(Pred_Name/Pred_Arity, Types),(Fuzzy_H :- Cls)):-
	!, % If patter matching, backtracking forbiden.
	print_msg('debug', 'rfuzzy_type_for(Pred_Name/Pred_Arity, Types)', rfuzzy_type_for(Pred_Name/Pred_Arity, Types)),
	(
	    (   % Types has the form [restaurant/1]
		number(Pred_Arity), % A must be a number.
		nonvar(Pred_Name), % Can not be a variable.
		nonvar(Types),
		
		functor(H, Pred_Name, Pred_Arity),
		% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
		translate_functor(H, 'type', 'yes', Fuzzy_H, _Unused_Truth_Value),
		translate_each_type(Fuzzy_H, Pred_Arity, 1, Types, Cls)
	    )
	;
	    print_msg('error', 'translate :: Syntax Error in type definition', rfuzzy_type_for(Pred_Name/Pred_Arity, Types))
	),
	!. % Backtracking forbidden.

% rules with credibility:
translate(((Head cred (Cred_Op, Cred)) :~ Body), Translation):-
	!, % If patter matching, backtracking forbiden.
	print_msg('debug', '(Head cred (Cred_Op, Cred)) :~ Body)', ((Head cred (Cred_Op, Cred))  :~ Body)),
	translate_rule(Head, Cred_Op, Cred, Body, Translation).

% rules without credibility:
translate((Head :~ Body), Translation):-
	!, % If patter matching, backtracking forbiden.
	print_msg('debug', '(Head :~ Body)', (Head  :~ Body)),
	translate_rule(Head, 'prod', 1, Body, Translation).

translate(rfuzzy_synonym(Existing_Predicate_Name/Arity, New_Predicate_Name/Arity, Cred_Op, Cred), Translation):-
	!,
	print_msg('debug', 'translate(rfuzzy_synonym(Existing_Predicate_Name/Arity, New_Predicate_Name/Arity, Cred_Op, Cred))) ', rfuzzy_synonym(Existing_Predicate_Name/Arity, New_Predicate_Name/Arity, Cred_Op, Cred)),
	nonvar(Existing_Predicate_Name), nonvar(New_Predicate_Name), nonvar(Cred_Op), number(Cred), number(Arity),
	test_aggregator_is_defined(Cred_Op, 'yes'),

	functor(New_Predicate_Functor, New_Predicate_Name, Arity), 
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(New_Predicate_Functor, 'synonym', 'yes', Fuzzy_Pred_Functor, Truth_Value_Out),

	functor(Credibility_Functor, Cred_Op, 3), 
	Credibility_Functor=..[Cred_Op, Truth_Value_In, Cred, Truth_Value_Out],

	Arity_plus_1 is Arity + 1,
	Arity_plus_2 is Arity_plus_1 + 1,

	% retrieve_predicate_info(Category, Name, Arity, List, Show_Error)
	retrieve_predicate_info('fuzzy_rule', Existing_Predicate_Name, Arity_plus_1, _List, 'yes'),

	add_preffix_to_name(Existing_Predicate_Name, "rfuzzy_aux_", Existing_Predicate_Aux_Name),
	functor(Existing_Predicate_Aux_Functor, Existing_Predicate_Aux_Name, Arity_plus_2),
	copy_args(Arity_plus_1, Fuzzy_Pred_Functor, Existing_Predicate_Aux_Functor),
	arg(Arity_plus_2, Existing_Predicate_Aux_Functor, Truth_Value_In),

	Translation = (Fuzzy_Pred_Functor :- Existing_Predicate_Aux_Functor, Credibility_Functor, (Truth_Value_Out .>=. 0, Truth_Value_Out .=<. 1)).

translate(rfuzzy_antonym(Existing_Predicate_Name/Arity, New_Predicate_Name/Arity, Cred_Op, Cred), Translation):-
	!,
	print_msg('debug', 'translate(rfuzzy_antonym(Existing_Predicate_Name/Arity, New_Predicate_Name/Arity, Cred_Op, Cred))) ', rfuzzy_antonym(Existing_Predicate_Name/Arity, New_Predicate_Name/Arity, Cred_Op, Cred)),
	nonvar(Existing_Predicate_Name), nonvar(New_Predicate_Name), nonvar(Cred_Op), number(Cred), number(Arity),
	test_aggregator_is_defined(Cred_Op, 'yes'),

	functor(New_Predicate_Functor, New_Predicate_Name, Arity), 
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(New_Predicate_Functor, 'synonym', 'yes', Fuzzy_Pred_Functor, Truth_Value_Out),

	functor(Credibility_Functor, Cred_Op, 3), 
	Credibility_Functor=..[Cred_Op, Truth_Value_Aux, Cred, Truth_Value_Out],

	Arity_plus_1 is Arity + 1,
	Arity_plus_2 is Arity_plus_1 + 1,

	% retrieve_predicate_info(Category, Name, Arity, List, Show_Error)
	retrieve_predicate_info('fuzzy_rule', Existing_Predicate_Name, Arity_plus_1, _List, 'yes'),

	add_preffix_to_name(Existing_Predicate_Name, "rfuzzy_aux_", Existing_Predicate_Aux_Name),
	functor(Existing_Predicate_Aux_Functor, Existing_Predicate_Aux_Name, Arity_plus_2),
	copy_args(Arity_plus_1, Fuzzy_Pred_Functor, Existing_Predicate_Aux_Functor),
	arg(Arity_plus_2, Existing_Predicate_Aux_Functor, Truth_Value_In),

	Translation = (Fuzzy_Pred_Functor :- Existing_Predicate_Aux_Functor, (Truth_Value_Aux is 1 - Truth_Value_In), Credibility_Functor, (Truth_Value_Out .>=. 0, Truth_Value_Out .=<. 1)).

translate(rfuzzy_quantifier(Quantifier_Name/Arity, Condition, TV_Thershold), Translation):-
	!,
	nonvar(Quantifier_Name), nonvar(Condition), number(TV_Thershold), number(Arity), Arity = 1,
	functor(Quantifier_Functor_Aux, Quantifier_Name, Arity),
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(Quantifier_Functor_Aux, 'quantifier', 'yes', Quantifier_Functor, Truth_Value),
	arg(1, Quantifier_Functor, Fuzzy_Predicate_Functor_In),
	
	(
	    (   Condition = over, 
		Formula = (
			      (Max_In .=. FP_Truth_Value - TV_Thershold), 
			       max(0, Max_In, Dividend), 
			       Truth_Value .=. ((Dividend)/(1 - TV_Thershold)))
	    ) 
	;
	    (   Condition = under, 
		Formula = (
			      (Min_In .=. FP_Truth_Value - TV_Thershold), 
			       min(0, Min_In, Dividend), 
			       Truth_Value .=. ((Dividend)/(0 - TV_Thershold)))
	    )
	),

	Translation= (
			 Quantifier_Functor :-
		     (
			 functor(Fuzzy_Predicate_Functor_In, FP_Name, FP_Arity), 
			 FP_Arity_Aux is FP_Arity - 1,
			 functor(FP_Functor, FP_Name, FP_Arity), 
			 copy_args(FP_Arity_Aux, Fuzzy_Predicate_Functor_In, FP_Functor),			 
			 arg(FP_Arity, FP_Functor, FP_Truth_Value),
			 FP_Functor,
			 Formula
		     )
		     ).



% fuzzification:
translate(rfuzzy_define_fuzzification(Pred/1, Crisp_P/2, Funct_P/2), (Fuzzy_Pred_Functor :- (Crisp_P_F, Funct_P_F))):-
	!, % If patter matching, backtracking forbiden.
	print_msg('debug', 'translate: rfuzzy_define_fuzzification(Pred/1, Crisp_P/2, Funct_P/2)', rfuzzy_define_fuzzification(Pred/1, Crisp_P/2, Funct_P/2)),
	% retrieve_predicate_info(Category, Name, Arity, List, Show_Error)
	retrieve_predicate_info('crisp', Crisp_P, 2, _List_1, 'yes'),
	retrieve_predicate_info('function', Funct_P, 2, _List_2, 'yes'),
	functor(Pred_Functor, Pred, 1),
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(Pred_Functor, 'fuzzification', 'yes', Fuzzy_Pred_Functor, Truth_Value),

	% We need to do here as in other translations, so 
	% it generates aux and main predicates for fuzzifications too.
	functor(Crisp_P_F, Crisp_P, 2),
	functor(Funct_P_F, Funct_P, 2),

	arg(1, Fuzzy_Pred_Functor, Input),
	arg(1, Crisp_P_F, Input),
	arg(2, Crisp_P_F, Crisp_Value),
	arg(1, Funct_P_F, Crisp_Value),
	arg(2, Funct_P_F, Truth_Value),
	!.

translate(rfuzzy_non_rfuzzy_fuzzy_rule(Pred_Name/Pred_Arity), []) :-
	% save_predicate_definition(Category, Pred_Name, Pred_Arity, Sub_Category, Sub_Pred_Name, Sub_Pred_Arity)	
	save_predicate_definition('fuzzy_rule', Pred_Name, Pred_Arity, 'non_rfuzzy_fuzzy_rule', Pred_Name, Pred_Arity).

% crisp predicates (non-facts) and crisp facts.
translate(Other, Other) :-
	print_msg('debug', 'Non-Rfuzzy predicate', Other),
	nonvar(Other), 
	(
	    (
		functor(Other, ':-', 2), !,
		arg(1, Other, Arg_1), 
		nonvar(Arg_1), 
		functor(Arg_1, Name, Arity)
	    )
	;
	    (
		functor(Other, Name, Arity), 
		Name \== ':-',
		Name \== ':~',
		Name \== ':#',
		Name \== 'value',
		Name \== 'fuzzify'
	    )
	),
	% save_predicate_definition(Category, Pred_Name, Pred_Arity, Sub_Category, Sub_Pred_Name, Sub_Pred_Arity)
	save_predicate_definition('crisp', Name, Arity, 'crisp', Name, Arity).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

translate_rule(Head, Cred_Op, Cred, Body, (Fuzzy_Head :- Fuzzy_Body)) :-
	print_msg('debug', 'translate_rule(Head, Cred_Op, Cred, Body) ', (translate_rule(Head, Cred_Op, Cred, Body))),
	nonvar(Head), nonvar(Cred_Op), nonvar(Body), number(Cred),

	% Change head's name.
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(Head, 'rule', 'yes', Fuzzy_Head, Truth_Value),

	% Translate all predicates in the body.
	extract_aggregator(Body, TV_Aggregator, Tmp_Body),

	translate_rule_body(Tmp_Body, TV_Aggregator, Truth_Value, Fuzzy_Body).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

extract_aggregator(Body, Aggregator_Op, Tmp_Body) :-
	print_msg('debug', 'extract_aggregator(Body)', extract_aggregator(Body)),
	extract_aggregator_aux(Body, Aggregator_Op, Tmp_Body),
	print_msg('debug', 'extract_aggregator(Body, Aggregator_Op, Tmp_Body)', extract_aggregator(Body, Aggregator_Op, Tmp_Body)).
	
extract_aggregator_aux(Body, Aggregator_Op_Name, Tmp_Body) :-
	nonvar(Body),
	functor(Body, Aggregator_Op_Name, 1),
	test_aggregator_is_defined(Aggregator_Op_Name, 'no'),
	arg(1, Body, Tmp_Body), !.
extract_aggregator_aux(Body, 'null', Body) :- !.

test_aggregator_is_defined(Aggregator_Op_Name, _Show_Error) :-
	nonvar(Aggregator_Op_Name),
	defined_aggregators(Aggregators),
	memberchk_local(Aggregator_Op_Name, Aggregators), !.
test_aggregator_is_defined(Aggregator_Op_Name, Show_Error) :-
	nonvar(Aggregator_Op_Name),
 	% retrieve_predicate_info(Category, Name, Arity, List, Show_Error)
	retrieve_predicate_info('aggregator', Aggregator_Op_Name, 3, _List, Show_Error), !.

	

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% Security issues
translate_rule_body(Body_F, TV_Aggregator, _Truth_Value, _FB) :- 
	print_msg('debug', 'translate_rule_body(Body_F, TV_Aggregator) - variable problem', (Body_F, TV_Aggregator)),
	var(Body_F), !, fail. % If this is a variable the tranlate rules loop forever !!!

% Conjunction.
translate_rule_body((Tmp_Body_1, Tmp_Body_2), TV_Aggregator, Truth_Value, (FB_1, FB_2, Aggr_F)) :- !,
	print_msg('debug', 'translate_rule_body(Body, TV_Aggregator, Truth_Value) - conjunction',((Tmp_Body_1, Tmp_Body_2), TV_Aggregator, Truth_Value)),
	nonvar(TV_Aggregator),
	\+ ( TV_Aggregator = 'none' ),
	translate_rule_body(Tmp_Body_1, TV_Aggregator, TV_1, FB_1),
	translate_rule_body(Tmp_Body_2, TV_Aggregator, TV_2, FB_2),
	functor(Aggr_F, TV_Aggregator, 3),
	arg(1, Aggr_F, TV_1), 
	arg(2, Aggr_F, TV_2), 
	arg(3, Aggr_F, Truth_Value), !.

% Quantifier.
translate_rule_body(Body_F_In, _TV_Aggregator, Truth_Value, Translation) :-
	print_msg('debug', 'translate_rule_body(Body, Truth_Value) - with quantifier',(Body_F_In, Truth_Value)),
	nonvar(Body_F_In),
	functor(Body_F_In, Pred_Name, 1),
	functor(Body_F, Pred_Name, 1),
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(Body_F, 'quantifier', 'no', Fuzzy_Functor, Truth_Value),
	functor(Fuzzy_Functor, Fuzzy_Functor_Name, Fuzzy_Functor_Arity),
	print_msg('debug', 'test_quantifier_is_defined(Fuzzy_Functor_Name, Fuzzy_Functor_Arity)', (Fuzzy_Functor_Name, Fuzzy_Functor_Arity)),
	test_quantifier_is_defined(Fuzzy_Functor_Name, Fuzzy_Functor_Arity),
	print_msg('debug', 'test_quantifier_is_defined(Fuzzy_Functor_Name, Fuzzy_Functor_Arity) - YES ', (Fuzzy_Functor_Name, Fuzzy_Functor_Arity)),

	arg(1, Body_F_In, SubBody),
	translate_rule_body(SubBody, 'none', _SubCall_Truth_Value, SubCall),
	print_msg('debug', 'translate_rule_body(Fuzzy_Functor) - with quantifier',(Fuzzy_Functor)),
	arg(1, Fuzzy_Functor, SubCall),
	Translation = (Fuzzy_Functor, (Truth_Value .>=. 0, Truth_Value .=<. 1)),
	print_msg('debug', 'translate_rule_body(Translation) - with quantifier',(Translation)).

% Normal.
translate_rule_body(Body_F, _TV_Aggregator, Truth_Value, (Fuzzy_Functor, (Truth_Value .>=. 0, Truth_Value .=<. 1))) :-
	print_msg('debug', 'translate_rule_body(Body, Truth_Value) - without quantifier',(Body_F, Truth_Value)),
	nonvar(Body_F),
	% translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value)
	translate_functor(Body_F, 'fuzzy_rule', 'no', Fuzzy_Functor, Truth_Value),
	functor(Fuzzy_Functor, Fuzzy_Functor_Name, Fuzzy_Functor_Arity),
	% retrieve_predicate_info(Category, Name, Arity, List, Show_Error)
	retrieve_predicate_info('fuzzy_rule', Fuzzy_Functor_Name, Fuzzy_Functor_Arity, _List, 'yes'), !,
	print_msg('debug', 'translate_rule_body(Body, Truth_Value, Fuzzy_Functor)',(Body_F, Truth_Value, Fuzzy_Functor)),
	print_msg_nl('debug').

translate_rule_body(Body_F, _TV_Aggregator, _Truth_Value, _Result) :-
	print_msg('error', 'translate_rule_body(Body)',(Body_F)), !, fail.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

test_quantifier_is_defined(Quantifier_Name, _Quantifier_Arity) :-
	defined_quantifiers(Quantifiers_List),
	memberchk_local(Quantifier_Name, Quantifiers_List), !. 
test_quantifier_is_defined(Quantifier_Name, Quantifier_Arity) :-
	% retrieve_predicate_info(Category, Name, Arity, List, Show_Error)
	retrieve_predicate_info('quantifier', Quantifier_Name, Quantifier_Arity, _List, 'no'), !.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

translate_each_type(H, Arity, Actual, [Type/1], Type_F) :-
	print_msg('debug', 'translate_each_type(H, Arity, Actual, Type)', (H, Arity, Actual, Type) ),
	Actual = Arity, !, % Security conditions.
	translate_each_type_aux(H, Actual, Type, Type_F),
	!. % Backtracking not allowed.

translate_each_type(H, Arity, Actual, [Type/1 | More], (Type_F, More_F)) :-
	print_msg('debug', 'translate_each_type(H, Arity, Actual, Type)', (H, Arity, Actual, Type) ),
	Actual < Arity, !,  % Security conditions.
	translate_each_type_aux(H, Actual, Type, Type_F),
	NewActual is Actual + 1, % Next values.
	!,
	translate_each_type(H, Arity, NewActual, More, More_F),
	!. % Backtracking not allowed here.

translate_each_type_aux(H, Actual, Type, Type_F) :-
	print_msg('debug', 'translate_each_type_aux(H, Actual, Type)', translate_each_type_aux(H, Actual, Type)),
	% retrieve_predicate_info(Category, Name, Arity, List, Show_Error)
	retrieve_predicate_info('crisp', Type, 1, _List, 'yes'), !,	
	functor(Type_F, Type, 1), % Build functor.
	arg(1, Type_F, X),       % Argument of functor is X.
	arg(Actual, H, X). % Unify with Argument of functor.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

build_straight_lines(X, V, [(X1,V1),(X2,V2)], (Point1 ; Line ; Point2)) :-
	print_msg('debug', 'build_straight_lines', (build_straight_lines(X, V, [(X1,V1),(X2,V2)], (Point1, Line, Point2)))),
	build_point(X, V, X1, V1, Point1),
	build_line(X, V, X1, V1, X2, V2, Line),
	build_point(X, V, X2, V2, Point2).

build_straight_lines(X, V, [(X1,V1),(X2,V2)|List], (Point ; Line ; More)) :-
	print_msg('debug', 'build_straight_lines', (build_straight_lines(X, V, [(X1,V1),(X2,V2)|List], (Point, Line, More)))),
	build_point(X, V, X1, V1, Point),
	build_line(X, V, X1, V1, X2, V2, Line),
	build_straight_lines(X, V, [(X2,V2)|List], More).

build_point(X, V, X1, V1, (X .=. X1, V .=. V1)) :-
	print_msg('debug', 'build_point', build_point(X, V, X, V, (H :- (H :- X1 .=. X, V1 .=. V)))).

build_line(X, V, X1, V1, X2, V2, (X .>. X1, X .<. X2, Calculate_V)) :-
	print_msg('debug', 'build_line', (build_line(X, V, X1, V1, X2, V2, (X .>. X1, X .<. X2, Calculate_V)))),

	number(X1), number(X2),
	number(V1), number(V2),
	X1 < X2, 

	!, % Backtracking is not allowed here.
	evaluate_V(X, V, X1, V1, X2, V2, Calculate_V).

evaluate_V(_X, V, _X1, Vf, _X2, Vf, (V .=. Vf)) :- !.

evaluate_V(X, V, X1, V1, X2, V2, (Pend .=. ((V2-V1)/(X2-X1)), V .=. V1+Pend*(X-X1))) :-
	X2 - X1 > 0,
	V1 \= V2.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------


translate_functor(Functor, Category, Save_Predicate, Fuzzy_Functor, Truth_Value) :-
	print_msg('debug', 'translate_functor(Functor, Category)', translate_functor(Functor, Category)),
	functor(Functor, Name, Arity),
	translation_info(Category, Sub_Category_Of, Add_Args, Fix_Priority, Priority, Preffix_String),
	number(Add_Args),
	Fuzzy_Arity is Arity + Add_Args, % Fuzzy Args.
	add_preffix_to_name(Name, Preffix_String, Fuzzy_Name), % Change name
	functor(Fuzzy_Functor, Fuzzy_Name, Fuzzy_Arity),
	copy_args(Arity, Functor, Fuzzy_Functor), !,
	translate_functor_add_args(Fuzzy_Functor, Fuzzy_Arity, Add_Args, Fix_Priority, Priority, Truth_Value),
	print_msg('debug', 'translate_functor :: added args: Fuzzy_Functor', Fuzzy_Functor),
	translate_functor_save_predicate_def(Save_Predicate, Sub_Category_Of, Name, Arity, Category, Fuzzy_Name, Fuzzy_Arity),
	print_msg('debug', 'translate_functor :: result: (Fuzzy_Functor, Truth_Value)', (Fuzzy_Functor, Truth_Value)).


translate_functor_add_args(Fuzzy_Functor, Fuzzy_Arity, Add_Args, Fix_Priority, Priority, Truth_Value) :-
	print_msg('debug', 'translate_functor_add_args(Fuzzy_Functor, Fuzzy_Arity, Add_Args)', (Fuzzy_Functor, Fuzzy_Arity, Add_Args, Fix_Priority, Priority)),
	number(Add_Args),
	(
	    (	Add_Args = 0, Truth_Value = 'no_truth_value_argument_added', !  )
	;
	    (	Add_Args = 1, arg(Fuzzy_Arity, Fuzzy_Functor, Truth_Value), !  )
	;
	    (	Add_Args = 2,
		% print_msg('debug', 'translate_functor_1 :: Fuzzy_Arity_Aux', Fuzzy_Arity_Aux),
		arg(Fuzzy_Arity, Fuzzy_Functor, Truth_Value),
		(
		    (	Fix_Priority = 'no'    )
		;
		    (
			Fix_Priority = 'yes',
			Fuzzy_Arity_Aux is Fuzzy_Arity - 1,
			arg(Fuzzy_Arity_Aux, Fuzzy_Functor, Priority)
		    )
		)
	    )
	), !.

% translate_functor_save_predicate(Save_Predicate, Sub_Category_Of, Category, Name, Arity).
translate_functor_save_predicate_def('no', _Sub_Category_Of, _Pred_Name, _Pred_Arity, _Category, _Fuzzy_Name, _Fuzzy_Arity) :- !.
translate_functor_save_predicate_def('yes', '', Pred_Name, Pred_Arity_In, Category, Fuzzy_Name, Fuzzy_Arity) :- !,
	translation_info(Category, '', Add_Args, _Fix_Priority, _Priority, _Preffix_String),
	Pred_Arity is Pred_Arity_In + Add_Args,
	save_predicate_definition(Category, Pred_Name, Pred_Arity, Category, Fuzzy_Name, Fuzzy_Arity), !.
translate_functor_save_predicate_def('yes', Sub_Category_Of, Pred_Name, Pred_Arity_In, Category, Fuzzy_Name, Fuzzy_Arity) :- !,
	translation_info(Sub_Category_Of, '', Add_Args, _Fix_Priority, _Priority, _Preffix_String),
	Pred_Arity is Pred_Arity_In + Add_Args,
	save_predicate_definition(Sub_Category_Of, Pred_Name, Pred_Arity, Category, Fuzzy_Name, Fuzzy_Arity), !.

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

add_preffix_to_name(Input, Preffix, Output) :-
	string(Preffix),
	atom(Input),
	atom_codes(Input, Input_Chars),
	append_local(Preffix, Input_Chars, Output_Chars),
	atom_codes(Output, Output_Chars), 
	atom(Output), !.
%	print_msg('debug', 'add_preffix_to_name', add_preffix_to_name(Prefix, Input, Output)).

append_local([], N2, N2).
append_local([Elto|N1], N2, [Elto|Res]) :-
	append_local(N1, N2, Res).

memberchk_local(Element, [Element | _Tail]) :- !.
memberchk_local(Element, [_Head | Tail]) :- !,
	memberchk_local(Element, Tail).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

build_auxiliary_clauses([], [end_of_file]) :- !.
build_auxiliary_clauses([Predicate_Def|Predicate_Defs], Clauses) :-
	print_msg_nl('debug'),
	print_msg('debug', 'build_auxiliary_clauses IN (Predicate_Def)', (Predicate_Def)),
	test_if_list_contains_non_rfuzzy_fuzzy_rule(Predicate_Def), !,
	print_msg('debug', 'build_auxiliary_clauses OUT', 'nothing'),
	build_auxiliary_clauses(Predicate_Defs, Clauses).	
build_auxiliary_clauses([Predicate_Def|Predicate_Defs], [Pred_Main, Pred_Aux | Clauses]) :-
	print_msg_nl('debug'),
	print_msg('debug', 'build_auxiliary_clauses IN (Predicate_Def)', (Predicate_Def)),
	build_auxiliary_clause(Predicate_Def, Pred_Main, Pred_Aux), !,
	print_msg('debug', 'build_auxiliary_clauses OUT (Pred_Main, Pred_Aux)', (Pred_Main, Pred_Aux)),
	build_auxiliary_clauses(Predicate_Defs, Clauses).	

build_auxiliary_clause(predicate_definition(Category, Pred_Name, Pred_Arity, List), Fuzzy_Cl_Main, Fuzzy_Cl_Aux) :-

	Category = 'fuzzy_rule',
	% Build MAIN functor.
	functor(Pred_Functor, Pred_Name, Pred_Arity),
	% Build AUXILIAR functor
	add_preffix_to_name(Pred_Name, "rfuzzy_aux_", Aux_Pred_Name),
	Aux_Pred_Arity is Pred_Arity + 1,
	functor(Aux_Pred_Functor, Aux_Pred_Name, Aux_Pred_Arity),
	arg(Aux_Pred_Arity, Aux_Pred_Functor, Aux_Pred_Truth_Value_Arg),
	arg(Pred_Arity,         Aux_Pred_Functor, Aux_Pred_Priority_Arg),
	% Unify crisp args of MAIN and AUXILIAR functors.
	Pred_Crisp_Arity is Pred_Arity - 1,
	copy_args(Pred_Crisp_Arity, Pred_Functor, Aux_Pred_Functor),

	print_msg('debug', 'Now building functor from (List, Pred_Name, Aux_Pred_Functor)', (List, Pred_Name, Aux_Pred_Functor)),
	build_functors(List, 'type',                             'true', Aux_Pred_Functor, Fuzzy_Pred_Types, [], Def_1, [], NDef_1),
	build_functors(List, 'fact',                              'fail',  Aux_Pred_Functor, Fuzzy_Pred_Fact, Def_1, Def_2, NDef_1, NDef_2),
	build_functors(List, 'fuzzification',                'fail',  Aux_Pred_Functor, Fuzzy_Pred_Fuzzification, Def_2, Def_3, NDef_2, NDef_3),
	build_functors(List, 'rule',                              'fail',  Aux_Pred_Functor, Fuzzy_Pred_Rule, Def_3, Def_4, NDef_3, NDef_4),
	build_functors(List, 'default_with_cond',      'fail',  Aux_Pred_Functor, Fuzzy_Pred_Default_With_Cond, Def_4, Def_5, NDef_4, NDef_5),
	build_functors(List, 'default_without_cond', 'fail',  Aux_Pred_Functor, Fuzzy_Pred_Default_Without_Cond, Def_5, Def_6, NDef_5, NDef_6),
	build_functors(List, 'synonym',                     'fail',  Aux_Pred_Functor, Fuzzy_Pred_Synonym, Def_6, Def_7, NDef_6, NDef_7),
	build_functors(List, 'antonym',                      'fail',  Aux_Pred_Functor, Fuzzy_Pred_Antonym, Def_7, Def, NDef_7, NDef),
	build_functors_notify_missing_facilities(Pred_Name, Def, NDef),

	(Fuzzy_Cl_Main = (
			     (
				 Pred_Functor :- (
						     print_msg('debug', 'Predicate called', Pred_Functor),
						     findall(Aux_Pred_Functor, Aux_Pred_Functor, Results), 
						     supreme(Results, Pred_Functor)
						 )		     
			     ) % Main Fuzzy Pred
			 )
	),
	(Fuzzy_Cl_Aux = ( 
			    ( 
				Aux_Pred_Functor :- ( 
							Fuzzy_Pred_Types,
							(   
							    Fuzzy_Pred_Fact ; 
							    Fuzzy_Pred_Fuzzification ;
							    Fuzzy_Pred_Rule ;
							    Fuzzy_Pred_Default_With_Cond ; 
							    Fuzzy_Pred_Default_Without_Cond ;
							    Fuzzy_Pred_Synonym ;
							    Fuzzy_Pred_Antonym 
							),
							% Security conditions.
							Aux_Pred_Truth_Value_Arg .>=. 0,
							Aux_Pred_Truth_Value_Arg .=<. 1,
							Aux_Pred_Priority_Arg .>=. 0,
							Aux_Pred_Priority_Arg .=<. 1
						    )
			    )
			)
	).

build_auxiliary_clause(Predicate_Definition, _Fuzzy_Cl_Main, _Fuzzy_Cl_Aux) :-
	print_msg('error', 'Error building auxiliary clauses for predicate definition', Predicate_Definition),
	!, fail.

build_functors([], Category, On_Error, _Functor_In, On_Error, Def_In, Def_In, NDef_In, [Category | NDef_In]) :- !.
	
build_functors([(Category, Sub_Pred_Name, Sub_Pred_Arity)|_List], Category, _On_Error, Functor_In, Functor, Def_In, [Category | Def_In], NDef_In, NDef_In) :-

	!, % Backtracking not allowed.
	functor(Functor, Sub_Pred_Name, Sub_Pred_Arity),  % Create functor
	copy_args(Sub_Pred_Arity, Functor_In, Functor).              % Unify args with the auxiliar one.

build_functors([(_Other_Category, _Sub_Pred_Name, _Sub_Pred_Arity)|List], Category, On_Error, Functor_In, Functor, Def_In, Def_Out, NDef_In, NDef_Out) :-
	build_functors(List, Category, On_Error, Functor_In, Functor, Def_In, Def_Out, NDef_In, NDef_Out).

% build_functors_notify_missing_facilities(Pred_Name, Def, NDef),
build_functors_notify_missing_facilities(_Pred_Name, Def, _NDef) :- 
	(
	    memberchk_local('synonym', Def)
	;
	    memberchk_local('antonym', Def)
	), !. % No errors.

build_functors_notify_missing_facilities(Pred_Name, _Def, NDef_In) :-
	% Not an error if the missing information belongs to the following categories:
	lists_substraction(NDef_In, ['fact', 'function', 'fuzzification', 'rule', 'default_with_cond', 'synonym', 'antonym'], NDef_Out),
	(
	    (   NDef_Out = [], !  )
	;
	    print_msg('info', 'Facilities not defined for the predicate :: (Predicate_Name, Facilities) ', (Pred_Name, NDef_Out))
	), !.

lists_substraction([], _List_2, []) :- !.
lists_substraction([Head | Tail ], List_2, Result_List) :-
	memberchk_local(Head, List_2), !, 
	lists_substraction(Tail, List_2, Result_List).
lists_substraction([Head | Tail ], List_2, [Head | Result_List]) :-
	lists_substraction(Tail, List_2, Result_List).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

test_if_list_contains_non_rfuzzy_fuzzy_rule(predicate_definition(_Category, _Pred_Name, _Pred_Arity, List)) :-
	test_if_list_contains_non_rfuzzy_fuzzy_rule_aux(List).

test_if_list_contains_non_rfuzzy_fuzzy_rule_aux([('non_rfuzzy_fuzzy_rule', _Sub_Pred_Name, _Sub_Pred_Arity)|_List]) :- !.
test_if_list_contains_non_rfuzzy_fuzzy_rule_aux([(_Category, _Sub_Pred_Name, _Sub_Pred_Arity)|List]) :-
	test_if_list_contains_non_rfuzzy_fuzzy_rule_aux(List).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

generate_introspection_predicate(Fuzzy_Rules_To_Build, Fuzzy_Rules_Built, Fuzzy_Rules) :-
	retrieve_all_predicate_info_with_category(_Any_Category, Retrieved),
	generate_introspection_predicate_aux(Fuzzy_Rules_To_Build, Fuzzy_Rules_Built, Fuzzy_Rules_Tmp),
	generate_introspection_predicate_aux(Retrieved, Fuzzy_Rules_Tmp, Fuzzy_Rules).

% generate_introspection_predicate_aux(Input_List, Accumulator_List, Result_List),
generate_introspection_predicate_aux([], Accumulator_List, [Fnot | Accumulator_List]) :- !,
	Fnot = (rfuzzy_introspection('quantifier', 'fnot', 2)).
generate_introspection_predicate_aux([Input|Input_List], Accumulator_List, Result_List) :-
	generate_introspection_predicate_real(Input, Output),
	generate_introspection_predicate_aux(Input_List, [Output|Accumulator_List], Result_List).

generate_introspection_predicate_real(predicate_definition(Category, Pred_Name, Pred_Arity, _List), rfuzzy_introspection(Category, Pred_Name, Pred_Arity)).
% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

defined_quantifiers([fnot]).

add_auxiliar_code(Fuzzy_Rules_In, Fuzzy_Rules_Out) :-
	code_for_quantifier_fnot(Quantifier_Code_Fnot), 
	code_for_getting_attribute_values(Code_For_Getting_Attribute_Values),
	append_local(Quantifier_Code_Fnot, Fuzzy_Rules_In, Fuzzy_Rules_Aux),
	append_local(Code_For_Getting_Attribute_Values, Fuzzy_Rules_Aux, Fuzzy_Rules_Out).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

code_for_getting_attribute_values([Code_1, Code_2, Code_3]) :-
	Code_1 = (rfuzzy_var_truth_value(Var, Condition, Value) :-
		 print_msg('debug', 'rfuzzy_var_truth_value :: Var', Var),
		 var(Var),					 
		 dump_constraints(Var, Var, Dump), !,
		 print_msg('debug', 'rfuzzy_var_truth_value :: dump_constraints :: Dump', Dump),
		 rfuzzy_process_attribute_dump(Dump, Var, Condition, Value),
		 !),
		 Code_2 = (rfuzzy_var_truth_value(Var, 'constant', Var) :- nonvar(Var), !),
		 Code_3 = (rfuzzy_var_truth_value(Var, 'error', 0) :-
			  print_msg('error', 'rfuzzy_var_truth_value :: Var', Var),
			  !).

%    dump_internal(Var, Var, [cva(Var, Value)])
% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

code_for_quantifier_fnot([Code]) :-
	Code = (
		   fnot(Fuzzy_Predicate_Functor, Truth_Value) :-
	       
	       print_msg('debug', 'fnot', 'Computing results list.'),
	       findall(Fuzzy_Predicate_Functor, Fuzzy_Predicate_Functor, Results_List), !,
	       print_msg('debug', 'fnot', Results_List),
	       reorder_by_truth_value(Results_List, [], Results_List_Aux),
	       print_msg('debug', 'reorder_by_truth_value', Results_List_Aux),
	       one_by_one_first_tail(Results_List_Aux, Result_Functor),
	       print_msg('debug', 'take_an_element', Result_Functor),
	       
	       functor(Fuzzy_Predicate_Functor, _FP_Name, FP_Arity), 
	       FP_Arity_Aux is FP_Arity - 1,
	       copy_args(FP_Arity_Aux, Result_Functor, Fuzzy_Predicate_Functor),
	       arg(FP_Arity, Result_Functor, SubCall_Truth_Value),
	       
	       print_msg('debug', 'fnot :: adjusting Truth_Value', Truth_Value),
	       Truth_Value .=. 1 - SubCall_Truth_Value,
	       Truth_Value .>=. 0, Truth_Value .=<. 1,
	       print_msg('debug', 'fnot :: result', Fuzzy_Predicate_Functor)
	       ).

% ------------------------------------------------------
% ------------------------------------------------------
% ------------------------------------------------------

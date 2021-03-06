
:- module(ex_attr_ciao, _, _).
:- use_package(attr).
:- use_module(library(write), [write/1, write/2]).
:- use_module(library(terms_vars)).

:- multifile portray_attribute/2.
:- multifile portray/1.

%:- attributes(portray).

test(Var1, Var2) :-
	put_attr(Var1, (Var1, one)),
	put_attr(Var2, (Var2, two)),
	get_attr(Var1, Attribute_Var_1), 
	get_attr(Var2, Attribute_Var_2),
	print_attributes('1st: We load an attribute into each variable', Attribute_Var_1, Attribute_Var_2),
	% Real test
	Var1 = Var2.

print_attributes(Msg, Attribute_Var_1, Attribute_Var_2) :-
	nl,
	write(Msg),
	nl,
	write('Attribute 1st var: '),
	write(Attribute_Var_1),
	nl, 
	write('Attribute 2nd var: '),
	write(Attribute_Var_2),
	nl.

attr_unify_hook(Attribute_Var_1, Attribute_Var_2) :-
	print_attributes('2nd: Note the second argument is not an attribute.', Attribute_Var_1, Attribute_Var_2),
	get_attr(Attribute_Var_2, Real_Attribute_Var_2), 
	print_attributes('3rd: You must retrieve the attribute of the second argument (if any)', Attribute_Var_1, Real_Attribute_Var_2),
	attr_unify_hook_aux(Attribute_Var_1, Real_Attribute_Var_2).

attr_unify_hook_aux((Var_1, _Value_1), (Var_2, _Value_2)) :-
	get_attr(Var_1, Attribute_Var_1), 
	get_attr(Var_2, Attribute_Var_2), 
	print_attributes('4th: Note the attributes retrieved are the same one.', Attribute_Var_1, Attribute_Var_2),
	fail.

attr_unify_hook_aux((Var_1, Value_1), (Var_2, Value_2)) :-
	del_attr(Var_2),
	put_attr(Var_2, (Var_2, Value_1 + Value_2)),
	get_attr(Var_1, New_Attr_1),
	get_attr(Var_2, New_Attr_2),
	print_attributes('5th: Note the attributes unified are the same one.', New_Attr_1, New_Attr_2),
	nl.

portray(Term) :-
	varsbag(Term, [], Vars),
	portray_vars_attributes(Vars),
	nl,
	write('portray: '), 
	write(Term), 
	write(' with vars '), 
	write(Vars), 
	nl.

portray_attribute(Attribute, Var) :-
	write('portray_attribute'), nl, 
	attr_portray_hook(Attribute, Var).

attr_portray_hook(Attribute, Var) :-
	write('attr_portray_hook'), nl, 
	write('Attribute for '),
	write(Var),
	write(' is '),
	write(Attribute).

attribute_goals(X) --> 
	[ex_attr_ciao:attr_portray_hook(X, G)],
	{get_attr(X, G)}.

portray_vars_attributes([]).
portray_vars_attributes([Var | Vars]) :-
	portray_var_attributes(Var),
	portray_vars_attributes(Vars).

portray_var_attributes(Var) :-
	get_attr(Var, Attribute), !, 
	attr_portray_hook(Attribute, Var).

portray_var_attributes(_Var) :- !.
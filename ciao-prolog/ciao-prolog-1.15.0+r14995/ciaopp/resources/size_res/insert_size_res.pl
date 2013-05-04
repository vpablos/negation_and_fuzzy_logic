:- module(insert_size_res, [insert_size_function/3], [assertions]).

:- use_module(resources(init_res(symtable_res)), [insert_symbol_field/4]
	).


insert_size_function([],               _,            _).
insert_size_function([Pred|Component], [Size|SList], ST) :-
	insert_symbol_field(ST, Pred, size, Size),
	insert_size_function(Component, SList, ST).

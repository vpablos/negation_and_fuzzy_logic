
:- module(zebra, [zebra/7], [ assertions , nativeprops ]).
:- use_module(library(format)).
:- use_module(library(prolog_sys)).

:- entry zebra(A,B,C,D,E,F,G)
	: ( mshare([[A],[B],[C],[D],[E],[F],[G]])
	  , var(A), var(B), var(C), var(D), var(E), var(F), var(G)
	  ).

zebra(Englishman,Spaniard,Japanese,Ukrainian,Norwegian,Zebra,Water):-
	Englishman = Red, 
	Spaniard = Dog, 
	Green = Coffee, 
	Ukrainian = Tea, 
	to_the_right(Green,Ivory),
	Winston = Snails, 
	Kool = Yellow,
	Milk = third, 
	Norwegian = first,
	next_to(Fox,Chesterfield),
	next_to(Horse,Kool),
	Lucky = Juice, 
	Japanese = Parliament, 
	next_to(Norwegian,Blue),
	houses([Blue,Green,Red,Yellow,Ivory]),
	houses([Norwegian,Englishman,Spaniard,Japanese,Ukrainian]),
%% 	more(Dog,Zebra,Fox,Snails,Horse,
%% 	     Parliament,Kool,Lucky,Chesterfield,Winston,
%% 	     Milk,Juice,Water,Tea,Coffee).
%% 
%% 	more(Dog,Zebra,Fox,Snails,Horse,
%% 	     Parliament,Kool,Lucky,Chesterfield,Winston,
%% 	     Milk,Juice,Water,Tea,Coffee):-
	houses([Dog,Zebra,Fox,Snails,Horse]),
	houses([Parliament,Kool,Lucky,Chesterfield,Winston]),
	houses([Milk,Juice,Water,Tea,Coffee]).

houses(Prop):- domain(Prop,[first,second,third,fourth,fifth]).

domain([],_).
domain([X|Rest],Domain):- 
	select(X,Domain,NewDomain), 
	domain(Rest,NewDomain).

select(X,[X|R],R).
select(X,[Y|R],[Y|Rest]):-
	select(X,R,Rest).

next_to(fifth,fourth).
next_to(fourth,fifth).
next_to(fourth,third).
next_to(third,fourth).
next_to(third,second).
next_to(second,third).
next_to(second,first).
next_to(first,second).

to_the_right(fifth,fourth).
to_the_right(fourth,third).
to_the_right(third,second).
to_the_right(second,first).

%----------------------------------------------------------------------------

demo:-
	format('Zebra problem ~n~n',[]),
	time(_,E),
	zebra(E,S,J,U,N,Z,W),
	time(T,S),
	write_sol(E,S,J,U,N,Z,W),
	format('Solved in ~w msec. ~n',[T]).

time(Time,_):- statistics(runtime,[_,Time]).

write_sol(E,S,J,U,N,Z,W):-
	person(Z,E,S,J,U,N,Owner),
	person(W,E,S,J,U,N,Drinker),
	format('The Zebra is owned by the ~w. ~nThe ~w drinks water.~n', 
	[Owner, Drinker]).

person(O,O,_,_,_,_,'Englishman').
person(O,_,O,_,_,_,'Spaniard').
person(O,_,_,O,_,_,'Japanese').
person(O,_,_,_,O,_,'Ukrainian').
person(O,_,_,_,_,O,'Norwegian').


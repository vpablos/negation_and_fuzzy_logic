:- module(warplan, [plans/2], [ assertions ]).

:- entry plans(X,Y) : ground([X,Y]).

:- use_module(library(write), 
	[write/1]).
:- use_module(library(prolog_sys), 
	[statistics/2]).

:- op(700,xfy,'!!').
:- op(800,xfy,'##').
:- op(900,yfx,::).

%% not(X):- call(X), !, fail.  % added M.H.
%% not(_). 

plans(C,_) :- \+(consistent0(C,true)), !, nl, write('impossible'), nl.
plans(C,T) :- time(M0), plan(C,true,T,T1), time(M1), nl, output(T1), nl,
   Time is (M1-M0)/1000, write(Time), write(' secs.'), nl.

time(T) :- statistics(runtime,[T,_]).

output(T::U) :- !, output1(T), write(U), write('.'), nl.
output(T) :- write(T), write('.'), nl.

output1(T'!!'U) :- !, output1(T), write(U), write(';'), nl.
output1(T) :- write(T), write(';'), nl.

plan(X'##'C,P,T,T2) :- !, solve(X,P,T,P1,T1), plan(C,P1,T1,T2).
plan(X,P,T,T1) :- solve(X,P,T,_,T1).

solve(X,P,T,P,T) :- always(X).
solve(X,P,T,P1,T) :- holds(X,T), and(X,P,P1).
solve(X,P,T,X'##'P,T1) :- add(X,U), achieve(X,U,P,T,T1).

achieve(_,U,P,T,T1::U ) :- 
   preserves(U,P),
   can(U,C),
   consistent(C,P),
   plan(C,P,T,T1),
   preserves(U,P).

achieve(X,U,P,T::V,T1::V) :- 
   preserved(X,V),
   retrace(P,V,P1),
   achieve(X,U,P1,T,T1),
   preserved(X,V).

holds(X,_::V) :- add(X,V).
holds(X,T::V) :- !, 
   preserved(X,V),
   holds(X,T),
   preserved(X,V).
holds(X,T) :- given(T,X).

preserved(X,V) :- mkground(X'##'V,0,_), del(X,V), !, fail.
preserved(_,_).

preserves(U,X'##'C) :- preserved(X,U), preserves(U,C).
preserves(_,true).

retrace(P,V,P2) :- 
   can(V,C),
   retrace1(P,V,C,P1),
   conjoin(C,P1,P2).

retrace1(X'##'P,V,C,P1) :- add(Y,V), warplan:equiv(X,Y), !, retrace1(P,V,C,P1).
retrace1(X'##'P,V,C,P1) :- elem(Y,C), warplan:equiv(X,Y), !, retrace1(P,V,C,P1).
retrace1(X'##'P,V,C,X'##'P1) :- retrace1(P,V,C,P1).
retrace1(true,_,_,true).

consistent0(C,P) :- consistent(C,P).

consistent(C,P) :- 
   mkground(C'##'P,0,_),
   imposs(S),
   \+(\+(intersect(C,S))),
   implied(S,C'##'P), 
   !, fail.
consistent(_,_).

%imposs(_) :- fail.  % To stop Quintus complaining.
imposs(sometimes).

and(X,P,P) :- elem(Y,P), warplan:equiv(X,Y), !.
and(X,P,X'##'P).

conjoin(X'##'C,P,X'##'P1) :- !, conjoin(C,P,P1).
conjoin(X,P,X'##'P).

elem(X,Y'##'_) :- elem(X,Y).
elem(X,_'##'C) :- !, elem(X,C).
elem(X,X).

intersect(S1,S2) :- elem(X,S1), elem(X,S2).

implied(S1'##'S2,C) :- !, implied(S1,C), implied(S2,C).
implied(X,C) :- elem(X,C).
%% implied(X,_) :- call(X).

notequal(X,Y) :- 
   \+(X=Y),
   \+(X=qqq(_)),
   \+(Y=qqq(_)).

equiv(X,Y) :- \+(nonequiv(X,Y)).

nonequiv(X,Y) :- mkground(X'##'Y,0,_), X=Y, !, fail.
nonequiv(_,_).

mkground(qqq(N1),N1,N2) :- !, N2 is N1+1.
mkground(qqq(_),N1,N1) :- !.
mkground(X,N1,N2) :- X =.. [_|L], mkgroundlist(L,N1,N2).

mkgroundlist([X|L],N1,N3) :- mkground(X,N1,N2), mkgroundlist(L,N2,N3).
mkgroundlist([],N1,N1).

test1 :- plans( status(lightswitch(1),on), start).
test2 :- plans( nextto(box(1),box(2)) '##' nextto(box(2),box(3)), start).
test3 :- plans( at(robot,point(6)), start).
test4 :- plans( nextto(box(2),box(3)) '##' nextto(box(3),door(1)) '##'
		status(lightswitch(1),on) '##' nextto(box(1),box(2)) '##'
		inroom(robot,room(2)), start).

add( at(robot,P), 	goto1(P,_)).
add( nextto(robot,X),	goto2(X,_)).
add( nextto(X,Y), 	pushto(X,Y,_)).
add( nextto(Y,X),	pushto(X,Y,_)).
add( status(S,on),	turnon(S)).
add( on(robot,B),	climbon(B)).
add( onfloor,		climboff(_)).
add( inroom(robot,R2), 	gothru(_,_,R2)).

del( at(X,_),U) :- moved(X,U).
del( nextto(Z,robot),U) :- !, del(nextto(robot,Z),U).
del( nextto(robot,X), pushto(X,_,_)) :- !, fail.
del( nextto(robot,B), climbon(B)) :- !, fail.
del( nextto(robot,B), climboff(B)) :- !, fail.
del( nextto(X,_),U) :- moved(X,U).
del( nextto(_,X),U) :- moved(X,U).
del( on(X,_),U) :- moved(X,U).
del( onfloor,climbon(_)).
del( inroom(robot,_), gothru(_,_,_)).
del( status(S,_), turnon(S)).

moved( robot, goto1(_,_)).
moved( robot, goto2(_,_)).
moved( robot, pushto(_,_,_)).
moved( X, pushto(X,_,_)).
moved( robot, climbon(_)).
moved( robot, climboff(_)).
moved( robot, gothru(_,_,_)).


can( goto1(P,R), locinroom(P,R) '##' inroom(robot,R) '##' onfloor).
can( goto2(X,R), inroom(X,R) '##' inroom(robot,R) '##' onfloor).
can( pushto(X,Y,R),
	pushable(X) '##' inroom(Y,R) '##' inroom(X,R) '##' nextto(robot,X) '##' onfloor).
can( turnon(lightswitch(S)),
	on(robot,box(1)) '##' nextto(box(1), lightswitch(S))).
can( climbon(box(B)), nextto(robot,box(B)) '##' onfloor).
can( climboff(box(B)), on(robot,box(B))).
can( gothru(D,R1,R2),
	connects(D,R1,R2) '##' inroom(robot,R1) '##' nextto(robot,D) '##' onfloor).

always( connects(D,R1,R2)) :- connects1(D,R1,R2).
always( connects(D,R2,R1)) :- connects1(D,R1,R2).
always( inroom(D,R1)) :- always(connects(D,_,R1)).
always( pushable(box(_))).
always( locinroom(point(6),room(4))).
always( inroom(lightswitch(1),room(1))).
always( at(lightswitch(1),point(4))).

connects1(door(N),room(N),room(5)) :- range(N,1,4).

range(M,M,_).
range(M,L,N) :- L < N, L1 is L+1, range(M,L1,N).

given( start, at(box(N), point(N))) :- range(N,1,3).
given( start, at(robot,point(5))).
given( start, inroom(box(N),room(1))) :- range(N,1,3).
given( start, inroom(robot,room(1))).
given( start, onfloor).
given( start, status(lightswitch(1),off)).




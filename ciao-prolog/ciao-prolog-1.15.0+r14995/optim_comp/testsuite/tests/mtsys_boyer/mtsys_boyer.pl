/*-----------------------------------------------------------------------------
Program: Boyer (toy theorem prover)
Author:  E. Tick (after Lisp by R. Boyer)
Date:    November 12 1985

Notes:
1. To run:
        ?- go(X).
where X is output execution time.

-----------------------------------------------------------------------------*/

#include "../mtsys_common.pl"

#if defined(CIAO3)
% note: compiling everything to C did not get a better speedup, but generated a 3MB C file (that taked ages to compile)
:- '$default_preddef'(bytecode).
#endif

benchmark_data(boyer, 10, 0).

benchmark(_Data, X) :-
	wff(X), tautology(X).

wff(implies(and(implies(X,Y),
        and(implies(Y,Z),
            and(implies(Z,U),
            implies(U,W)))),
        implies(X,W))) :-
    X = f(plus(plus(a,b),plus(c,zero))),
    Y = f(times(times(a,b),plus(c,d))),
    Z = f(reverse(append(append(a,b),[]))),
    U = equal(plus(a,b),difference(x,y)),
    W = lessp(remainder(a,b),member(a,length(b))).

#if defined(CIAO3)
:- '$props'(tautology/1, [impnat=ptoc]).
#endif
tautology(Wff) :-
%    display('rewriting...'),nl,
    rewrite(Wff,NewWff),
%    display('proving...'),nl,
    tautology_2(NewWff,[],[]).

% M.H. Implications changed to ! for right now: incorrect under Quintus!!!
#if defined(CIAO3)
:- '$props'(tautology_2/3, [impnat=ptoc]).
#endif
tautology_2(Wff,Tlist,Flist) :-
    (truep(Wff,Tlist) -> true
    ;falsep(Wff,Flist) -> fail
    ;Wff = if(If,Then,Else) ->
        (truep(If,Tlist) -> tautology_2(Then,Tlist,Flist)
        ;falsep(If,Flist) -> tautology_2(Else,Tlist,Flist)
        ;tautology_2(Then,[If|Tlist],Flist),    % both must hold
         tautology_2(Else,Tlist,[If|Flist])
        )
    ),!.

#if defined(CIAO3)
:- '$props'(rewrite/2, [impnat=ptoc]).
#endif
rewrite(Atom,Atom) :-
    atomic(Atom),!.
rewrite(Old,New) :-
    rrr(Old, Mid, _F, N),
    rewrite_args(N,Old,Mid),
    ( equal(Mid,Next),    % should be ->, but is compiler smart enough?
      rewrite(Next,New)    % to generate cut for ->?
    ; New=Mid
    ),!.

#if defined(CIAO3)
:- '$props'(rrr/3, [impnat=ptoc]).
#endif
rrr(Old, Mid, F, N) :-
    functor(Old,F,N),
    functor(Mid,F,N).

#if defined(CIAO3)
:- '$props'(rewrite_args/3, [impnat=ptoc]).
#endif
rewrite_args(0,_,_) :- !.
rewrite_args(N,Old,Mid) :-
    arg(N,Old,OldArg),
    arg(N,Mid,MidArg),
    rewrite(OldArg,MidArg),
    N1 is N-1,
    rewrite_args(N1,Old,Mid).

#if defined(CIAO3)
:- '$props'(truep/2, [impnat=ptoc]).
#endif
truep(t,_) :- !.
truep(Wff,Tlist) :- member_(Wff,Tlist).

#if defined(CIAO3)
:- '$props'(falsep/2, [impnat=ptoc]).
#endif
falsep(f,_) :- !.
falsep(Wff,Flist) :- member_(Wff,Flist).

#if defined(CIAO3)
:- '$props'(member_/2, [impnat=ptoc]).
#endif
member_(X,[X|_]) :- !.
member_(X,[_|T]) :- member_(X,T).

equal(    and(P,Q),            % 106 rules
    if(P,if(Q,t,f),f)
    ).
equal(    append(append(X,Y),Z),
    append(X,append(Y,Z))
    ).
equal(    assignment(X,append(A,B)),
    if(assignedp(X,A),
       assignment(X,A),
       assignment(X,B))
    ).
equal(    assume_false(Var,Alist),
    cons(cons(Var,f),Alist)
    ).
equal(    assume_true(Var,Alist),
    cons(cons(Var,t),Alist)
    ).
equal(    boolean(X),
    or(equal(X,t),equal(X,f))
    ).
equal(    car(gopher(X)),
    if(listp(X),
       car(flatten(X)),
       zero)
    ).
equal(    compile(Form),
    reverse(codegen(optimize(Form),[]))
    ).
equal(    count_list(Z,sort_lp(X,Y)),
    plus(count_list(Z,X),
         count_list(Z,Y))
    ).
equal(    countps_(L,Pred),
          countps_loop(L,Pred,zero)
    ).
equal(    difference(A,B),
    C
    ) :- difference(A,B,C).
equal(    divides(X,Y),
    zerop(remainder(Y,X))
    ).
equal(    dsort(X),
    sort2(X)
    ).
equal(    eqp(X,Y),
    equal(fix(X),fix(Y))
    ).
equal(    equal(A,B),
    C
    ) :- eq(A,B,C).
equal(    even1(X),
    if(zerop(X),t,odd(decr(X)))
    ).
equal(    exec(append(X,Y),Pds,Envrn),
    exec(Y,exec(X,Pds,Envrn),Envrn)
    ).
equal(    exp(A,B),
    C
    ) :- exp(A,B,C).
equal(    fact_(I),
    fact_loop(I,1)
    ).
equal(    falsify(X),
    falsify1(normalize(X),[])
    ).
equal(    fix(X),
    if(numberp(X),X,zero)
    ).
equal(    flatten(cdr(gopher(X))),
    if(listp(X),
       cdr(flatten(X)),
       cons(zero,[]))
    ).
equal(  gcd(A,B),
    C
    ) :- gcd(A,B,C).
equal(    get(J,set(I,Val,Mem)),
    if(eqp(J,I),Val,get(J,Mem))
    ).
equal(    greatereqp(X,Y),
    not(lessp(X,Y))
    ).
equal(    greatereqpr(X,Y),
    not(lessp(X,Y))
    ).
equal(    greaterp(X,Y),
    lessp(Y,X)
    ).
equal(    if(if(A,B,C),D,E),
    if(A,if(B,D,E),if(C,D,E))
    ).
equal(    iff(X,Y),
    and(implies(X,Y),implies(Y,X))
    ).
equal(    implies(P,Q),
    if(P,if(Q,t,f),t)
    ).
equal(    last(append(A,B)),
    if(listp(B),
       last(B),
       if(listp(A),
          cons(car(last(A))),
          B))
    ).
equal(    length(A),
    B
    ) :- mylength(A,B).
equal(    lesseqp(X,Y),
    not(lessp(Y,X))
    ).
equal(    lessp(A,B),
    C
    ) :- lessp(A,B,C).
equal(    listp(gopher(X)),
    listp(X)
    ).
equal(    mc_flatten(X,Y),
    append(flatten(X),Y)
    ).
equal(    meaning(A,B),
    C
    ) :- meaning(A,B,C).
equal(  member(A,B),
    C
    ) :- mymember(A,B,C).
equal(    not(P),
    if(P,f,t)
    ).
equal(  nth(A,B),
    C
    ) :- nth(A,B,C).
equal(    numberp(greatest_factor(X,Y)),
    not(and(or(zerop(Y),equal(Y,1)),
        not(numberp(X))))
    ).
equal(    or(P,Q),
    if(P,t,if(Q,t,f),f)
    ).
#if defined(SWIPROLOG)
equal(  plus(A,B),
    C
    ) :- plus_(A,B,C).
#else
equal(  plus(A,B),
    C
    ) :- plus(A,B,C).
#endif
equal(  power_eval(A,B),
    C
    ) :- power_eval(A,B,C).
equal(    prime(X),
    and(not(zerop(X)),
        and(not(equal(X,add1(zero))),
            prime1(X,decr(X))))
    ).
equal(    prime_list(append(X,Y)),
    and(prime_list(X),prime_list(Y))
    ).
equal(  quotient(A,B),
    C
    ) :- quotient(A,B,C).
equal(  remainder(A,B),
    C
    ) :- remainder(A,B,C).
equal(    reverse_(X),
    reverse_loop(X,[])
    ).
equal(    reverse(append(A,B)),
    append(reverse(B),reverse(A))
    ).
equal(    reverse_loop(A,B),
    C
    ) :- reverse_loop(A,B,C).
equal(    samefringe(X,Y),
    equal(flatten(X),flatten(Y))
    ).
equal(    sigma(zero,I),
    quotient(times(I,add1(I)),2)
    ).
equal(    sort2(delete(X,L)),
    delete(X,sort2(L))
    ).
equal(    tautology_checker(X),
    tautologyp(normalize(X),[])
    ).
equal(  times(A,B),
    C
    ) :- times(A,B,C).
equal(    times_list(append(X,Y)),
    times(times_list(X),times_list(Y))
    ).
equal(    value(normalize(X),A),
    value(X,A)
    ).
equal(    zerop(X),
    or(equal(X,zero),not(numberp(X)))
    ).

difference(X,            X,        zero        ) :- !.
difference(plus(X,Y),        X,        fix(Y)        ) :- !.
difference(plus(Y,X),        X,        fix(Y)        ) :- !.
difference(plus(X,Y),        plus(X,Z),    difference(Y,Z)    ) :- !.
difference(plus(B,plus(A,C)),    A,        plus(B,C)    ) :- !.
difference(add1(plus(Y,Z)),    Z,        add1(Y)        ) :- !.
difference(add1(add1(X)),    2,        fix(X)        ).

eq(plus(A,B),        zero,        and(zerop(A),zerop(B))        ) :- !.
eq(plus(A,B),        plus(A,C),    equal(fix(B),fix(C))        ) :- !.
eq(zero,        difference(X,Y),not(lessp(Y,X))            ) :- !.
eq(X,            difference(X,Y),and(numberp(X),
                        and(or(equal(X,zero),
                            zerop(Y))))        ) :- !.
eq(times(X,Y),        zero,        or(zerop(X),zerop(Y))        ) :- !.
eq(append(A,B),        append(A,C),    equal(B,C)            ) :- !.
eq(flatten(X),        cons(Y,[]),    and(nlistp(X),equal(X,Y))    ) :- !.
eq(greatest_factor(X,Y),zero,        and(or(zerop(Y),equal(Y,1)),
                        equal(X,zero))        ) :- !.
eq(greatest_factor(X,_),1,        equal(X,1)            ) :- !.
eq(Z,            times(W,Z),    and(numberp(Z),
                        or(equal(Z,zero),
                           equal(W,1)))        ) :- !.
eq(X,            times(X,Y),    or(equal(X,zero),
                       and(numberp(X),equal(Y,1)))    ) :- !.
eq(times(A,B),        1,        and(not(equal(A,zero)),
                      and(not(equal(B,zero)),
                        and(numberp(A),
                          and(numberp(B),
                            and(equal(decr(A),zero),
                          equal(decr(B),zero))))))
                                    ) :- !.
eq(difference(X,Y),    difference(Z,Y),if(lessp(X,Y),
                        not(lessp(Y,Z)),
                        if(lessp(Z,Y),
                            not(lessp(Y,X)),
                            equal(fix(X),fix(Z))))    ) :- !.
eq(lessp(X,Y),        Z,        if(lessp(X,Y),
                       equal(t,Z),
                       equal(f,Z))            ).

exp(I,        plus(J,K),    times(exp(I,J),exp(I,K))) :- !.
exp(I,        times(J,K),    exp(exp(I,J),K)        ).

gcd(X,        Y,        gcd(Y,X)        ) :- !.
gcd(times(X,Z),    times(Y,Z),    times(Z,gcd(X,Y))    ).

mylength(reverse(X),length(X)).
mylength(cons(_,cons(_,cons(_,cons(_,cons(_,cons(_,X7)))))),
     plus(6,length(X7))).

lessp(remainder(_,Y),    Y,    not(zerop(Y))            ) :- !.
lessp(quotient(I,J),    I,    and(not(zerop(I)),
                    or(zerop(J),
                       not(equal(J,1))))    ) :- !.
lessp(remainder(X,Y),    X,    and(not(zerop(Y)),
                    and(not(zerop(X)),
                          not(lessp(X,Y))))    ) :- !.
lessp(plus(X,Y),    plus(X,Z),    lessp(Y,Z)        ) :- !.
lessp(times(X,Z),    times(Y,Z),    and(not(zerop(Z)),
                        lessp(X,Y))        ) :- !.
lessp(Y,        plus(X,Y),    not(zerop(X))        ) :- !.
lessp(length(delete(X,L)),      length(L),    member(X,L)    ).

meaning(plus_tree(append(X,Y)),A,
    plus(meaning(plus_tree(X),A),
         meaning(plus_tree(Y),A))
    ) :- !.
meaning(plus_tree(plus_fringe(X)),A,
    fix(meaning(X,A))
    ) :- !.
meaning(plus_tree(delete(X,Y)),A,
    if(member(X,Y),
       difference(meaning(plus_tree(Y),A),
              meaning(X,A)),
       meaning(plus_tree(Y),A))).

mymember(X,append(A,B),or(member(X,A),member(X,B))) :- !.
mymember(X,reverse(Y),member(X,Y)) :- !.
mymember(A,intersect(B,C),and(member(A,B),member(A,C))).

nth(zero,_,zero).
nth([],I,if(zerop(I),[],zero)).
nth(append(A,B),I,append(nth(A,I),nth(B,difference(I,length(A))))).

#if defined(SWIPROLOG)
plus_(plus(X,Y),Z,
    plus(X,plus(Y,Z))
    ) :- !.
plus_(remainder(X,Y),
         times(Y,quotient(X,Y)),
    fix(X)
    ) :- !.
plus_(X,add1(Y),
    if(numberp(Y),
       add1(plus(X,Y)),
       add1(X))
    ).
#else
plus(plus(X,Y),Z,
    plus(X,plus(Y,Z))
    ) :- !.
plus(remainder(X,Y),
         times(Y,quotient(X,Y)),
    fix(X)
    ) :- !.
plus(X,add1(Y),
    if(numberp(Y),
       add1(plus(X,Y)),
       add1(X))
    ).
#endif

power_eval(big_plus1(L,I,Base),Base,
    plus(power_eval(L,Base),I)
    ) :- !.
power_eval(power_rep(I,Base),Base,
    fix(I)
    ) :- !.
power_eval(big_plus(X,Y,I,Base),Base,
    plus(I,plus(power_eval(X,Base),
            power_eval(Y,Base)))
    ) :- !.
power_eval(big_plus(power_rep(I,Base),
                power_rep(J,Base),
                zero,
                Base),
           Base,
    plus(I,J)
    ).

quotient(plus(X,plus(X,Y)),2,plus(X,quotient(Y,2))).
quotient(times(Y,X),Y,if(zerop(Y),zero,fix(X))).

remainder(_,        1,zero) :- !.
remainder(X,        X,zero) :- !.
remainder(times(_,Z),    Z,zero) :- !.
remainder(times(Y,_),    Y,zero).

reverse_loop(X,Y,    append(reverse(X),Y)    ) :- !.
reverse_loop(X,[],    reverse(X)        ).

times(X,     plus(Y,Z),     plus(times(X,Y),times(X,Z))    ) :- !.
times(times(X,Y),Z,         times(X,times(Y,Z))        ) :- !.
times(X,     difference(C,W),difference(times(C,X),times(W,X))) :- !.
times(X,     add1(Y),        if(numberp(Y),
                    plus(X,times(X,Y)),
                    fix(X))            ).
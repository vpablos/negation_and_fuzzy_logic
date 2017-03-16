:- module(crypta, [crypta/1], []).
/*-------------------------------------------------------------------------*/
/* Benchmark (Finite Domain)                                               */
/*                                                                         */
/* Name           : crypta.pl                                              */
/* Title          : crypt-arithmetic                                       */
/* Original Source: P. Van Hentenryck's book                               */
/* Adapted by     : Daniel Diaz for GNU Prolog                             */
/* Date           : September 1992                                         */
/* Adapted by     : Jose Manuel Gomez for Ciao Prolog                      */
/* Date           : September 2003                                         */
/*                                                                         */
/* Solve the operation:                                                    */
/*                                                                         */
/*    B A I J J A J I I A H F C F E B B J E A                              */
/*  + D H F G A B C D I D B I F F A G F E J E                              */
/*  -----------------------------------------                              */
/*  = G J E G A C D D H F A F J B F I H E E F                              */
/*                                                                         */
/* Solution:                                                               */
/*  [A,B,C,D,E,F,G,H,I,J]                                                  */
/*  [1,2,3,4,5,6,7,8,9,0]                                                  */
/*-------------------------------------------------------------------------*/

:- use_package(fd).
:- use_module(library(prolog_sys), [statistics/2]).
:- use_module(library(format)).

crypta(L) :-
	statistics(runtime,_),
	do_crypta(L),
	statistics(runtime,[_, Time]),
	format("Used ~d milliseconds~n", Time).

do_crypta(LD):-
	LD=[A,B,C,D,E,F,G,H,I,J],

	LD in 0..9,
	[Sr1,Sr2] in 0..1,
	[B,D,G] in 1..9,

	all_different(LD),

	    A+10*E+100*J+1000*B+10000*B+100000*E+1000000*F+
	    E+10*J+100*E+1000*F+10000*G+100000*A+1000000*F
	.=. F+10*E+100*E+1000*H+10000*I+100000*F+1000000*B+10000000*Sr1,
      
      
	    C+10*F+100*H+1000*A+10000*I+100000*I+1000000*J+
	    F+10*I+100*B+1000*D+10000*I+100000*D+1000000*C+Sr1
	.=. J+10*F+100*A+1000*F+10000*H+100000*D+1000000*D+10000000*Sr2,
      
	    A+10*J+100*J+1000*I+10000*A+100000*B+
	    B+10*A+100*G+1000*F+10000*H+100000*D+Sr2
	.=.  C+10*A+100*G+1000*E+10000*J+100000*G,

	labeling(LD).
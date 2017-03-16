%:- module(regexp, [regexp_match/2]).

%:- use_module(library(lists)).

% !! ciao, before commit
% vvv Dat: see in utils_ciao.pl
%     :- use_module(library(dcg(dcg_tr))). % Dat: for regexp.pl ERROR: this module should import phrase/3 from dcg_tr

regexp_match(RegexpAtom, Atom) :-
	atom_codes(RegexpAtom, RegexpS),
	atom_codes(Atom, String),
	regexp(RegexpS, Regexp),
	Replacement = "",
	outexplist(Replacement, OutExpL),
	replace(Regexp, String, OutExpL, Result),
	Result = Replacement.

% match(+Regexp, -Match, +Pre0, -Pre, +SRML0, -SRML, +Input, -Rest):
% Az Input fuzerbol kielemezheto egy Regexpnek megfelelo Match fuzer
% ha az elozo kielemzett karakter Pre0 volt es eddig SRML a kielemzett
% alkifejezesek listaja (Digit-Match) alakban.  Az utolso kielemzett
% karakter Pre, az osszes kielemzett alkifejezes listaja SRML, es
% a fennmarado fuzer Rest.  Amig nem elemeztunk ki semmit, akkor
% Pre legyen ures lista.
match(or(Regexp, _), Match, Pre0, Pre, SRML0, SRML) -->
        match(Regexp, Match, Pre0, Pre, SRML0, SRML).
match(or(_, Regexp), Match, Pre0, Pre, SRML0, SRML) -->
        match(Regexp, Match, Pre0, Pre, SRML0, SRML).
match(none, "", Pre, Pre, SRML, SRML) -->
        "".
match(conc(H, T), Match, Pre0, Pre, SRML0, SRML) -->
        match(H, Match1, Pre0, Pre1, SRML0, SRML1),
        {append(Match1, Match2, Match)},
        match(T, Match2, Pre1, Pre, SRML1, SRML).


match(more0(Regexp), Match, Pre0, Pre, SRML0, SRML) -->
        match(Regexp, Match1, Pre0, Pre1, SRML0, SRML1),
        ( {Match1 = [] ->
           !, Match = Match1, Pre = Pre1, SRML = SRML1}
         ;
           {append(Match1, Match2, Match)},
           match(more0(Regexp), Match2, Pre1, Pre, SRML1, SRML)
         ).
match(more0(_), Match, Pre0, Pre, SRML0, SRML) -->
        match(none, Match, Pre0, Pre, SRML0, SRML).
match(more1(Regexp), Match, Pre0, Pre, SRML0, SRML) -->
        match(conc(Regexp, more0(Regexp)), Match, Pre0, Pre, SRML0, SRML).
match(optional(Regexp), Match, Pre0, Pre, SRML0, SRML) -->
        match(or(Regexp, none), Match, Pre0, Pre, SRML0, SRML).



match(period, [C], _, [C], SRML, SRML) -->
        [C].
match(literal(C), [C], _, [C], SRML, SRML) -->
        [C].
match(wchar, [C], _, [C], SRML, SRML) -->
        [C], {wchar(C)}.
match(nonwchar, [C], _, [C], SRML, SRML) -->
        [C], {\+ wchar(C)}.
match(begin, [], "", "", SRML, SRML) -->
        "".
match(end, [], Pre, Pre, SRML, SRML, "", ""). % sorry
match(wbegin, [], Pre, Pre, SRML, SRML, [C|Str], [C|Str]) :- % sorry
        nonwcharpre(Pre),
        wchar(C).
match(wend, [], [Pre], [Pre], SRML, SRML, Str, Str) :- % sorry
        wchar(Pre),
        (   Str = ""
        ;   Str = [C|_], \+ wchar(C)
        ).

% vvv !! ciao-10.0-6 compilation error: ERROR: this module should import phrase/3 from dcg_tr
match(nth(D), Match, Pre0, Pre, SRML, SRML) -->
        {memberchk(D-Match, SRML)}, % Dat: the last with this number is valid
        Match,
        {newpre(Match, Pre0, Pre)}.
match(outof(CD), [C], _, [C], SRML, SRML) -->
        [C],
        {outof(CD, C)}.
match(oneof(CD), [C], _, [C], SRML, SRML) -->
        [C],
        {oneof(CD, C)}.
match(group(D, Regexp), Match, Pre0, Pre, SRML0, [D-Match|SRML]) -->
        match(Regexp, Match, Pre0, Pre, SRML0, SRML).

newpre([], Pre, Pre) :- !.
newpre(Match, _, [Pre]) :-
        last(Match, Pre).


wchar(C) :-
        C >= 0'a, C =< 0'z.
wchar(C) :-
        C >= 0'A, C =< 0'Z.
wchar(C) :-
        digit(C).

nonwcharpre([]).
nonwcharpre([C]) :-
        \+ wchar(C).

oneof([H|_], C) :-
        in(H, C), !.
oneof([_|T], C) :-
        oneof(T, C).

in(range(F, L), C) :-
        C >= F, C =< L, !.
in(single(C), C).

outof(CD, C) :-
        \+ oneof(CD, C).

replace(R, SI, O, SO) :-
        replace_reg(SI, R, O, [], SO).

replace_reg([], R, O, Pre, SO) :-
        !, replace_sing([], R, O, Pre, [], SO, _, []).
replace_reg(SI, R, O, Pre, SO) :-
        replace_sing(SI, R, O, Pre, SOE, SO, Pre1, SR),
        replace_reg(SR, R, O, Pre1, SOE).

% replace_sing(+SI, +R, +O, +Pre, +SOE, -SO, -Pre1, -SR)
%
% SO egy fuzer, aminek a vege
% SOE, az eleje pedig SI kezdeti R-rel nem illesztheto, es egy R-rel
% illesztheto (leheto leghosszabb) resze, vegul plusz egy (az illesztest
% koveto) karakter abban az estben, ha az illesztes ures. Az SI-bol megmarado
% resz SR. (SR az a fuzer akar lenni, ahol a cserelgetest folytatni kell.)
% Pre az elozo karakter, Pre1 a kovetkezo mintaillesztes megelozo karaktere).
replace_sing([], R, O, Pre0, SOE, SO, Pre, []) :-
        match(R, M, Pre0, Pre, [], SML, [], []), !,
        replace(O, M, SML, SOE, SO).
replace_sing([], _, _, Pre, SO, SO, Pre, []) :- !.
replace_sing(SI, R, O, Pre0, SOE, SO, Pre, SR) :-
        longmatch(SI, R, Pre0, M, SML, Pre1, SR1), !,
        replace(O, M, SML, SOE1, SO),
        ( M = [], SR1 = [C|SR2] ->
            SOE1 = [C|SOE],
            SR = SR2,
            Pre = [C]
        ;
            SOE1 = SOE,
            SR = SR1,
            Pre = Pre1
        ).
replace_sing([C|SI], R, O, _, SOE, [C|SO], Pre, SR) :-
        replace_sing(SI, R, O, [C], SOE, SO, Pre, SR).

% longmatch(SI, R, Pre0, M, SML, Pre, SR): 
longmatch(SI, R, Pre0, M, SML, Pre, SR) :-
        match(R, M1, Pre0, Pre1, [], SML1, SI, SR1),
        longmatch(SI, R, Pre0, M1, M, SML1, SML, Pre1, Pre, SR1, SR).

longmatch(SI, R, Pre0, M0, M, SML0, SML, Pre1, Pre, SR0, SR) :-
        append(M0, [_|_], M1),
        ( match(R, M1, Pre0, Pre2, [], SML1, SI, SR1) ->
            longmatch(SI, R, Pre0, M1, M, SML1, SML, Pre2, Pre, SR1, SR)
        ;
            M = M0,
            SML = SML0,
            Pre = Pre1,
            SR = SR0
        ).

replace([], _, _, SO, SO).
replace([literal(C)|O], M, SML, SOE, [C|SO]) :-
        replace(O, M, SML, SOE, SO).
replace([nth(D)|O], M, SML, SOE, SO) :-
        submatch(D-SM, SML),
        append(SM, SO1, SO),
        replace(O, M, SML, SOE, SO1).
replace([all|O], M, SML, SOE, SO) :-
        append(M, SO1, SO),
        replace(O, M, SML, SOE, SO1).

submatch(X, L) :-
        memberchk(X, L), !.
submatch(_-"", _).

%%---------------------------------------------------%%

% sedg(+RS, +I, +OS, -O)
%
% RS regularis kifejezes fuzerre, I input fuzerre, OS kimeno kifejezes
% fuzerre visszaadja az eredmeny fuzert O-ban
%
sedg(RS, I, OS, O) :-
        on_exception(T-R, regexp(RS, RE), handle(T, RS, R)),
        on_exception(T-R, outexplist(OS, OE), handle(T, OS, R)),
        replace(RE, I, OE, O).

% handle(+T, +S, +R)
%
% elemzi a T tipusu hibat, ami S elemzesekor fordult elo, ugy hogy
% R elemzesere mar nem kerult sor
%
handle(T, S, R) :-
        my_format(user_output, '*** ERROR ***~nType: ~p~n', [T]),
        append(H, R, S),
        length(H, N),
        my_format(user_output, '~s~n~*|~s', [H, N, R]),
        fail.

% regexp(+S, -R)
%
% A teljes S regexp fuzer absztrakt alakja R
%
regexp(S, R) :-
        regexp(R, [], _, 0, _, S, M),
        ( M = "" ->
            true
        ;
            throw('rest in regexp'-M)
        ).

/************************************************************************/
/*                                                                      */
/*                       DCG elemzo szabalyok                           */
/*                                                                      */
/************************************************************************/

% regexp(-R, +L0, -L, +P0, -P)
%
% R regexp jon ugy, hogy ha a benne lezarulo csoportok sorszamainak
% listajat L0 ele fuzzuk, akkor L-et kapjuk es a benne nyilo zarojelek
% szama + P0 = P.
%
% Az L0-L es P0-P argumentumparok az alabbi allapotvaltozoknak felelnek meg:
%
% L0-L: lezarult csoportok sorszamainak listaja (csak a csoporthivatkozasra
% hasznalhato csoportok),
%
% P0-P: megnyitott csoportok szama.
%
regexp(R, L0, L, P0, P) -->
        regexp_1(C, L0, L1, P0, P1),
        regexp_tail(C, R, L1, L, P1, P).

% regexp_tail(+C, -R, +L0, -L, +P0, -P)
%
% Egy C regexpel kezdodo R regexp jon. L0, L, P0, P szerepe pontosan az
% mint regexp/7 (regexp/5 DCG) eseteben.
%
regexp_tail(C, or(C, A), L0, L, P0, P) -->
        "\\|", !, regexp(A, L0, L, P0, P).
regexp_tail(C, C, L, L, P, P) -->
        "".

% regexp_1(-R, +L0, -L, +P0, -P)
%
% Egy 1. szintu R regexp kielemzheto. L0, L, P0, P szerepe pontosan az
% mint regexp/7 (regexp/5 DCG) eseteben.
%
regexp_1(R, L0, L, P0, P) -->
        regexp_2(H, L0, L1, P0, P1), regexp_1(H, R, L1, L, P1, P).

% regexp_1(R0, -R, +L0, -L, +P0, -P)
%
% Egy R0 2. szintu regexp-pel kezdodo 1. szintu R regexp kielemzheto.
% L0, L, P0, P szerepe pontosan az mint regexp/7 (regexp/5 DCG) eseteben.
%
regexp_1(R1, conc(R1, R2), L0, L, P0, P) -->
        conccont, !, regexp_1(R2, L0, L, P0, P).
regexp_1(R, R, L, L, P, P) --> "".

% conccont(+L, -L)
%
% az L listaban tovabbi elemek elemezhetok ki egy 1. szintu regularis
% kifejezeshez
%
conccont(L, L) :-
        L = [_|_],
        \+ prefix("\\|", L),
        \+ prefix("\\)", L).

% regexp_2(-R2, +L0, -L, +P0, -P)
%
% Egy 2. szintu R2 regexp kielemzheto. L0, L, P0, P szerepe pontosan az
% mint regexp/7 (regexp/5 DCG) eseteben.
%
regexp_2(R, L0, L, P0, P) -->
        regexp_3(B, L0, L, P0, P), repetition(B, R).

% repetition(+R3, -R)
%
% Kielemezheto egy 3. szintu nem ures regexp R ismetlese, vagy egy
% 3. szintu regexp, ha elotte egy R3 3. szintu regexp volt.
%
repetition(B, conc(B, R)) -->
	{empty_reg(B)}, [C], {rep_op(C)}, !, repetition1(literal(C), R).
repetition(B, R) -->
	repetition1(B, R).

% empty_reg(?R3)
%
% R3 egy ures fuzerre illeszkedo nem csoport 3. szintu regularis kifejezes
%
empty_reg(none).
empty_reg(begin).
empty_reg(end).
empty_reg(wbegin).
empty_reg(wend).

% rep_op(?Op)
%
% Op egy ismetlo operator.
%
rep_op(0'*).
rep_op(0'+).
rep_op(0'?).

% repetition(+R3, -R)
%
% Kielemezheto egy 3. szintu R3 regexp R ismetlese.
%
repetition1(B, R) -->
        "*", !, repetition1(more0(B), R).
repetition1(B, R) -->
        "+", !, repetition1(more1(B), R).
repetition1(B, R) -->
        "?", !, repetition1(optional(B), R).
repetition1(B, B) -->
        "".

% regexp_3(-R3, +L0, -L, +P0, -P)
%
% Egy 3. szintu R3 regexp kielemzheto. L0, L, P0, P szerepe pontosan az
% mint regexp/7 (regexp/5 DCG) eseteben.
%
regexp_3(period, L, L, P, P) -->
        ".", !.
regexp_3(literal(C), L, L, P, P) -->
        literal(C), !.
regexp_3(begin, L, L, P, P) -->
        "^", !.
regexp_3(end, L, L, P, P) -->
        "$", !.
regexp_3(wbegin, L, L, P, P) -->
        "\\<", !.
regexp_3(wend, L, L, P, P) -->
        "\\>", !.
regexp_3(wchar, L, L, P, P) -->
        "\\w", !.
regexp_3(nonwchar, L, L, P, P) -->
        "\\W", !.
regexp_3(nth(D), L, L, P, P) -->
% vvv %%%% pts %%%% for swi-prolog
%        [0'\\, C],
        [92, C],
        {digit(C, D), D > 0}, !,
        check(memberchk(P, L), 'bad subexp number').
regexp_3(outof(CD), L, L, P, P) -->
        "[^", !,
        re_expect([C], 'no char for outof'),
        chardescrs(C, CD),
        re_expect("]", 'no closing bracket for outof').
regexp_3(oneof(CD), L, L, P, P) -->
        "[", !,
        re_expect([C], 'no char for oneof'),
        chardescrs(C, CD),
        re_expect("]", 'no closing bracket for oneof').
regexp_3(G, L0, L1, P0, P) -->
        "\\(", !,
        {P1 is P0 + 1},
        regexp(R, L0, L, P1, P),
        re_expect("\\)", 'no closing paranthesis for group'),
        {( P1 < 10 ->
           G = group(P1, R),
           L1 = [P1|L]
         ;
           G = R,
           L1 = L
         )}.
regexp_3(none, L, L, P, P) -->
        "".

literal(C) -->
        [C], {\+ special(C)}.
literal(C) -->
% vvv %%%% pts %%%% for swi-prolog
%        [0'\\, C], {\+ escapable(C)}.
        [92, C], {\+ escapable(C)}.

% special(C)
%
% C kulonleges jelentessel bir egy regexpben.
%
special(C) :-
        memberchk(C, "\\.*+?[]^$").

% escapable(C)
%
% C kulonleges jelentessel bir egy regexpben, ha megelozi
% egy '\' karakter.
%
escapable(C) :-
        memberchk(C, "<>wW()|").
escapable(C) :-
        C >= 0'1, C =< 0'9.

% digit(C, D)
%
% C D ASCII kodja, es D >= 0, D < 10.
%
digit(C, D) :-
        digit(C), D is C - 0'0.

% digit(C)
%
% C egy tizes szamrendszerbeli szamjegy ASCII kodja.
%
digit(C) :-
        C >= 0'0, C =< 0'9.

% chardescrs(+C, -CDS)
%
% Kielemezheto egy C karakterrel kezdodo CDS karakterleiro lista.
%
chardescrs(C0, [range(C0, C1)|CDS]) -->
        "-", noncbracket(C1), !, chardescrs(CDS).
chardescrs(C, [single(C)|CDS]) -->
        chardescrs(CDS).

% chardescrs(-CDS)
%
% Kielemezheto egy CDS karakterleiro lista.
%
chardescrs([range(C0, C1)|RCD]) -->
        noncbracket(C0), "-", noncbracket(C1), !, chardescrs(RCD).
chardescrs([single(C)|RCD]) -->
        noncbracket(C), !, chardescrs(RCD).
chardescrs([]) --> "".

% noncbracket(-C)
%
% Kielemzheto egy ']' karakterrel nem egyenlo C karakter.
%
noncbracket(C) -->
        [C], {C =\= 0']}.

% outexplist(+S, -OL)
%
% S fuzerbol maradek nelkul kielemezheto egy OL kimeno-kifejezes lista.
%
outexplist(S, OL) :-
        outexplist(OL, S, R),
        ( R = [] ->
            true
        ;
            throw('rest in outexp'-R)
        ).

% outexplist(-OL)
%
% Kielemzheto egy OL kimeno-kifejezes lista.
%
outexplist([nth(D)|OL]) -->
% vvv %%%% pts %%%% for swi-prolog
%        [0'\\, C], {digit(C, D), D > 0}, !, outexplist(OL).
        [92, C], {digit(C, D), D > 0}, !, outexplist(OL).
outexplist([all|OL]) -->
        "\\&", !, outexplist(OL).
outexplist([literal(C)|OL]) -->
        oliteral(C), !, outexplist(OL).
outexplist([]) --> "".

% oliteral(-C)
%
% Kielemezheto egy kimeno-kifejezes szerinti C literalis.
%
oliteral(C) -->
        [C], {\+ ospecial(C)}.
oliteral(C) -->
% vvv %%%% pts %%%% for swi-prolog
%        [0'\\, C], {\+ oescapable(C)}.
        [92, C], {\+ oescapable(C)}.

% ospecial(+C)
%
% C karakter specialis jelentessel bir a kimeno-kifejezesben.
%
ospecial(C) :-
        memberchk(C, "\\&").

% oescapable(+C)
%
% C kulonleges jelentessel bir egy kimeno-kifejezesben, ha megelozi
% egy '\' karakter.
%
oescapable(C) :-
        C >= 0'1, C =< 0'9.

/************************************************************************/
/*                                                                      */
/*                   Hibakezelesi seged eljarasok                       */
/*                                                                      */
/************************************************************************/

% check(+Pred, +ExType, +S, -S)
%
% Ez egy DCG elemzobol hivando. Ellenorzi, hogy Pred teljesul-e, es ha
% nem akkor egy ExType-S tipusu kivetelt dob.  Nem elemez le semmit.
%
check(Pred, ExType, S, S) :-
        ( call(Pred) ->
            true
        ;
            throw(ExType-S)
        ).

% re_expect(+Expected, +ExType, +S, -R)
%
% Az S fuzerbol megprobalja kielemezni az Expected fuzert. Ha sikerul,
% akkor a maradek R. Ha nem, akkor egy ExType-S tipusu kivetelt dob.
%
re_expect(Expected, ExType, S, R) :-
        ( append(Expected, R, S) ->
            true
        ;
            throw(ExType-S)
        ).
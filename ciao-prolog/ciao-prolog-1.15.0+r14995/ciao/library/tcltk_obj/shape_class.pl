%%---------------------------------------------------------------------
%%
%% SHAPE CLASS
%%
%%---------------------------------------------------------------------

:- class(shape_class,[],[objects]).

:- use_package(assertions).

:- doc(author, "Montserrat Urraca").


:- use_class(library('tcltk_obj/canvas_class')).

%%---------------------------------------------------------------------
%% COLOR 
%%---------------------------------------------------------------------

:- data         tcl_color/1.
:- inheritable  tcl_color/1.

tcl_color(black).  % default color.

%:- export(set_fg_color/1).

%set_fg_color(Color) :-
%	atom(Color),
%	retract_fact(tcl_color(_,BG)),
%	asserta_fact(tcl_color(Color,BG)),
%	notify_changes.

:- export(bg_color/1).

bg_color(Color) :-
	nonvar(Color),
	!,
	atom(Color),
	retract_fact(tcl_color(_)),
	asserta_fact(tcl_color(Color)),
	notify_changes.

bg_color(Background) :-
%	!,
	tcl_color(Background).


%%---------------------------------------------------------------------
%% BORDER WIDTH
%%---------------------------------------------------------------------

:- data        border/1.
:- inheritable border/1.

border(1).

:- export(border_width/1).

border_width(Border) :-
	nonvar(Border),
	!,
	number(Border),
	Border > 0,
	set_fact(border(Border)),
	notify_changes.

border_width(Border) :-
	border(Border).

%%---------------------------------------------------------------------
%% IMPLEMENTATION
%%---------------------------------------------------------------------

:- export([tcl_name/1,creation_options/1]).

tcl_name(_) :- fail.

%creation_options([min(fill),BG,min(outline),FG,min(width),B]) :-
creation_options([min(fill),BG,min(width),B]) :-
	tcl_color(BG),
	border(B).

:- inheritable(notify_changes/0).

notify_changes:-
	self(Shape),
	owner(AnOwner),
	AnOwner instance_of canvas_class,
	AnOwner:shape_changed(Shape),
	fail.
notify_changes.

:- export([add_owner/1,remove_owner/1]).

add_owner(Owner) :-
	\+ owner(Owner),
	Owner instance_of canvas_class,
	assertz_fact(owner(Owner)),
	self(Shape),
	Owner:add_shape(Shape),
	!.
add_owner(_).


remove_owner(Owner) :-
	retract_fact(owner(Owner)),
	Owner instance_of canvas_class,
	self(Shape),
	Owner:remove_shape(Shape),
	!.

remove_owner(_).

%%---------------------------------------------------------------------
%% CONSTRUCTOR/DESTRUCTOR
%%---------------------------------------------------------------------

:- data        owner/1.
:- inheritable owner/1.

:- set_prolog_flag(multi_arity_warnings,off).

shape_class.  % Not owned

shape_class([]) :- !.

shape_class([AnOwner|Next]) :-
	add_owner(AnOwner),
	!,
	shape_class(Next).

shape_class(AnOwner) :-
	!,
	add_owner(AnOwner).

:- set_prolog_flag(multi_arity_warnings,on).

destructor :-
	self(Shape),
	retract_fact(owner(AnOwner)),
	AnOwner instance_of canvas_class,     % Owner is still alive
	AnOwner:remove_shape(Shape),
	fail.

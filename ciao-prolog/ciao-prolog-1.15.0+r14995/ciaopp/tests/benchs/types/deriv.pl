:- module(deriv, [d/3], [assertions,regtypes]).

:- entry d(X,Y,Z) : arithexpression * ground * var.

% Old
% :- entry d(X,Y,Z) : expression * ground * var.

d(U+V,X,DU+DV)			:-  !,d(U,X,DU), d(V,X,DV).
d(U-V,X,DU-DV)			:-  !,d(U,X,DU), d(V,X,DV).
d(U*V,X, DU*V+U*DV)		:-  !,d(U,X,DU), d(V,X,DV).
d(U/V,X,(DU*V-U*DV)/V**2)	:-  !,d(U,X,DU), d(V,X,DV).
d(U**N,X, DU*N*U**N1)		:-  !,integer(N), N1 is N-1, d(U,X,DU).
d(-U,X,-DU)			:-  !,d(U,X,DU).
d(exp(U),X,exp(U)*DU)		:-  !,d(U,X,DU).
d(log(U),X,DU/U)		:-  !,d(U,X,DU).
d(X,X,1) :- !.
d(_C,_X,0).


 %% Old
 %% :- regtype expression/1.

 %% expression(X):- atom(X).
 %% expression(X):- num(X).
 %% expression(-(X)):- expression(X).
 %% expression(log(X)):- expression(X).
 %% expression(exp(X)):- expression(X).
 %% expression(^(X,Y)):- expression(X), expression(Y). 
 %% expression(/(X,Y)):- expression(X), expression(Y). 
 %% expression(-(X,Y)):- expression(X), expression(Y). 
 %% expression(*(X,Y)):- expression(X), expression(Y). 
 %% expression(+(X,Y)):- expression(X), expression(Y). 


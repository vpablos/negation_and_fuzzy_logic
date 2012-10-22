:- module(database,_,[rfuzzy, clpr]).
% or clpq. We can use clpr or clpq.
% debug with pkgs_output_debug, 

% Define the file where we want debug msgs.
% :- define_pkgs_output_debug_file('~/secured/negation_and_fuzzy_logic/fuzzy_logic/rfuzzy/rfuzzy_ciao/debug_restaurant.pl').

% Activate/Deactivate debug.
% :- activate_rfuzzy_debug.

rfuzzy_define_database(restaurant/7, 
	[(restaurant_id, rfuzzy_string_type), 
	  (restaurant_type, rfuzzy_enum_type), 
	   (food_type, rfuzzy_enum_type),
	    (years_since_opening, rfuzzy_integer_type), 
	     (distance_to_the_city_center, rfuzzy_integer_type), 
	      (price_average, rfuzzy_integer_type), 
	       (menu_price, rfuzzy_integer_type)]).

% restaurant(restaurant_id,                        2,        3,      4,          5,         6,        7, ).
%restaurant(rfuzzy_default_values, 1,        0,       null,      null,     null,       800).  <- nonsense ??
restaurant(kenzo,                           fast_casual,     japanese,           5,    null,       50,     null).
restaurant(burguer_king,               fast_food,        american,         10,    null,       10,     5).
restaurant(pizza_jardin,                 fast_casual,     italian,                5,    null,       15,     null).
restaurant(subway,                         fast_food,       sandwiches,        5,    null,      15,      10).
restaurant(derroscas,                     fast_food,        mediterranean,   3,    null,      25,      null).
restaurant(il_tempietto,                  fast_casual,    italian,                5,    null,       20,     null).
restaurant(kono_pizza,                   fast_food,       pizza,                  4,    null,      15,      null).
restaurant(paellador,                       fast_food,       paella,                8,     null,      40,     null).
restaurant(tapasbar,                        fast_food,       tapas,                 3,     null,      10,     null).
restaurant(meson_del_jamon,        fast_food,       spanish,              8,     100,      20,     15).
restaurant(museo_del_jamon,        fast_food,       spanish,              8,     150,      20,     15).
restaurant(zalacain,                         fine_dining,    basque,             15,     null,      60,     50).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rfuzzy_similarity_between(spanish, tapas, 0.6).
rfuzzy_similarity_between(mediterranean, spanish, 0.6) cred (prod, 0.8).
rfuzzy_similarity_between(mediterranean, italian, 0.6) cred (prod, 0.8).

near_function :# (0, [ (0, 1), (100, 1), (1000, 0.1) ], 1000) .

rfuzzy_type_for('fuzzy_rule', near_the_city_center/1, [restaurant]).
rfuzzy_default_value_for(near_the_city_center, 0).
rfuzzy_define_fuzzification(near_the_city_center, distance_to_the_city_center, near_function).

traditional_function :# (0, [ (0, 1), (5, 0.2), (10, 0.8), (15, 1), (100, 1) ], 100) .
rfuzzy_define_fuzzification(traditional, years_since_opening, traditional_function).

rfuzzy_type_for('crisp_rule', is_zalacain/1, [restaurant]).
is_zalacain(Restaurant) :- restaurant_id(Restaurant, Restaurant_Id), Restaurant_Id = zalacain.

cheap_function :# (0, [ (0, 1), (10, 1), (15, 0.9), (20, 0.8), (30, 0.5), (50, 0.1), (100, 0) ], 100) .
rfuzzy_type_for('fuzzy_rule', cheap/1, [restaurant]).
rfuzzy_default_value_for(cheap, 0.5).
rfuzzy_default_value_for(cheap, 0.2) if thershold(near_the_city_center, over, 0.7).
rfuzzy_default_value_for(cheap, 0.1) if is_zalacain/1.
rfuzzy_define_fuzzification(cheap, price_average, cheap_function).

rfuzzy_synonym(cheap, unexpensive, prod, 1).
rfuzzy_antonym(cheap, expensive, prod, 1).

rfuzzy_quantifier(my_very/2, TV_In, TV_Out) :-
 	Thershold .=. 0.7,
	Min_In .=. TV_In - Thershold, 
	min(0, Min_In, Dividend), 
	TV_Out .=. ((Dividend)/(0 - Thershold)).

rfuzzy_type_for('fuzzy_rule', tempting_restaurant/1, [restaurant]).
rfuzzy_default_value_for(tempting_restaurant, 0.1).
tempting_restaurant(R) cred (min, 0.7) :~ min((near_the_city_center(R), fnot(my_very(expensive(R))), very(traditional(R)))).
tempting_restaurant(R) cred (min, 0.5) :~ near_the_city_center(R).

% More tests (maybe not needed in this DB).
not_very_expensive_restaurant(R) :~ fnot(very(expensive(R))).

rfuzzy_aggregator(max_with_min_a_half/3, TV_In_1, TV_In_2, TV_Out) :-
	max(TV_In_1, TV_In_2, TV_Aux), min(TV_Aux, 0.5, TV_Out).


test1(A, B) :- A .=. B.
test2(A, B) :- A .>. B.
test3(A, B, C) :- C .=. A + B.

% TYPE DECLARATION
%rfuzzy_type_for(house/7, [codetype/1,housetype/1,positive_integer/1,positive_integer/1,positive_integer/1,positive_integer/1,positive_integer/1]).
rfuzzy_define_database(house/7, 
	[(house_code, rfuzzy_enum_type), 
	  (house_type, rfuzzy_enum_type), 
	   (house_size, rfuzzy_integer_type),
	    (house_rooms_number, rfuzzy_integer_type), 
	     (house_price, rfuzzy_integer_type), 
	      (house_distance_to_the_center, rfuzzy_integer_type), 
	       (house_distance_to_the_beach, rfuzzy_integer_type)]).

% TYPE DEFINITION
housetype(apartment). housetype(villa). housetype(town_house).

codetype('lfs2168'). codetype('lfs2144'). codetype('lfs2147'). codetype('lfs2145').
codetype('c358'). codetype('lfs2110'). codetype('lfs2124'). codetype('lfs2123').
codetype('lfs2155'). codetype('lfs2111'). codetype('lfs2047'). codetype('lfs2041').
codetype('es13462'). codetype('lfs1942'). codetype('lfs1917'). codetype('lfb143').
codetype('5607/152'). codetype('es13340'). codetype('lfs1939'). codetype('lfs1938').

%positive_integer(1).
%positive_integer(X) :- positive_integer(Y),number(Y),X is Y + 1.
fraction(X):- X .>=. 0 , X .=<. 1 .

% DATABASE
%DEFINE ATRIBUTES
house(lfs2168,'apartment',114,5,630000,2,5700).
house(lfs2144,'apartment',77,3,420000,7,3500).
house(lfs2147,'apartment',80,2,675000,12,200).
house(lfs2145,'apartment',224,8,790000,20,100).
house(c358,'apartment',74,3,340000,5,3100).
house(lfs2110,'apartment',415,9,2500000,8,2400).
house(lfs2124,'apartment',63,2,275000,15,450).
house(lfs2123,'apartment',62,3,285000,6,1000).
house(lfs2155,'villa',2300,9,3000000,13,800).
house(lfs2111,'villa',700,10,1100000,9,4500).
house(lfs2047,'villa',1750,11,1650000,15,1000).
house(lfs2041,'villa',4000,13,2500000,4,1800).
house(es13462,'villa',600,6,4000000,6,1500).
house(lfs1942,'villa',900,10,3100000,3,3400).
house(lfs1917,'villa',210,5,590000,13,5000).
house(lfb143,'villa',1200,9,2750000,7,4000).
house(5607/152,'town_house',161,7,815000,6,1200).
house(es13340,'town_house',1025,8,2800000,25,7000).
house(lfs1939,'town_house',860,9,1800000,14,2400).
house(lfs1938,'town_house',520,11,1990000,19,80).

% FUZZY FUNCTIONS OVER THE DATABASE
expensive(X,Y):- house(X,_,_,_,P,_,_),expensive_func(P,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(expensive/2).
cheap(X,Y):- house(X,_,_,_,P,_,_),cheap_func(P,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(cheap/2).
big(X,Y):- house(X,_,S,_,_,_,_),big_func(S,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(big/2).
small(X,Y):- house(X,_,S,_,_,_,_),small_func(S,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(small/2).
close_to_center(X,Y):- house(X,_,_,_,_,D,_),close_to_center_func(D,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(close_to_center/2).
far_from_center(X,Y):- house(X,_,_,_,_,D,_),far_from_center_func(D,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(far_from_center/2).
close_to_beach(X,Y):- house(X,_,_,_,_,_,D),close_to_beach_func(D,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(close_to_beach/2).

% CRISP FUNCTIONS
equal(X,X).
greater(X,Y):- X.>.Y.
getHouseType(X,Y):- house(X,Y,_,_,_,_,_).

% FUZZY FUNCTIONS OVER QUANTITATIVE ATTRIBUTES
%rfuzzy_type_for(expensive_func/1, [positive_integer/1]).
% rfuzzy_default_value_for(expensive_func/1,1).
expensive_func :# (50000, [(50000,0),(100000,0.1),(250000,0.2),(350000,0.3),(450000,0.5),(550000,0.6),
	            (800000,0.7),(1000000,0.8),(1500000,0.9),(2500000,1)], 2500000).

%rfuzzy_type_for(cheap_func/1, [positive_integer/1]).
%rfuzzy_default_value_for(cheap_func/1,0).
cheap_func :# ([(0,1),(30000,1),(50000,0.8),(100000,0.7),(250000,0.5),(350000,0.3),
	            (450000,0.1),(550000,0)], 550000).

%rfuzzy_type_for(big_func/1, [positive_integer/1]).
%rfuzzy_default_value_for(big_func/1,1).
big_func :# (0, [(0,0),(50,0.1),(80,0.2),(120,0.3),(200,0.4),(300,0.5),(500,0.7),(1000,0.8),(1500,0.9),(2500,1)], 2500).

%rfuzzy_type_for(small_func/1, [positive_integer/1]).
%rfuzzy_default_value_for(small_func/1,0).
small_func :# (0, [(0,1),(50,1),(80,0.9),(100,0.8),(150,0.7),(200,0.5),(300,0.2),(400,0.1),(500,0)], 500).

%rfuzzy_type_for(close_to_center_func/1, [positive_integer/1]).
%rfuzzy_default_value_for(close_to_center_func/1,0).
close_to_center_func :# (0, [(0,1),(2,1),(4,0.8),(7,0.6),(10,0.5),(12,0.3),(15,0.2),(20,0)], 20).

%rfuzzy_type_for(far_from_center_func/1, [positive_integer/1]).
%rfuzzy_default_value_for(far_from_center_func/1,1).
far_from_center_func :# (0, [(0,0),(7,0),(8,0.1),(10,0.3),(14,0.4),(20,0.7),(25,0.8),(30,1)], 30).

%rfuzzy_type_for(close_to_beach_func/1, [positive_integer/1]).
%rfuzzy_default_value_for(close_to_beach_func/1,0).
close_to_beach_func :# (0, [(0,1),(100,1),(1000,0.5),(2000,0)], 2000).

% QUALIFIERS
%rfuzzy_type_for(very_func/1, [fraction/1]).
%rfuzzy_default_value_for(very_func/1,0.5).
very_func :# (0, [(0,0),(0.5,0),(0.8,0.8),(1,1)], 1).

%rfuzzy_type_for(little_func/1, [fraction/1]).
%rfuzzy_default_value_for(little_func/1,0.5).
little_func :# (0, [(0,1),(0.1,1),(0.4,0),(1,0)], 1).

% QUALIFIED FUZZY FUNCTIONS
very_expensive(X,Y):- expensive(X,T),very_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(very_expensive/2).
very_cheap(X,Y):- cheap(X,T),very_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(very_cheap/2).
very_big(X,Y):- big(X,T),very_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(very_big/2).
very_small(X,Y):- small(X,T),very_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(very_small/2).
very_close_to_center(X,Y):- close_to_center(X,T),very_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(very_close_to_center/2).
very_far_from_center(X,Y):- far_from_center(X,T),very_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(very_far_from_center/2).
very_close_to_beach(X,Y):- close_to_beach(X,T),very_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(very_close_to_beach/2).

little_expensive(X,Y):- expensive(X,T),little_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(little_expensive/2).
little_cheap(X,Y):- cheap(X,T),little_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(little_cheap/2).
little_big(X,Y):- big(X,T),little_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(little_big/2).
little_small(X,Y):- small(X,T),little_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(little_small/2).
little_close_to_center(X,Y):- close_to_center(X,T),little_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(little_close_to_center/2).
little_far_from_center(X,Y):- far_from_center(X,T),little_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(little_far_from_center/2).
little_close_to_beach(X,Y):- close_to_beach(X,T),little_func(T,Y).
rfuzzy_non_rfuzzy_fuzzy_rule(little_close_to_beach/2).


my_prod(X,Y,M):- M .=. X * Y.
test_my_prod(M) :- X .=. 0.7, Y .=. 0.5, my_prod(X, Y, M).
rfuzzy_aggregator(my_prod/3).


% Rules
rfuzzy_type_for(q1/1, [codetype/1]).
rfuzzy_default_value_for(q1/1,0.5).
q1(X):~ my_prod((cheap(X), close_to_center(X))).

rfuzzy_type_for(q2/1, [codetype/1]).
rfuzzy_default_value_for(q2/1,0.5).
q2(X):~ my_prod((cheap(X), little_big(X), close_to_beach(X))).

rfuzzy_type_for(q3/1, [codetype/1]).
rfuzzy_default_value_for(q3/1,0.5).
q3(X):~ my_prod((close_to_beach(X), very_far_from_center(X))).
t1(X,Y):- getHouseType(X,'apartment'),q3(X,Z), Y = Z ; Y = 0.

rfuzzy_type_for(q4/1, [codetype/1]).
rfuzzy_default_value_for(q4/1,0.5).
q4(X):~ my_prod((expensive(X), big(X), very_close_to_beach(X))).% missing crisp and not* parts 

rfuzzy_type_for(q5/1, [codetype/1]).
rfuzzy_default_value_for(q5/1,0.5).
q5(X):~ my_prod((very_cheap(X))). % 2 missing crisp parts

rfuzzy_type_for(q6/1, [codetype/1]).
rfuzzy_default_value_for(q6/1,0.5).
q6(X):~ my_prod((close_to_center(X), close_to_beach(X))). % 2 missing crisp parts



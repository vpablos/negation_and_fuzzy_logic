%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  opt_cnegf.pl
%%  Module CNEGF
%%                                 Juan Manuel Martinez Barrena
%%                                                  version 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- module(opt_cnegf,_,[]).

%% To execute this use in ciao top level
%% the predicate main as follows:
%% ?- main([example1, example2]).

:- load_compilation_module('/home/clip/ciaopp-0.8p24/src/topcpaths').
%:-('/home/susana/src/Ciao/ciaopp-0.8p24/src/topcpaths').



:- use_module(.(neg)).

:- use_module(ciaopp(m_ciaopp),[precompile/2]).
:- use_package(runtime_ops).
:- use_package(assertions).
:- use_module(library(file_utils),[file_terms/2]).
:- use_module(library(write)). 
:- use_module(library(system)). 
 
% Optimization of the negation calls of a list of programs Files.
main([]).
main([File|Files]):-
	new_finite_facts,
	neg_optimize(File,_File_out),
	main(Files).

% Create finite_facts.pl file to add the finite facts in finite.pl and used in cnegf.pl
new_finite_facts :-
	open('finite_facts.pl', write, S),
	write_term(S,(':-module(finite_facts, [finite/2], [])'),[]),
	write_term(S,'.',[]),
	put_code(S,10),
	put_code(S,10),
	put_code(S,10),
	close(S).


% Optimization of the negation calls of a list of a program File.
neg_optimize(File, File_salida):-
	opt_code(File, File_opt), % File Precompilation: to get steps_ub(_) & not_fails

	add_expand(File_opt,:-(use_package(.(finite))),File_finite),  % Add use_package(.(finite)) &  precompile:
						                      %    to get finite_facts.pl with finite if not_fails & steps_ub(_)
	add_expand(File_finite,:-(use_package(.(cnegf))),File_cnegf), % Add use_package(.(cnegf)) & precompile: 
						                      %    to change neg into cnegf whenever it's finite

						                      % Output file: filename_CNEGF.pl
	atom_concat(File_cnegf,'.pl', File1), % File with old name
	atom_concat(File,'_CNEGF', File_salida), % new name
	atom_concat(File_salida,'.pl', File_salida1), % File with new name
	rename_file(File1, File_salida1). % Rename File



	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Precompilation of the program
% Obtains file File_typesfd_shfr_upper_nf_co.pl
opt_code(File,File_opt):-       
	m_ciaopp:precompile(File,[none,none,typesfd,shfr,none,none,none,nf,none,none,none,none,yes]),
	m_ciaopp:precompile(File,[none,none,typesfd,shfr,none,none,upper,nf,none,none,none,none,yes]),	
	atom_concat(File,'_typesfd_shfr_upper_nf_co',File_opt). % obtains new file name

% Adds a line to the file File and obtain File_new_co after expanding
add_expand(File,Line,File_new_co):-
	atom_concat(File,'_new',File_new), % obtains new file name
	enclose(File,Line,File_new), % obtains the terms of a new file with Line
	get_full_code(File_new), % obtains the expanded new file File_new_co.pl 
	atom_concat(File_new,'_co',File_new_co). % obtains new file name
	
% Adds a line to the file File and obtain File_new
add(File,Line,File_new):-
	atom_concat(File,'_new',File_new), % obtains new file name
	enclose(File,Line,File_new). % obtains the terms of a new file with Line

% Precompilation to obtain the expanded program
get_full_code(File):-
        m_ciaopp:precompile(File,[none,none,none,
	                 none,none,
			 none,none,none,none,none,none,none,
			 yes]).

% enclose(File,Line,FileOut) joins the file File and the comand Line in the file FileOut
enclose(File,Line,FileOut):-
	atom_concat(File,'.pl',File1),
	file_terms(File1,Terms1),
	add_line(Terms1,Line,TermsOut),
	atom_concat(FileOut,'.pl',FileOut1),
	file_terms(FileOut1,TermsOut).



% add_line(Terms1,Line,TermsOut) includes Line as second element of Terms1
add_line([],Line,[Line]):- !.
add_line([(:-module(_Mod,Preds,Packs))|Terms1],Line,[(:-module(_,Preds,Packs)),Line|Terms1]):- !.
add_line([(:-module(_Mod,Preds))|Terms1],Line,[(:-module(_,Preds)),Line|Terms1]):- !.
add_line(Terms1,Line,[Line|Terms1]).

	
% rename(File, File_newname)  File gets the new name and turns into File_newname
%	atom_concat(File,'_CNEGF', File_salida), % new name
%	rename(File_cnegf, File_salida). % File_cnegf gets the new name
rename(File, File_newname):-
	atom_concat(File,'.pl',File1),
	atom_concat(File_newname,'.pl',File_newname1),
	file_terms(File1,Terms),
	file_terms(File_newname1,Terms).


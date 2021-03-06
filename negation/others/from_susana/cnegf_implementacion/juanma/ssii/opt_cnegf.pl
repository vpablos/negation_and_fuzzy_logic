:- module(_opt_cnegf,_,[]).

:- load_compilation_module('/home/clip/ciaopp-0.8p24/src/topcpaths').
%('/home/susana/src/Ciao/ciaopp-0.8p24/src/topcpaths').


:- use_module(.(neg)).
%%%
:- use_module(ciaopp(m_ciaopp),[precompile/2]).
:- use_package(runtime_ops).
:- use_package(assertions).
:- use_module(library(file_utils),[file_terms/2]).
%%%
 
% Optimization of the negation calls of a list of programs Files.
main([]).
main([File|Files]):-
	neg_optimize(File,_File_out),
	main(Files).

% Optimization of the negation calls of a list of a program File.
neg_optimize(File,_File_out):-
	opt_code(File, File_opt), % Se precompila con las opciones en dos pasos
	add_expand(File_opt,:-(use_package(.(finite))),File_finite), % Se a�ade use_package(.(finite)) al fichero resultado de la precompilacion
	add_expand(File_finite,:-(use_package(.(cnegf))),_File_out). % Se a�ade use_package(.(cnegf)) al fichero resultado de expandir finite

main2([]).
main2([File|Files]):-
	neg_optimize2(File,_File_out),
	main2(Files).

% Optimization of the negation calls of a list of a program File.
neg_optimize2(File,_File_out):-
	opt_code(File, File_opt), % Se precompila con las opciones en dos pasos
	add_expand(File_opt,:-(use_package(.(finite))),File_finite), % Se a�ade use_package(.(finite)) al fichero resultado de la precompilacion
	add_expand(File_finite,:-(use_package(.(reg))),File_reg), % Se quitan los regedit
	add_expand(File_reg,:-(use_package(.(cnegf))),_File_out). % Se a�ade use_package(.(cnegf)) al fichero resultado de expandir finite
	
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

	

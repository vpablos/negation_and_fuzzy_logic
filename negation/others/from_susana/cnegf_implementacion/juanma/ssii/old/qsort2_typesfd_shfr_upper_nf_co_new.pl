:-(module(_157513,[/(qsort,2),/(partition,4),/(append,3),/(less,2),/(greatereq,2),/(prueba_2,2),/(prueba_3,3),/(prueba_4,4)],ciaopp)) .
:-(use_package('.'(finite))) .
:-(new_declaration(/(comment,2))) .
:-(op(975,xfx,=>)) .
:-(op(978,xfx,::)) .
:-(new_declaration(/(decl,1))) .
:-(op(1150,fx,decl)) .
:-(new_declaration(/(decl,2))) .
:-(op(1150,xfx,decl)) .
:-(new_declaration(/(pred,1))) .
:-(op(1150,fx,pred)) .
:-(new_declaration(/(pred,2))) .
:-(op(1150,xfx,pred)) .
:-(new_declaration(/(prop,1))) .
:-(op(1150,fx,prop)) .
:-(new_declaration(/(prop,2))) .
:-(op(1150,xfx,prop)) .
:-(new_declaration(/(modedef,1))) .
:-(op(1150,fx,modedef)) .
:-(new_declaration(/(calls,1))) .
:-(op(1150,fx,calls)) .
:-(new_declaration(/(calls,2))) .
:-(op(1150,xfx,calls)) .
:-(new_declaration(/(success,1))) .
:-(op(1150,fx,success)) .
:-(new_declaration(/(success,2))) .
:-(op(1150,xfx,success)) .
:-(new_declaration(/(comp,1))) .
:-(op(1150,fx,comp)) .
:-(new_declaration(/(comp,2))) .
:-(op(1150,xfx,comp)) .
:-(new_declaration(/(entry,1))) .
:-(op(1150,fx,entry)) .
:-(use_module('.'(neg))) .
:-(success(trust,neg(_144183))) .
:-(pred(true,=>(:(qsort(_144328,_144345),','(list(_144328,numexp),var(_144345))),+(','(list(_144328,numexp),ground(_144345)),','(possibly_fails,covered))))) .
:-(pred(true,=>(:(qsort(_144791,_144808),','(ground(_144791),','(var(_144808),mshare([[_144808]])))),','(ground(_144791),ground(_144808))))) .
:-(entry(:(qsort(_145186,_145203),','(list(_145186,num),','(var(_145203),ground(_145186)))))) .
:-(qsort([_145461|_145478],_145497),','(partition(_145478,_145461,_145566,_145585),','(qsort(_145585,_145634),','(qsort(_145566,_145683),append(_145683,[_145461|_145634],_145497))))) .
qsort([],[]) .
:-(pred(true,=>(:(partition(_146055,_146072,_146089,_146106),','(term(_146055),','(term(_146072),','(term(_146089),term(_146106))))),+(','(list(_146055,numexp),','(term(_146072),','(list(_146089,numexp),list(_146106,numexp)))),','(possibly_fails,not_covered))))) .
:-(pred(true,=>(:(partition(_146737,_146754,_146771,_146788),mshare([[_146737],[_146737,_146754],[_146737,_146754,_146771],[_146737,_146754,_146771,_146788],[_146737,_146754,_146788],[_146737,_146771],[_146737,_146771,_146788],[_146737,_146788],[_146754],[_146754,_146771],[_146754,_146771,_146788],[_146754,_146788],[_146771],[_146771,_146788],[_146788]])),','(ground(_146737),','(ground(_146771),','(ground(_146788),mshare([[_146754]]))))))) .
partition([],_147634,[],[]) .
:-(partition([_147765|_147782],_147801,[_147765|_147830],_147857),','(less(_147765,_147801),partition(_147782,_147801,_147830,_147857))) .
:-(partition([_148144|_148161],_148180,_148197,[_148144|_148232]),','(greatereq(_148144,_148180),partition(_148161,_148180,_148197,_148232))) .
:-(pred(true,=>(:(append(_148557,_148574,_148591),','(term(_148557),','(term(_148574),term(_148591)))),+(','(list(_148557,term),','(term(_148574),term(_148591))),','(possibly_fails,not_covered))))) .
:-(pred(true,=>(:(append(_149095,_149112,_149129),mshare([[_149095],[_149095,_149112],[_149095,_149112,_149129],[_149095,_149129],[_149112],[_149112,_149129],[_149129]])),mshare([[_149095,_149112,_149129],[_149095,_149129],[_149112,_149129]])))) .
append([],_149638,_149638) .
:-(append([_149752|_149769],_149788,[_149752|_149817]),append(_149769,_149788,_149817)) .
:-(pred(true,=>(:(less(_150031,_150048),','(term(_150031),term(_150048))),+(','(numexp(_150031),numexp(_150048)),','(possibly_fails,not_covered))))) .
:-(pred(true,=>(:(less(_150464,_150481),mshare([[_150464],[_150464,_150481],[_150481]])),','(ground(_150464),ground(_150481))))) .
:-(less(_150805,_150822),<(_150805,_150822)) .
:-(pred(true,=>(:(greatereq(_151009,_151026),','(term(_151009),term(_151026))),+(','(numexp(_151009),numexp(_151026)),','(possibly_fails,not_covered))))) .
:-(pred(true,=>(:(greatereq(_151452,_151469),mshare([[_151452],[_151452,_151469],[_151469]])),','(ground(_151452),ground(_151469))))) .
:-(greatereq(_151803,_151820),>=(_151803,_151820)) .
:-(pred(true,=>(:(prueba_2(_152007,_152024),','(term(_152007),term(_152024))),+(','(term(_152007),term(_152024)),','(possibly_fails,covered))))) .
:-(pred(true,=>(:(prueba_2(_152432,_152449),mshare([[_152432],[_152432,_152449],[_152449]])),mshare([[_152432],[_152432,_152449],[_152449]])))) .
:-(prueba_2(_152797,_152814),neg(qsort(_152797,_152814))) .
:-(pred(true,=>(:(prueba_3(_153033,_153050,_153067),','(term(_153033),','(term(_153050),term(_153067)))),+(','(term(_153033),','(term(_153050),term(_153067))),','(possibly_fails,covered))))) .
:-(pred(true,=>(:(prueba_3(_153550,_153567,_153584),mshare([[_153550],[_153550,_153567],[_153550,_153567,_153584],[_153550,_153584],[_153567],[_153567,_153584],[_153584]])),mshare([[_153550],[_153550,_153567],[_153550,_153567,_153584],[_153550,_153584],[_153567],[_153567,_153584],[_153584]])))) .
:-(prueba_3(_154175,_154192,_154209),neg(append(_154175,_154192,_154209))) .
:-(pred(true,=>(:(prueba_4(_154446,_154463,_154480,_154497),','(term(_154446),','(term(_154463),','(term(_154480),term(_154497))))),+(','(term(_154446),','(term(_154463),','(term(_154480),term(_154497)))),','(possibly_fails,covered))))) .
:-(pred(true,=>(:(prueba_4(_155055,_155072,_155089,_155106),mshare([[_155055],[_155055,_155072],[_155055,_155072,_155089],[_155055,_155072,_155089,_155106],[_155055,_155072,_155106],[_155055,_155089],[_155055,_155089,_155106],[_155055,_155106],[_155072],[_155072,_155089],[_155072,_155089,_155106],[_155072,_155106],[_155089],[_155089,_155106],[_155106]])),mshare([[_155055],[_155055,_155072],[_155055,_155072,_155089],[_155055,_155072,_155089,_155106],[_155055,_155072,_155106],[_155055,_155089],[_155055,_155089,_155106],[_155055,_155106],[_155072],[_155072,_155089],[_155072,_155089,_155106],[_155072,_155106],[_155089],[_155089,_155106],[_155106]])))) .
:-(prueba_4(_156276,_156293,_156310,_156327),neg(partition(_156276,_156293,_156310,_156327))) .
:-(regtype(/(t199,1))) .
:-(t199(partition(_156703,_156720,_156737,_156754)),','(term(_156703),','(term(_156720),','(term(_156737),term(_156754))))) .
:-(t199(qsort(_157036,_157053)),','(term(_157036),term(_157053))) .
:-(t199(append(_157259,_157276,_157293)),','(term(_157259),','(term(_157276),term(_157293)))) .

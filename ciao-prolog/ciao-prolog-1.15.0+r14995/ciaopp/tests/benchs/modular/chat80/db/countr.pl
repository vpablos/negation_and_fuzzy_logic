
:- module(countr,[ country/10 ],[ assertions ]).
% Facts about countries.

:- use_module(engine(arithmetic), [(is)/2, (>)/2]).

% country(Country,Region,Latitude,Longitude,
%         Area/1000,Area mod 1000,
%         Population/1000000,Population mod 1000000 / 1000,
%         Capital,Currency)

:- true pred country(A,B,C,D,E,F,G,H,I,J)
        => ( term_typing:ground([A,B,C,D,E,F,G,H,I,J]) ).

country(Country,Region,Latitude,Longitude,
	AreaDiv,AreaMod,PopulationDiv,PopulationMod,
        Capital,Currency):-
country_db(Country,Region,Latitude,Longitude,
	AreaDiv,AreaMod,PopulationDiv,PopulationMod,
        Capital,Currency).

:- true pred country_db(A,B,C,D,E,F,G,H,I,J)
        => ( term_typing:ground([A,B,C,D,E,F,G,H,I,J]) ).

country_db(afghanistan,indian_subcontinent,33,-65,254,861,18,290,kabul,afghani).
country_db(albania,southern_europe,41,-20,11,100,2,350,tirana,lek).
country_db(algeria,north_africa,35,-11,919,951,15,770,algiers,dinar).
country_db(andorra,southern_europe,42,-1,0,179,0,25,andorra_la_villa,
	franc_peseta).
country_db(angola,southern_africa,-12,-18,481,351,5,810,luanda,?).
country_db(argentina,south_america,-35,66,1072,67,23,920,buenos_aires,peso).
country_db(australia,australasia,-23,-135,2967,909,13,268,canberra,
	australian_dollar).
country_db(austria,western_europe,47,-14,32,374,7,520,vienna,schilling).
country_db(bahamas,caribbean,24,74,4,404,0,190,nassau,bahamian_dollar).
country_db(bahrain,middle_east,26,-50,0,231,0,230,manama,dinar).
country_db(bangladesh,indian_subcontinent,24,-90,55,126,71,317,dacca,taka).
country_db(barbados,caribbean,13,59,0,166,0,240,bridgetown,east_carribean_dollar).
country_db(belgium,western_europe,51,-5,11,779,9,711,brussels,franc).
country_db(belize,central_america,17,88,8,866,0,82,belize_town,?).
country_db(bhutan,indian_subcontinent,27,-90,19,305,1,150,thimphu,indian_rupee).
country_db(bolivia,south_america,-17,64,424,162,5,330,sucre,peso).
country_db(botswana,southern_africa,-22,-24,219,815,0,650,gaborone,
	south_african_rand).
country_db(brazil,south_america,-13,53,3286,470,105,137,brasilia,cruzeiro).
country_db(bulgaria,eastern_europe,43,-25,42,829,8,620,sofia,lev).
country_db(burma,southeast_east,21,-96,261,789,29,560,rangoon,kyat).
country_db(burundi,central_africa,-3,-30,10,739,3,600,bujumbura,franc).
country_db(cambodia,southeast_east,12,-105,69,898,7,640,phnom_penh,riel).
country_db(cameroon,west_africa,3,-12,183,568,6,170,yaounde,cfa_franc).
country_db(canada,north_america,60,100,3851,809,22,47,ottawa,canadian_dollar).
country_db(central_african_republic,central_africa,7,-20,241,313,1,720,bangui,
	cfa_franc).
country_db(chad,central_africa,12,-17,495,752,3,870,n_djamena,cfa_franc).
country_db(chile,south_america,-35,71,286,396,10,230,santiago,escudo).
country_db(china,far_east,30,-110,3691,502,840,0,peking,yuan).
country_db(colombia,south_america,4,73,455,335,23,210,bogota,peso).
country_db(congo,central_africa,-1,-16,132,46,1,1,brazzaville,cfa_franc).
country_db(costa_rica,central_america,10,84,19,653,1,890,san_jose,colon).
country_db(cuba,caribbean,22,79,44,218,8,870,havana,peso).
country_db(cyprus,southern_europe,35,-33,3,572,0,660,nicosia,pound).
country_db(czechoslovakia,eastern_europe,49,-17,49,371,14,580,prague,koruna).
country_db(dahomey,west_africa,8,-2,43,483,2,910,porto_novo,cfa_franc).
country_db(denmark,scandinavia,55,-9,16,615,5,130,copenhagen,krone).
country_db(djibouti,east_africa,12,-42,9,71,0,45,djibouti,?).
country_db(dominican_republic,caribbean,19,70,18,704,4,430,santa_domingo,peso).
country_db(east_germany,eastern_europe,52,-12,40,646,16,980,east_berlin,ddr_mark).
country_db(ecuador,south_america,-2,78,105,685,6,730,quito,sucre).
country_db(egypt,north_africa,28,-31,386,872,35,620,cairo,egyptian_pound).
country_db(eire,western_europe,53,8,26,600,3,30,dublin,irish_pound).
country_db(el_salvador,central_america,14,89,8,260,3,860,san_salvador,colon).
country_db(equatorial_guinea,west_africa,1,-10,10,832,0,300,santa_isabel,peveta).
country_db(ethiopia,east_africa,8,-40,457,142,26,80,addis_ababa,ethiopean_dollar).
country_db(fiji,australasia,-17,-179,7,55,0,550,suva,fiji_dollar).
country_db(finland,scandinavia,65,-27,130,119,4,660,helsinki,markka).
country_db(france,western_europe,47,-3,212,973,52,350,paris,franc).
country_db(french_guiana,south_america,4,53,34,740,0,27,cayenne,?).
country_db(gabon,central_africa,0,-10,102,317,0,520,libreville,cfa_franc).
country_db(gambia,west_africa,13,16,4,3,0,490,banjul,dalasi).
country_db(ghana,west_africa,6,1,92,100,9,360,accra,cedi).
country_db(greece,southern_europe,40,-23,50,547,9,30,athens,drachma).
country_db(grenada,caribbean,12,61,0,133,0,100,st_georges,east_caribbean_dollar).
country_db(guatemala,central_america,15,90,42,42,5,540,guatamala_city,quetzal).
country_db(guinea,west_africa,10,10,94,925,4,210,conakry,syli).
country_db(guinea_bissau,west_africa,12,15,13,948,0,510,bissau,pataca).
country_db(guyana,south_america,5,59,83,0,0,760,georgetown,guyana_dollar).
country_db(haiti,caribbean,19,72,10,714,5,200,port_au_prince,gourde).
country_db(honduras,central_america,14,86,43,277,2,780,tegucigalpa,lempira).
country_db(hungary,eastern_europe,47,-19,35,919,10,410,budapest,forint).
country_db(iceland,western_europe,65,19,39,702,0,210,reykjavik,krona).
country_db(india,indian_subcontinent,20,-80,1229,919,574,220,new_delhi,rupee).
country_db(indonesia,southeast_east,-5,-115,735,268,124,600,jakarta,rupiah).
country_db(iran,middle_east,33,-53,636,363,32,1,tehran,rial).
country_db(iraq,middle_east,33,-44,167,567,10,410,baghdad,dinar).
country_db(israel,middle_east,32,-35,34,493,3,228,jerusalem,israeli_pound).
country_db(italy,southern_europe,42,-13,116,303,55,262,rome,lira).
country_db(ivory_coast,west_africa,7,5,124,503,4,640,abidjan,cfa_franc).
country_db(jamaica,caribbean,18,77,4,411,1,980,kingston,jamaican_dollar).
country_db(japan,far_east,36,-136,143,574,108,710,tokyo,yen).
country_db(jordan,middle_east,31,-36,32,297,2,560,amman,dinar).
country_db(kenya,east_africa,1,-38,224,960,12,480,nairobi,kenya_shilling).
country_db(kuwait,middle_east,29,-47,7,780,0,880,kuwait_city,kuwaiti_dinar).
country_db(laos,southeast_east,18,-105,3,180,3,180,vientiane,kip).
country_db(lebanon,middle_east,34,-36,4,15,3,213,beirut,lebanese_pound).
country_db(lesotho,southern_africa,-30,-28,11,716,1,200,masero,rand).
country_db(liberia,west_africa,6,9,43,0,1,660,monrovia,us_dollar).
country_db(libya,north_africa,28,-17,679,536,2,257,tripoli,libyan_dinar).
country_db(liechtenstein,western_europe,47,-9,0,62,0,23,vaduz,swiss_franc).
country_db(luxembourg,western_europe,50,-6,0,999,0,350,luxembourg,
	luxembourg_franc).
country_db(malagasy,southern_africa,-20,-47,203,35,7,655,tananarive,ariary).
country_db(malawi,southern_africa,-13,-34,45,747,4,790,zomba,kwacha).
country_db(malaysia,southeast_east,5,-110,128,328,10,920,kuala_lumpa,
	malaysian_dollar).
country_db(maldives,indian_subcontinent,2,-73,0,115,0,123,male,rupee).
country_db(mali,west_africa,15,10,464,873,5,380,bamako,mali_franc).
country_db(malta,southern_europe,36,-14,0,122,0,319,valetta,pound).
country_db(mauritania,west_africa,21,10,419,229,1,260,nouakchott,ouguiya).
country_db(mauritius,southern_africa,-20,-57,0,787,0,870,port_louis,rupee).
country_db(mexico,central_america,20,100,761,601,54,300,mexico_city,peso).
country_db(monaco,southern_europe,44,-7,0,1,0,30,monaco,french_franc).
country_db(mongolia,northern_asia,47,-103,604,247,1,360,ulan_bator,tighrik).
country_db(morocco,north_africa,32,6,171,953,16,310,rabat,dirham).
country_db(mozambique,southern_africa,-19,-35,303,373,8,820,maputo,?).
country_db(nepal,indian_subcontinent,28,-84,54,362,12,20,katmandu,nepalese_rupee).
country_db(netherlands,western_europe,52,-5,14,192,13,500,amsterdam,guilder).
country_db(new_zealand,australasia,-40,-176,103,736,2,962,wellington,
	new_zealand_dollar).
country_db(nicaragua,central_america,12,85,57,143,2,10,managua,cordoba).
country_db(niger,west_africa,13,-10,489,206,4,300,niamey,cfa_franc).
country_db(nigeria,west_africa,8,-8,356,669,79,759,lagos,naira).
country_db(north_korea,far_east,40,-127,46,768,15,90,pvongvang,won).
country_db(norway,scandinavia,64,-11,125,181,3,960,oslo,krone).
country_db(oman,middle_east,23,-58,82,0,0,720,muscat,riyal_omani).
country_db(pakistan,indian_subcontinent,30,-70,342,750,66,750,islamad,rupee).
country_db(panama,central_america,9,80,28,753,1,570,panama,balboa).
country_db(papua_new_guinea,
          australasia,-8,-145,183,540,2,580,port_harcourt,australian_dollar).
country_db(paraguay,south_america,-23,57,157,47,2,670,asuncion,guarani).
country_db(peru,south_america,-8,75,496,222,14,910,lima,sol).
country_db(philippines,southeast_east,12,-123,115,707,40,220,quezon_city,piso).
country_db(poland,eastern_europe,52,-20,120,359,33,360,warsaw,zloty).
country_db(portugal,southern_europe,40,7,35,340,8,560,lisbon,escudo).
country_db(qatar,middle_east,25,-51,4,0,0,115,doha,riyal).
country_db(romania,eastern_europe,46,-25,91,699,5,690,bucharest,leu).
country_db(rwanda,central_africa,-2,-30,10,169,3,980,kigali,rwanda_franc).
country_db(san_marino,southern_europe,44,-12,0,24,0,20,san_marino,italian_lira).
country_db(saudi_arabia,middle_east,26,-44,873,0,8,100,riyadh,riyal).
country_db(senegal,west_africa,14,14,76,124,4,230,dakar,cfa_franc).
country_db(seychelles,east_africa,-4,-55,0,40,0,156,victoria,rupee).
country_db(sierra_leone,west_africa,9,12,27,925,2,860,freetown,leone).
country_db(singapore,southeast_east,1,-104,0,226,2,190,singapore,
	singapore_dollar).
country_db(somalia,east_africa,7,-47,246,155,3,100,mogadishu,somali_shilling).
country_db(south_africa,southern_africa,-30,-25,471,819,23,720,pretoria,rand).
country_db(south_korea,far_east,36,-128,38,31,33,333,seoul,won).
country_db(south_yemen,middle_east,15,-48,111,0,1,600,aden,dinar).
country_db(soviet_union,northern_asia,57,-80,8347,250,250,900,moscow,ruble).
country_db(spain,southern_europe,40,5,194,883,34,860,madrid,peseta).
country_db(sri_lanka,indian_subcontinent,7,-81,25,332,13,250,colombo,rupee).
country_db(sudan,central_africa,15,-30,967,491,16,900,khartoum,pound).
country_db(surinam,south_america,4,56,55,0,0,208,paramaribo,?).
country_db(swaziland,southern_africa,-26,-31,6,705,0,460,mbabane,lilageru).
country_db(sweden,scandinavia,63,-15,173,665,8,144,stockholm,krona).
country_db(switzerland,western_europe,46,-8,15,941,6,440,bern,franc).
country_db(syria,middle_east,35,-38,71,498,6,895,damascus,syrian_pound).
country_db(taiwan,far_east,23,-121,13,592,15,737,taipei,taiwan_dollar).
country_db(tanzania,east_africa,-7,-34,363,708,14,0,dar_es_salaam,
	tanzanian_shilling).
country_db(thailand,southeast_east,16,-102,198,455,39,950,bangkok,baht).
country_db(togo,west_africa,8,-1,21,853,2,120,lome,cfa_franc).
country_db(tonga,australasia,-20,173,0,269,0,90,nukualofa,pa_anga).
country_db(trinidad_and_tobago,caribbean,10,61,1,979,5,510,port_of_spain,
	trinidad_and_tobago_dollar).
country_db(tunisia,north_africa,33,-9,63,378,5,510,tunis,dinar).
country_db(turkey,middle_east,39,-36,301,380,37,930,ankara,lira).
country_db(uganda,east_africa,2,-32,91,134,10,810,kampala,uganda_shilling).
country_db(united_arab_emirates,middle_east,24,-54,32,278,0,210,abu_dhabi,dirham).
country_db(united_kingdom,western_europe,54,2,94,209,55,930,london,pound).
country_db(united_states,north_america,37,96,3615,122,211,210,washington,dollar).
country_db(upper_volta,west_africa,12,2,105,869,5,740,ouagadougou,cfa_franc).
country_db(uruguay,south_america,-32,55,68,548,2,990,montevideo,peso).
country_db(venezuela,south_america,8,65,352,143,11,520,caracas,bolivar).
country_db(vietnam,southeast_east,17,-107,126,436,41,850,hanoi,dong).
country_db(west_germany,western_europe,52,-9,95,815,61,970,bonn,deutsche_mark).
country_db(western_samoa,australasia,-14,172,1,133,0,150,apia,tala).
country_db(yemen,middle_east,15,-44,75,289,1,600,sana,rial).
country_db(yugoslavia,southern_europe,44,-20,98,766,21,126,belgrade,dinar).
country_db(zaire,central_africa,-3,-23,905,63,23,560,kinshasa,zaire).
country_db(zambia,southern_africa,-15,-28,290,724,4,640,lusaka,kwacha).
country_db(zimbabwe,southern_africa,-20,-30,150,333,5,690,salisbury,
	rhodesian_dollar).

%% Simulate slow database access: 
old_country_db(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10) :- 
	db_loop(100),
	country_db(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10).

db_loop(0).
db_loop(N) :-
	N > 0,
	N1 is N-1,
	db_loop(N1).

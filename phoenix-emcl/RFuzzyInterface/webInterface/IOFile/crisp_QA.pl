house(lfs2168,'apartment',114,5,630000,2,5700).
house(lfs2144,'apartment',77,3,420000,7,3500).
house(lfs2147,'apartment',80,2,675000,12,200).
house(lfs2145,'apartment',224,8,790000,20,100).
house(c358,'apartment',74,3,340000,5,3100).
house(lfs2110,'apartment',415,9,2500000,8,2400).
house(lfs2124,'apartment',63,2,275000,15,450).
house(lfs2123,'apartment',62,3,285000,6,1000).

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
house(lfs2155,'villa',2300,9,3000000,13,800).
main :- findall(HOUSE_CODE,house(HOUSE_CODE,_,_,_,_,_,_),L),write(L).
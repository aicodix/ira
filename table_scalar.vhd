-- code table generated from table_scalar.txt by generate_table_scalar_vhd.cc
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

use work.ldpc_scalar.all;

package table_scalar is
	function init_block_parities return block_parities;
	function init_block_counts return block_counts;
	function init_block_offsets return block_offsets;
	function init_block_shifts return block_shifts;
end package;

package body table_scalar is
	function init_block_parities return block_parities is
	begin
		return 45;
	end function;

	function init_block_counts return block_counts is
	begin
		return (
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
14,
		others => count_scalar'low);
	end function;

	function init_block_offsets return block_offsets is
	begin
		return (
0,2,3,6,10,31,45,59,69,90,94,126,135,179,
1,3,7,9,39,40,46,62,82,91,113,129,135,136,
1,2,2,7,30,40,47,51,85,90,92,114,136,137,
3,5,7,8,8,17,48,48,50,93,123,134,137,138,
2,4,10,11,29,36,45,46,49,94,100,107,138,139,
5,5,5,9,30,32,50,73,77,94,95,131,139,140,
5,6,8,9,12,16,48,51,89,96,98,106,140,141,
7,9,13,14,19,33,47,52,66,97,108,123,141,142,
4,8,8,10,12,21,53,55,89,96,98,116,142,143,
1,2,4,6,9,29,54,57,87,99,108,111,143,144,
1,4,9,10,12,13,55,63,78,99,100,100,144,145,
0,5,8,11,15,23,56,56,57,97,101,122,145,146,
0,2,12,12,13,31,52,57,76,90,102,104,146,147,
4,10,11,13,13,41,53,58,68,103,107,110,147,148,
3,4,12,13,14,22,51,59,62,104,105,116,148,149,
4,7,10,15,18,26,60,68,86,102,105,125,149,150,
3,6,6,9,16,35,61,84,85,91,106,114,150,151,
2,3,3,17,28,39,62,69,88,102,107,129,151,152,
6,6,7,11,14,18,50,60,63,108,119,121,152,153,
1,4,12,13,19,35,64,77,87,96,109,127,153,154,
5,8,10,20,27,38,46,65,74,110,113,132,154,155,
1,2,4,11,16,21,56,66,82,103,110,111,155,156,
0,2,4,8,9,22,67,81,84,98,112,120,156,157,
0,5,6,23,23,36,55,64,68,106,109,113,157,158,
0,9,11,24,27,38,69,78,80,114,124,133,158,159,
8,9,11,22,25,42,70,79,81,92,115,118,159,160,
0,7,14,14,25,26,58,67,71,116,120,128,160,161,
6,8,9,20,27,34,47,72,73,97,117,118,161,162,
10,14,14,25,28,43,71,73,75,112,118,128,162,163,
0,5,11,12,18,29,49,74,80,92,104,119,163,164,
3,6,6,10,20,30,65,70,75,91,120,126,164,165,
0,4,7,13,31,44,59,71,76,99,121,134,165,166,
1,2,3,8,17,32,45,70,77,119,122,127,166,167,
10,14,14,33,37,42,52,65,78,95,123,130,167,168,
2,7,12,34,34,37,58,61,79,105,109,124,168,169,
3,5,11,14,26,35,53,80,86,112,122,125,169,170,
3,5,6,13,28,36,66,79,81,117,124,126,170,171,
1,9,12,13,14,37,54,76,82,101,127,133,171,172,
7,10,14,21,33,38,64,83,88,125,128,130,172,173,
0,7,10,19,32,39,49,83,84,101,111,129,173,174,
0,0,11,12,13,40,61,67,85,103,121,130,174,175,
5,8,11,13,41,44,72,83,86,95,131,132,175,176,
1,1,3,24,24,42,54,63,87,93,117,132,176,177,
1,2,4,11,41,43,72,74,88,115,115,133,177,178,
1,7,12,15,43,44,60,75,89,93,131,134,178,179,
		others => 0);
	end function;

	function init_block_shifts return block_shifts is
	begin
		return (
0,52,205,145,164,263,0,173,301,0,187,78,0,359,
0,279,351,314,42,179,0,92,151,0,29,180,0,0,
210,0,89,22,290,13,0,184,33,203,0,28,0,0,
0,220,272,51,348,69,0,98,205,0,195,296,0,0,
39,0,203,13,169,319,332,80,0,0,340,171,0,0,
0,82,329,199,283,55,0,4,91,329,0,24,0,0,
45,0,156,348,166,62,290,0,222,0,253,299,0,0,
0,79,210,179,200,45,300,0,273,0,162,61,0,0,
324,0,281,136,32,262,0,321,189,189,0,214,0,0,
53,218,120,270,0,75,0,348,334,0,89,271,0,0,
20,252,213,0,279,349,0,181,16,95,0,320,0,0,
342,240,232,0,94,192,0,322,84,303,0,88,0,0,
288,183,0,251,302,51,25,0,147,283,0,186,0,0,
154,155,318,0,162,111,248,0,321,0,257,80,0,0,
98,145,6,66,0,301,3,0,329,0,225,170,0,0,
333,93,214,0,39,224,0,230,19,281,0,304,0,0,
198,164,257,143,0,243,0,171,172,273,0,202,0,0,
24,42,65,0,168,190,0,28,308,109,0,134,0,0,
130,132,157,120,39,0,48,143,0,0,52,105,0,0,
108,36,313,14,0,26,0,18,184,305,0,153,0,0,
51,341,114,0,194,225,139,0,257,0,322,39,0,0,
316,220,191,115,207,0,180,0,254,29,262,0,0,0,
300,58,107,227,198,0,0,177,298,12,0,97,0,0,
244,197,186,0,160,336,17,173,0,273,84,0,0,0,
63,285,32,0,37,146,0,166,15,0,69,113,0,0,
222,254,104,50,0,57,0,20,294,190,0,76,0,0,
185,89,215,293,199,0,203,275,0,0,112,19,0,0,
183,45,251,287,0,68,178,0,191,185,0,354,0,0,
201,11,166,202,0,170,265,0,69,172,0,49,0,0,
305,234,358,328,316,0,327,0,296,74,190,0,0,0,
326,228,285,195,273,0,47,237,0,53,0,217,0,0,
36,22,262,267,0,301,329,80,0,129,0,38,0,0,
107,186,276,283,64,0,338,220,0,212,0,208,0,0,
135,25,112,0,315,222,91,332,0,156,0,253,0,0,
62,195,8,0,306,337,269,109,0,70,233,0,0,0,
232,325,356,75,57,0,217,0,187,53,2,0,0,0,
186,8,20,176,306,0,53,196,0,352,38,0,0,0,
77,289,301,184,253,0,29,50,0,109,0,246,0,0,
79,350,57,222,117,0,296,0,168,111,0,95,0,0,
197,314,69,265,227,0,353,253,0,155,331,0,0,0,
112,219,125,202,276,0,221,272,0,302,41,0,0,0,
151,174,184,343,0,100,89,114,0,230,0,182,0,0,
342,353,166,46,295,0,79,159,0,179,251,0,0,0,
301,323,314,193,259,0,102,47,0,28,164,0,0,0,
200,347,247,291,186,0,192,148,0,322,225,0,0,0,
		others => 0);
	end function;
end package body;

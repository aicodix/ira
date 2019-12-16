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
		return 8;
	end function;

	function init_block_counts return block_counts is
	begin
		return (
16,
16,
16,
16,
19,
18,
19,
17,
		others => count_scalar'low);
	end function;

	function init_block_offsets return block_offsets is
	begin
		return (
0,2,5,5,8,13,15,15,21,21,26,29,34,36,37,44,
0,0,6,7,12,14,14,19,22,23,24,29,30,30,37,38,
3,3,7,9,11,15,16,17,21,23,23,31,31,33,38,39,
0,0,7,8,12,16,18,20,24,26,27,30,32,35,39,40,
0,0,0,1,4,6,9,10,17,17,19,25,25,28,33,33,36,40,41,
0,0,2,4,9,10,11,13,13,18,22,22,26,29,34,35,41,42,
0,0,1,2,3,6,10,11,18,19,20,24,27,27,31,32,35,42,43,
0,1,4,5,8,12,14,16,20,25,28,28,32,34,36,43,44,
		others => 0);
	end function;

	function init_block_shifts return block_shifts is
	begin
		return (
77,207,0,96,202,0,148,222,0,328,70,0,61,147,0,359,
59,175,0,292,350,0,339,298,0,203,207,64,0,353,0,0,
96,255,0,78,346,0,121,179,50,0,153,0,229,143,0,0,
0,298,258,0,80,0,349,163,0,26,306,300,0,340,0,0,
247,271,47,0,334,67,0,240,0,294,82,0,238,332,0,352,30,0,0,
319,10,0,289,148,0,59,205,163,0,221,203,0,125,0,280,0,0,
202,148,120,309,0,75,340,0,239,0,70,176,0,201,256,112,0,0,0,
291,55,0,63,343,0,264,7,0,47,0,298,207,242,0,0,0,
		others => 0);
	end function;
end package body;

/*
Generate table_scalar.vhd from table_scalar.txt

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include "ldpc_scalar.hh"

int main()
{
	int offsets[BLOCK_LOCATIONS_MAX];
	int shifts[BLOCK_LOCATIONS_MAX];
	int counts[BLOCK_PARITIES_MAX];
	int parities = 0;
	std::ifstream table_txt("table_scalar.txt");
	for (int loc = 0; table_txt >> counts[parities]; ++parities) {
		for (int num = 0; num < counts[parities]; ++num, ++loc) {
			table_txt >> offsets[loc];
			table_txt.ignore(1, ':');
			table_txt >> shifts[loc];
		}
	}
	std::ofstream table_vhd("table_scalar.vhd");
	table_vhd << "-- code table generated from table_scalar.txt by generate_table_scalar_vhd.cc" << std::endl;
	table_vhd << "--" << std::endl;
	table_vhd << "-- Copyright 2019 Ahmet Inan <inan@aicodix.de>" << std::endl;
	table_vhd << std::endl;
	table_vhd << "use work.ldpc_scalar.all;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "package table_scalar is" << std::endl;
	table_vhd << "	function init_block_parities return block_parities;" << std::endl;
	table_vhd << "	function init_block_counts return block_counts;" << std::endl;
	table_vhd << "	function init_block_offsets return block_offsets;" << std::endl;
	table_vhd << "	function init_block_shifts return block_shifts;" << std::endl;
	table_vhd << "end package;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "package body table_scalar is" << std::endl;
	table_vhd << "	function init_block_parities return block_parities is" << std::endl;
	table_vhd << "	begin" << std::endl;
	table_vhd << "		return " << parities << ";" << std::endl;
	table_vhd << "	end function;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "	function init_block_counts return block_counts is" << std::endl;
	table_vhd << "	begin" << std::endl;
	table_vhd << "		return (" << std::endl;
	for (int pty = 0; pty < parities; ++pty)
		table_vhd << counts[pty] << "," << std::endl;
	table_vhd << "		others => count_scalar'low);" << std::endl;
	table_vhd << "	end function;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "	function init_block_offsets return block_offsets is" << std::endl;
	table_vhd << "	begin" << std::endl;
	table_vhd << "		return (" << std::endl;
	for (int pty = 0, loc = 0; pty < parities; ++pty) {
		for (int num = 0; num < counts[pty]; ++num, ++loc)
			table_vhd << offsets[loc] << ",";
		table_vhd << std::endl;
	}
	table_vhd << "		others => 0);" << std::endl;
	table_vhd << "	end function;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "	function init_block_shifts return block_shifts is" << std::endl;
	table_vhd << "	begin" << std::endl;
	table_vhd << "		return (" << std::endl;
	for (int pty = 0, loc = 0; pty < parities; ++pty) {
		for (int num = 0; num < counts[pty]; ++num, ++loc)
			table_vhd << shifts[loc] << ",";
		table_vhd << std::endl;
	}
	table_vhd << "		others => 0);" << std::endl;
	table_vhd << "	end function;" << std::endl;
	table_vhd << "end package body;" << std::endl;

	return 0;
}

/*
Generate table_vector.vhd from table_vector.txt

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include "ldpc_vector.hh"

int main()
{
	int offsets[VECTOR_LOCATIONS_MAX];
	int shifts[VECTOR_LOCATIONS_MAX];
	int counts[VECTOR_PARITIES_MAX];
	int parities = 0;
	std::ifstream table_txt("table_vector.txt");
	for (int loc = 0; table_txt >> counts[parities]; ++parities) {
		for (int num = 0; num < counts[parities]; ++num, ++loc) {
			table_txt >> offsets[loc];
			table_txt.ignore(1, ':');
			table_txt >> shifts[loc];
		}
	}
	std::ofstream table_vhd("table_vector.vhd");
	table_vhd << "-- code table generated from table_vector.txt by generate_table_vector_vhd.cc" << std::endl;
	table_vhd << "--" << std::endl;
	table_vhd << "-- Copyright 2019 Ahmet Inan <inan@aicodix.de>" << std::endl;
	table_vhd << std::endl;
	table_vhd << "use work.ldpc_scalar.all;" << std::endl;
	table_vhd << "use work.ldpc_vector.all;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "package table_vector is" << std::endl;
	table_vhd << "	function init_vector_parities return vector_parities;" << std::endl;
	table_vhd << "	function init_vector_counts return vector_counts;" << std::endl;
	table_vhd << "	function init_vector_offsets return vector_offsets;" << std::endl;
	table_vhd << "	function init_vector_shifts return vector_shifts;" << std::endl;
	table_vhd << "end package;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "package body table_vector is" << std::endl;
	table_vhd << "	function init_vector_parities return vector_parities is" << std::endl;
	table_vhd << "	begin" << std::endl;
	table_vhd << "		return " << parities << ";" << std::endl;
	table_vhd << "	end function;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "	function init_vector_counts return vector_counts is" << std::endl;
	table_vhd << "	begin" << std::endl;
	table_vhd << "		return (" << std::endl;
	for (int pty = 0; pty < parities; ++pty)
		table_vhd << counts[pty] << "," << std::endl;
	table_vhd << "		others => count_scalar'low);" << std::endl;
	table_vhd << "	end function;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "	function init_vector_offsets return vector_offsets is" << std::endl;
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
	table_vhd << "	function init_vector_shifts return vector_shifts is" << std::endl;
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

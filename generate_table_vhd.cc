/*
Generate table.vhd from table.txt

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>

int main()
{
	const int VECTOR_SCALARS = 15;
	const int CODE_SCALARS = 16200;
	const int TOTAL_LINKS_MAX = 75240;
	const int LOCATIONS_MAX = TOTAL_LINKS_MAX / VECTOR_SCALARS;
	const int CODE_VECTORS = CODE_SCALARS / VECTOR_SCALARS;
	const int PARITIES_MAX = (CODE_VECTORS * 4) / 5;

	int offsets[LOCATIONS_MAX];
	int shifts[LOCATIONS_MAX];
	int counts[PARITIES_MAX];
	int parities = 0;
	std::ifstream table_txt("table.txt");
	for (int loc = 0; table_txt >> counts[parities]; ++parities) {
		for (int num = 0; num < counts[parities]; ++num, ++loc) {
			table_txt >> offsets[loc];
			table_txt.ignore(1, ':');
			table_txt >> shifts[loc];
		}
	}
	std::ofstream table_vhd("table.vhd");
	table_vhd << "-- code table generated from table.txt by generate_table_vhd.cc" << std::endl;
	table_vhd << "--" << std::endl;
	table_vhd << "-- Copyright 2019 Ahmet Inan <inan@aicodix.de>" << std::endl;
	table_vhd << std::endl;
	table_vhd << "use work.ldpc.all;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "package table is" << std::endl;
	table_vhd << "	function init_parities return parities;" << std::endl;
	table_vhd << "	function init_counts return counts;" << std::endl;
	table_vhd << "	function init_offsets return offsets;" << std::endl;
	table_vhd << "	function init_shifts return shifts;" << std::endl;
	table_vhd << "end package;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "package body table is" << std::endl;
	table_vhd << "	function init_parities return parities is" << std::endl;
	table_vhd << "	begin" << std::endl;
	table_vhd << "		return " << parities << ";" << std::endl;
	table_vhd << "	end function;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "	function init_counts return counts is" << std::endl;
	table_vhd << "	begin" << std::endl;
	table_vhd << "		return (" << std::endl;
	for (int pty = 0; pty < parities; ++pty)
		table_vhd << counts[pty] << "," << std::endl;
	table_vhd << "		others => count_scalar'low);" << std::endl;
	table_vhd << "	end function;" << std::endl;
	table_vhd << std::endl;
	table_vhd << "	function init_offsets return offsets is" << std::endl;
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
	table_vhd << "	function init_shifts return shifts is" << std::endl;
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

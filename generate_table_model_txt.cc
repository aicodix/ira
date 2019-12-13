/*
generate table_model.txt from table_input.txt

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <iostream>
#include "ldpc_vector.hh"

int main()
{
	int offsets[VECTOR_PARITIES_MAX][COUNT_MAX];
	int shifts[VECTOR_PARITIES_MAX][COUNT_MAX];
	int counts[VECTOR_PARITIES_MAX];
	int parities = 0;
	std::ifstream table_input("table_input.txt");
	for (; table_input >> counts[parities]; ++parities) {
		for (int num = 0; num < counts[parities]; ++num) {
			table_input >> offsets[parities][num];
			table_input.ignore(1, ':');
			table_input >> shifts[parities][num];
		}
	}
	std::ofstream table_model("table_model.txt");
	table_model << "max:";
	for (int line = 0; line < parities; ++line) {
		for (int pty = 0; pty < parities; ++pty) {
			int weight = counts[line] == counts[pty] ? 2 : 1;
			table_model << " +" << weight << "P" << pty << "L" << line;
		}
	}
	table_model << ";" << std::endl;

	for (int line = 0; line < parities; ++line) {
		for (int pty = 0; pty < parities; ++pty)
			table_model << " +P" << pty << "L" << line;
		table_model << " <= 1;" << std::endl;
	}

	for (int pty = 0; pty < parities; ++pty) {
		for (int line = 0; line < parities; ++line)
			table_model << " +P" << pty << "L" << line;
		table_model << " <= 1;" << std::endl;
	}

	for (int pty0 = 0; pty0 < parities; ++pty0) {
		for (int pty1 = pty0+1; pty1 < parities; ++pty1) {
			for (int num0 = 0; num0 < counts[pty0]; ++num0)
				for (int num1 = 0; num1 < counts[pty1]; ++num1)
					if (offsets[pty0][num0] == offsets[pty1][num1])
						goto found;
			continue;
			found:
			for (int line = 0; line < parities; ++line)
				table_model << "P" << pty0 << "L" << line << " + P" << pty1 << "L" << (line+1)%parities << " <= 1;" << std::endl;
			for (int line = 0; line < parities; ++line)
				table_model << "P" << pty1 << "L" << line << " + P" << pty0 << "L" << (line+1)%parities << " <= 1;" << std::endl;
		}
	}

	table_model << "int";
	for (int line = 0; line < parities; ++line)
		for (int pty = 0; pty < parities; ++pty)
			table_model << " P" << pty << "L" << line;
	table_model << ";" << std::endl;

	return 0;
}

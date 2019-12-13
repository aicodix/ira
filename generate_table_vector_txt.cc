/*
generate table_vector.txt from table_input.txt and table_solution.txt

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
	int lines[VECTOR_PARITIES_MAX];
	for (int line = 0; line < parities; ++line)
		lines[line] = -1;
	std::ifstream table_solution("table_solution.txt");
	std::string buf;
	while (getline(table_solution, buf)) {
		if (buf[0] != 'P')
			continue;
		std::string subP = buf.substr(1);
		size_t L;
		int pty = std::stoi(subP, &L);
		std::string subL = subP.substr(L+1);
		size_t V;
		int line = std::stoi(subL, &V);
		std::string subV = subL.substr(V);
		int val = std::stoi(subV);
		if (pty < 0 || pty >= parities || line < 0 || line >= parities || val < 0 || val > 1) {
			std::cerr << "parsing or bound error!" << std::endl;
			return 1;
		}
		if (val)
			lines[line] = pty;
	}
	for (int line = 0; line < parities; ++line) {
		if (lines[line] < 0) {
			std::cerr << "no solution found!" << std::endl;
			return 1;
		}
	}
	std::ofstream table_vector("table_vector.txt");
	for (int line = 0; line < parities; ++line) {
		int pty = lines[line];
		table_vector << counts[pty];
		for (int num = 0; num < counts[pty]; ++num)
			table_vector << '\t' << offsets[pty][num] << ':' << shifts[pty][num];
		table_vector << std::endl;
	}
	return 0;
}

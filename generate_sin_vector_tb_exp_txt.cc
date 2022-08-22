/*
Generate sin_vector_tb_exp.txt interleaved from sin_vector_tb_inp.txt

Copyright 2022 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <algorithm>
#include "ldpc_vector.hh"

int parities = 0;

#include "sin_vector.hh"

int main()
{
	std::ifstream table_txt("table_vector.txt");
	parities = std::count(std::istreambuf_iterator<char>(table_txt),
		std::istreambuf_iterator<char>(), '\n');
	std::ifstream soft_input("sin_vector_tb_inp.txt");
	std::ofstream soft_output("sin_vector_tb_exp.txt");
	while (soft_input.good()) {
		int soft[CODE_SCALARS], vars[CODE_VECTORS][VECTOR_SCALARS];
		for (int j = 0; j < CODE_SCALARS; ++j)
			if (!(soft_input >> soft[j]))
				return 0;
		sin_vector(vars, soft);
		for (int j = 0; j < CODE_VECTORS; ++j)
			for (int n = 0; n < VECTOR_SCALARS; ++n)
				soft_output << '\t' << vars[j][n];
		soft_output << std::endl;
	}
	return 0;
}

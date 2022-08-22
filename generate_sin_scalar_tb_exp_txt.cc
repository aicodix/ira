/*
Generate sin_scalar_tb_exp.txt interleaved from sin_scalar_tb_inp.txt

Copyright 2022 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <algorithm>
#include "ldpc_scalar.hh"

int parities = 0;

#include "sin_scalar.hh"

int main()
{
	std::ifstream table_txt("table_scalar.txt");
	parities = std::count(std::istreambuf_iterator<char>(table_txt),
		std::istreambuf_iterator<char>(), '\n');
	std::ifstream soft_input("sin_scalar_tb_inp.txt");
	std::ofstream soft_output("sin_scalar_tb_exp.txt");
	while (soft_input.good()) {
		int soft[CODE_SCALARS], vars[CODE_SCALARS];
		for (int j = 0; j < CODE_SCALARS; ++j)
			if (!(soft_input >> soft[j]))
				return 0;
		sin_scalar(vars, soft);
		for (int j = 0; j < CODE_SCALARS; ++j)
			soft_output << '\t' << vars[j];
		soft_output << std::endl;
	}
	return 0;
}

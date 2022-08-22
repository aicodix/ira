/*
Generate sde_vector_tb_exp.txt deinterleaved from sde_vector_tb_inp.txt

Copyright 2022 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <algorithm>
#include "ldpc_vector.hh"

int parities = 0;

#include "sde_vector.hh"

int main()
{
	std::ifstream table_txt("table_vector.txt");
	parities = std::count(std::istreambuf_iterator<char>(table_txt),
		std::istreambuf_iterator<char>(), '\n');
	std::ifstream soft_input("sde_vector_tb_inp.txt");
	std::ofstream soft_output("sde_vector_tb_exp.txt");
	while (soft_input.good()) {
		int soft[CODE_SCALARS], vars[CODE_VECTORS][VECTOR_SCALARS];
		for (int j = 0; j < CODE_VECTORS; ++j)
			for (int n = 0; n < VECTOR_SCALARS; ++n)
				if (!(soft_input >> vars[j][n]))
					return 0;
		sde_vector(soft, vars);
		for (int j = 0; j < CODE_SCALARS; ++j)
			soft_output << '\t' << soft[j];
		soft_output << std::endl;
	}
	return 0;
}

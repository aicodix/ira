/*
Generate dec_scalar_tb_exp.txt decoded from dec_scalar_tb_inp.txt

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include "ldpc_scalar.hh"

int offsets[BLOCK_LOCATIONS_MAX];
int shifts[BLOCK_LOCATIONS_MAX];
int counts[BLOCK_PARITIES_MAX];
int parities = 0;

#include "dec_scalar.hh"

int main()
{
	std::ifstream table_txt("table_scalar.txt");
	for (int loc = 0; table_txt >> counts[parities]; ++parities) {
		for (int num = 0; num < counts[parities]; ++num, ++loc) {
			table_txt >> offsets[loc];
			table_txt.ignore(1, ':');
			table_txt >> shifts[loc];
		}
	}
	std::ifstream soft_input("dec_scalar_tb_inp.txt");
	std::ofstream soft_output("dec_scalar_tb_exp.txt");
	while (soft_input.good()) {
		int inp[CODE_SCALARS], out[CODE_SCALARS];
		for (int j = 0; j < CODE_SCALARS; ++j)
			if (!(soft_input >> inp[j]))
				return 0;
		dec_scalar(out, inp);
		for (int j = 0; j < CODE_SCALARS; ++j)
			soft_output << '\t' << out[j];
		soft_output << std::endl;
	}
	return 0;
}

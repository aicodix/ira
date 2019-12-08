/*
Generate soft_expected.txt decoded from soft_input.txt

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <functional>
#include <random>
#include "ldpc.hh"

int offsets[LOCATIONS_MAX];
int shifts[LOCATIONS_MAX];
int counts[PARITIES_MAX];
int parities = 0;

#include "dec_reference.hh"

int main()
{
	std::ifstream table_txt("table.txt");
	for (int loc = 0; table_txt >> counts[parities]; ++parities) {
		for (int num = 0; num < counts[parities]; ++num, ++loc) {
			table_txt >> offsets[loc];
			table_txt.ignore(1, ':');
			table_txt >> shifts[loc];
		}
	}
	std::ifstream soft_input("soft_input.txt");
	std::ofstream soft_output("soft_expected.txt");
	while (soft_input.good()) {
		int inp[CODE_SCALARS], out[CODE_SCALARS];
		for (int j = 0; j < CODE_SCALARS; ++j)
			if (!(soft_input >> inp[j]))
				return 0;
		dec(out, inp);
		for (int j = 0; j < CODE_SCALARS; ++j)
			soft_output << '\t' << out[j];
		soft_output << std::endl;
	}
	return 0;
}

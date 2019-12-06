/*
Generate random noise

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <functional>
#include <random>

const int CODES = 10;
const int ITERATIONS_MAX = 25;
const int VMAG_MAX = 127;
const int CMAG_MAX = 31;
const int COUNT_MIN = 2;
const int COUNT_MAX = 27;
const int VECTOR_SCALARS = 15;
const int BLOCK_SCALARS = 360;
const int CODE_SCALARS = 16200;
const int TOTAL_LINKS_MAX = 75240;
const int LOCATIONS_MAX = TOTAL_LINKS_MAX / VECTOR_SCALARS;
const int CODE_VECTORS = CODE_SCALARS / VECTOR_SCALARS;
const int CODE_BLOCKS = CODE_SCALARS / BLOCK_SCALARS;
const int BLOCK_VECTORS = BLOCK_SCALARS / VECTOR_SCALARS;
const int PARITIES_MAX = (CODE_VECTORS * 4) / 5;
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
	std::random_device rd;
	std::default_random_engine generator(rd());
	typedef std::uniform_int_distribution<int> uniform;
	auto input = std::bind(uniform(-128, 127), generator);
	std::ofstream soft_input("soft_input.txt");
	std::ofstream soft_output("soft_expected.txt");
	for (int i = 0; i < CODES; ++i) {
		int inp[CODE_SCALARS], out[CODE_SCALARS];
		for (int j = 0; j < CODE_SCALARS; ++j)
			soft_input << '\t' << (inp[j] = input());
		soft_input << std::endl;
		dec(out, inp);
		for (int j = 0; j < CODE_SCALARS; ++j)
			soft_output << '\t' << out[j];
		soft_output << std::endl;
	}
	return 0;
}

/*
Generate cnp_scalar_tb_inp.txt from random noise

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <functional>
#include <random>
#include "ldpc_scalar.hh"

int main()
{
	std::random_device rd;
	std::default_random_engine generator(rd());
	typedef std::uniform_int_distribution<int> uniform;
	auto count = std::bind(uniform(COUNT_MIN, COUNT_MAX), generator);
	auto sequence = std::bind(uniform(0, ITERATIONS_MAX-1), generator);
	auto input = std::bind(uniform(-VMAG_MAX, VMAG_MAX), generator);
	auto offset = std::bind(uniform(0, CODE_SCALARS-1), generator);
	auto location = std::bind(uniform(0, SCALAR_LOCATIONS_MAX-1), generator);

	std::ofstream scalar_input("cnp_scalar_tb_inp.txt");

	for (int i = 0; i < 100; ++i) {
		int cnt = count();
		int seq = sequence();
		scalar_input << cnt << '\t' << seq;
		for (int j = 0; j < cnt; ++j)
			scalar_input << '\t' << location() << '\t' << offset() << '\t' << input();
		scalar_input << std::endl;
	}
	return 0;
}

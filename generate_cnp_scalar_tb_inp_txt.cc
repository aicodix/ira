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
	typedef std::default_random_engine generator;
	typedef std::uniform_int_distribution<int> uniform;
	auto count = std::bind(uniform(COUNT_MIN, COUNT_MAX), generator(rd()));
	auto sequence = std::bind(uniform(0, ITERATIONS_MAX-1), generator(rd()));
	auto input = std::bind(uniform(-VMAG_MAX, VMAG_MAX), generator(rd()));
	auto previous = std::bind(uniform(-CMAG_MAX, CMAG_MAX), generator(rd()));
	auto wd_flag = std::bind(uniform(0, 1), generator(rd()));
	auto offset = std::bind(uniform(0, CODE_SCALARS-1), generator(rd()));
	auto location = std::bind(uniform(0, SCALAR_LOCATIONS_MAX-1), generator(rd()));

	std::ofstream scalar_input("cnp_scalar_tb_inp.txt");

	for (int i = 0; i < 100; ++i) {
		int cnt = count();
		int seq = sequence();
		scalar_input << cnt << '\t' << seq;
		for (int j = 0; j < cnt; ++j) {
			scalar_input << '\t' << (wd_flag() ? "TRUE" : "FALSE");
			scalar_input << '\t' << location();
			scalar_input << '\t' << offset();
			scalar_input << '\t' << input();
			scalar_input << '\t' << previous();
		}
		scalar_input << std::endl;
	}
	return 0;
}

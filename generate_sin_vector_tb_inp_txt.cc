/*
Generate sin_vector_tb_inp.txt from random noise

Copyright 2022 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <functional>
#include <random>
#include "ldpc_vector.hh"

int main()
{
	std::random_device rd;
	typedef std::default_random_engine generator;
	typedef std::uniform_int_distribution<int> uniform;
	auto input = std::bind(uniform(SOFT_MIN, SOFT_MAX), generator(rd()));
	std::ofstream soft_input("sin_vector_tb_inp.txt");
	for (int i = 0; i < 10; ++i) {
		for (int j = 0; j < CODE_SCALARS; ++j)
			soft_input << '\t' << input();
		soft_input << std::endl;
	}
	return 0;
}


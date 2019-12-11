/*
Generate dec_scalar_tb_exp.txt processed from dec_scalar_tb_inp.txt

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <functional>
#include <random>
#include "ldpc_scalar.hh"
#include "cnp_reference.hh"

int main()
{
	std::ifstream scalar_input("cnp_scalar_tb_inp.txt");
	std::ofstream scalar_output("cnp_scalar_tb_exp.txt");

	for (int cnt; scalar_input >> cnt;) {
		int seq;
		scalar_input >> seq;
		int loc[COUNT_MAX];
		int off[COUNT_MAX];
		int inp[COUNT_MAX];
		for (int j = 0; j < cnt; ++j) {
			scalar_input >> loc[j];
			scalar_input >> off[j];
			scalar_input >> inp[j];
		}
		int out[COUNT_MAX];
		cnp(out, inp, cnt, 1);
		scalar_output << seq;
		for (int j = 0; j < cnt; ++j) {
			scalar_output << '\t' << loc[j];
			scalar_output << '\t' << off[j];
			scalar_output << '\t' << out[j];
		}
		scalar_output << std::endl;
	}
	return 0;
}

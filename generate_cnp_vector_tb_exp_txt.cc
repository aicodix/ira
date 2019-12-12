/*
Generate dec_vector_tb_exp.txt processed from dec_vector_tb_inp.txt

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <functional>
#include <random>
#include "ldpc_vector.hh"
#include "cnp_vector.hh"

int main()
{
	std::ifstream vector_input("cnp_vector_tb_inp.txt");
	std::ofstream vector_output("cnp_vector_tb_exp.txt");

	for (int cnt; vector_input >> cnt;) {
		int seq;
		vector_input >> seq;
		int inp[COUNT_MAX][VECTOR_SCALARS];
		int wdf[COUNT_MAX], loc[COUNT_MAX];
		int off[COUNT_MAX], shi[COUNT_MAX];
		for (int j = 0; j < cnt; ++j) {
			char chr;
			vector_input >> chr;
			wdf[j] = chr == 'T';
			vector_input.ignore(4, 'E');
			vector_input >> loc[j];
			vector_input >> off[j];
			vector_input.ignore(1, ':');
			vector_input >> shi[j];
			for (int k = 0; k < VECTOR_SCALARS; ++k)
				vector_input >> inp[j][k];
		}
		int out[COUNT_MAX][VECTOR_SCALARS];
		cnp_vector(out, inp, cnt, 1);
		for (int j = 0; j < cnt; ++j) {
			vector_output << seq << '\t';
			vector_output << (wdf[j] ? "TRUE" : "FALSE") << '\t';
			vector_output << loc[j] << '\t';
			vector_output << off[j] << ':' << shi[j];
			for (int k = 0; k < VECTOR_SCALARS; ++k)
				vector_output << '\t' << out[j][k];
			vector_output << std::endl;
		}
	}
	return 0;
}

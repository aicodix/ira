/*
Generate dec_expected.txt processed from dec_input.txt

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <functional>
#include <random>
#include "ldpc.hh"
#include "cnp_reference.hh"

int main()
{
	std::ifstream vector_input("cnp_input.txt");
	std::ofstream vector_output("cnp_expected.txt");

	for (int cnt; vector_input >> cnt;) {
		int seq;
		vector_input >> seq;
		int inp[COUNT_MAX*VECTOR_SCALARS];
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
				vector_input >> inp[COUNT_MAX*k+j];
		}
		int out[COUNT_MAX*VECTOR_SCALARS];
		for (int k = 0; k < VECTOR_SCALARS; ++k)
			cnp(out+COUNT_MAX*k, inp+COUNT_MAX*k, cnt, 1);
		for (int j = 0; j < cnt; ++j) {
			vector_output << seq << '\t';
			vector_output << (wdf[j] ? "TRUE" : "FALSE") << '\t';
			vector_output << loc[j] << '\t';
			vector_output << off[j] << ':' << shi[j];
			for (int k = 0; k < VECTOR_SCALARS; ++k)
				vector_output << '\t' << out[COUNT_MAX*k+j];
			vector_output << std::endl;
		}
	}
	return 0;
}

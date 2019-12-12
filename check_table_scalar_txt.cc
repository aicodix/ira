/*
check table_scalar.txt for data hazards

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#include <fstream>
#include <iostream>
#include "ldpc_scalar.hh"

int main()
{
	int offsets[SCALAR_PARITIES_MAX][COUNT_MAX];
	int counts[SCALAR_PARITIES_MAX];
	int parities = 0;
	std::ifstream table_txt("table_scalar.txt");
	for (; table_txt >> counts[parities]; ++parities)
		for (int num = 0; num < counts[parities]; ++num)
			table_txt >> offsets[parities][num];
	int violations = 0;
	for (int pty = 0; pty < parities; ++pty) {
		for (int num0 = 0; num0 < counts[pty]; ++num0) {
			for (int num1 = num0+1; num1 < counts[pty]; ++num1) {
				if (offsets[pty][num0] == offsets[pty][num1]) {
					std::cout << "parity " << pty << " has duplicate location offsets " << offsets[pty][num0] << std::endl;
					++violations;
				}
			}
		}
	}
	for (int pty0 = 0; pty0 < parities; ++pty0) {
		int pty1 = (pty0 + 1) % parities;
		for (int num0 = 0; num0 < counts[pty0]; ++num0) {
			for (int num1 = 0; num1 < counts[pty1]; ++num1) {
				if (offsets[pty0][num0] == offsets[pty1][num1]) {
					std::cout << "consecutive parities " << pty0 << " and " << pty1 << " have same location offset " << offsets[pty0][num0] << std::endl;
					++violations;
				}
			}
		}
	}
	if (violations)
		std::cout << violations;
	else
		std::cout << "no";
	std::cout << " violations detected." << std::endl;
	return !!violations;
}

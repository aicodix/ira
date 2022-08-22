/*
scalar soft input interleaver reference code

Copyright 2022 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

void sin_scalar(int *vars, const int *soft)
{
	int messages = CODE_SCALARS - BLOCK_SCALARS * parities;
	for (int i = 0; i < messages; ++i)
		vars[i] = soft[i];
	for (int i = 0; i < parities; ++i)
		for (int j = 0; j < BLOCK_SCALARS; ++j)
			vars[messages+BLOCK_SCALARS*i+j] = soft[messages+parities*j+i];
}


/*
scalar soft output deinterleaver reference code

Copyright 2022 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

void sde_scalar(int *soft, const int *vars)
{
	int messages = CODE_SCALARS - BLOCK_SCALARS * parities;
	for (int i = 0; i < messages; ++i)
		soft[i] = vars[i];
	for (int i = 0; i < parities; ++i)
		for (int j = 0; j < BLOCK_SCALARS; ++j)
			soft[messages+parities*j+i] = vars[messages+BLOCK_SCALARS*i+j];
}


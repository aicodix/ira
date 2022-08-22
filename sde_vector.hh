/*
vector soft output deinterleaver reference code

Copyright 2022 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

void sde_vector(int *soft, const int vars[][VECTOR_SCALARS])
{
	int q = parities / BLOCK_VECTORS;
	for (int i = 0; i < CODE_BLOCKS - q; ++i)
		for (int j = 0; j < BLOCK_VECTORS; ++j)
			for (int n = 0; n < VECTOR_SCALARS; ++n)
				soft[BLOCK_SCALARS*i+BLOCK_VECTORS*n+j] = vars[BLOCK_VECTORS*i+j][n];
	int R = parities * VECTOR_SCALARS;
	int K = CODE_SCALARS - R;
	int messages = CODE_VECTORS - parities;
	for (int i = 0; i < q; ++i)
		for (int j = 0; j < BLOCK_VECTORS; ++j)
			for (int n = 0; n < VECTOR_SCALARS; ++n)
				soft[K+q*(BLOCK_VECTORS*n+j)+i] = vars[messages+BLOCK_VECTORS*i+j][n];
}


/*
vector soft input interleaver reference code

Copyright 2022 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

void sin_vector(int vars[][VECTOR_SCALARS], const int *soft)
{
	int q = parities / BLOCK_VECTORS;
	for (int i = 0; i < CODE_BLOCKS - q; ++i)
		for (int j = 0; j < BLOCK_VECTORS; ++j)
			for (int n = 0; n < VECTOR_SCALARS; ++n)
				vars[BLOCK_VECTORS*i+j][n] = soft[BLOCK_SCALARS*i+BLOCK_VECTORS*n+j];
	int R = parities * VECTOR_SCALARS;
	int K = CODE_SCALARS - R;
	int messages = CODE_VECTORS - parities;
	for (int i = 0; i < q; ++i)
		for (int j = 0; j < BLOCK_VECTORS; ++j)
			for (int n = 0; n < VECTOR_SCALARS; ++n)
				vars[messages+BLOCK_VECTORS*i+j][n] = soft[K+q*(BLOCK_VECTORS*n+j)+i];
}


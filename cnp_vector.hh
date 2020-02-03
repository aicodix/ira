/*
vector check node processor reference code

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

#include "cnp_scalar.hh"

void cnp_vector(int (*output)[VECTOR_SCALARS], const int (*input)[VECTOR_SCALARS], const int (*prev)[VECTOR_SCALARS], int cnt, int beta)
{
	for (int i = 0; i < VECTOR_SCALARS; ++i) {
		int inp[COUNT_MAX], out[COUNT_MAX], prv[COUNT_MAX];
		for (int n = 0; n < cnt; ++n)
			inp[n] = input[n][i];
		for (int n = 0; n < cnt; ++n)
			prv[n] = prev[n][i];
		cnp_scalar(out, inp, prv, cnt, beta);
		for (int n = 0; n < cnt; ++n)
			output[n][i] = out[n];
	}
}


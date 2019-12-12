/*
scalar IRA-LDPC decoder reference code

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

#include "cnp_scalar.hh"

int add_scalar(int a, int b)
{
	return min_scalar(max_scalar(a + b, -VMAG_MAX), VMAG_MAX);
}
int sub_scalar(int a, int b)
{
	return min_scalar(max_scalar(a - b, -VMAG_MAX), VMAG_MAX);
}
void dec_scalar(int *output, const int *input)
{
	int vars[CODE_SCALARS];
	int messages = CODE_SCALARS - parities;
	for (int i = 0; i < messages; ++i)
		vars[i] = min_scalar(max_scalar(input[i], -VMAG_MAX), VMAG_MAX);
	int q = parities / BLOCK_SCALARS;
	for (int i = 0; i < q; ++i)
		for (int j = 0; j < BLOCK_SCALARS; ++j)
			vars[messages+BLOCK_SCALARS*i+j] = min_scalar(max_scalar(input[messages+q*j+i], -VMAG_MAX), VMAG_MAX);
	int bnls[SCALAR_LOCATIONS_MAX];
	for (int seq = 0; seq < ITERATIONS_MAX; ++seq) {
		int loc = 0;
		for (int pty = 0; pty < parities; ++pty) {
			int cnt = counts[pty];
			int *off = offsets + loc;
			int *bnl = bnls + loc;
			int tmp[COUNT_MAX];
			int inp[COUNT_MAX];
			for (int num = 0; num < cnt; ++num) {
				tmp[num] = vars[off[num]];
				if (seq)
					inp[num] = sub_scalar(tmp[num], bnl[num]);
				else
					inp[num] = tmp[num];
			}
			int out[COUNT_MAX];
			cnp_scalar(out, inp, cnt, 1);
			for (int num = 0; num < cnt; ++num) {
				tmp[num] = add_scalar(inp[num], out[num]);
				bnl[num] = out[num];
				vars[off[num]] = tmp[num];
			}
			loc += cnt;
		}
	}
	for (int i = 0; i < messages; ++i)
		output[i] = vars[i];
	for (int i = 0; i < q; ++i)
		for (int j = 0; j < BLOCK_SCALARS; ++j)
			output[messages+q*j+i] = vars[messages+BLOCK_SCALARS*i+j];
}


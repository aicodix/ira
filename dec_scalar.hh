/*
scalar IRA-LDPC decoder reference code

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

#include <iostream>
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
	int messages = CODE_SCALARS - BLOCK_SCALARS * parities;
	for (int i = 0; i < messages; ++i)
		vars[i] = min_scalar(max_scalar(input[i], -VMAG_MAX), VMAG_MAX);
	for (int i = 0; i < parities; ++i)
		for (int j = 0; j < BLOCK_SCALARS; ++j)
			vars[messages+BLOCK_SCALARS*i+j] = min_scalar(max_scalar(input[messages+parities*j+i], -VMAG_MAX), VMAG_MAX);
	int bnls[SCALAR_LOCATIONS_MAX] = { 0 };
	for (int seq = 0; seq < ITERATIONS_MAX; ++seq) {
		int loc = 0, blk = 0;
		for (int pty = 0; pty < parities; ++pty) {
			int cnt = counts[pty];
			for (int bs = 0; bs < BLOCK_SCALARS; ++bs) {
				int *bnl = bnls + loc;
				int wdf[COUNT_MAX];
				int off[COUNT_MAX];
				int inp[COUNT_MAX];
				for (int num = 0; num < cnt; ++num) {
					wdf[num] = !bs && offsets[blk+num] == CODE_BLOCKS-1 && shifts[blk+num] == BLOCK_SCALARS-1;
					off[num] = BLOCK_SCALARS * offsets[blk+num] + (shifts[blk+num] + bs) % BLOCK_SCALARS;
					inp[num] = sub_scalar(vars[off[num]], bnl[num]);
					if (wdf[num])
						inp[num] = VMAG_MAX;
				}
				int out[COUNT_MAX];
				cnp_scalar(out, inp, bnl, cnt, 1);
				for (int num = 0; num < cnt; ++num) {
					bnl[num] = out[num];
					if (!wdf[num])
						vars[off[num]] = add_scalar(inp[num], out[num]);
				}
				loc += cnt;
			}
			blk += cnt;
		}
	}
	for (int i = 0; i < messages; ++i)
		output[i] = vars[i];
	for (int i = 0; i < parities; ++i)
		for (int j = 0; j < BLOCK_SCALARS; ++j)
			output[messages+parities*j+i] = vars[messages+BLOCK_SCALARS*i+j];
}


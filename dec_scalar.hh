/*
scalar IRA-LDPC decoder reference code

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

#include "cnp_scalar.hh"

int add_scalar(int a, int b)
{
	return clamp_scalar(a + b, -VMAG_MAX, VMAG_MAX);
}
int sub_scalar(int a, int b)
{
	return clamp_scalar(a - b, -VMAG_MAX, VMAG_MAX);
}
void dec_scalar(int *vars)
{
	for (int j = 0; j < CODE_SCALARS; ++j)
		vars[j] = clamp_scalar(vars[j], -VMAG_MAX, VMAG_MAX);
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
}


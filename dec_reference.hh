/*
IRA-LDPC decoder reference code

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

#include "cnp_reference.hh"

void nul(int *output)
{
	for (int i = 0; i < VECTOR_SCALARS; ++i)
		output[i] = 0;
}
void cpy(int *output, const int *input)
{
	for (int i = 0; i < VECTOR_SCALARS; ++i)
		output[i] = input[i];
}
void rot(int *output, const int *input, int shift)
{
	for (int i = 0; i < VECTOR_SCALARS; ++i)
		output[(i + shift + VECTOR_SCALARS) % VECTOR_SCALARS] = input[i];
}
void add(int *o, const int *a, const int *b)
{
	for (int i = 0; i < VECTOR_SCALARS; ++i)
		o[i] = min(max(a[i] + b[i], -VMAG_MAX), VMAG_MAX);
}
void sub(int *o, const int *a, const int *b)
{
	for (int i = 0; i < VECTOR_SCALARS; ++i)
		o[i] = min(max(a[i] - b[i], -VMAG_MAX), VMAG_MAX);
}
void cnp(int (*output)[VECTOR_SCALARS], const int (*input)[VECTOR_SCALARS], int cnt, int beta)
{
	for (int i = 0; i < VECTOR_SCALARS; ++i) {
		int inp[COUNT_MAX], out[COUNT_MAX];
		for (int n = 0; n < cnt; ++n)
			inp[n] = input[n][i];
		cnp(out, inp, cnt, beta);
		for (int n = 0; n < cnt; ++n)
			output[n][i] = out[n];
	}
}
void dec(int *output, const int *input)
{
	int vars[CODE_VECTORS][VECTOR_SCALARS];
	for (int i = 0; i < CODE_BLOCKS; ++i)
		for (int j = 0; j < BLOCK_VECTORS; ++j)
			for (int n = 0; n < VECTOR_SCALARS; ++n)
				vars[BLOCK_VECTORS*i+j][n] = min(max(input[BLOCK_SCALARS*i+BLOCK_VECTORS*n+j], -VMAG_MAX), VMAG_MAX);
	int wd_flags[LOCATIONS_MAX];
	int bnls[LOCATIONS_MAX][VECTOR_SCALARS];
	for (int seq = 0; seq < ITERATIONS_MAX; ++seq) {
		int loc = 0;
		for (int pty = 0; pty < parities; ++pty) {
			int cnt = counts[pty];
			int *off = offsets + loc;
			int *shi = shifts + loc;
			int *wdf = wd_flags + loc;
			int (*bnl)[VECTOR_SCALARS] = bnls + loc;
			int tmp[COUNT_MAX][VECTOR_SCALARS];
			int inp[COUNT_MAX][VECTOR_SCALARS];
			int prev_val;
			for (int num = 0; num < cnt; ++num) {
				if (!seq) {
					if (num)
						wdf[num] = off[num-1] == off[num];
					else
						wdf[num] = 0;
				}
				rot(tmp[num], vars[off[num]], shi[num]);
				if (off[num] == CODE_VECTORS-1 && shi[num] == 1) {
					prev_val = tmp[num][0];
					tmp[num][0] = VMAG_MAX;
				}
				if (seq)
					sub(inp[num], tmp[num], bnl[num]);
				else
					cpy(inp[num], tmp[num]);
			}
			int out[COUNT_MAX][VECTOR_SCALARS];
			cnp(out, inp, cnt, 1);
			int first_wdf;
			for (int num = 0; num < cnt; ++num) {
				add(tmp[num], inp[num], out[num]);
				if (off[num] == CODE_VECTORS-1 && shi[num] == 1)
					tmp[num][0] = prev_val;
				if (!wdf[num]) {
					cpy(bnl[num], out[num]);
					rot(vars[off[num]], tmp[num], -shi[num]);
				} else if (!seq) {
					nul(bnl[num]);
				}
				if (num) {
					if (off[num-1] == off[num]) {
						wdf[num-1] = wdf[num];
					} else {
						wdf[num-1] = first_wdf;
						first_wdf = wdf[num];
					}
				} else {
					first_wdf = wdf[num];
				}
			}
			wdf[cnt-1] = first_wdf;
			loc += cnt;
		}
	}
	for (int i = 0; i < CODE_BLOCKS; ++i)
		for (int j = 0; j < BLOCK_VECTORS; ++j)
			for (int n = 0; n < VECTOR_SCALARS; ++n)
				output[BLOCK_SCALARS*i+BLOCK_VECTORS*n+j] = vars[BLOCK_VECTORS*i+j][n];
}


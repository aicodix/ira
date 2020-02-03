/*
scalar check node processor reference code

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

#include "exclusive_reduce.hh"

int abs_scalar(int a)
{
	if (a < 0)
		return -a;
	return a;
}
int sgn_scalar(int a)
{
	if (a < 0)
		return -1;
	return 1;
}
int min_scalar(int a, int b)
{
	if (a < b)
		return a;
	return b;
}
int max_scalar(int a, int b)
{
	if (a > b)
		return a;
	return b;
}
int mul_scalar(int a, int b)
{
	return a * b;
}
int self_corr(int a, int b)
{
	return (a == 0 || (a < 0) == (b < 0)) ? b : 0;
}
void cnp_scalar(int *output, const int *input, const int *prev, int cnt, int beta)
{
	int imags[cnt];
	for (int i = 0; i < cnt; ++i)
		imags[i] = min_scalar(max_scalar(abs_scalar(input[i]) - beta, 0), CMAG_MAX);

	int omags[cnt];
	CODE::exclusive_reduce(imags, omags, cnt, min_scalar);

	int isgns[cnt];
	for (int i = 0; i < cnt; ++i)
		isgns[i] = sgn_scalar(input[i]);

	int osgns[cnt];
	CODE::exclusive_reduce(isgns, osgns, cnt, mul_scalar);

	for (int i = 0; i < cnt; ++i)
		output[i] = self_corr(prev[i], osgns[i] * omags[i]);
}

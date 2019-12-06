/*
Check node processor reference code

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

#include "exclusive_reduce.hh"

int abs(int a)
{
	if (a < 0)
		return -a;
	return a;
}
int sgn(int a)
{
	if (a < 0)
		return -1;
	return 1;
}
int min(int a, int b)
{
	if (a < b)
		return a;
	return b;
}
int max(int a, int b)
{
	if (a > b)
		return a;
	return b;
}
int mul(int a, int b)
{
	return a * b;
}
void cnp(int *output, const int *input, int cnt, int beta)
{
	int imags[cnt];
	for (int i = 0; i < cnt; ++i)
		imags[i] = min(max(abs(input[i]) - beta, 0), CMAG_MAX);

	int omags[cnt];
	CODE::exclusive_reduce(imags, omags, cnt, min);

	int isgns[cnt];
	for (int i = 0; i < cnt; ++i)
		isgns[i] = sgn(input[i]);

	int osgns[cnt];
	CODE::exclusive_reduce(isgns, osgns, cnt, mul);

	for (int i = 0; i < cnt; ++i)
		output[i] = osgns[i] * omags[i];
}

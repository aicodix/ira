/*
vector LDPC decoder configuration

Copyright 2019 Ahmet Inan <inan@aicodix.de>
*/

#pragma once

const int VECTOR_SCALARS = 15;
const int VECTOR_LOCATIONS_MAX = (TOTAL_LINKS_MAX+1) / VECTOR_SCALARS;
const int CODE_VECTORS = CODE_SCALARS / VECTOR_SCALARS;
const int BLOCK_VECTORS = BLOCK_SCALARS / VECTOR_SCALARS;
const int VECTOR_PARITIES_MAX = SCALAR_PARITIES_MAX / VECTOR_SCALARS;


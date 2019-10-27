-- LDPC decoder configuration
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

package ldpc is
	constant iterations_max : positive := 25;
	constant code_scalars : positive := 16200;
	constant block_scalars : positive := 360;
	constant vector_scalars : positive := 15;
	constant code_vectors : positive := code_scalars / vector_scalars;
	constant code_blocks : positive := code_scalars / block_scalars;
	constant block_vectors : positive := block_scalars / vector_scalars;
	constant degree_max : positive := 27;
	constant total_links_max : positive := 75240;
	constant locations_max : positive := total_links_max / vector_scalars;
	constant parities_min : positive := code_vectors / 9;
	constant parities_max : positive := (code_vectors * 4) / 5;
	subtype soft_scalar is integer range -128 to 127;
	subtype mag_scalar is natural range 0 to 31;
	subtype count_scalar is positive range 2 to degree_max;
	subtype sequence_scalar is natural range 0 to iterations_max-1;
	subtype location_scalar is natural range 0 to locations_max-1;
	subtype offset_scalar is natural range 0 to code_vectors-1;
	subtype shift_scalar is natural range 0 to vector_scalars-1;
	type soft_vector is array (0 to vector_scalars-1) of soft_scalar;
	type sgn_vector is array (0 to vector_scalars-1) of boolean;
	type mag_vector is array (0 to vector_scalars-1) of mag_scalar;
end package;


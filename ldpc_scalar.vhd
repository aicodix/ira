-- scalar LDPC decoder configuration
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

package ldpc_scalar is
	constant iterations_max : positive := 25;
	constant code_scalars : positive := 16200;
	constant block_scalars : positive := 360;
	constant code_blocks : positive := code_scalars / block_scalars;
	constant degree_max : positive := 27;
	constant total_links_max : positive := 75239;
	constant scalar_locations_max : positive := total_links_max;
	constant scalar_parities_min : positive := code_scalars / 9;
	constant scalar_parities_max : positive := (code_scalars * 4) / 5;
	constant scalar_messages_min : positive := code_scalars - scalar_parities_max;
	constant scalar_messages_max : positive := code_scalars - scalar_parities_min;
	subtype scalar_location is natural range 0 to scalar_locations_max-1;
	subtype scalar_offset is natural range 0 to code_scalars-1;
	subtype scalar_parities is positive range scalar_parities_min to scalar_parities_max;
	subtype scalar_messages is positive range scalar_messages_min to scalar_messages_max;
	subtype soft_scalar is integer range -128 to 127;
	subtype cmag_scalar is natural range 0 to 31;
	subtype vmag_scalar is natural range 0 to 127;
	subtype count_scalar is positive range 2 to degree_max;
	subtype sequence_scalar is natural range 0 to iterations_max-1;
	type scalar_counts is array (0 to scalar_parities_max-1) of count_scalar;
	type scalar_offsets is array (0 to scalar_locations_max-1) of scalar_offset;
	type vsft_scalar is record
		sgn : boolean;
		mag : vmag_scalar;
	end record;
	type csft_scalar is record
		sgn : boolean;
		mag : cmag_scalar;
	end record;
	function soft_to_vsft (val : soft_scalar) return vsft_scalar;
	function csft_to_soft (val : csft_scalar) return soft_scalar;
	function vsft_to_soft (val : vsft_scalar) return soft_scalar;
end package;

package body ldpc_scalar is
	function soft_to_vsft (val : soft_scalar) return vsft_scalar is
		variable tmp : vsft_scalar;
	begin
		tmp.sgn := val < 0;
		if abs(val) > vmag_scalar'high then
			tmp.mag := vmag_scalar'high;
		else
			tmp.mag := abs(val);
		end if;
		return tmp;
	end function;

	function csft_to_soft (val : csft_scalar) return soft_scalar is
	begin
		if val.sgn then
			return -val.mag;
		else
			return val.mag;
		end if;
	end function;

	function vsft_to_soft (val : vsft_scalar) return soft_scalar is
	begin
		if val.sgn then
			return -val.mag;
		else
			return val.mag;
		end if;
	end function;
end package body;


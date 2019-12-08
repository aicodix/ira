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
	constant messages_min : positive := code_vectors - parities_max;
	constant messages_max : positive := code_vectors - parities_min;
	subtype soft_scalar is integer range -128 to 127;
	subtype cmag_scalar is natural range 0 to 31;
	subtype vmag_scalar is natural range 0 to 127;
	subtype count_scalar is positive range 2 to degree_max;
	subtype sequence_scalar is natural range 0 to iterations_max-1;
	subtype location_scalar is natural range 0 to locations_max-1;
	subtype offset_scalar is natural range 0 to code_vectors-1;
	subtype shift_scalar is natural range 0 to vector_scalars-1;
	subtype parities is positive range parities_min to parities_max;
	subtype messages is positive range messages_min to messages_max;
	type counts is array (0 to parities_max-1) of count_scalar;
	type offsets is array (0 to locations_max-1) of offset_scalar;
	type shifts is array (0 to locations_max-1) of shift_scalar;
	type soft_vector is array (0 to vector_scalars-1) of soft_scalar;
	type sign_vector is array (0 to vector_scalars-1) of boolean;
	type cmag_vector is array (0 to vector_scalars-1) of cmag_scalar;
	type vmag_vector is array (0 to vector_scalars-1) of vmag_scalar;
	type vsft_scalar is record
		sgn : boolean;
		mag : vmag_scalar;
	end record;
	type csft_scalar is record
		sgn : boolean;
		mag : cmag_scalar;
	end record;
	type vsft_vector is array (0 to vector_scalars-1) of vsft_scalar;
	type csft_vector is array (0 to vector_scalars-1) of csft_scalar;
	function soft_to_vsft (val : soft_scalar) return vsft_scalar;
	function csft_to_soft (val : csft_scalar) return soft_scalar;
	function vsft_to_soft (val : vsft_scalar) return soft_scalar;
	function soft_to_vsft (val : soft_vector) return vsft_vector;
	function csft_to_soft (val : csft_vector) return soft_vector;
	function vsft_to_soft (val : vsft_vector) return soft_vector;
	function sign_of_vsft (val : vsft_vector) return sign_vector;
	function vmag_of_vsft (val : vsft_vector) return vmag_vector;
	function sign_and_cmag_to_csft (sgn : sign_vector; mag : cmag_vector) return csft_vector;
end package;

package body ldpc is
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

	function soft_to_vsft (val : soft_vector) return vsft_vector is
		variable tmp : vsft_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := soft_to_vsft(val(idx));
		end loop;
		return tmp;
	end function;

	function csft_to_soft (val : csft_vector) return soft_vector is
		variable tmp : soft_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := csft_to_soft(val(idx));
		end loop;
		return tmp;
	end function;

	function vsft_to_soft (val : vsft_vector) return soft_vector is
		variable tmp : soft_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := vsft_to_soft(val(idx));
		end loop;
		return tmp;
	end function;

	function sign_of_vsft (val : vsft_vector) return sign_vector is
		variable tmp : sign_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := val(idx).sgn;
		end loop;
		return tmp;
	end function;

	function vmag_of_vsft (val : vsft_vector) return vmag_vector is
		variable tmp : vmag_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := val(idx).mag;
		end loop;
		return tmp;
	end function;

	function sign_and_cmag_to_csft (sgn : sign_vector; mag : cmag_vector) return csft_vector is
		variable tmp : csft_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := (sgn(idx), mag(idx));
		end loop;
		return tmp;
	end function;
end package body;


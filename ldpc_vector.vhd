-- vector LDPC decoder configuration
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

use work.ldpc_scalar.all;

package ldpc_vector is
	constant vector_scalars : positive := 15;
	constant code_vectors : positive := code_scalars / vector_scalars;
	constant block_vectors : positive := block_scalars / vector_scalars;
	constant vector_locations_max : positive := (total_links_max+1) / vector_scalars;
	constant vector_parities_min : positive := scalar_parities_min / vector_scalars;
	constant vector_parities_max : positive := scalar_parities_max / vector_scalars;
	constant vector_messages_min : positive := scalar_messages_min / vector_scalars;
	constant vector_messages_max : positive := scalar_messages_max / vector_scalars;
	subtype vector_location is natural range 0 to vector_locations_max-1;
	subtype vector_offset is natural range 0 to code_vectors-1;
	subtype vector_shift is natural range 0 to vector_scalars-1;
	subtype vector_parities is positive range vector_parities_min to vector_parities_max;
	subtype vector_messages is positive range vector_messages_min to vector_messages_max;
	type vector_counts is array (0 to vector_parities_max-1) of count_scalar;
	type vector_offsets is array (0 to vector_locations_max-1) of vector_offset;
	type vector_shifts is array (0 to vector_locations_max-1) of vector_shift;
	type soft_vector is array (0 to vector_scalars-1) of soft_scalar;
	type bool_vector is array (0 to vector_scalars-1) of boolean;
	type cmag_vector is array (0 to vector_scalars-1) of cmag_scalar;
	type vmag_vector is array (0 to vector_scalars-1) of vmag_scalar;
	type vsft_vector is array (0 to vector_scalars-1) of vsft_scalar;
	type csft_vector is array (0 to vector_scalars-1) of csft_scalar;
	type two_min_vector is array (0 to vector_scalars-1) of two_min_scalar;
	function soft_to_vsft (val : soft_vector) return vsft_vector;
	function soft_to_csft (val : soft_vector) return csft_vector;
	function csft_to_soft (val : csft_vector) return soft_vector;
	function vsft_to_soft (val : vsft_vector) return soft_vector;
	function sign_of_vsft (val : vsft_vector) return bool_vector;
	function vmag_of_vsft (val : vsft_vector) return vmag_vector;
	function sign_and_cmag_to_csft (sgn : bool_vector; mag : cmag_vector) return csft_vector;
	function min_sum (val : vmag_vector) return cmag_vector;
	function select_other (mag : cmag_vector; min : two_min_vector) return cmag_vector;
	function two_min (mag : cmag_vector; min : two_min_vector) return two_min_vector;
	function self_corr (prv, nxt : csft_vector) return csft_vector;
	function index_to_mask (enable : boolean; index : vector_shift) return bool_vector;
end package;

package body ldpc_vector is
	function soft_to_vsft (val : soft_vector) return vsft_vector is
		variable tmp : vsft_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := soft_to_vsft(val(idx));
		end loop;
		return tmp;
	end function;

	function soft_to_csft (val : soft_vector) return csft_vector is
		variable tmp : csft_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := soft_to_csft(val(idx));
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

	function sign_of_vsft (val : vsft_vector) return bool_vector is
		variable tmp : bool_vector;
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

	function sign_and_cmag_to_csft (sgn : bool_vector; mag : cmag_vector) return csft_vector is
		variable tmp : csft_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := (sgn(idx), mag(idx));
		end loop;
		return tmp;
	end function;

	function min_sum (val : vmag_vector) return cmag_vector is
		variable tmp : cmag_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := min_sum(val(idx));
		end loop;
		return tmp;
	end function;

	function select_other (mag : cmag_vector; min : two_min_vector) return cmag_vector is
		variable tmp : cmag_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := select_other(mag(idx), min(idx));
		end loop;
		return tmp;
	end function;

	function two_min (mag : cmag_vector; min : two_min_vector) return two_min_vector is
		variable tmp : two_min_vector;
	begin
		for idx in cmag_vector'range loop
			tmp(idx) := two_min(mag(idx), min(idx));
		end loop;
		return tmp;
	end function;

	function self_corr (prv, nxt : csft_vector) return csft_vector is
		variable tmp : csft_vector;
	begin
		for idx in csft_vector'range loop
			tmp(idx) := self_corr(prv(idx), nxt(idx));
		end loop;
		return tmp;
	end function;

	function index_to_mask (enable : boolean; index : vector_shift) return bool_vector is
		variable tmp : bool_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := enable and idx = index;
		end loop;
		return tmp;
	end function;
end package body;


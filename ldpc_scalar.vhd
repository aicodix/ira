-- scalar LDPC decoder configuration
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ldpc_scalar is
	constant iterations_max : positive := 25;
	constant code_scalars : positive := 64800;
	constant block_scalars : positive := 360;
	constant code_blocks : positive := code_scalars / block_scalars;
	constant degree_max : positive := 27;
	constant total_links_max : positive := 233999;
	constant soft_bits : positive := 8;
	constant vsft_bits : positive := 8;
	constant csft_bits : positive := 6;
	constant scalar_locations_max : positive := total_links_max+1;
	constant block_locations_max : positive := (total_links_max+1) / block_scalars;
	constant scalar_parities_min : positive := code_scalars / 9;
	constant scalar_parities_max : positive := (code_scalars * 3) / 4;
	constant block_parities_min : positive := scalar_parities_min / block_scalars;
	constant block_parities_max : positive := scalar_parities_max / block_scalars;
	constant scalar_messages_min : positive := code_scalars - scalar_parities_max;
	constant scalar_messages_max : positive := code_scalars - scalar_parities_min;
	subtype scalar_location is natural range 0 to scalar_locations_max-1;
	subtype block_location is natural range 0 to block_locations_max-1;
	subtype scalar_offset is natural range 0 to code_scalars-1;
	subtype block_offset is natural range 0 to code_blocks-1;
	subtype block_shift is natural range 0 to block_scalars-1;
	subtype scalar_parities is positive range scalar_parities_min to scalar_parities_max;
	subtype block_parities is positive range block_parities_min to block_parities_max;
	subtype scalar_messages is positive range scalar_messages_min to scalar_messages_max;
	subtype soft_scalar is integer range - (2 ** (soft_bits-1)) to (2 ** (soft_bits-1)) - 1;
	subtype cmag_scalar is natural range 0 to (2 ** (csft_bits-1)) - 1;
	subtype cmag_scalar_logic is std_logic_vector (csft_bits-1 downto 0);
	subtype vmag_scalar is natural range 0 to (2 ** (vsft_bits-1)) - 1;
	subtype vmag_scalar_logic is std_logic_vector (vsft_bits-1 downto 0);
	subtype count_scalar is positive range 2 to degree_max;
	subtype sequence_scalar is natural range 0 to iterations_max-1;
	subtype csft_scalar_logic is std_logic_vector (cmag_scalar_logic'length downto 0);
	subtype vsft_scalar_logic is std_logic_vector (vmag_scalar_logic'length downto 0);
	type block_counts is array (0 to block_parities_max-1) of count_scalar;
	type block_offsets is array (0 to block_locations_max-1) of block_offset;
	type block_shifts is array (0 to block_locations_max-1) of block_shift;
	type vsft_scalar is record
		sgn : boolean;
		mag : vmag_scalar;
	end record;
	type csft_scalar is record
		sgn : boolean;
		mag : cmag_scalar;
	end record;
	type two_min_scalar is record
		lo, hi : cmag_scalar;
	end record;
	function depth_to_width (val : natural) return natural;
	function soft_to_vsft (val : soft_scalar) return vsft_scalar;
	function soft_to_csft (val : soft_scalar) return csft_scalar;
	function csft_to_soft (val : csft_scalar) return soft_scalar;
	function vsft_to_soft (val : vsft_scalar) return soft_scalar;
	function min_sum (val : vmag_scalar) return cmag_scalar;
	function select_other (mag : cmag_scalar; min : two_min_scalar) return cmag_scalar;
	function two_min (mag : cmag_scalar; min : two_min_scalar) return two_min_scalar;
	function self_corr (prv, nxt : csft_scalar) return csft_scalar;
	function bool_to_logic (val : boolean) return std_logic;
	function logic_to_bool (val : std_logic) return boolean;
	function logic_to_csft (val : csft_scalar_logic) return csft_scalar;
	function csft_to_logic (val : csft_scalar) return csft_scalar_logic;
	function logic_to_vsft (val : vsft_scalar_logic) return vsft_scalar;
	function vsft_to_logic (val : vsft_scalar) return vsft_scalar_logic;
end package;

package body ldpc_scalar is
	function depth_to_width (val : natural) return natural is
		variable tmp : natural := val - 1;
		variable cnt : natural := 0;
	begin
		while tmp > 0 loop
			cnt := cnt + 1;
			tmp := tmp / 2;
		end loop;
		-- report "DEPTH: " & integer'image(val) & " WIDTH: " & integer'image(cnt);
		return cnt;
	end function;

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

	function soft_to_csft (val : soft_scalar) return csft_scalar is
		variable tmp : csft_scalar;
	begin
		tmp.sgn := val < 0;
		if abs(val) > cmag_scalar'high then
			tmp.mag := cmag_scalar'high;
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

	function min_sum (val : vmag_scalar) return cmag_scalar is
		constant beta : integer := 1;
		constant max : integer := cmag_scalar'high + beta;
	begin
		if val > max then
			return cmag_scalar'high;
		elsif val < beta then
			return 0;
		else
			return val - beta;
		end if;
	end function;

	function select_other (mag : cmag_scalar; min : two_min_scalar) return cmag_scalar is
		variable tmp : cmag_scalar;
	begin
		if mag = min.lo then
			return min.hi;
		else
			return min.lo;
		end if;
	end function;

	function two_min (mag : cmag_scalar; min : two_min_scalar) return two_min_scalar is
		variable tmp : two_min_scalar;
	begin
		if mag < min.lo then
			return (mag, min.lo);
		elsif mag < min.hi then
			return (min.lo, mag);
		else
			return min;
		end if;
	end function;

	function self_corr (prv, nxt : csft_scalar) return csft_scalar is
		variable tmp : csft_scalar;
	begin
		if prv.mag = 0 or prv.sgn = nxt.sgn then
			return nxt;
		else
			return (nxt.sgn, 0);
		end if;
	end function;

	function bool_to_logic (val : boolean) return std_logic is
	begin
		if val then
			return '1';
		else
			return '0';
		end if;
	end function;

	function logic_to_bool (val : std_logic) return boolean is
	begin
		return val = '1';
	end function;

	function logic_to_csft (val : csft_scalar_logic) return csft_scalar is
	begin
		return (logic_to_bool(val(val'high)), to_integer(unsigned(val(cmag_scalar_logic'high downto 0))));
	end function;

	function csft_to_logic (val : csft_scalar) return csft_scalar_logic is
	begin
		return bool_to_logic(val.sgn) & std_logic_vector(to_unsigned(val.mag, cmag_scalar_logic'length));
	end function;

	function logic_to_vsft (val : vsft_scalar_logic) return vsft_scalar is
	begin
		return (logic_to_bool(val(val'high)), to_integer(unsigned(val(vmag_scalar_logic'high downto 0))));
	end function;

	function vsft_to_logic (val : vsft_scalar) return vsft_scalar_logic is
	begin
		return bool_to_logic(val.sgn) & std_logic_vector(to_unsigned(val.mag, vmag_scalar_logic'length));
	end function;
end package body;


-- vector check node processor
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity cnp_vector is
	port (
		clock : in std_logic;
		start : in boolean;
		count : in count_scalar;
		busy : out boolean := false;
		valid : out boolean := false;
		iseq : in sequence_scalar;
		oseq : out sequence_scalar;
		isft : in soft_vector;
		osft : out soft_vector;
		osgn : out sgn_vector;
		omag : out mag_vector;
		iwdf : in boolean;
		owdf : out boolean;
		iloc : in location_scalar;
		oloc : out location_scalar;
		ioff : in offset_scalar;
		ooff : out offset_scalar;
		ishi : in shift_scalar;
		oshi : out shift_scalar
	);
end cnp_vector;

architecture rtl of cnp_vector is
	type two_min_scalar is record
		lo, hi : mag_scalar;
	end record;
	type two_min_vector is array (0 to vector_scalars-1) of two_min_scalar;
	signal imin, dmin, omin : two_min_vector;
	signal ipty, dpty, opty : sgn_vector;
	subtype num_scalar is natural range 0 to degree_max;
	signal num : num_scalar := num_scalar'high;
	signal isgn : sgn_vector;
	signal imag : mag_vector;
	signal this_count, prev_count : count_scalar;
	signal seq, dseq : sequence_scalar;
	signal this_start, prev_start : boolean := false;
	signal okay : boolean := true;
	signal dvalid : boolean := false;
	signal shorter : boolean;
	signal finalize : boolean;

	signal buf_wren : boolean := false;
	signal buf_addr : natural range 0 to degree_max-1;
	signal buf_isft : soft_vector;
	signal buf_osft : soft_vector;
	signal buf_isgn : sgn_vector;
	signal buf_osgn : sgn_vector;
	signal buf_imag : mag_vector;
	signal buf_omag : mag_vector;
	signal buf_iwdf : boolean;
	signal buf_owdf : boolean;
	signal buf_iloc : location_scalar;
	signal buf_oloc : location_scalar;
	signal buf_ioff : offset_scalar;
	signal buf_ooff : offset_scalar;
	signal buf_ishi : shift_scalar;
	signal buf_oshi : shift_scalar;

	function ms (val : soft_scalar) return mag_scalar is
		constant max : integer := mag_scalar'high;
		constant min : integer := -max;
	begin
		if val < min or val > max then
			return mag_scalar'high;
		else
			return abs(val);
		end if;
	end function;

	function oms (val : soft_scalar) return mag_scalar is
		constant beta : integer := 1;
		constant max : integer := mag_scalar'high + beta;
		constant min : integer := -max;
	begin
		if val < min or val > max then
			return mag_scalar'high;
		elsif abs(val) < beta then
			return 0;
		else
			return abs(val) - beta;
		end if;
	end function;

	function oms (val : soft_vector) return mag_vector is
		variable tmp : mag_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := oms(val(idx));
		end loop;
		return tmp;
	end function;

	function other (mag : mag_scalar; min : two_min_scalar) return mag_scalar is
		variable tmp : mag_scalar;
	begin
		if mag = min.lo then
			return min.hi;
		else
			return min.lo;
		end if;
	end function;

	function other (mag : mag_vector; min : two_min_vector) return mag_vector is
		variable tmp : mag_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := other(mag(idx), min(idx));
		end loop;
		return tmp;
	end function;

	function neg (val : soft_scalar) return boolean is
	begin
		return val < 0;
	end function;

	function neg (val : soft_vector) return sgn_vector is
		variable tmp : sgn_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := neg(val(idx));
		end loop;
		return tmp;
	end function;

	function two_min (mag : mag_scalar; min : two_min_scalar) return two_min_scalar is
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

	function two_min (mag : mag_vector; min : two_min_vector) return two_min_vector is
		variable tmp : two_min_vector;
	begin
		for idx in mag_vector'range loop
			tmp(idx) := two_min(mag(idx), min(idx));
		end loop;
		return tmp;
	end function;
begin
	buf_inst : entity work.buf_vector
		port map (clock,
			buf_wren, buf_addr,
			buf_isft, buf_osft,
			buf_isgn, buf_osgn,
			buf_imag, buf_omag,
			buf_iwdf, buf_owdf,
			buf_iloc, buf_oloc,
			buf_ioff, buf_ooff,
			buf_ishi, buf_oshi);

	imag <= oms(isft);
	isgn <= neg(isft);
	osft <= buf_osft;
	omag <= other(buf_omag, omin);
	osgn <= buf_osgn xor opty;
	owdf <= buf_owdf;
	oloc <= buf_oloc;
	ooff <= buf_ooff;
	oshi <= buf_oshi;
	finalize <= false when not this_start else num = prev_count when shorter else num = this_count;

	process (clock)
	begin
		if rising_edge(clock) then
			valid <= dvalid;
			oseq <= dseq;
			omin <= dmin;
			opty <= dpty;
			if start or finalize then
				num <= 0;
				dvalid <= false;
				buf_wren <= false;
				prev_start <= this_start;
				this_start <= start;
				prev_count <= this_count;
				dseq <= seq;
				seq <= iseq;
				if start then
					this_count <= count;
					shorter <= count < this_count;
				else
					this_count <= count_scalar'low;
					shorter <= true;
					busy <= true;
				end if;
				dmin <= imin;
				dpty <= ipty;
				imin <= (others => (mag_scalar'high, mag_scalar'high));
				ipty <= (others => false);
			elsif num /= num_scalar'high then
				num <= num + 1;
				if shorter then
					if num = prev_count-2 then
						busy <= false;
					elsif num = this_count-2 then
						busy <= true;
					end if;
					if num = prev_count-1 then
						okay <= true;
					elsif num = this_count-1 then
						okay <= false;
					end if;
				end if;
				if okay then
					imin <= two_min(imag, imin);
					ipty <= ipty xor isgn;
				end if;
				if num = 0 then
					dvalid <= prev_start;
				elsif num = prev_count then
					dvalid <= false;
				end if;
				buf_wren <= true;
				buf_addr <= num;
				buf_isft <= isft;
				buf_imag <= imag;
				buf_isgn <= isgn;
				buf_iwdf <= iwdf;
				buf_iloc <= iloc;
				buf_ioff <= ioff;
				buf_ishi <= ishi;
			else
				dvalid <= false;
				buf_wren <= false;
			end if;
		end if;
	end process;
end rtl;


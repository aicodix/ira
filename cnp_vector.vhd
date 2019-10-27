-- vector check node processor
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity cnp_vector is
	port (
		clock : in std_logic;
		busy : out boolean := false;
		istart : in boolean;
		ostart : out boolean := false;
		icount : in count_scalar;
		ocount : out count_scalar;
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
	signal imin0, imin1, omin0, omin1 : mag_vector;
	signal ipty, opty : sgn_vector;
	subtype num_scalar is natural range 0 to degree_max;
	signal num : num_scalar := num_scalar'high;
	signal isgn : sgn_vector;
	signal imag : mag_vector;
	signal count, prev : count_scalar;
	signal seq : sequence_scalar;
	signal start : boolean := false;
	signal okay : boolean := true;
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

	function ms (val : soft_vector) return mag_vector is
		constant max : integer := mag_scalar'high;
		constant min : integer := -max;
		variable tmp : mag_vector;
	begin
		for idx in tmp'range loop
			if val(idx) < min or val(idx) > max then
				tmp(idx) := mag_scalar'high;
			else
				tmp(idx) := abs(val(idx));
			end if;
		end loop;
		return tmp;
	end function;

	function oms (val : soft_vector) return mag_vector is
		constant beta : integer := 1;
		constant max : integer := mag_scalar'high + beta;
		constant min : integer := -max;
		variable tmp : mag_vector;
	begin
		for idx in tmp'range loop
			if val(idx) < min or val(idx) > max then
				tmp(idx) := mag_scalar'high;
			elsif abs(val(idx)) < beta then
				tmp(idx) := 0;
			else
				tmp(idx) := abs(val(idx)) - beta;
			end if;
		end loop;
		return tmp;
	end function;

	function other (mag, mag0, mag1 : mag_vector) return mag_vector is
		variable tmp : mag_vector;
	begin
		for idx in tmp'range loop
			if mag(idx) = mag0(idx) then
				tmp(idx) := mag1(idx);
			else
				tmp(idx) := mag0(idx);
			end if;
		end loop;
		return tmp;
	end function;

	function neg (val : soft_vector) return sgn_vector is
		variable tmp : sgn_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := val(idx) < 0;
		end loop;
		return tmp;
	end function;

	procedure two_min (signal mag : in mag_vector;
			signal min0, min1 : inout mag_vector) is
	begin
		for idx in mag_vector'range loop
			if mag(idx) < min0(idx) then
				min1(idx) <= min0(idx);
				min0(idx) <= mag(idx);
			elsif mag(idx) < min1(idx) then
				min1(idx) <= mag(idx);
			end if;
		end loop;
	end procedure;
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
	omag <= other(buf_omag, omin0, omin1);
	osgn <= buf_osgn xor opty;
	owdf <= buf_owdf;
	oloc <= buf_oloc;
	ooff <= buf_ooff;
	oshi <= buf_oshi;
	finalize <= false when not start else num = prev when shorter else num = count;

	process (clock)
	begin
		if rising_edge(clock) then
			if istart or finalize then
				num <= 0;
				buf_wren <= false;
				ostart <= start;
				start <= istart;
				prev <= count;
				ocount <= count;
				oseq <= seq;
				seq <= iseq;
				if istart then
					count <= icount;
					shorter <= icount < count;
				else
					count <= count_scalar'low;
					shorter <= true;
					busy <= true;
				end if;
				omin0 <= imin0;
				omin1 <= imin1;
				opty <= ipty;
				imin0 <= (others => mag_scalar'high);
				imin1 <= (others => mag_scalar'high);
				ipty <= (others => false);
			elsif num /= num_scalar'high then
				num <= num + 1;
				ostart <= false;
				if shorter then
					if num = prev-2 then
						busy <= false;
					elsif num = count-2 then
						busy <= true;
					end if;
					if num = prev-1 then
						okay <= true;
					elsif num = count-1 then
						okay <= false;
					end if;
				end if;
				if okay then
					two_min(imag, imin0, imin1);
					ipty <= ipty xor isgn;
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
				buf_wren <= false;
			end if;
		end if;
	end process;
end rtl;


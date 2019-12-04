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
		ivsft : in vsft_vector;
		ovsft : out vsft_vector;
		ocsft : out csft_vector;
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
		lo, hi : cmag_scalar;
	end record;
	type two_min_vector is array (0 to vector_scalars-1) of two_min_scalar;
	signal imin, dmin, omin : two_min_vector;
	signal ipty, dpty, opty : sign_vector;
	subtype num_scalar is natural range 0 to degree_max;
	signal num : num_scalar := num_scalar'high;
	signal icmag : cmag_vector;
	signal this_count, prev_count : count_scalar;
	signal seq, dseq : sequence_scalar;
	signal this_start, prev_start : boolean := false;
	signal okay : boolean := true;
	signal dvalid : boolean := false;
	signal shorter : boolean;
	signal finalize : boolean;

	signal buf_wren : boolean := false;
	signal buf_addr : natural range 0 to degree_max-1;
	signal buf_ivsft : vsft_vector;
	signal buf_ovsft : vsft_vector;
	signal buf_icmag : cmag_vector;
	signal buf_ocmag : cmag_vector;
	signal buf_iwdf : boolean;
	signal buf_owdf : boolean;
	signal buf_iloc : location_scalar;
	signal buf_oloc : location_scalar;
	signal buf_ioff : offset_scalar;
	signal buf_ooff : offset_scalar;
	signal buf_ishi : shift_scalar;
	signal buf_oshi : shift_scalar;

	function oms (val : vmag_scalar) return cmag_scalar is
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

	function oms (val : vmag_vector) return cmag_vector is
		variable tmp : cmag_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := oms(val(idx));
		end loop;
		return tmp;
	end function;

	function other (mag : cmag_scalar; min : two_min_scalar) return cmag_scalar is
		variable tmp : cmag_scalar;
	begin
		if mag = min.lo then
			return min.hi;
		else
			return min.lo;
		end if;
	end function;

	function other (mag : cmag_vector; min : two_min_vector) return cmag_vector is
		variable tmp : cmag_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := other(mag(idx), min(idx));
		end loop;
		return tmp;
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

	function two_min (mag : cmag_vector; min : two_min_vector) return two_min_vector is
		variable tmp : two_min_vector;
	begin
		for idx in cmag_vector'range loop
			tmp(idx) := two_min(mag(idx), min(idx));
		end loop;
		return tmp;
	end function;
begin
	buf_inst : entity work.buf_vector
		port map (clock,
			buf_wren, buf_addr,
			buf_ivsft, buf_ovsft,
			buf_icmag, buf_ocmag,
			buf_iwdf, buf_owdf,
			buf_iloc, buf_oloc,
			buf_ioff, buf_ooff,
			buf_ishi, buf_oshi);

	icmag <= oms(vmag_of_vsft(ivsft));
	ovsft <= buf_ovsft;
	ocsft <= sign_and_cmag_to_csft(opty xor sign_of_vsft(buf_ovsft), other(buf_ocmag, omin));
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
				imin <= (others => (cmag_scalar'high, cmag_scalar'high));
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
					imin <= two_min(icmag, imin);
					ipty <= ipty xor sign_of_vsft(ivsft);
				end if;
				if num = 0 then
					dvalid <= prev_start;
				elsif num = prev_count then
					dvalid <= false;
				end if;
				buf_wren <= true;
				buf_addr <= num;
				buf_ivsft <= ivsft;
				buf_icmag <= icmag;
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


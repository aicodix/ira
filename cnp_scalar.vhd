-- scalar check node processor
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;

entity cnp_scalar is
	port (
		clock : in std_logic;
		reset : in std_logic;
		start : in boolean;
		count : in count_scalar;
		ready : out boolean := true;
		valid : out boolean := false;
		iseq : in sequence_scalar;
		oseq : out sequence_scalar;
		ivsft : in vsft_scalar;
		ovsft : out vsft_scalar;
		icsft : in csft_scalar;
		ocsft : out csft_scalar;
		iwdf : in boolean;
		owdf : out boolean;
		iloc : in scalar_location;
		oloc : out scalar_location;
		ioff : in scalar_offset;
		ooff : out scalar_offset
	);
end cnp_scalar;

architecture rtl of cnp_scalar is
	signal imin, dmin, omin : two_min_scalar;
	signal ipty, dpty, opty : boolean;
	subtype num_scalar is natural range 0 to degree_max;
	signal num : num_scalar := num_scalar'high;
	signal icmag : cmag_scalar;
	signal this_count, prev_count : count_scalar;
	signal seq, dseq : sequence_scalar;
	signal this_start, prev_start : boolean := false;
	signal okay : boolean := true;
	signal dvalid : boolean := false;
	signal shorter : boolean;
	signal finalize : boolean;

	signal buf_wren : boolean := false;
	signal buf_addr : natural range 0 to degree_max-1;
	signal buf_ivsft : vsft_scalar;
	signal buf_ovsft : vsft_scalar;
	signal buf_icsft : csft_scalar;
	signal buf_ocsft : csft_scalar;
	signal buf_icmag : cmag_scalar;
	signal buf_ocmag : cmag_scalar;
	signal buf_iwdf : boolean;
	signal buf_owdf : boolean;
	signal buf_iloc : scalar_location;
	signal buf_oloc : scalar_location;
	signal buf_ioff : scalar_offset;
	signal buf_ooff : scalar_offset;
begin
	buf_inst : entity work.buf_scalar
		port map (clock,
			buf_wren, buf_addr,
			buf_ivsft, buf_ovsft,
			buf_icsft, buf_ocsft,
			buf_icmag, buf_ocmag,
			buf_iwdf, buf_owdf,
			buf_iloc, buf_oloc,
			buf_ioff, buf_ooff);

	icmag <= min_sum(ivsft.mag);
	ovsft <= buf_ovsft;
	ocsft <= self_corr(buf_ocsft, (opty xor buf_ovsft.sgn, select_other(buf_ocmag, omin)));
	owdf <= buf_owdf;
	oloc <= buf_oloc;
	ooff <= buf_ooff;
	finalize <= false when not this_start else num = prev_count when shorter else num = this_count;

	process (clock, reset)
	begin
		if reset = '1' then
			ready <= true;
			valid <= false;
			num <= num_scalar'high;
			this_start <= false;
			prev_start <= false;
			okay  <= true;
			dvalid  <= false;
			buf_wren <= false;
		elsif rising_edge(clock) then
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
					ready <= false;
				end if;
				dmin <= imin;
				dpty <= ipty;
				imin <= (cmag_scalar'high, cmag_scalar'high);
				ipty <= false;
			elsif num /= num_scalar'high then
				num <= num + 1;
				if shorter then
					if num = prev_count-2 then
						ready <= true;
					elsif num = this_count-2 then
						ready <= false;
					end if;
					if num = prev_count-1 then
						okay <= true;
					elsif num = this_count-1 then
						okay <= false;
					end if;
				end if;
				if okay then
					imin <= two_min(icmag, imin);
					ipty <= ipty xor ivsft.sgn;
				end if;
				if num = 0 then
					dvalid <= prev_start;
				elsif num = prev_count then
					dvalid <= false;
				end if;
				buf_wren <= true;
				buf_addr <= num;
				buf_ivsft <= ivsft;
				buf_icsft <= icsft;
				buf_icmag <= icmag;
				buf_iwdf <= iwdf;
				buf_iloc <= iloc;
				buf_ioff <= ioff;
			else
				dvalid <= false;
				buf_wren <= false;
			end if;
		end if;
	end process;
end rtl;


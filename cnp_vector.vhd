-- vector check node processor
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;
use work.ldpc_vector.all;

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
		icsft : in csft_vector;
		ocsft : out csft_vector;
		iwdf : in boolean;
		owdf : out boolean;
		iloc : in vector_location;
		oloc : out vector_location;
		ioff : in vector_offset;
		ooff : out vector_offset;
		ishi : in vector_shift;
		oshi : out vector_shift
	);
end cnp_vector;

architecture rtl of cnp_vector is
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
	signal buf_icsft : csft_vector;
	signal buf_ocsft : csft_vector;
	signal buf_icmag : cmag_vector;
	signal buf_ocmag : cmag_vector;
	signal buf_iwdf : boolean;
	signal buf_owdf : boolean;
	signal buf_iloc : vector_location;
	signal buf_oloc : vector_location;
	signal buf_ioff : vector_offset;
	signal buf_ooff : vector_offset;
	signal buf_ishi : vector_shift;
	signal buf_oshi : vector_shift;
begin
	buf_inst : entity work.buf_vector
		port map (clock,
			buf_wren, buf_addr,
			buf_ivsft, buf_ovsft,
			buf_icsft, buf_ocsft,
			buf_icmag, buf_ocmag,
			buf_iwdf, buf_owdf,
			buf_iloc, buf_oloc,
			buf_ioff, buf_ooff,
			buf_ishi, buf_oshi);

	icmag <= min_sum(vmag_of_vsft(ivsft));
	ovsft <= buf_ovsft;
	ocsft <= self_corr(buf_ocsft, sign_and_cmag_to_csft(opty xor sign_of_vsft(buf_ovsft), select_other(buf_ocmag, omin)));
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
				buf_icsft <= icsft;
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


-- buffer for the scalar check node processor
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;

entity buf_scalar is
	port (
		clock : in std_logic;
		wren : in boolean;
		addr : in natural range 0 to degree_max-1;
		ivsft : in vsft_scalar;
		ovsft : out vsft_scalar;
		icsft : in csft_scalar;
		ocsft : out csft_scalar;
		icmag : in cmag_scalar;
		ocmag : out cmag_scalar;
		iwdf : in boolean;
		owdf : out boolean;
		iloc : in scalar_location;
		oloc : out scalar_location;
		ioff : in scalar_offset;
		ooff : out scalar_offset
	);
end buf_scalar;

architecture rtl of buf_scalar is
	type wdfs_array is array (0 to degree_max-1) of boolean;
	signal wdfs : wdfs_array;
	type vsft_array is array (0 to degree_max-1) of vsft_scalar;
	signal vsfts : vsft_array;
	type csft_array is array (0 to degree_max-1) of csft_scalar;
	signal csfts : csft_array;
	type cmag_array is array (0 to degree_max-1) of cmag_scalar;
	signal cmags : cmag_array;
	type locs_array is array (0 to degree_max-1) of scalar_location;
	signal locs : locs_array;
	type offs_array is array (0 to degree_max-1) of scalar_offset;
	signal offs : offs_array;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				wdfs(addr) <= iwdf;
				vsfts(addr) <= ivsft;
				csfts(addr) <= icsft;
				cmags(addr) <= icmag;
				locs(addr) <= iloc;
				offs(addr) <= ioff;
			end if;
			owdf <= wdfs(addr);
			ovsft <= vsfts(addr);
			ocsft <= csfts(addr);
			ocmag <= cmags(addr);
			oloc <= locs(addr);
			ooff <= offs(addr);
		end if;
	end process;
end rtl;


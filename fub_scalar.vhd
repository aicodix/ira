-- scalar helper array for buf_vector
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity fub_scalar is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		addr : in natural range 0 to size-1;
		ivsft : in vsft_scalar;
		ovsft : out vsft_scalar;
		icmag : in cmag_scalar;
		ocmag : out cmag_scalar
	);
end fub_scalar;

architecture rtl of fub_scalar is
	type vsft_array is array (0 to size-1) of vsft_scalar;
	signal vsfts : vsft_array;
	type cmag_array is array (0 to size-1) of cmag_scalar;
	signal cmags : cmag_array;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				vsfts(addr) <= ivsft;
				cmags(addr) <= icmag;
			end if;
			ovsft <= vsfts(addr);
			ocmag <= cmags(addr);
		end if;
	end process;
end rtl;


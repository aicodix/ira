-- scalar variable nodes
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;

entity var_scalar is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to size-1;
		rpos : in natural range 0 to size-1;
		isft : in vsft_scalar;
		osft : out vsft_scalar
	);
end var_scalar;

architecture rtl of var_scalar is
	type vsft_array is array (0 to size-1) of vsft_scalar;
	signal sfts : vsft_array;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				sfts(wpos) <= isft;
			end if;
			if rden then
				osft <= sfts(rpos);
			end if;
		end if;
	end process;
end rtl;


-- vector variable nodes
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_vector.all;

entity var_vector is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to size-1;
		rpos : in natural range 0 to size-1;
		isft : in vsft_vector;
		osft : out vsft_vector
	);
end var_vector;

architecture rtl of var_vector is
	type vsft_array is array (0 to size-1) of vsft_vector_logic;
	signal sfts : vsft_array := (others => (others => '0'));
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				sfts(wpos) <= vsft_to_logic(isft);
			end if;
			if rden then
				osft <= logic_to_vsft(sfts(rpos));
			end if;
		end if;
	end process;
end rtl;


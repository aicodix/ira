-- vector bit node links
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_vector.all;

entity bnl_vector is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to size-1;
		rpos : in natural range 0 to size-1;
		isft : in csft_vector;
		osft : out csft_vector
	);
end bnl_vector;

architecture rtl of bnl_vector is
	type csft_array is array (0 to size-1) of csft_vector_logic;
	signal sfts : csft_array := (others => (others => '0'));
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				sfts(wpos) <= csft_to_logic(isft);
			end if;
			if rden then
				osft <= logic_to_csft(sfts(rpos));
			end if;
		end if;
	end process;
end rtl;


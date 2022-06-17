-- locations for the vector decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_vector.all;
use work.table_vector.all;

entity loc_vector is
	port (
		clock : in std_logic;
		rden : in boolean;
		rpos : in vector_location;
		ooff : out vector_offset;
		oshi : out vector_shift
	);
end loc_vector;

architecture rtl of loc_vector is
	signal offs : vector_offsets := init_vector_offsets;
	signal shis : vector_shifts := init_vector_shifts;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if rden then
				ooff <= offs(rpos);
				oshi <= shis(rpos);
			end if;
		end if;
	end process;
end rtl;


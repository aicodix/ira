-- locations for the scalar decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;
use work.table_scalar.all;

entity loc_scalar is
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in scalar_location;
		rpos : in scalar_location;
		ioff : in scalar_offset;
		ooff : out scalar_offset
	);
end loc_scalar;

architecture rtl of loc_scalar is
	signal offs : scalar_offsets := init_scalar_offsets;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				offs(wpos) <= ioff;
			end if;
			if rden then
				ooff <= offs(rpos);
			end if;
		end if;
	end process;
end rtl;


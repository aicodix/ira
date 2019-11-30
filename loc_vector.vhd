-- locations for the vector decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;
use work.table.all;

entity loc_vector is
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in location_scalar;
		rpos : in location_scalar;
		ioff : in offset_scalar;
		ooff : out offset_scalar;
		ishi : in shift_scalar;
		oshi : out shift_scalar
	);
end loc_vector;

architecture rtl of loc_vector is
	signal offs : offsets := init_offsets;
	signal shis : shifts := init_shifts;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				offs(wpos) <= ioff;
				shis(wpos) <= ishi;
			end if;
			if rden then
				ooff <= offs(rpos);
				oshi <= shis(rpos);
			end if;
		end if;
	end process;
end rtl;


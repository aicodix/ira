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
		wpos : in block_location;
		rpos : in block_location;
		ioff : in block_offset;
		ooff : out block_offset;
		ishi : in block_shift;
		oshi : out block_shift
	);
end loc_scalar;

architecture rtl of loc_scalar is
	signal offs : block_offsets := init_block_offsets;
	signal shis : block_shifts := init_block_shifts;
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


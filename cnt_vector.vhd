-- counts for the vector decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;
use work.table.all;

entity cnt_vector is
	port (
		clock : in std_logic;
		wren : in boolean;
		wpos : in natural range 0 to parities_max-1;
		rpos : in natural range 0 to parities_max-1;
		icnt : in count_scalar;
		ocnt : out count_scalar
	);
end cnt_vector;

architecture rtl of cnt_vector is
	signal cnts : counts := init_counts;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				cnts(wpos) <= icnt;
			end if;
			ocnt <= cnts(rpos);
		end if;
	end process;
end rtl;


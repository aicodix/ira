-- counts for the scalar decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;
use work.table_scalar.all;

entity cnt_scalar is
	port (
		clock : in std_logic;
		rpos : in natural range 0 to block_parities_max-1;
		ocnt : out count_scalar
	);
end cnt_scalar;

architecture rtl of cnt_scalar is
	signal cnts : block_counts := init_block_counts;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			ocnt <= cnts(rpos);
		end if;
	end process;
end rtl;


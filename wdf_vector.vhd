-- write disable flags for the vector decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity wdf_vector is
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in location_scalar;
		rpos : in location_scalar;
		iwdf : in boolean;
		owdf : out boolean
	);
end wdf_vector;

architecture rtl of wdf_vector is
	type wd_flags is array (0 to locations_max-1) of boolean;
	signal wdfs : wd_flags;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				wdfs(wpos) <= iwdf;
			end if;
			if rden then
				owdf <= wdfs(rpos);
			end if;
		end if;
	end process;
end rtl;


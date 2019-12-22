-- data hazard detection
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;

entity data_hazard_detection is
	generic (
		size : positive;
		depth : positive
	);
	port (
		clock : in std_logic;
		reset : in boolean;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to size-1;
		rpos : in natural range 0 to size-1
	);
end data_hazard_detection;

architecture rtl of data_hazard_detection is
begin
	process (clock)
		subtype pos_scalar is natural range 0 to size;
		type pos_array is array (0 to depth-1) of pos_scalar;
		variable pos : pos_array := (others => pos_scalar'high);
	begin
		if reset then
			pos := (others => pos_scalar'high);
		elsif rising_edge(clock) then
			if rden then
				if pos(0) /= rpos then
					for idx in pos'range loop
						if pos(idx) = rpos then
							report "read without writing back: " & HT & integer'image(rpos);
						end if;
					end loop;
					pos := rpos & pos(pos'low to pos'high-1);
				end if;
			end if;
			if wren then
				for idx in pos'range loop
					if pos(idx) = wpos then
						pos(idx) := pos_scalar'high;
					end if;
				end loop;
			end if;
		end if;
	end process;
end rtl;


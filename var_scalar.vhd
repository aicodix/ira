-- scalar variable nodes
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity var_scalar is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to size-1;
		rpos : in natural range 0 to size-1;
		ivar : in soft_scalar;
		ovar : out soft_scalar
	);
end var_scalar;

architecture rtl of var_scalar is
	type scalar_array is array (0 to size-1) of soft_scalar;
	signal vars : scalar_array;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				vars(wpos) <= ivar;
			end if;
			if rden then
				ovar <= vars(rpos);
			end if;
		end if;
	end process;
end rtl;


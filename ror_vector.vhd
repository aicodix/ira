-- rotate right vector elements
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity ror_vector is
	port (
		clock : in std_logic;
		clken : in boolean;
		shift : in natural range 0 to soft_vector'length-1;
		ivsft : in vsft_vector;
		ovsft : out vsft_vector
	);
end ror_vector;

architecture rtl of ror_vector is
	function rotate_right (vec : vsft_vector; shi : natural range 0 to vsft_vector'length-1) return vsft_vector is
		variable tmp : vsft_vector;
	begin
		for o in vsft_vector'range loop
			for i in vsft_vector'range loop
				if shi = (o - i + soft_vector'length) rem soft_vector'length then
					tmp(o) := vec(i);
				end if;
			end loop;
		end loop;
		return tmp;
	end function;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if clken then
				ovsft <= rotate_right(ivsft, shift);
			end if;
		end if;
	end process;
end rtl;


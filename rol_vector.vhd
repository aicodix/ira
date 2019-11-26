-- rotate left vector elements
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity rol_vector is
	port (
		clock : in std_logic;
		shift : in natural range 0 to soft_vector'length-1;
		isoft : in soft_vector;
		osoft : out soft_vector
	);
end rol_vector;

architecture rtl of rol_vector is
	function rotate_left (vec : soft_vector; shi : natural range 0 to soft_vector'length-1) return soft_vector is
		variable tmp : soft_vector;
	begin
		if shi = 0 then
			tmp := vec;
		else
			for idx in soft_vector'low+1 to soft_vector'high loop
				if shi = idx - soft_vector'low then
					tmp := vec(idx to soft_vector'high) & vec(soft_vector'low to idx-1);
				end if;
			end loop;
		end if;
		return tmp;
	end function;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			osoft <= rotate_left(isoft, shift);
		end if;
	end process;
end rtl;


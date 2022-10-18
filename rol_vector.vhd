-- rotate left vector elements
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ldpc_scalar.all;
use work.ldpc_vector.all;

entity rol_vector is
	port (
		clock : in std_logic;
		clken : in boolean;
		shift : in natural range 0 to soft_vector'length-1;
		ivsft : in vsft_vector;
		ovsft : out vsft_vector
	);
end rol_vector;

architecture rtl of rol_vector is
	function rotate_left (vec : vsft_vector; shi : natural range 0 to vsft_vector'length-1) return vsft_vector is
		constant len : positive := vsft_vector'length;
		constant stages : positive := depth_to_width(len);
		variable rotate : std_logic_vector(stages-1 downto 0);
		type tmp_type is array (natural range 0 to stages) of vsft_vector;
		variable tmp : tmp_type;
	begin
		rotate := std_logic_vector(to_unsigned(shi, stages));
		tmp(0) := vec;
		for i in 0 to stages-1 loop
			if rotate(i) = '0' then
				tmp(i+1) := tmp(i);
			else
				tmp(i+1) := tmp(i)(2**i to len-1) & tmp(i)(0 to 2**i-1);
			end if;
		end loop;
		return tmp(tmp'high);
	end function;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if clken then
				ovsft <= rotate_left(ivsft, shift);
			end if;
		end if;
	end process;
end rtl;


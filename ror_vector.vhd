-- rotate right vector elements
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity ror_vector is
	port (
		shift : in natural range 0 to soft_vector'length-1;
		isoft : in soft_vector;
		osoft : out soft_vector
	);
end ror_vector;

architecture rtl of ror_vector is
begin
	process (shift, isoft)
	begin
		if shift = 0 then
			osoft <= isoft;
		else
			for idx in soft_vector'low+1 to soft_vector'high loop
				if shift = soft_vector'high - idx then
					osoft <= isoft(idx to soft_vector'high) & isoft(soft_vector'low to idx-1);
				end if;
			end loop;
		end if;
	end process;
end rtl;


-- variable nodes for the vector decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;
use work.table.all;

entity var_vector is
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to code_vectors-1;
		rpos : in natural range 0 to code_vectors-1;
		ivar : in soft_vector;
		ovar : out soft_vector
	);
end var_vector;

architecture rtl of var_vector is
	type cvss is array (0 to code_vectors-1) of soft_scalar;
	type vscs is array (0 to vector_scalars-1) of cvss;
	signal vars : vscs;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				for idx in ivar'range loop
					vars(idx)(wpos) <= ivar(idx);
				end loop;
			end if;
			if rden then
				for idx in ovar'range loop
					ovar(idx) <= vars(idx)(rpos);
				end loop;
			end if;
		end if;
	end process;
end rtl;


-- saturating addition for the vector decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity add_vector is
	port (
		clock : in std_logic;
		isft : in soft_vector;
		isgn : in sgn_vector;
		imag : in mag_vector;
		osft : out soft_vector
	);
end add_vector;

architecture rtl of add_vector is
	function add (val : soft_vector; sgn : sgn_vector; mag : mag_vector) return soft_vector is
		variable tmp : soft_vector;
	begin
		for idx in tmp'range loop
			if sgn(idx) then
				if val(idx)-mag(idx) < soft_scalar'low then
					tmp(idx) := soft_scalar'low;
				else
					tmp(idx) := val(idx)-mag(idx);
				end if;
			else
				if val(idx)+mag(idx) > soft_scalar'high then
					tmp(idx) := soft_scalar'high;
				else
					tmp(idx) := val(idx)+mag(idx);
				end if;
			end if;
		end loop;
		return tmp;
	end function;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			osft <= add(isft, isgn, imag);
		end if;
	end process;
end rtl;


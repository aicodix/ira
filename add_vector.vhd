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
		subtype signed_mag_scalar is integer range -mag_scalar'high to mag_scalar'high;
		type signed_mag_vector is array (0 to vector_scalars-1) of signed_mag_scalar;
		variable sig : signed_mag_vector;
		subtype sum_scalar is integer range soft_scalar'low-mag_scalar'high to soft_scalar'high+mag_scalar'high;
		type sum_vector is array (0 to vector_scalars-1) of sum_scalar;
		variable sum : sum_vector;
	begin
		for idx in tmp'range loop
			if sgn(idx) then
				sig(idx) := -mag(idx);
			else
				sig(idx) := mag(idx);
			end if;
			sum(idx) := val(idx) + sig(idx);
			if sum(idx) > soft_scalar'high then
				tmp(idx) := soft_scalar'high;
			elsif sum(idx) < soft_scalar'low then
				tmp(idx) := soft_scalar'low;
			else
				tmp(idx) := sum(idx);
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


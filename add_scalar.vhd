-- scalar saturating addition
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity add_scalar is
	port (
		clock : in std_logic;
		clken : in boolean;
		isft : in soft_scalar;
		isgn : in boolean;
		imag : in mag_scalar;
		osft : out soft_scalar
	);
end add_scalar;

architecture rtl of add_scalar is
	function add (val : soft_scalar; sgn : boolean; mag : mag_scalar) return soft_scalar is
		subtype signed_mag_scalar is integer range -mag_scalar'high to mag_scalar'high;
		variable sig : signed_mag_scalar;
		subtype sum_scalar is integer range soft_scalar'low-mag_scalar'high to soft_scalar'high+mag_scalar'high;
		variable sum : sum_scalar;
	begin
		if sgn then
			sig := -mag;
		else
			sig := mag;
		end if;
		sum := val + sig;
		if sum > soft_scalar'high then
			return soft_scalar'high;
		elsif sum < soft_scalar'low then
			return soft_scalar'low;
		else
			return sum;
		end if;
	end function;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if clken then
				osft <= add(isft, isgn, imag);
			end if;
		end if;
	end process;
end rtl;


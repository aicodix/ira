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
		ivsft : in vsft_scalar;
		icsft : in csft_scalar;
		ovsft : out vsft_scalar
	);
end add_scalar;

architecture rtl of add_scalar is
	function add (vsft : vsft_scalar; csft : csft_scalar) return vsft_scalar is
		variable tmp : vsft_scalar;
	begin
		if vsft.sgn = csft.sgn then
			tmp.sgn := vsft.sgn;
			if vsft.mag + csft.mag > vmag_scalar'high then
				tmp.mag := vmag_scalar'high;
			else
				tmp.mag := vsft.mag + csft.mag;
			end if;
		else
			if vsft.mag > csft.mag then
				tmp.sgn := vsft.sgn;
				tmp.mag := vsft.mag - csft.mag;
			else
				tmp.sgn := csft.sgn;
				tmp.mag := csft.mag - vsft.mag;
			end if;
		end if;
		return tmp;
	end function;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if clken then
				ovsft <= add(ivsft, icsft);
			end if;
		end if;
	end process;
end rtl;


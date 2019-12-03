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
		ivsgn : in boolean;
		ivmag : in vmag_scalar;
		icsgn : in boolean;
		icmag : in cmag_scalar;
		ovsgn : out boolean;
		ovmag : out vmag_scalar
	);
end add_scalar;

architecture rtl of add_scalar is
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if clken then
				if ivsgn = icsgn then
					if ivmag + icmag > vmag_scalar'high then
						ovmag <= vmag_scalar'high;
					else
						ovmag <= ivmag + icmag;
					end if;
					ovsgn <= ivsgn;
				else
					if ivmag > icmag then
						ovmag <= ivmag - icmag;
						ovsgn <= ivsgn;
					else
						ovmag <= icmag - ivmag;
						ovsgn <= icsgn;
					end if;
				end if;
			end if;
		end if;
	end process;
end rtl;


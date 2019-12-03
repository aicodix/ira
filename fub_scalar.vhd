-- scalar helper array for buf_vector
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity fub_scalar is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		addr : in natural range 0 to size-1;
		ivsgn : in boolean;
		ovsgn : out boolean;
		ivmag : in vmag_scalar;
		ovmag : out vmag_scalar;
		icmag : in cmag_scalar;
		ocmag : out cmag_scalar
	);
end fub_scalar;

architecture rtl of fub_scalar is
	type sign_array is array (0 to size-1) of boolean;
	signal vsgns : sign_array;
	type vmag_array is array (0 to size-1) of vmag_scalar;
	signal vmags : vmag_array;
	type cmag_array is array (0 to size-1) of cmag_scalar;
	signal cmags : cmag_array;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				vsgns(addr) <= ivsgn;
				vmags(addr) <= ivmag;
				cmags(addr) <= icmag;
			end if;
			ovsgn <= vsgns(addr);
			ovmag <= vmags(addr);
			ocmag <= cmags(addr);
		end if;
	end process;
end rtl;


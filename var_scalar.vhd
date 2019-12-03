-- scalar variable nodes
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity var_scalar is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to size-1;
		rpos : in natural range 0 to size-1;
		isgn : in boolean;
		osgn : out boolean;
		imag : in vmag_scalar;
		omag : out vmag_scalar
	);
end var_scalar;

architecture rtl of var_scalar is
	type sign_array is array (0 to size-1) of boolean;
	signal sgns : sign_array;
	type vmag_array is array (0 to size-1) of vmag_scalar;
	signal mags : vmag_array;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				sgns(wpos) <= isgn;
				mags(wpos) <= imag;
			end if;
			if rden then
				osgn <= sgns(rpos);
				omag <= mags(rpos);
			end if;
		end if;
	end process;
end rtl;


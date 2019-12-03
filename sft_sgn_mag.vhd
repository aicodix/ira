-- scalar soft, sign and magnitude array
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity sft_sgn_mag is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		addr : in natural range 0 to size-1;
		isft : in soft_scalar;
		osft : out soft_scalar;
		isgn : in boolean;
		osgn : out boolean;
		imag : in mag_scalar;
		omag : out mag_scalar
	);
end sft_sgn_mag;

architecture rtl of sft_sgn_mag is
	type sft_array is array (0 to size-1) of soft_scalar;
	signal sfts : sft_array;
	type sgn_array is array (0 to size-1) of boolean;
	signal sgns : sgn_array;
	type mag_array is array (0 to size-1) of mag_scalar;
	signal mags : mag_array;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				sfts(addr) <= isft;
				sgns(addr) <= isgn;
				mags(addr) <= imag;
			end if;
			osft <= sfts(addr);
			osgn <= sgns(addr);
			omag <= mags(addr);
		end if;
	end process;
end rtl;


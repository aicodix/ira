-- scalar offset from block location and current shift
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;

entity off_scalar is
	port (
		clock : in std_logic;
		clken : in boolean;
		ioff : in block_offset;
		ishi : in block_shift;
		ibs : in block_shift;
		ooff : out scalar_offset
	);
end off_scalar;

architecture rtl of off_scalar is
	function sca_off (off : block_offset; shi, bs : block_shift) return scalar_offset is
	begin
		if shi + bs < block_scalars then
			return block_scalars * off + shi + bs;
		else
			return block_scalars * off + shi + bs - block_scalars;
		end if;
	end function;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if clken then
				ooff <= sca_off(ioff, ishi, ibs);
			end if;
		end if;
	end process;
end rtl;


-- interleaver address generator for scalar decoder
--
-- Copyright 2022 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;

entity itl_scalar is
	port (
		clock : in std_logic;
		start : in boolean;
		ptys : in block_parities;
		pos : out scalar_offset;
		last : out boolean;
		last_next : out boolean
	);
end itl_scalar;

architecture rtl of itl_scalar is
	signal msgs : scalar_messages;
	signal cs : natural range 0 to code_scalars-block_scalars := code_scalars - block_scalars;
	signal bs : natural range 0 to block_scalars-1 := block_scalars-1;
begin
	pos <= cs + bs;
	last_next <= bs = block_scalars-1 and cs = code_scalars-2*block_scalars;
	last <= bs = block_scalars-1 and cs = code_scalars-block_scalars;

	process (clock)
	begin
		if rising_edge(clock) then
			if start then
				cs <= 0;
				bs <= 0;
				msgs <= BLOCK_SCALARS * (CODE_BLOCKS - ptys);
			elsif cs < msgs then
				cs <= cs + 1;
--				report "MSG" & HT & integer'image(cs) & HT & integer'image(bs);
			elsif not (cs = code_scalars-block_scalars and bs = block_scalars-1) then
				if cs = code_scalars-block_scalars then
					cs <= msgs;
					bs <= bs + 1;
				else
					cs <= cs + block_scalars;
				end if;
--				report "PTY" & HT & integer'image(cs) & HT & integer'image(bs);
			end if;
		end if;
	end process;
end rtl;


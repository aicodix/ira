-- interleaver address generator for vector decoder
--
-- Copyright 2022 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_vector.all;

entity itl_vector is
	port (
		clock : in std_logic;
		reset : in std_logic;
		clken : in boolean;
		ptys : in vector_parities;
		pos : out vector_offset;
		idx : out vector_shift;
		last : out boolean;
		last_next : out boolean
	);
end itl_vector;

architecture rtl of itl_vector is
	signal msgs : vector_messages;
	signal cv : natural range 0 to code_vectors-block_vectors := 0;
	signal bv : natural range 0 to block_vectors-1 := 0;
	signal vs : vector_shift := 0;
begin
	pos <= cv + bv;
	idx <= vs;
	last_next <= bv = block_vectors-1 and vs = vector_scalars-1 and cv = code_vectors-2*block_vectors;
	last <= bv = block_vectors-1 and vs = vector_scalars-1 and cv = code_vectors-block_vectors;

	process (clock, reset)
	begin
		if reset = '1' then
			cv <= 0;
			bv <= 0;
			vs <= 0;
		elsif rising_edge(clock) then
			if clken then
				if cv < msgs then
					if bv = block_vectors-1 then
						bv <= 0;
						if vs = vector_scalars-1 then
							vs <= 0;
							cv <= cv + block_vectors;
						else
							vs <= vs + 1;
						end if;
					else
						bv <= bv + 1;
					end if;
					if cv = 0 then
						msgs <= CODE_VECTORS - ptys;
					end if;
--					report "MSG" & HT & integer'image(cv) & HT & integer'image(bv) & HT & integer'image(vs);
				else
					if cv = code_vectors-block_vectors then
						cv <= msgs;
						if bv = block_vectors-1 then
							bv <= 0;
							if vs = vector_scalars-1 then
								vs <= 0;
								cv <= 0;
							else
								vs <= vs + 1;
							end if;
						else
							bv <= bv + 1;
						end if;
					else
						cv <= cv + block_vectors;
					end if;
--					report "PTY" & HT & integer'image(cv) & HT & integer'image(bv) & HT & integer'image(vs);
				end if;
			end if;
		end if;
	end process;
end rtl;


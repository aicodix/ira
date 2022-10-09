-- interleaver address generator for vector decoder
--
-- Copyright 2022 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_vector.all;

entity itl_vector is
	port (
		clock : in std_logic;
		start : in boolean;
		ptys : in vector_parities;
		pos : out vector_offset;
		idx : out vector_shift;
		last : out boolean;
		last_next : out boolean
	);
end itl_vector;

architecture rtl of itl_vector is
	signal msgs : vector_messages;
	signal cv : natural range 0 to code_vectors-block_vectors := code_vectors-block_vectors;
	signal bv : natural range 0 to block_vectors-1 := block_vectors-1;
	signal vs : vector_shift := vector_scalars-1;
begin
	pos <= cv + bv;
	idx <= vs;
	last_next <= bv = block_vectors-1 and vs = vector_scalars-1 and cv = code_vectors-2*block_vectors;
	last <= bv = block_vectors-1 and vs = vector_scalars-1 and cv = code_vectors-block_vectors;

	process (clock)
	begin
		if rising_edge(clock) then
			if start then
				cv <= 0;
				bv <= 0;
				vs <= 0;
				msgs <= CODE_VECTORS - ptys;
			elsif cv < msgs then
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
--				report "MSG" & HT & integer'image(cv) & HT & integer'image(bv) & HT & integer'image(vs);
			elsif not (cv = code_vectors-block_vectors and bv = block_vectors-1 and vs = vector_scalars-1) then
				if cv = code_vectors-block_vectors then
					cv <= msgs;
					if bv = block_vectors-1 then
						bv <= 0;
						if vs /= vector_scalars-1 then
							vs <= vs + 1;
						end if;
					else
						bv <= bv + 1;
					end if;
				else
					cv <= cv + block_vectors;
				end if;
--				report "PTY" & HT & integer'image(cv) & HT & integer'image(bv) & HT & integer'image(vs);
			end if;
		end if;
	end process;
end rtl;


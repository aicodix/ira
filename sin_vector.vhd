-- vector soft input interleaver
--
-- Copyright 2022 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;
use work.ldpc_vector.all;
use work.table_vector.all;

entity sin_vector is
	port (
		clock : in std_logic;
		ready : out boolean := true;
		flush : in boolean;
		istart : in boolean;
		ostart : out boolean := false;
		isoft : in vsft_scalar;
		osoft : out vsft_vector
	);
end sin_vector;

architecture rtl of sin_vector is
	signal itl_last, itl_last_next : boolean;
	signal itl_idx : vector_shift;
	signal var_wren, var_rden : boolean := false;
	signal vec_wren : bool_vector := (others => false);
	signal var_wpos, var_rpos : natural range 0 to code_vectors-1;
	signal ptys : vector_parities := init_vector_parities;
begin
	itl_inst : entity work.itl_vector
		port map (clock,
			istart,
			ptys,
			var_wpos,
			itl_idx,
			itl_last,
			itl_last_next);

	vec_wren <= index_to_mask(var_wren, itl_idx);
	vector_inst : for idx in soft_vector'range generate
		scalar_inst : entity work.var_scalar
			generic map (code_vectors)
			port map (clock,
				vec_wren(idx),
				var_rden,
				var_wpos,
				var_rpos,
				isoft,
				osoft(idx));
	end generate;

	process (clock)
	begin
		if rising_edge(clock) then
			if istart then
				var_wren <= true;
			elsif itl_last_next then
				ready <= false;
			elsif itl_last then
				var_wren <= false;
			end if;
			if flush then
				var_rpos <= 0;
				var_rden <= true;
			elsif var_rpos /= code_vectors-1 then
				var_rpos <= var_rpos + 1;
				if var_rpos = code_vectors-2 then
					ready <= true;
				end if;
			else
				var_rden <= false;
			end if;
			ostart <= flush;
		end if;
	end process;
end rtl;


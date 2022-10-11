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
		reset : in boolean;
		iready : out boolean := true;
		ivalid : in boolean;
		isoft : in vsft_scalar;
		oflush : in boolean;
		ostart : out boolean := false;
		osoft : out vsft_vector
	);
end sin_vector;

architecture rtl of sin_vector is
	signal input : boolean := true;
	signal itl_clken : boolean;
	signal itl_last, itl_last_next : boolean;
	signal itl_idx : vector_shift;
	signal var_rden : boolean := false;
	signal var_rpos : natural range 0 to code_vectors-1 := code_vectors-1;
	signal var_wren : bool_vector;
	signal var_wpos : natural range 0 to code_vectors-1;
	signal ptys : vector_parities := init_vector_parities;
begin
	itl_clken <= ivalid and input;
	itl_inst : entity work.itl_vector
		port map (clock, reset,
			itl_clken,
			ptys,
			var_wpos,
			itl_idx,
			itl_last,
			itl_last_next);

	var_wren <= index_to_mask(ivalid and input, itl_idx);
	vector_inst : for idx in soft_vector'range generate
		scalar_inst : entity work.var_scalar
			generic map (code_vectors)
			port map (clock,
				var_wren(idx),
				var_rden,
				var_wpos,
				var_rpos,
				isoft,
				osoft(idx));
	end generate;

	process (clock)
	begin
		if rising_edge(clock) then
			if reset then
				iready <= true;
				ostart <= false;
				input <= true;
				var_rden <= false;
				var_rpos <= code_vectors-1;
			else
				if itl_last_next then
					iready <= false;
				elsif itl_last then
					input <= false;
				end if;
				if oflush then
					var_rpos <= 0;
					var_rden <= true;
				elsif var_rpos /= code_vectors-1 then
					var_rpos <= var_rpos + 1;
					if var_rpos = code_vectors-2 then
						input <= true;
						iready <= true;
					end if;
				else
					var_rden <= false;
				end if;
				ostart <= oflush;
			end if;
		end if;
	end process;
end rtl;


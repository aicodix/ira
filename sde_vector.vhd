-- vector soft ouput deinterleaver
--
-- Copyright 2022 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;
use work.ldpc_vector.all;
use work.table_vector.all;

entity sde_vector is
	port (
		clock : in std_logic;
		ready : out boolean := true;
		fetch : in boolean;
		istart : in boolean;
		ostart : out boolean := false;
		isoft : in vsft_vector;
		osoft : out vsft_scalar
	);
end sde_vector;

architecture rtl of sde_vector is
	signal itl_last, itl_last_next : boolean;
	signal itl_idx, didx : vector_shift;
	signal var_wren, var_rden : boolean := false;
	signal vec_rden : bool_vector := (others => false);
	signal var_wpos, var_rpos : natural range 0 to code_vectors-1;
	signal var_osft : vsft_vector;
	signal ptys : vector_parities := init_vector_parities;
begin
	itl_inst : entity work.itl_vector
		port map (clock,
			fetch,
			ptys,
			var_rpos,
			itl_idx,
			itl_last,
			itl_last_next);

	osoft <= var_osft(didx);
	vec_rden <= index_to_mask(var_rden, itl_idx);
	vector_inst : for idx in soft_vector'range generate
		scalar_inst : entity work.var_scalar
			generic map (code_vectors)
			port map (clock,
				var_wren,
				vec_rden(idx),
				var_wpos,
				var_rpos,
				isoft(idx),
				var_osft(idx));
	end generate;

	process (clock)
	begin
		if rising_edge(clock) then
			if istart then
				var_wpos <= 0;
				var_wren <= true;
			elsif var_wpos /= code_vectors-1 then
				var_wpos <= var_wpos + 1;
				if var_wpos = code_vectors-2 then
					ready <= false;
				end if;
			else
				var_wren <= false;
			end if;
			if fetch then
				var_rden <= true;
			elsif itl_last_next then
				ready <= true;
			elsif itl_last then
				var_rden <= false;
			end if;
			ostart <= fetch;
			didx <= itl_idx;
		end if;
	end process;
end rtl;


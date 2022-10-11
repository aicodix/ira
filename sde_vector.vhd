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
		reset : in boolean;
		iready : out boolean := true;
		istart : in boolean;
		isoft : in vsft_vector;
		oready : in boolean;
		ovalid : out boolean := false;
		osoft : out vsft_scalar
	);
end sde_vector;

architecture rtl of sde_vector is
	signal output : boolean := false;
	signal itl_clken : boolean;
	signal itl_last, itl_last_next : boolean;
	signal itl_idx, didx : vector_shift;
	signal var_rden : bool_vector;
	signal var_rpos : natural range 0 to code_vectors-1;
	signal var_wren : boolean := false;
	signal var_wpos : natural range 0 to code_vectors-1 := code_vectors-1;
	signal var_osft : vsft_vector;
	signal ptys : vector_parities := init_vector_parities;
begin
	itl_clken <= oready and output;
	itl_inst : entity work.itl_vector
		port map (clock, reset,
			itl_clken,
			ptys,
			var_rpos,
			itl_idx,
			itl_last,
			itl_last_next);

	osoft <= var_osft(didx);
	var_rden <= index_to_mask(oready and output, itl_idx);
	vector_inst : for idx in soft_vector'range generate
		scalar_inst : entity work.var_scalar
			generic map (code_vectors)
			port map (clock,
				var_wren,
				var_rden(idx),
				var_wpos,
				var_rpos,
				isoft(idx),
				var_osft(idx));
	end generate;

	process (clock)
	begin
		if rising_edge(clock) then
			if reset then
				iready <= true;
				ovalid <= false;
				output <= false;
				var_wren <= false;
				var_wpos <= code_vectors-1;
			else
				if istart then
					var_wpos <= 0;
					var_wren <= true;
				elsif var_wpos /= code_vectors-1 then
					var_wpos <= var_wpos + 1;
					if var_wpos = code_vectors-2 then
						iready <= false;
						output <= true;
					end if;
				else
					var_wren <= false;
				end if;
				if itl_last_next then
					iready <= true;
				elsif itl_last then
					output <= false;
				end if;
				ovalid <= oready and output;
				didx <= itl_idx;
			end if;
		end if;
	end process;
end rtl;


-- vector variable nodes
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_vector.all;

entity var_vector is
	port (
		clock : in std_logic;
		wren : in bool_vector;
		rden : in bool_vector;
		wpos : in vpos_vector;
		rpos : in vpos_vector;
		isft : in vsft_vector;
		osft : out vsft_vector
	);
end var_vector;

architecture rtl of var_vector is
begin
	vector_inst : for idx in soft_vector'range generate
		scalar_inst : entity work.var_scalar
			generic map (code_vectors)
			port map (clock,
				wren(idx), rden(idx),
				wpos(idx), rpos(idx),
				isft(idx), osft(idx));
	end generate;
end rtl;


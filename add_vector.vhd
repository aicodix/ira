-- vector saturating addition
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_vector.all;

entity add_vector is
	port (
		clock : in std_logic;
		clken : in boolean;
		ivsft : in vsft_vector;
		icsft : in csft_vector;
		ovsft : out vsft_vector
	);
end add_vector;

architecture rtl of add_vector is
begin
	vector_inst : for idx in soft_vector'range generate
		scalar_inst : entity work.add_scalar
			port map (clock, clken,
				ivsft(idx), icsft(idx),
				ovsft(idx));
	end generate;
end rtl;


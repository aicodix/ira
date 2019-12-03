-- vector saturating addition
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity add_vector is
	port (
		clock : in std_logic;
		clken : in boolean;
		ivsgn : in sign_vector;
		ivmag : in vmag_vector;
		icsgn : in sign_vector;
		icmag : in cmag_vector;
		ovsgn : out sign_vector;
		ovmag : out vmag_vector
	);
end add_vector;

architecture rtl of add_vector is
begin
	vector_inst : for idx in soft_vector'range generate
		scalar_inst : entity work.add_scalar
			port map (clock, clken,
				ivsgn(idx), ivmag(idx),
				icsgn(idx), icmag(idx),
				ovsgn(idx), ovmag(idx));
	end generate;
end rtl;


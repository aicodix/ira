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
		isft : in soft_vector;
		isgn : in sgn_vector;
		imag : in mag_vector;
		osft : out soft_vector
	);
end add_vector;

architecture rtl of add_vector is
begin
	vector_inst : for idx in soft_vector'range generate
		scalar_inst : entity work.add_scalar
			port map (clock, clken,
				isft(idx), isgn(idx), imag(idx),
				osft(idx));
	end generate;
end rtl;


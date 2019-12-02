-- vector bit node links
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity bnl_vector is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to size-1;
		rpos : in natural range 0 to size-1;
		isgn : in sgn_vector;
		osgn : out sgn_vector;
		imag : in mag_vector;
		omag : out mag_vector
	);
end bnl_vector;

architecture rtl of bnl_vector is
begin
	vector_inst : for idx in soft_vector'range generate
		scalar_inst : entity work.bnl_scalar
			generic map (size)
			port map (clock, wren, rden, wpos, rpos,
				isgn(idx), osgn(idx),
				imag(idx), omag(idx));
	end generate;
end rtl;


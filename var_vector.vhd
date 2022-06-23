-- vector variable nodes
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ldpc_scalar.all;
use work.ldpc_vector.all;

entity var_vector is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to size-1;
		rpos : in natural range 0 to size-1;
		isft : in vsft_vector;
		osft : out vsft_vector
	);
end var_vector;

architecture rtl of var_vector is
	constant addr_width : positive := depth_to_width(size);
	constant data_width : positive := vsft_vector_logic'length;
	signal waddr : std_logic_vector(addr_width-1 downto 0);
	signal raddr : std_logic_vector(addr_width-1 downto 0);
	signal odata : vsft_vector_logic;
	signal idata : vsft_vector_logic;
begin
	ram_inst : entity work.sdp_ram
		generic map (size, addr_width, data_width)
		port map (clock,
			bool_to_logic(wren), bool_to_logic(rden),
			waddr, raddr, idata, odata);

	waddr <= std_logic_vector(to_unsigned(wpos, addr_width));
	raddr <= std_logic_vector(to_unsigned(rpos, addr_width));
	idata <= vsft_to_logic(isft);
	osft <= logic_to_vsft(odata);
end rtl;


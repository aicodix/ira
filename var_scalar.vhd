-- scalar variable nodes
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ldpc_scalar.all;

entity var_scalar is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to size-1;
		rpos : in natural range 0 to size-1;
		isft : in vsft_scalar;
		osft : out vsft_scalar
	);
end var_scalar;

architecture rtl of var_scalar is
	constant addr_width : positive := depth_to_width(size);
	signal waddr : std_logic_vector(addr_width-1 downto 0);
	signal raddr : std_logic_vector(addr_width-1 downto 0);
	signal idata : vsft_scalar_logic;
	signal odata : vsft_scalar_logic;
begin
	ram_inst : entity work.sdp_ram
		generic map (size, addr_width, vsft_scalar_logic'length)
		port map (clock,
			bool_to_logic(wren), bool_to_logic(rden),
			waddr, raddr, idata, odata);

	waddr <= std_logic_vector(to_unsigned(wpos, addr_width));
	raddr <= std_logic_vector(to_unsigned(rpos, addr_width));
	idata <= vsft_to_logic(isft);
	osft <= logic_to_vsft(odata);
end rtl;


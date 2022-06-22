-- scalar bit node links
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ldpc_scalar.all;

entity bnl_scalar is
	generic (
		size : positive
	);
	port (
		clock : in std_logic;
		wren : in boolean;
		rden : in boolean;
		wpos : in natural range 0 to size-1;
		rpos : in natural range 0 to size-1;
		isft : in csft_scalar;
		osft : out csft_scalar
	);
end bnl_scalar;

architecture rtl of bnl_scalar is
	constant addr_width : positive := depth_to_width(size);
	signal waddr : std_logic_vector(addr_width-1 downto 0);
	signal raddr : std_logic_vector(addr_width-1 downto 0);
	signal idata : csft_scalar_logic;
	signal odata : csft_scalar_logic;
begin
	ram_inst : entity work.sdp_ram
		generic map (size, addr_width, csft_scalar_logic'length)
		port map (clock,
			bool_to_logic(wren), bool_to_logic(rden),
			waddr, raddr, idata, odata);

	waddr <= std_logic_vector(to_unsigned(wpos, addr_width));
	raddr <= std_logic_vector(to_unsigned(rpos, addr_width));
	idata <= csft_to_logic(isft);
	osft <= logic_to_csft(odata);
end rtl;


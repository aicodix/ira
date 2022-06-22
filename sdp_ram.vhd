-- simple dual port single clock ram
--
-- Copyright 2022 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sdp_ram is
	generic (
		addr_depth : positive;
		addr_width : positive;
		data_width : positive
	);
	port (
		clock : in std_logic;
		wren : in std_logic;
		rden : in std_logic;
		waddr : in std_logic_vector (addr_width-1 downto 0);
		raddr : in std_logic_vector (addr_width-1 downto 0);
		idata : in std_logic_vector (data_width-1 downto 0);
		odata : out std_logic_vector (data_width-1 downto 0) := (others => '0')
	);
end sdp_ram;

architecture rtl of sdp_ram is
	type data_array is array (addr_depth-1 downto 0) of std_logic_vector (data_width-1 downto 0);
	signal data : data_array := (others => (others => '0'));
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren = '1' then
				data(to_integer(unsigned(waddr))) <= idata;
			end if;
			if rden = '1' then
				odata <= data(to_integer(unsigned(raddr)));
			end if;
		end if;
	end process;
end rtl;


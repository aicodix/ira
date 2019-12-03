-- buffer for the vector check node processor
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;

entity buf_vector is
	port (
		clock : in std_logic;
		wren : in boolean;
		addr : in natural range 0 to degree_max-1;
		ivsgn : in sign_vector;
		ovsgn : out sign_vector;
		ivmag : in vmag_vector;
		ovmag : out vmag_vector;
		icmag : in cmag_vector;
		ocmag : out cmag_vector;
		iwdf : in boolean;
		owdf : out boolean;
		iloc : in location_scalar;
		oloc : out location_scalar;
		ioff : in offset_scalar;
		ooff : out offset_scalar;
		ishi : in shift_scalar;
		oshi : out shift_scalar
	);
end buf_vector;

architecture rtl of buf_vector is
	type wdfs_array is array (0 to degree_max-1) of boolean;
	signal wdfs : wdfs_array;
	type locs_array is array (0 to degree_max-1) of location_scalar;
	signal locs : locs_array;
	type offs_array is array (0 to degree_max-1) of offset_scalar;
	signal offs : offs_array;
	type shis_array is array (0 to degree_max-1) of shift_scalar;
	signal shis : shis_array;
begin
	vector_inst : for idx in soft_vector'range generate
		scalar_inst : entity work.fub_scalar
			generic map (degree_max)
			port map (clock, wren, addr,
				ivsgn(idx), ovsgn(idx),
				ivmag(idx), ovmag(idx),
				icmag(idx), ocmag(idx));
	end generate;

	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				wdfs(addr) <= iwdf;
				locs(addr) <= iloc;
				offs(addr) <= ioff;
				shis(addr) <= ishi;
			end if;
			owdf <= wdfs(addr);
			oloc <= locs(addr);
			ooff <= offs(addr);
			oshi <= shis(addr);
		end if;
	end process;
end rtl;


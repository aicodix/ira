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
		isft : in soft_vector;
		osft : out soft_vector;
		isgn : in sgn_vector;
		osgn : out sgn_vector;
		imag : in mag_vector;
		omag : out mag_vector;
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
	type mags_array is array (0 to degree_max-1) of mag_scalar;
	type mags_vector is array (0 to vector_scalars-1) of mags_array;
	signal mags : mags_vector;
	type sfts_array is array (0 to degree_max-1) of soft_scalar;
	type sfts_vector is array (0 to vector_scalars-1) of sfts_array;
	signal sfts : sfts_vector;
	type sgns_array is array (0 to degree_max-1) of sgn_vector;
	signal sgns : sgns_array;
	type wdfs_array is array (0 to degree_max-1) of boolean;
	signal wdfs : wdfs_array;
	type locs_array is array (0 to degree_max-1) of location_scalar;
	signal locs : locs_array;
	type offs_array is array (0 to degree_max-1) of offset_scalar;
	signal offs : offs_array;
	type shis_array is array (0 to degree_max-1) of shift_scalar;
	signal shis : shis_array;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				for idx in isft'range loop
					sfts(idx)(addr) <= isft(idx);
				end loop;
				for idx in imag'range loop
					mags(idx)(addr) <= imag(idx);
				end loop;
				sgns(addr) <= isgn;
				wdfs(addr) <= iwdf;
				locs(addr) <= iloc;
				offs(addr) <= ioff;
				shis(addr) <= ishi;
			end if;
			for idx in osft'range loop
				osft(idx) <= sfts(idx)(addr);
			end loop;
			for idx in omag'range loop
				omag(idx) <= mags(idx)(addr);
			end loop;
			osgn <= sgns(addr);
			owdf <= wdfs(addr);
			oloc <= locs(addr);
			ooff <= offs(addr);
			oshi <= shis(addr);
		end if;
	end process;
end rtl;


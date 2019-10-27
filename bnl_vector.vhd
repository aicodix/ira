-- bit node links for the vector decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;
use work.table.all;

entity bnl_vector is
	port (
		clock : in std_logic;
		wren : in boolean;
		wpos : in location_scalar;
		rpos : in location_scalar;
		isgn : in sgn_vector;
		osgn : out sgn_vector;
		imag : in mag_vector;
		omag : out mag_vector
	);
end bnl_vector;

architecture rtl of bnl_vector is
	type lmb is array (0 to locations_max-1) of boolean;
	type vslb is array (0 to vector_scalars-1) of lmb;
	signal sgns : vslb;
	type lmms is array (0 to locations_max-1) of mag_scalar;
	type vsms is array (0 to vector_scalars-1) of lmms;
	signal mags : vsms;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if wren then
				for idx in isgn'range loop
					sgns(idx)(wpos) <= isgn(idx);
				end loop;
				for idx in imag'range loop
					mags(idx)(wpos) <= imag(idx);
				end loop;
			end if;
			for idx in osgn'range loop
				osgn(idx) <= sgns(idx)(rpos);
			end loop;
			for idx in omag'range loop
				omag(idx) <= mags(idx)(rpos);
			end loop;
		end if;
	end process;
end rtl;


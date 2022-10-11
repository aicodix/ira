-- scalar soft output deinterleaver
--
-- Copyright 2022 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;
use work.table_scalar.all;

entity sde_scalar is
	port (
		clock : in std_logic;
		reset : in boolean;
		iready : out boolean := true;
		istart : in boolean;
		isoft : in vsft_scalar;
		oready : in boolean;
		ovalid : out boolean := false;
		osoft : out vsft_scalar
	);
end sde_scalar;

architecture rtl of sde_scalar is
	signal output : boolean := false;
	signal itl_clken : boolean;
	signal itl_last, itl_last_next : boolean;
	signal var_rden : boolean;
	signal var_rpos : natural range 0 to code_scalars-1;
	signal var_wren : boolean := false;
	signal var_wpos : natural range 0 to code_scalars-1 := code_scalars-1;
	signal ptys : block_parities := init_block_parities;
begin
	itl_clken <= oready and output;
	itl_inst : entity work.itl_scalar
		port map (clock, reset,
			itl_clken,
			ptys,
			var_rpos,
			itl_last,
			itl_last_next);

	var_rden <= oready and output;
	var_inst : entity work.var_scalar
		generic map (code_scalars)
		port map (clock,
			var_wren, var_rden,
			var_wpos, var_rpos,
			isoft, osoft);

	process (clock)
	begin
		if rising_edge(clock) then
			if reset then
				iready <= true;
				ovalid <= false;
				output <= false;
				var_wren <= false;
				var_wpos <= code_scalars-1;
			else
				if istart then
					var_wpos <= 0;
					var_wren <= true;
				elsif var_wpos /= code_scalars-1 then
					var_wpos <= var_wpos + 1;
					if var_wpos = code_scalars-2 then
						iready <= false;
						output <= true;
					end if;
				else
					var_wren <= false;
				end if;
				if itl_last_next then
					iready <= true;
				elsif itl_last then
					output <= false;
				end if;
				ovalid <= oready and output;
			end if;
		end if;
	end process;
end rtl;


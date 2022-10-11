-- scalar soft input interleaver
--
-- Copyright 2022 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;
use work.table_scalar.all;

entity sin_scalar is
	port (
		clock : in std_logic;
		reset : in boolean;
		iready : out boolean := true;
		ivalid : in boolean;
		isoft : in vsft_scalar;
		oflush : in boolean;
		ostart : out boolean := false;
		osoft : out vsft_scalar
	);
end sin_scalar;

architecture rtl of sin_scalar is
	signal input : boolean := true;
	signal itl_clken : boolean;
	signal itl_last, itl_last_next : boolean;
	signal var_rden : boolean := false;
	signal var_rpos : natural range 0 to code_scalars-1 := code_scalars-1;
	signal var_wren : boolean;
	signal var_wpos : natural range 0 to code_scalars-1;
	signal ptys : block_parities := init_block_parities;
begin
	itl_clken <= ivalid and input;
	itl_inst : entity work.itl_scalar
		port map (clock, reset,
			itl_clken,
			ptys,
			var_wpos,
			itl_last,
			itl_last_next);

	var_wren <= ivalid and input;
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
				ostart <= false;
				input <= true;
				var_rden <= false;
				var_rpos <= code_scalars-1;
			else
				if itl_last_next then
					iready <= false;
				elsif itl_last then
					input <= false;
				end if;
				if oflush then
					var_rpos <= 0;
					var_rden <= true;
				elsif var_rpos /= code_scalars-1 then
					var_rpos <= var_rpos + 1;
					if var_rpos = code_scalars-2 then
						input <= true;
						iready <= true;
					end if;
				else
					var_rden <= false;
				end if;
				ostart <= oflush;
			end if;
		end if;
	end process;
end rtl;


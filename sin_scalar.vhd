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
		ready : out boolean := true;
		flush : in boolean;
		istart : in boolean;
		ostart : out boolean := false;
		isoft : in vsft_scalar;
		osoft : out vsft_scalar
	);
end sin_scalar;

architecture rtl of sin_scalar is
	signal itl_last, itl_last_next : boolean;
	signal var_wren, var_rden : boolean := false;
	signal var_wpos, var_rpos : natural range 0 to code_scalars-1;
	signal ptys : block_parities := init_block_parities;
begin
	itl_inst : entity work.itl_scalar
		port map (clock,
			istart,
			ptys,
			var_wpos,
			itl_last,
			itl_last_next);

	var_inst : entity work.var_scalar
		generic map (code_scalars)
		port map (clock,
			var_wren, var_rden,
			var_wpos, var_rpos,
			isoft, osoft);

	process (clock)
	begin
		if rising_edge(clock) then
			if istart then
				var_wren <= true;
			elsif itl_last_next then
				ready <= false;
			elsif itl_last then
				var_wren <= false;
			end if;
			if flush then
				var_rpos <= 0;
				var_rden <= true;
			elsif var_rpos /= code_scalars-1 then
				var_rpos <= var_rpos + 1;
				if var_rpos = code_scalars-2 then
					ready <= true;
				end if;
			else
				var_rden <= false;
			end if;
			ostart <= flush;
		end if;
	end process;
end rtl;


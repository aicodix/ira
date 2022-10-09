-- testbench for the scalar soft output deinterleaver
--
-- Copyright 2022 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.ldpc_scalar.all;

entity sde_scalar_tb is
end sde_scalar_tb;

architecture behavioral of sde_scalar_tb is
	signal clock : std_logic := '0';
	signal reset : std_logic := '1';
	signal done : boolean := false;
	signal sde_ready : boolean;
	signal sde_fetch : boolean := false;
	signal sde_istart : boolean := false;
	signal sde_ostart : boolean;
	signal sde_isoft : vsft_scalar := soft_to_vsft(0);
	signal sde_osoft : vsft_scalar;
begin
	sde_inst : entity work.sde_scalar
		port map (clock,
			sde_ready, sde_fetch,
			sde_istart, sde_ostart,
			sde_isoft, sde_osoft);

	clk_gen : process
	begin
		while not done loop
			wait for 5 ns;
			clock <= not clock;
		end loop;
		wait;
	end process;

	rst_gen : process
	begin
		wait for 100 ns;
		reset <= '0';
		wait;
	end process;

	end_sim : process (reset, clock)
		constant max : positive := 3*code_scalars;
		variable num : natural range 0 to max;
	begin
		if reset = '1' then
			num := 0;
		elsif rising_edge(clock) then
			if not sde_ready then
				num := 0;
			elsif num < max then
				num := num + 1;
			else
				done <= true;
			end if;
		end if;
	end process;

	start_swap : process (reset, clock)
		variable prv : boolean;
	begin
		if reset = '1' then
			prv := true;
		elsif rising_edge(clock) then
			if prv and not sde_ready then
				sde_fetch <= true;
			else
				sde_fetch <= false;
			end if;
			prv := sde_ready;
		end if;
	end process;

	soft_input : process (reset, clock)
		file input : text open read_mode is "sde_scalar_tb_inp.txt";
		variable buf : line;
		variable val : soft_scalar;
		variable pos : natural range 0 to code_scalars;
		variable eof : boolean := false;
	begin
		if reset = '1' then
			pos := 0;
		elsif rising_edge(clock) and sde_ready and not eof then
			if pos = 0 then
				readline(input, buf);
				sde_istart <= true;
			else
				sde_istart <= false;
				read(buf, val);
				sde_isoft <= soft_to_vsft(val);
			end if;
			if pos = code_scalars then
				pos := 0;
				if endfile(input) then
					eof := true;
				end if;
			else
				pos := pos + 1;
			end if;
		end if;
	end process;

	soft_output : process (reset, clock)
		file output : text open write_mode is "sde_scalar_tb_out.txt";
		variable buf : line;
		variable val : soft_scalar;
		variable pos : natural range 0 to code_scalars;
	begin
		if reset = '1' then
			pos := code_scalars;
		elsif rising_edge(clock) then
			if sde_ostart then
				pos := 0;
			elsif pos < code_scalars then
				val := vsft_to_soft(sde_osoft);
				write(buf, HT);
				write(buf, val);
				pos := pos + 1;
				if pos = code_scalars then
					writeline(output, buf);
				end if;
			end if;
		end if;
	end process;
end behavioral;


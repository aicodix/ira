-- testbench for the vector soft input interleaver
--
-- Copyright 2022 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.ldpc_scalar.all;
use work.ldpc_vector.all;

entity sin_vector_tb is
end sin_vector_tb;

architecture behavioral of sin_vector_tb is
	signal clock : std_logic := '0';
	signal reset : std_logic := '1';
	signal done : boolean := false;
	signal sin_reset : boolean := false;
	signal sin_iready : boolean;
	signal sin_ivalid : boolean := false;
	signal sin_isoft : vsft_scalar := soft_to_vsft(0);
	signal sin_oflush : boolean := false;
	signal sin_ostart : boolean;
	signal sin_osoft : vsft_vector;
begin
	sin_inst : entity work.sin_vector
		port map (clock, sin_reset,
			sin_iready, sin_ivalid, sin_isoft,
			sin_oflush, sin_ostart, sin_osoft);

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
			if not sin_iready then
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
			if prv and not sin_iready then
				sin_oflush <= true;
			else
				sin_oflush <= false;
			end if;
			prv := sin_iready;
		end if;
	end process;

	soft_input : process (reset, clock)
		file input : text open read_mode is "sin_vector_tb_inp.txt";
		variable buf : line;
		variable val : soft_scalar;
		variable pos : natural range 0 to code_scalars-1;
		variable eof : boolean := false;
	begin
		if reset = '1' then
			pos := 0;
		elsif rising_edge(clock) then
			if sin_iready and not eof then
				if pos = 0 then
					readline(input, buf);
				end if;
				read(buf, val);
				sin_isoft <= soft_to_vsft(val);
				sin_ivalid <= true;
				if pos = code_scalars-1 then
					pos := 0;
					if endfile(input) then
						eof := true;
					end if;
				else
					pos := pos + 1;
				end if;
			else
				sin_ivalid <= false;
			end if;
		end if;
	end process;

	soft_output : process (reset, clock)
		file output : text open write_mode is "sin_vector_tb_out.txt";
		variable buf : line;
		variable val : soft_vector;
		variable pos : natural range 0 to code_vectors;
	begin
		if reset = '1' then
			pos := code_vectors;
		elsif rising_edge(clock) then
			if sin_ostart then
				pos := 0;
			elsif pos < code_vectors then
				val := vsft_to_soft(sin_osoft);
				for idx in val'range loop
					write(buf, HT);
					write(buf, val(idx));
				end loop;
				pos := pos + 1;
				if pos = code_vectors then
					writeline(output, buf);
				end if;
			end if;
		end if;
	end process;
end behavioral;


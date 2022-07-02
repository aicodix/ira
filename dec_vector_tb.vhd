-- testbench for the vector decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.ldpc_scalar.all;

entity dec_vector_tb is
end dec_vector_tb;

architecture behavioral of dec_vector_tb is
	signal clock : std_logic := '0';
	signal reset : std_logic := '1';
	signal done : boolean := false;
	signal last_input : boolean := false;
	signal last_output : boolean := false;
	signal dec_iready : boolean;
	signal dec_ivalid : boolean := false;
	signal dec_isoft : soft_scalar := 0;
	signal dec_oready : boolean := true;
	signal dec_ovalid : boolean;
	signal dec_osoft : soft_scalar;
begin
	dec_inst : entity work.dec_vector
		port map (clock, reset,
			dec_iready, dec_ivalid, dec_isoft,
			dec_oready, dec_ovalid, dec_osoft);

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
		constant max : positive := code_scalars;
		variable num : natural range 0 to max;
	begin
		if reset = '1' then
			num := 0;
		elsif rising_edge(clock) then
			if not last_output then
				num := 0;
			elsif num < max then
				num := num + 1;
			else
				done <= true;
			end if;
		end if;
	end process;

	counter : process (reset, clock)
		variable num : natural;
		variable prv_ovalid : boolean;
	begin
		if reset = '1' then
			num := 0;
			prv_ovalid := dec_ovalid;
		elsif rising_edge(clock) then
			if prv_ovalid and not dec_ovalid then
				if num >= code_scalars then
					report natural'image(num) & " clock cycles";
				end if;
				num := 0;
			else
				num := num + 1;
			end if;
			prv_ovalid := dec_ovalid;
		end if;
	end process;

	soft_input : process (reset, clock)
		file input : text open read_mode is "dec_vector_tb_inp.txt";
		variable buf : line;
		variable val : soft_scalar;
		variable pos : natural range 0 to code_scalars-1;
	begin
		if reset = '1' then
			pos := 0;
		elsif rising_edge(clock) then
			if pos = 0 and endfile(input) then
				dec_ivalid <= false;
				last_input <= true;
			elsif dec_iready then
				if pos = 0 then
					readline(input, buf);
				end if;
				read(buf, val);
				dec_isoft <= val;
				dec_ivalid <= true;
				if pos = code_scalars-1 then
					pos := 0;
				else
					pos := pos + 1;
				end if;
			end if;
		end if;
	end process;

	soft_output : process (reset, clock)
		file output : text open write_mode is "dec_vector_tb_out.txt";
		variable buf : line;
		variable val : soft_scalar;
		variable pos : natural range 0 to code_scalars-1;
	begin
		if reset = '1' then
			pos := 0;
		elsif rising_edge(clock) then
			if dec_ovalid then
				val := dec_osoft;
				write(buf, HT);
				write(buf, val);
				if pos = code_scalars-1 then
					writeline(output, buf);
					last_output <= last_input;
					pos := 0;
				else
					pos := pos + 1;
				end if;
			end if;
		end if;
	end process;
end behavioral;


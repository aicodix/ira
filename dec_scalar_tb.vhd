-- testbench for the scalar decoder
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.ldpc_scalar.all;

entity dec_scalar_tb is
end dec_scalar_tb;

architecture behavioral of dec_scalar_tb is
	signal clock : std_logic := '0';
	signal reset : std_logic := '1';
	signal done : boolean := false;
	signal dec_ready : boolean;
	signal dec_istart : boolean := false;
	signal dec_ostart : boolean;
	signal dec_isoft : soft_scalar := 0;
	signal dec_osoft : soft_scalar;
begin
	dec_inst : entity work.dec_scalar
		port map (clock, dec_ready,
			dec_istart, dec_ostart,
			dec_isoft, dec_osoft);

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
			if not dec_ready then
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
	begin
		if reset = '1' then
			num := 0;
		elsif rising_edge(clock) then
			if dec_istart then
				if num >= code_scalars then
					report natural'image(num) & " clock cycles";
				end if;
				num := 0;
			else
				num := num + 1;
			end if;
		end if;
	end process;

	soft_input : process (reset, clock)
		file input : text open read_mode is "dec_scalar_tb_inp.txt";
		variable buf : line;
		variable val : soft_scalar;
		variable pos : natural range 0 to code_scalars;
		variable eof : boolean := false;
	begin
		if reset = '1' then
			pos := 0;
		elsif rising_edge(clock) and dec_ready then
			if pos = 0 then
				if not eof then
					readline(input, buf);
				end if;
				dec_istart <= true;
			else
				dec_istart <= false;
				if eof then
					val := 0;
				else
					read(buf, val);
				end if;
				dec_isoft <= val;
			end if;
			if pos = code_scalars then
				if not eof then
					pos := 0;
				end if;
				if endfile(input) then
					eof := true;
				end if;
			else
				pos := pos + 1;
			end if;
		end if;
	end process;

	soft_output : process (reset, clock)
		file output : text open write_mode is "dec_scalar_tb_out.txt";
		variable buf : line;
		variable val : soft_scalar;
		variable pos : natural range 0 to code_scalars;
	begin
		if reset = '1' then
			pos := code_scalars;
		elsif rising_edge(clock) then
			if dec_ostart then
				pos := 0;
			elsif pos < code_scalars then
				val := dec_osoft;
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


-- testbench for the vector check node processor
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.ldpc_scalar.all;
use work.ldpc_vector.all;

entity cnp_vector_tb is
end cnp_vector_tb;

architecture behavioral of cnp_vector_tb is
	signal clock : std_logic := '0';
	signal reset : std_logic := '1';
	signal done : boolean := false;
	signal cnp_start : boolean := false;
	signal cnp_count : count_scalar;
	signal cnp_ready : boolean;
	signal cnp_valid : boolean;
	signal cnp_iseq : sequence_scalar;
	signal cnp_oseq : sequence_scalar;
	signal cnp_ivsft : vsft_vector := soft_to_vsft((others => 0));
	signal cnp_ovsft : vsft_vector;
	signal cnp_icsft : csft_vector := soft_to_csft((others => 0));
	signal cnp_ocsft : csft_vector;
	signal cnp_iwdf : boolean;
	signal cnp_owdf : boolean;
	signal cnp_iloc : vector_location;
	signal cnp_oloc : vector_location;
	signal cnp_ioff : vector_offset;
	signal cnp_ooff : vector_offset;
	signal cnp_ishi : vector_shift;
	signal cnp_oshi : vector_shift;
begin
	cnp_inst : entity work.cnp_vector
		port map (clock, reset,
			cnp_start, cnp_count,
			cnp_ready, cnp_valid,
			cnp_iseq, cnp_oseq,
			cnp_ivsft, cnp_ovsft,
			cnp_icsft, cnp_ocsft,
			cnp_iwdf, cnp_owdf,
			cnp_iloc, cnp_oloc,
			cnp_ioff, cnp_ooff,
			cnp_ishi, cnp_oshi);

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
		constant max : positive := 3*degree_max;
		variable num : natural range 0 to max;
	begin
		if reset = '1' then
			num := 0;
		elsif rising_edge(clock) then
			if cnp_start then
				num := 0;
			elsif num < max then
				num := num + 1;
			else
				done <= true;
			end if;
		end if;
	end process;

	soft_input : process (reset, clock)
		file input : text open read_mode is "cnp_vector_tb_inp.txt";
		variable buf : line;
		variable val : soft_vector;
		variable prv : soft_vector;
		variable wdf : boolean;
		variable loc : vector_location;
		variable off : vector_offset;
		variable shi : vector_shift;
		variable del : character;
		variable cnt : count_scalar;
		variable seq : sequence_scalar;
		variable num : natural range 0 to degree_max;
	begin
		if reset = '1' then
			num := 0;
		elsif rising_edge(clock) and cnp_ready then
			if num = 0 then
				readline(input, buf);
				read(buf, cnt);
				cnp_count <= cnt;
				read(buf, seq);
				cnp_iseq <= seq;
				cnp_start <= true;
			elsif not endfile(input) then
				cnp_start <= false;
				readline(input, buf);
				read(buf, wdf);
				cnp_iwdf <= wdf;
				read(buf, loc);
				cnp_iloc <= loc;
				read(buf, off);
				cnp_ioff <= off;
				read(buf, del);
				read(buf, shi);
				cnp_ishi <= shi;
				for idx in val'range loop
					read(buf, val(idx));
				end loop;
				cnp_ivsft <= soft_to_vsft(val);
				for idx in prv'range loop
					read(buf, prv(idx));
				end loop;
				cnp_icsft <= soft_to_csft(prv);
			end if;
			if num = cnt then
				if not endfile(input) then
					num := 0;
				end if;
			else
				num := num + 1;
			end if;
		end if;
	end process;

	soft_output : process (reset, clock)
		file output : text open write_mode is "cnp_vector_tb_out.txt";
		variable buf : line;
		variable val : soft_vector;
		variable wdf : boolean;
		variable loc : vector_location;
		variable off : vector_offset;
		variable shi : vector_shift;
		variable seq : sequence_scalar;
	begin
		if reset = '0' and rising_edge(clock) and cnp_valid then
			seq := cnp_oseq;
			write(buf, seq);
			write(buf, HT);
			wdf := cnp_owdf;
			write(buf, wdf);
			write(buf, HT);
			loc := cnp_oloc;
			write(buf, loc);
			write(buf, HT);
			off := cnp_ooff;
			write(buf, off);
			write(buf, ':');
			shi := cnp_oshi;
			write(buf, shi);
			val := csft_to_soft(cnp_ocsft);
			for idx in val'range loop
				write(buf, HT);
				write(buf, val(idx));
			end loop;
			writeline(output, buf);
		end if;
	end process;
end behavioral;


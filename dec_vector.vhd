-- SISO vector decoder for IRA-LDPC codes
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;
use work.ldpc_vector.all;
use work.table_vector.all;

entity dec_vector is
	port (
		clock : in std_logic;
		ready : out boolean := true;
		istart : in boolean;
		ostart : out boolean := false;
		isoft : in soft_vector;
		osoft : out soft_vector
	);
end dec_vector;

architecture rtl of dec_vector is
	signal swap_cv : natural range 0 to code_vectors := code_vectors;
	subtype vector_index is natural range 0 to vector_scalars-1;
	signal prev_vsft : vsft_scalar;
	signal var_wren, var_rden : boolean := false;
	signal var_wpos, var_rpos : natural range 0 to code_vectors-1;
	signal var_isft, var_osft : vsft_vector;
	signal bnl_wren, bnl_rden : boolean := false;
	signal bnl_wpos, bnl_rpos : vector_location;
	signal bnl_isft, bnl_osft : csft_vector;
	signal first_wdf : boolean;
	signal wdf_wren, wdf_rden : boolean := false;
	signal wdf_wpos, wdf_rpos : vector_location;
	signal wdf_iwdf, wdf_owdf : boolean;
	signal loc_rden : boolean := false;
	signal loc_rpos : vector_location;
	signal loc_ooff : vector_offset;
	signal loc_oshi : vector_shift;
	signal cnt_rpos : natural range 0 to vector_parities_max-1;
	signal cnt_ocnt : count_scalar;
	signal cnp_start : boolean := false;
	signal cnp_count : count_scalar;
	signal cnp_ready, cnp_valid : boolean;
	signal cnp_iseq, cnp_oseq : sequence_scalar;
	signal cnp_ivsft, cnp_ovsft : vsft_vector;
	signal cnp_icsft, cnp_ocsft : csft_vector;
	signal cnp_iwdf, cnp_owdf : boolean;
	signal cnp_iloc, cnp_oloc : vector_location;
	signal cnp_ioff, cnp_ooff : vector_offset;
	signal cnp_ishi, cnp_oshi : vector_shift;
	signal ror_shift : natural range 0 to soft_vector'length-1;
	signal ror_ivsft, ror_ovsft : vsft_vector;
	signal rol_clken : boolean;
	signal rol_shift : natural range 0 to soft_vector'length-1;
	signal rol_ivsft, rol_ovsft : vsft_vector;
	signal sub_clken : boolean;
	signal sub_ivsft, sub_ovsft : vsft_vector;
	signal sub_icsft, inv_sub_icsft : csft_vector;
	signal add_ivsft, add_ovsft : vsft_vector;
	signal add_icsft : csft_vector;
	signal ptys : vector_parities := init_vector_parities;
	signal inp_pty : natural range 0 to vector_parities_max;
	signal prev_start : boolean := false;
	type swap_start_delays is array (1 to 2) of boolean;
	signal swap_start_d : swap_start_delays := (others => false);
	signal inp_seq, out_seq : sequence_scalar;
	type inp_stages is array (0 to 8) of boolean;
	signal inp_stage : inp_stages := (others => false);
	type swap_stages is array (0 to 3) of boolean;
	signal swap_stage : swap_stages := (others => false);
	subtype num_scalar is natural range 0 to degree_max;
	signal inp_num : num_scalar := 0;
	signal inp_cnt : count_scalar := degree_max;
	signal inp_loc : vector_location;
	type out_stages is array (0 to 5) of boolean;
	signal out_stage : out_stages := (others => false);
	type out_off_delays is array (1 to 4) of vector_offset;
	signal out_off_d : out_off_delays;
	type out_shi_delays is array (1 to 2) of vector_shift;
	signal out_shi_d : out_shi_delays;
	type out_wdf_delays is array (1 to 4) of boolean;
	signal out_wdf_d : out_wdf_delays;
	type inp_num_delays is array (1 to 8) of num_scalar;
	signal inp_num_d : inp_num_delays;
	type inp_cnt_delays is array (1 to 8) of count_scalar;
	signal inp_cnt_d : inp_cnt_delays;
	type inp_seq_delays is array (1 to 8) of sequence_scalar;
	signal inp_seq_d : inp_seq_delays;
	type inp_loc_delays is array (1 to 8) of vector_location;
	signal inp_loc_d : inp_loc_delays;
	type inp_wdf_delays is array (1 to 6) of boolean;
	signal inp_wdf_d : inp_wdf_delays;
	type inp_off_delays is array (1 to 6) of vector_offset;
	signal inp_off_d : inp_off_delays;
	type inp_shi_delays is array (1 to 6) of vector_shift;
	signal inp_shi_d : inp_shi_delays;
	type inp_bnl_delays is array (1 to 2) of csft_vector;
	signal inp_bnl_d : inp_bnl_delays;

	function inv (val : csft_vector) return csft_vector is
		variable tmp : csft_vector;
	begin
		for idx in tmp'range loop
			tmp(idx) := (not val(idx).sgn, val(idx).mag);
		end loop;
		return tmp;
	end function;
begin
	loc_rden <= cnp_ready;
	loc_inst : entity work.loc_vector
		port map (clock,
			loc_rden, loc_rpos,
			loc_ooff, loc_oshi);

	wdf_rden <= cnp_ready;
	wdf_inst : entity work.wdf_vector
		port map (clock,
			wdf_wren, wdf_rden,
			wdf_wpos, wdf_rpos,
			wdf_iwdf, wdf_owdf);

	var_rden <= cnp_ready;
	var_inst : entity work.var_vector
		generic map (code_vectors)
		port map (clock,
			var_wren, var_rden,
			var_wpos, var_rpos,
			var_isft, var_osft);

	cnt_inst : entity work.cnt_vector
		port map (clock,
			cnt_rpos, cnt_ocnt);

	bnl_rden <= cnp_ready;
	bnl_inst : entity work.bnl_vector
		generic map (vector_locations_max)
		port map (clock,
			bnl_wren, bnl_rden,
			bnl_wpos, bnl_rpos,
			bnl_isft, bnl_osft);

	out_stage(0) <= cnp_valid;
	cnp_inst : entity work.cnp_vector
		port map (clock,
			cnp_start, cnp_count,
			cnp_ready, cnp_valid,
			cnp_iseq, cnp_oseq,
			cnp_ivsft, cnp_ovsft,
			cnp_icsft, cnp_ocsft,
			cnp_iwdf, cnp_owdf,
			cnp_iloc, cnp_oloc,
			cnp_ioff, cnp_ooff,
			cnp_ishi, cnp_oshi);

	ror_inst : entity work.ror_vector
		port map (clock, true,
			ror_shift,
			ror_ivsft, ror_ovsft);

	rol_clken <= cnp_ready;
	rol_inst : entity work.rol_vector
		port map (clock, rol_clken,
			rol_shift,
			rol_ivsft, rol_ovsft);

	sub_clken <= cnp_ready;
	inv_sub_icsft <= inv(sub_icsft);
	sub_inst : entity work.add_vector
		port map (clock, sub_clken,
			sub_ivsft, inv_sub_icsft,
			sub_ovsft);

	add_inst : entity work.add_vector
		port map (clock, true,
			add_ivsft, add_icsft,
			add_ovsft);

	process (clock)
	begin
		if rising_edge(clock) then
			if istart then
				swap_cv <= 0;
				swap_start_d(1) <= prev_start;
				prev_start <= istart;
				swap_stage(0) <= true;
			elsif swap_cv /= code_vectors then
				swap_start_d(1) <= false;
				swap_cv <= swap_cv + 1;
				if swap_cv = code_vectors-2 then
					ready <= false;
				end if;
				if swap_cv = code_vectors-1 then
					swap_stage(0) <= false;
				end if;
			end if;

			if swap_stage(0) then
				swap_start_d(2) <= swap_start_d(1);
				var_wren <= true;
				var_isft <= soft_to_vsft(isoft);
				var_wpos <= swap_cv;
				var_rpos <= swap_cv;
			end if;

			swap_stage(1) <= swap_stage(0);
			if swap_stage(1) then
				if not swap_stage(0) then
					var_wren <= false;
				end if;
				ostart <= swap_start_d(2);
			end if;

			swap_stage(2) <= swap_stage(1);
			if swap_stage(2) then
				osoft <= vsft_to_soft(var_osft);
			end if;

			swap_stage(3) <= swap_stage(2);
			if swap_stage(3) and not swap_stage(2) then
				inp_stage(0) <= true;
			end if;

			if inp_stage(0) then
				if cnp_ready then
					if inp_num = inp_cnt then
						inp_num <= 0;
						inp_cnt <= cnt_ocnt;
						if inp_pty+1 = ptys then
							if inp_seq+1 = iterations_max then
								inp_stage(0) <= false;
							else
								inp_seq <= inp_seq + 1;
								inp_pty <= 0;
							end if;
						else
							inp_pty <= inp_pty + 1;
						end if;
					else
						inp_num <= inp_num + 1;
					end if;
					if inp_num = 0 then
						if inp_pty = 0 then
							inp_loc <= 0;
						end if;
					elsif inp_loc+1 /= vector_locations_max then
						inp_loc <= inp_loc + 1;
					end if;
					if inp_num = 0 then
						if inp_pty+1 = ptys then
							cnt_rpos <= 0;
						elsif cnt_rpos+1 /= vector_parities_max then
							cnt_rpos <= cnt_rpos + 1;
						end if;
					end if;
				end if;
			else
				cnt_rpos <= 0;
				inp_cnt <= cnt_ocnt;
				inp_num <= 0;
				inp_pty <= 0;
				inp_seq <= 0;
				inp_loc <= 0;
			end if;

--			report boolean'image(inp_stage(0)) & HT & boolean'image(cnp_ready) & HT & integer'image(inp_seq) & HT & integer'image(inp_cnt) & HT & integer'image(inp_num) & HT & integer'image(inp_loc) & HT & integer'image(inp_pty);

			if inp_stage(0) and cnp_ready then
				loc_rpos <= inp_loc;
				wdf_rpos <= inp_loc;
				inp_num_d(1) <= inp_num;
				inp_cnt_d(1) <= inp_cnt;
				inp_seq_d(1) <= inp_seq;
				inp_loc_d(1) <= inp_loc;
			end if;

			inp_stage(1) <= inp_stage(0);
			if inp_stage(1) and cnp_ready then
				inp_num_d(2) <= inp_num_d(1);
				inp_cnt_d(2) <= inp_cnt_d(1);
				inp_seq_d(2) <= inp_seq_d(1);
				inp_loc_d(2) <= inp_loc_d(1);
			end if;

			inp_stage(2) <= inp_stage(1);
			if inp_stage(2) and cnp_ready then
				var_rpos <= loc_ooff;
				if inp_seq_d(2) = 0 then
					if inp_num_d(2) = 1 then
						inp_wdf_d(1) <= false;
					else
						inp_wdf_d(1) <= inp_off_d(1) = loc_ooff;
					end if;
				else
					inp_wdf_d(1) <= wdf_owdf;
				end if;
				inp_num_d(3) <= inp_num_d(2);
				inp_cnt_d(3) <= inp_cnt_d(2);
				inp_seq_d(3) <= inp_seq_d(2);
				inp_loc_d(3) <= inp_loc_d(2);
				inp_off_d(1) <= loc_ooff;
				inp_shi_d(1) <= loc_oshi;
			end if;

			inp_stage(3) <= inp_stage(2);
			if inp_stage(3) and cnp_ready then
				if inp_num_d(3) = 1 then
					first_wdf <= inp_wdf_d(1);
				elsif inp_num_d(3) /= 0 then
					wdf_wren <= true;
					wdf_wpos <= inp_loc_d(4);
					if inp_off_d(2) = inp_off_d(1) then
						wdf_iwdf <= inp_wdf_d(1);
					else
						wdf_iwdf <= first_wdf;
						first_wdf <= inp_wdf_d(1);
					end if;
				end if;
				inp_num_d(4) <= inp_num_d(3);
				inp_cnt_d(4) <= inp_cnt_d(3);
				inp_seq_d(4) <= inp_seq_d(3);
				inp_loc_d(4) <= inp_loc_d(3);
				inp_wdf_d(2) <= inp_wdf_d(1);
				inp_off_d(2) <= inp_off_d(1);
				inp_shi_d(2) <= inp_shi_d(1);
			end if;

			inp_stage(4) <= inp_stage(3);
			if inp_stage(4) and cnp_ready then
				if inp_num_d(4) = inp_cnt_d(4) then
					wdf_wpos <= inp_loc_d(4);
					wdf_iwdf <= first_wdf;
				end if;
				rol_shift <= inp_shi_d(2);
				rol_ivsft <= var_osft;
				bnl_rpos <= inp_loc_d(4);
				inp_num_d(5) <= inp_num_d(4);
				inp_cnt_d(5) <= inp_cnt_d(4);
				inp_seq_d(5) <= inp_seq_d(4);
				inp_loc_d(5) <= inp_loc_d(4);
				inp_wdf_d(3) <= inp_wdf_d(2);
				inp_off_d(3) <= inp_off_d(2);
				inp_shi_d(3) <= inp_shi_d(2);
			end if;

			inp_stage(5) <= inp_stage(4);
			if inp_stage(5) and cnp_ready then
				if inp_num_d(5) = inp_cnt_d(5) then
					wdf_wren <= false;
				end if;
				inp_num_d(6) <= inp_num_d(5);
				inp_cnt_d(6) <= inp_cnt_d(5);
				inp_seq_d(6) <= inp_seq_d(5);
				inp_loc_d(6) <= inp_loc_d(5);
				inp_wdf_d(4) <= inp_wdf_d(3);
				inp_off_d(4) <= inp_off_d(3);
				inp_shi_d(4) <= inp_shi_d(3);
			end if;

			inp_stage(6) <= inp_stage(5);
			if inp_stage(6) and cnp_ready then
				if inp_off_d(4) = code_vectors-1 and inp_shi_d(4) = vector_scalars-1 then
					prev_vsft <= rol_ovsft(vsft_vector'low);
					sub_ivsft <= soft_to_vsft(vmag_scalar'high) & rol_ovsft(vsft_vector'low+1 to vsft_vector'high);
				else
					sub_ivsft <= rol_ovsft;
				end if;
				if inp_seq_d(6) = 0 then
					sub_icsft <= (others => (false, 0));
					inp_bnl_d(1) <= (others => (false, 0));
				else
					sub_icsft <= bnl_osft;
					inp_bnl_d(1) <= bnl_osft;
				end if;
				inp_num_d(7) <= inp_num_d(6);
				inp_cnt_d(7) <= inp_cnt_d(6);
				inp_seq_d(7) <= inp_seq_d(6);
				inp_loc_d(7) <= inp_loc_d(6);
				inp_wdf_d(5) <= inp_wdf_d(4);
				inp_off_d(5) <= inp_off_d(4);
				inp_shi_d(5) <= inp_shi_d(4);
			end if;

			inp_stage(7) <= inp_stage(6);
			if inp_stage(7) and cnp_ready then
				inp_num_d(8) <= inp_num_d(7);
				inp_cnt_d(8) <= inp_cnt_d(7);
				inp_seq_d(8) <= inp_seq_d(7);
				inp_loc_d(8) <= inp_loc_d(7);
				inp_wdf_d(6) <= inp_wdf_d(5);
				inp_off_d(6) <= inp_off_d(5);
				inp_shi_d(6) <= inp_shi_d(5);
				inp_bnl_d(2) <= inp_bnl_d(1);
			end if;

			inp_stage(8) <= inp_stage(7);
			if inp_stage(8) and cnp_ready then
				cnp_start <= inp_num_d(8) = 0;
				cnp_count <= inp_cnt_d(8);
				cnp_ivsft <= sub_ovsft;
				cnp_icsft <= inp_bnl_d(2);
				cnp_iseq <= inp_seq_d(8);
				cnp_iloc <= inp_loc_d(8);
				cnp_iwdf <= inp_wdf_d(6);
				cnp_ioff <= inp_off_d(6);
				cnp_ishi <= inp_shi_d(6);
			end if;

--			report boolean'image(cnp_start) & HT & boolean'image(cnp_ready) & HT & integer'image(cnp_iseq) & HT & integer'image(cnp_iloc) & HT & integer'image(cnp_ioff) & HT & integer'image(cnp_ishi) & HT & boolean'image(cnp_iwdf) & HT & integer'image(cnp_count) & HT &
--				integer'image(vsft_to_soft(cnp_ivsft(0))) & HT & integer'image(vsft_to_soft(cnp_ivsft(1))) & HT & integer'image(vsft_to_soft(cnp_ivsft(2))) & HT & integer'image(vsft_to_soft(cnp_ivsft(3))) & HT & integer'image(vsft_to_soft(cnp_ivsft(4)));

--			report boolean'image(cnp_valid) & HT & boolean'image(cnp_ready) & HT & integer'image(cnp_oseq) & HT & integer'image(cnp_oloc) & HT & integer'image(cnp_ooff) & HT & integer'image(cnp_oshi) & HT & boolean'image(cnp_owdf) & HT &
--				integer'image(vsft_to_soft(cnp_ovsft(0))) & HT & integer'image(vsft_to_soft(cnp_ovsft(1))) & HT & integer'image(vsft_to_soft(cnp_ovsft(2))) & HT & integer'image(vsft_to_soft(cnp_ovsft(3))) & HT & integer'image(vsft_to_soft(cnp_ovsft(4))) & HT &
--				integer'image(csft_to_soft(cnp_ocsft(0))) & HT & integer'image(csft_to_soft(cnp_ocsft(1))) & HT & integer'image(csft_to_soft(cnp_ocsft(2))) & HT & integer'image(csft_to_soft(cnp_ocsft(3))) & HT & integer'image(csft_to_soft(cnp_ocsft(4)));

			if  out_stage(0) then
				add_ivsft <= cnp_ovsft;
				add_icsft <= cnp_ocsft;
				out_wdf_d(1) <= cnp_owdf;
				out_off_d(1) <= cnp_ooff;
				out_shi_d(1) <= cnp_oshi;
				bnl_wpos <= cnp_oloc;
				bnl_wren <= cnp_oseq = 0 or not cnp_owdf;
				if not cnp_owdf then
					bnl_isft <= cnp_ocsft;
				elsif cnp_oseq = 0 then
					bnl_isft <= (others => (false, 0));
				end if;
			else
				bnl_wren <= false;
			end if;

			out_stage(1) <= out_stage(0);
			if out_stage(1) then
				out_off_d(2) <= out_off_d(1);
				out_shi_d(2) <= out_shi_d(1);
				out_wdf_d(2) <= out_wdf_d(1);
			end if;

			out_stage(2) <= out_stage(1);
			if out_stage(2) then
				ror_shift <= out_shi_d(2);
				if out_off_d(2) = code_vectors-1 and out_shi_d(2) = vector_scalars-1 then
					ror_ivsft <= prev_vsft & add_ovsft(vsft_vector'low+1 to vsft_vector'high);
				else
					ror_ivsft <= add_ovsft;
				end if;
				out_off_d(3) <= out_off_d(2);
				out_wdf_d(3) <= out_wdf_d(2);
			end if;

			out_stage(3) <= out_stage(2);
			if out_stage(3) then
				out_off_d(4) <= out_off_d(3);
				out_wdf_d(4) <= out_wdf_d(3);
			end if;

			out_stage(4) <= out_stage(3);
			if out_stage(4) then
				var_isft <= ror_ovsft;
				var_wpos <= out_off_d(4);
				var_wren <= not out_wdf_d(4);
			end if;

			out_stage(5) <= out_stage(4);
			if out_stage(5) and not out_stage(4) then
				var_wren <= false;
				if out_stage = (out_stage'low to out_stage'high-1 => false) & true and
						not inp_stage(inp_stage'high) and cnp_ready then
					ready <= true;
				end if;
			end if;
		end if;
	end process;
end rtl;


-- SISO scalar decoder for IRA-LDPC codes
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc_scalar.all;
use work.table_scalar.all;

entity dec_scalar is
	port (
		clock : in std_logic;
		busy : out boolean := false;
		istart : in boolean;
		ostart : out boolean := false;
		isoft : in soft_scalar;
		osoft : out soft_scalar
	);
end dec_scalar;

architecture rtl of dec_scalar is
	signal swap_cs : natural range 0 to code_scalars := code_scalars;
	signal swap_bs : natural range 0 to block_scalars := block_scalars;
	signal var_wren, var_rden : boolean := false;
	signal var_wpos, var_rpos : natural range 0 to code_scalars-1;
	signal var_isft, var_osft : vsft_scalar;
	signal bnl_wren, bnl_rden : boolean := false;
	signal bnl_wpos, bnl_rpos : scalar_location;
	signal bnl_isft, bnl_osft : csft_scalar;
	signal loc_wren, loc_rden : boolean := false;
	signal loc_wpos, loc_rpos : block_location;
	signal loc_ioff, loc_ooff : block_offset;
	signal loc_ishi, loc_oshi : block_shift;
	signal cnt_wren : boolean := false;
	signal cnt_wpos, cnt_rpos : natural range 0 to block_parities_max-1;
	signal cnt_icnt, cnt_ocnt : count_scalar;
	signal cnp_start : boolean := false;
	signal cnp_count : count_scalar;
	signal cnp_busy, cnp_valid : boolean;
	signal cnp_iseq, cnp_oseq : sequence_scalar;
	signal cnp_ivsft, cnp_ovsft : vsft_scalar;
	signal cnp_ocsft : csft_scalar;
	signal cnp_iwdf, cnp_owdf : boolean;
	signal cnp_iloc, cnp_oloc : scalar_location;
	signal cnp_ioff, cnp_ooff : scalar_offset;
	signal off_clken : boolean;
	signal off_ioff : block_offset;
	signal off_ishi, off_ibs : block_shift;
	signal off_ooff : scalar_offset;
	signal sub_clken : boolean;
	signal sub_ivsft, sub_ovsft : vsft_scalar;
	signal sub_icsft, inv_sub_icsft : csft_scalar;
	signal add_ivsft, add_ovsft : vsft_scalar;
	signal add_icsft : csft_scalar;
	signal pty_blocks : block_parities := init_block_parities;
	signal msg_scalars : scalar_messages := BLOCK_SCALARS * (CODE_BLOCKS - init_block_parities);
	signal inp_pty : natural range 0 to block_parities_max;
	signal inp_bs : block_shift;
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
	signal inp_loc : scalar_location;
	signal inp_blk, inp_blk0 : block_location;
	type out_stages is array (0 to 3) of boolean;
	signal out_stage : out_stages := (others => false);
	type out_off_delays is array (1 to 2) of scalar_offset;
	signal out_off_d : out_off_delays;
	type out_wdf_delays is array (1 to 2) of boolean;
	signal out_wdf_d : out_wdf_delays;
	type inp_bs_delays is array (1 to 2) of block_shift;
	signal inp_bs_d : inp_bs_delays;
	type inp_num_delays is array (1 to 8) of num_scalar;
	signal inp_num_d : inp_num_delays;
	type inp_cnt_delays is array (1 to 8) of count_scalar;
	signal inp_cnt_d : inp_cnt_delays;
	type inp_seq_delays is array (1 to 8) of sequence_scalar;
	signal inp_seq_d : inp_seq_delays;
	type inp_loc_delays is array (1 to 8) of scalar_location;
	signal inp_loc_d : inp_loc_delays;
	type inp_wdf_delays is array (1 to 8) of boolean;
	signal inp_wdf_d : inp_wdf_delays;
	type inp_off_delays is array (1 to 4) of scalar_offset;
	signal inp_off_d : inp_off_delays;

	function inv (val : csft_scalar) return csft_scalar is
	begin
		return (not val.sgn, val.mag);
	end function;

begin
	loc_rden <= not cnp_busy;
	loc_inst : entity work.loc_scalar
		port map (clock,
			loc_wren, loc_rden,
			loc_wpos, loc_rpos,
			loc_ioff, loc_ooff,
			loc_ishi, loc_oshi);

	var_rden <= not cnp_busy;
	var_inst : entity work.var_scalar
		generic map (code_scalars)
		port map (clock,
			var_wren, var_rden,
			var_wpos, var_rpos,
			var_isft, var_osft);

	cnt_inst : entity work.cnt_scalar
		port map (clock, cnt_wren,
			cnt_wpos, cnt_rpos,
			cnt_icnt, cnt_ocnt);

	bnl_rden <= not cnp_busy;
	bnl_inst : entity work.bnl_scalar
		generic map (scalar_locations_max)
		port map (clock,
			bnl_wren, bnl_rden,
			bnl_wpos, bnl_rpos,
			bnl_isft, bnl_osft);

	out_stage(0) <= cnp_valid;
	cnp_inst : entity work.cnp_scalar
		port map (clock,
			cnp_start, cnp_count,
			cnp_busy, cnp_valid,
			cnp_iseq, cnp_oseq,
			cnp_ivsft, cnp_ovsft,
			cnp_ocsft,
			cnp_iwdf, cnp_owdf,
			cnp_iloc, cnp_oloc,
			cnp_ioff, cnp_ooff);

	off_clken <= not cnp_busy;
	off_inst : entity work.off_scalar
		port map (clock, off_clken,
			off_ioff, off_ishi,
			off_ibs, off_ooff);

	sub_clken <= not cnp_busy;
	inv_sub_icsft <= inv(sub_icsft);
	sub_inst : entity work.add_scalar
		port map (clock, sub_clken,
			sub_ivsft, inv_sub_icsft,
			sub_ovsft);

	add_inst : entity work.add_scalar
		port map (clock, true,
			add_ivsft, add_icsft,
			add_ovsft);

	process (clock)
	begin
		if rising_edge(clock) then
			if istart then
				swap_cs <= 0;
				swap_bs <= 0;
				swap_start_d(1) <= prev_start;
				prev_start <= istart;
				swap_stage(0) <= true;
			elsif swap_cs < msg_scalars then
				swap_start_d(1) <= false;
				swap_cs <= swap_cs + 1;
--				report "MSG" & HT & integer'image(swap_cs) & HT & integer'image(swap_bs);
			elsif swap_bs /= block_scalars then
				if swap_cs = code_scalars-block_scalars then
					swap_cs <= msg_scalars;
					swap_bs <= swap_bs + 1;
				else
					swap_cs <= swap_cs + block_scalars;
				end if;
				if swap_cs = code_scalars-2*block_scalars and swap_bs = block_scalars-1 then
					busy <= true;
				end if;
				if swap_cs = code_scalars-block_scalars and swap_bs = block_scalars-1 then
					swap_stage(0) <= false;
				end if;
--				report "PTY" & HT & integer'image(swap_cs) & HT & integer'image(swap_bs);
			end if;

			if swap_stage(0) then
				swap_start_d(2) <= swap_start_d(1);
				var_wren <= true;
				var_isft <= soft_to_vsft(isoft);
				var_wpos <= swap_cs + swap_bs;
				var_rpos <= swap_cs + swap_bs;
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
--				busy <= false;
			end if;

			if inp_stage(0) then
				if not cnp_busy then
					if inp_num = inp_cnt then
						inp_num <= 0;
						inp_cnt <= cnt_ocnt;
						if inp_bs+1 = block_scalars then
							inp_bs <= 0;
							if inp_pty+1 = pty_blocks then
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
							inp_bs <= inp_bs + 1;
						end if;
					else
						inp_num <= inp_num + 1;
					end if;
					if inp_num = 0 then
						if inp_pty = 0 and inp_bs = 0 then
							inp_loc <= 0;
						end if;
					elsif inp_loc+1 /= scalar_locations_max then
						inp_loc <= inp_loc + 1;
					end if;
					if inp_num = 0 and inp_bs+1 = block_scalars then
						if inp_pty+1 = pty_blocks then
							cnt_rpos <= 0;
						elsif cnt_rpos+1 /= block_parities_max then
							cnt_rpos <= cnt_rpos + 1;
						end if;
					end if;
					if inp_num = 0 then
						if inp_pty = 0 and inp_bs = 0 then
							inp_blk <= 0;
							inp_blk0 <= 0;
						else
							inp_blk <= inp_blk0;
							if inp_bs+1 = block_scalars then
								inp_blk0 <= inp_blk;
							end if;
						end if;
					elsif inp_blk+1 /= block_locations_max then
						inp_blk <= inp_blk + 1;
					end if;
				end if;
			else
				cnt_rpos <= 0;
				inp_cnt <= cnt_ocnt;
				inp_num <= 0;
				inp_pty <= 0;
				inp_seq <= 0;
				inp_loc <= 0;
				inp_blk <= 0;
				inp_blk0 <= 0;
				inp_bs <= 0;
			end if;

--			report boolean'image(inp_stage(0)) & HT & boolean'image(cnp_busy) & HT & integer'image(inp_seq) & HT &
--				integer'image(inp_cnt) & HT & integer'image(inp_num) & HT & integer'image(inp_bs) & HT &
--				integer'image(inp_blk) & HT & integer'image(inp_loc) & HT & integer'image(inp_pty);

			if inp_stage(0) and not cnp_busy then
				loc_rpos <= inp_blk;
				inp_bs_d(1) <= inp_bs;
				inp_num_d(1) <= inp_num;
				inp_cnt_d(1) <= inp_cnt;
				inp_seq_d(1) <= inp_seq;
				inp_loc_d(1) <= inp_loc;
			end if;

			inp_stage(1) <= inp_stage(0);
			if inp_stage(1) and not cnp_busy then
				inp_bs_d(2) <= inp_bs_d(1);
				inp_num_d(2) <= inp_num_d(1);
				inp_cnt_d(2) <= inp_cnt_d(1);
				inp_seq_d(2) <= inp_seq_d(1);
				inp_loc_d(2) <= inp_loc_d(1);
			end if;

			inp_stage(2) <= inp_stage(1);
			if inp_stage(2) and not cnp_busy then
				inp_wdf_d(1) <= inp_bs_d(2) = 0 and loc_ooff = code_blocks-1 and loc_oshi = block_scalars-1;
				off_ioff <= loc_ooff;
				off_ishi <= loc_oshi;
				off_ibs <= inp_bs_d(2);
				inp_num_d(3) <= inp_num_d(2);
				inp_cnt_d(3) <= inp_cnt_d(2);
				inp_seq_d(3) <= inp_seq_d(2);
				inp_loc_d(3) <= inp_loc_d(2);
			end if;

			inp_stage(3) <= inp_stage(2);
			if inp_stage(3) and not cnp_busy then
				inp_num_d(4) <= inp_num_d(3);
				inp_cnt_d(4) <= inp_cnt_d(3);
				inp_seq_d(4) <= inp_seq_d(3);
				inp_loc_d(4) <= inp_loc_d(3);
				inp_wdf_d(2) <= inp_wdf_d(1);
			end if;

			inp_stage(4) <= inp_stage(3);
			if inp_stage(4) and not cnp_busy then
				var_rpos <= off_ooff;
				bnl_rpos <= inp_loc_d(4);
				inp_off_d(1) <= off_ooff;
				inp_num_d(5) <= inp_num_d(4);
				inp_cnt_d(5) <= inp_cnt_d(4);
				inp_seq_d(5) <= inp_seq_d(4);
				inp_loc_d(5) <= inp_loc_d(4);
				inp_wdf_d(3) <= inp_wdf_d(2);
			end if;

			inp_stage(5) <= inp_stage(4);
			if inp_stage(5) and not cnp_busy then
				inp_num_d(6) <= inp_num_d(5);
				inp_cnt_d(6) <= inp_cnt_d(5);
				inp_seq_d(6) <= inp_seq_d(5);
				inp_loc_d(6) <= inp_loc_d(5);
				inp_wdf_d(4) <= inp_wdf_d(3);
				inp_off_d(2) <= inp_off_d(1);
			end if;

			inp_stage(6) <= inp_stage(5);
			if inp_stage(6) and not cnp_busy then
				sub_ivsft <= var_osft;
				if inp_seq_d(6) = 0 then
					sub_icsft <= (false, 0);
				else
					sub_icsft <= bnl_osft;
				end if;
				inp_num_d(7) <= inp_num_d(6);
				inp_cnt_d(7) <= inp_cnt_d(6);
				inp_seq_d(7) <= inp_seq_d(6);
				inp_loc_d(7) <= inp_loc_d(6);
				inp_wdf_d(5) <= inp_wdf_d(4);
				inp_off_d(3) <= inp_off_d(2);
			end if;

			inp_stage(7) <= inp_stage(6);
			if inp_stage(7) and not cnp_busy then
				inp_num_d(8) <= inp_num_d(7);
				inp_cnt_d(8) <= inp_cnt_d(7);
				inp_seq_d(8) <= inp_seq_d(7);
				inp_loc_d(8) <= inp_loc_d(7);
				inp_wdf_d(6) <= inp_wdf_d(5);
				inp_off_d(4) <= inp_off_d(3);
			end if;

			inp_stage(8) <= inp_stage(7);
			if inp_stage(8) and not cnp_busy then
				cnp_start <= inp_num_d(8) = 0;
				cnp_count <= inp_cnt_d(8);
				if inp_wdf_d(6) then
					cnp_ivsft <= (false, vmag_scalar'high);
				else
					cnp_ivsft <= sub_ovsft;
				end if;
				cnp_iseq <= inp_seq_d(8);
				cnp_iloc <= inp_loc_d(8);
				cnp_iwdf <= inp_wdf_d(6);
				cnp_ioff <= inp_off_d(4);
			end if;

--			report boolean'image(cnp_start) & HT & boolean'image(cnp_busy) & HT & integer'image(cnp_iseq) & HT & integer'image(cnp_iloc) & HT & integer'image(cnp_ioff) & HT & boolean'image(cnp_iwdf) & HT & integer'image(cnp_count) & HT &
--				integer'image(vsft_to_soft(cnp_ivsft));

--			report boolean'image(cnp_valid) & HT & boolean'image(cnp_busy) & HT & integer'image(cnp_oseq) & HT & integer'image(cnp_oloc) & HT & integer'image(cnp_ooff) & HT & boolean'image(cnp_owdf) & HT &
--				integer'image(vsft_to_soft(cnp_ovsft)) & HT & integer'image(csft_to_soft(cnp_ocsft));

			if out_stage(0) then
				add_ivsft <= cnp_ovsft;
				add_icsft <= cnp_ocsft;
				out_wdf_d(1) <= cnp_owdf;
				out_off_d(1) <= cnp_ooff;
				bnl_wren <= true;
				bnl_wpos <= cnp_oloc;
				bnl_isft <= cnp_ocsft;
			else
				bnl_wren <= false;
			end if;

			out_stage(1) <= out_stage(0);
			if out_stage(1) then
				out_off_d(2) <= out_off_d(1);
				out_wdf_d(2) <= out_wdf_d(1);
			end if;

			out_stage(2) <= out_stage(1);
			if out_stage(2) then
				var_wren <= not out_wdf_d(2);
				var_wpos <= out_off_d(2);
				var_isft <= add_ovsft;
			end if;

			out_stage(3) <= out_stage(2);
			if out_stage(3) and not out_stage(2) then
				var_wren <= false;
				if out_stage = (out_stage'low to out_stage'high-1 => false) & true and
						not inp_stage(inp_stage'high) and not cnp_busy then
					busy <= false;
				end if;
			end if;
		end if;
	end process;
end rtl;


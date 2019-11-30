-- SISO vector decoder for IRA-LDPC codes
--
-- Copyright 2019 Ahmet Inan <inan@aicodix.de>

library ieee;
use ieee.std_logic_1164.all;
use work.ldpc.all;
use work.table.all;

entity dec_vector is
	port (
		clock : in std_logic;
		busy : out boolean := false;
		istart : in boolean;
		ostart : out boolean := false;
		isoft : in soft_scalar;
		osoft : out soft_scalar
	);
end dec_vector;

architecture rtl of dec_vector is
	signal swap_cb : natural range 0 to code_blocks := code_blocks;
	signal swap_bv : natural range 0 to block_vectors-1;
	signal swap_vs, swap_d1vs, swap_d2vs : natural range 0 to vector_scalars-1;
	signal prev_val : soft_scalar;
	signal var_wren : boolean := false;
	signal var_wpos, var_rpos : natural range 0 to code_vectors-1;
	signal var_ivar, var_ovar : soft_vector;
	signal bnl_wren : boolean := false;
	signal bnl_wpos, bnl_rpos : location_scalar;
	signal bnl_isgn, bnl_osgn : sgn_vector;
	signal bnl_imag, bnl_omag : mag_vector;
	signal first_wdf : boolean;
	signal wdf_wren : boolean := false;
	signal wdf_wpos, wdf_rpos : location_scalar;
	signal wdf_iwdf, wdf_owdf : boolean;
	signal loc_wren : boolean := false;
	signal loc_wpos, loc_rpos : location_scalar;
	signal loc_ioff, loc_ooff : offset_scalar;
	signal loc_ishi, loc_oshi : shift_scalar;
	signal cnt_wren : boolean := false;
	signal cnt_wpos, cnt_rpos : natural range 0 to parities_max-1;
	signal cnt_icnt, cnt_ocnt : count_scalar;
	signal cnp_busy : boolean;
	signal cnp_istart : boolean := false;
	signal cnp_ostart : boolean;
	signal cnp_icount, cnp_ocount : count_scalar;
	signal cnp_iseq, cnp_oseq : sequence_scalar;
	signal cnp_isft, cnp_osft : soft_vector;
	signal cnp_osgn : sgn_vector;
	signal cnp_omag : mag_vector;
	signal cnp_iwdf, cnp_owdf : boolean;
	signal cnp_iloc, cnp_oloc : location_scalar;
	signal cnp_ioff, cnp_ooff : offset_scalar;
	signal cnp_ishi, cnp_oshi : shift_scalar;
	signal rol_shift : natural range 0 to soft_vector'length-1;
	signal rol_isoft, rol_osoft : soft_vector;
	signal ror_shift : natural range 0 to soft_vector'length-1;
	signal ror_isoft, ror_osoft : soft_vector;
	signal sub_isft, sub_osft : soft_vector;
	signal sub_isgn, not_sub_isgn : sgn_vector;
	signal sub_imag : mag_vector;
	signal add_isft, add_osft : soft_vector;
	signal add_isgn : sgn_vector;
	signal add_imag : mag_vector;
	signal ptys : parities := init_parities;
	signal inp_pty : natural range 0 to parities_max;
	signal prev_start, swap_d1start, swap_d2start : boolean := false;
	signal inp_seq, out_seq : sequence_scalar;
	type inp_stages is array (0 to 8) of boolean;
	signal inp_stage : inp_stages := (others => false);
	type swap_stages is array (0 to 3) of boolean;
	signal swap_stage : swap_stages := (others => false);
	signal swap_d1soft, swap_d2soft : soft_scalar;
	signal swap_pos, swap_d1pos : natural range 0 to code_vectors-1;
	signal inp_num : natural range 0 to degree_max := 0;
	signal out_num : natural range 0 to degree_max := degree_max;
	signal inp_cnt, out_cnt : count_scalar := degree_max;
	signal inp_loc : location_scalar;
	type out_stages is array (0 to 5) of boolean;
	signal out_stage : out_stages := (others => false);
	signal out_d1off, out_d2off, out_d3off, out_d4off : offset_scalar;
	signal out_d1shi, out_d2shi : shift_scalar;
	signal out_d1wdf, out_d2wdf, out_d3wdf, out_d4wdf : boolean;
	signal inp_d1num, inp_d2num, inp_d3num, inp_d4num, inp_d5num, inp_d6num, inp_d7num, inp_d8num : natural range 0 to degree_max;
	signal inp_d1cnt, inp_d2cnt, inp_d3cnt, inp_d4cnt, inp_d5cnt, inp_d6cnt, inp_d7cnt, inp_d8cnt : count_scalar;
	signal inp_d1seq, inp_d2seq, inp_d3seq, inp_d4seq, inp_d5seq, inp_d6seq, inp_d7seq, inp_d8seq : sequence_scalar;
	signal inp_d1loc, inp_d2loc, inp_d3loc, inp_d4loc, inp_d5loc, inp_d6loc, inp_d7loc, inp_d8loc : location_scalar;
	signal inp_d1wdf, inp_d2wdf, inp_d3wdf, inp_d4wdf, inp_d5wdf, inp_d6wdf : boolean;
	signal inp_d1off, inp_d2off, inp_d3off, inp_d4off, inp_d5off, inp_d6off : offset_scalar;
	signal inp_d1shi, inp_d2shi, inp_d3shi, inp_d4shi, inp_d5shi, inp_d6shi : shift_scalar;
begin
	loc_inst : entity work.loc_vector
		port map (clock, loc_wren,
			loc_wpos, loc_rpos,
			loc_ioff, loc_ooff,
			loc_ishi, loc_oshi);

	wdf_inst : entity work.wdf_vector
		port map (clock, wdf_wren,
			wdf_wpos, wdf_rpos,
			wdf_iwdf, wdf_owdf);

	var_inst : entity work.var_vector
		port map (clock, var_wren,
			var_wpos, var_rpos,
			var_ivar, var_ovar);

	cnt_inst : entity work.cnt_vector
		port map (clock, cnt_wren,
			cnt_wpos, cnt_rpos,
			cnt_icnt, cnt_ocnt);

	bnl_inst : entity work.bnl_vector
		port map (clock, bnl_wren,
			bnl_wpos, bnl_rpos,
			bnl_isgn, bnl_osgn,
			bnl_imag, bnl_omag);

	cnp_inst : entity work.cnp_vector
		port map (clock, cnp_busy,
			cnp_istart, cnp_ostart,
			cnp_icount, cnp_ocount,
			cnp_iseq, cnp_oseq,
			cnp_isft, cnp_osft,
			cnp_osgn, cnp_omag,
			cnp_iwdf, cnp_owdf,
			cnp_iloc, cnp_oloc,
			cnp_ioff, cnp_ooff,
			cnp_ishi, cnp_oshi);

	rol_inst : entity work.rol_vector
		port map (clock, rol_shift,
			rol_isoft, rol_osoft);

	ror_inst : entity work.ror_vector
		port map (clock, ror_shift,
			ror_isoft, ror_osoft);

	not_sub_isgn <= not sub_isgn;
	sub_inst : entity work.add_vector
		port map (clock,
			sub_isft,
			not_sub_isgn,
			sub_imag,
			sub_osft);

	add_inst : entity work.add_vector
		port map (clock,
			add_isft,
			add_isgn,
			add_imag,
			add_osft);

	process (clock)
	begin
		if rising_edge(clock) then
			if istart then
				swap_cb <= 0;
				swap_bv <= 0;
				swap_vs <= 0;
				swap_d1start <= prev_start;
				prev_start <= istart;
				swap_stage(0) <= true;
			elsif swap_cb /= code_blocks then
				swap_d1start <= false;
				if swap_bv = block_vectors-1 then
					swap_bv <= 0;
					if swap_vs = vector_scalars-1 then
						swap_vs <= 0;
						swap_cb <= swap_cb + 1;
					else
						swap_vs <= swap_vs + 1;
					end if;
				else
					swap_bv <= swap_bv + 1;
				end if;
				if swap_cb = code_blocks-1 and swap_bv = block_vectors-2 and swap_vs = vector_scalars-1 then
					busy <= true;
				end if;
				if swap_cb = code_blocks-1 and swap_bv = block_vectors-1 and swap_vs = vector_scalars-1 then
					swap_stage(0) <= false;
				end if;
			end if;

			if swap_stage(0) then
				swap_d1vs <= swap_vs;
				swap_d2start <= swap_d1start;
				swap_d1soft <= isoft;
				swap_pos <= block_vectors * swap_cb + swap_bv;
				var_rpos <= block_vectors * swap_cb + swap_bv;
			end if;

			swap_stage(1) <= swap_stage(0);
			if swap_stage(1) then
				swap_d2vs <= swap_d1vs;
				ostart <= swap_d2start;
				swap_d2soft <= swap_d1soft;
				swap_d1pos <= swap_pos;
			end if;

			swap_stage(2) <= swap_stage(1);
			if swap_stage(2) then
				osoft <= var_ovar(swap_d2vs);
				var_wren <= true;
				var_wpos <= swap_d1pos;
				for idx in var_ivar'range loop
					if swap_d2vs = idx then
						var_ivar(idx) <= swap_d2soft;
					else
						var_ivar(idx) <= var_ovar(idx);
					end if;
				end loop;
			end if;

			swap_stage(3) <= swap_stage(2);
			if swap_stage(3) and not swap_stage(2) then
				var_wren <= false;
				inp_stage(0) <= true;
--				busy <= false;
			end if;

			if inp_stage(0) then
				if not cnp_busy then
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
					elsif inp_loc+1 /= locations_max-1 then
						inp_loc <= inp_loc + 1;
					end if;
					if inp_num+2 = inp_cnt then
						if inp_pty+1 = ptys then
							cnt_rpos <= 0;
						elsif cnt_rpos+1 /= parities_max-1 then
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

--			report boolean'image(inp_stage(0)) & HT & boolean'image(cnp_busy) & HT & integer'image(inp_seq) & HT & integer'image(inp_cnt) & HT & integer'image(inp_num) & HT & integer'image(inp_loc) & HT & integer'image(inp_pty);

			if inp_stage(0) and not cnp_busy then
				loc_rpos <= inp_loc;
				wdf_rpos <= inp_loc;
				inp_d1num <= inp_num;
				inp_d1cnt <= inp_cnt;
				inp_d1seq <= inp_seq;
				inp_d1loc <= inp_loc;
			end if;

			inp_stage(1) <= inp_stage(0);
			if inp_stage(1) and not cnp_busy then
				inp_d2num <= inp_d1num;
				inp_d2cnt <= inp_d1cnt;
				inp_d2seq <= inp_d1seq;
				inp_d2loc <= inp_d1loc;
			end if;

			inp_stage(2) <= inp_stage(1);
			if inp_stage(2) and not cnp_busy then
				var_rpos <= loc_ooff;
				if inp_d2seq = 0 then
					if inp_d2num = 1 then
						inp_d1wdf <= false;
					else
						inp_d1wdf <= inp_d1off = loc_ooff;
					end if;
				else
					inp_d1wdf <= wdf_owdf;
				end if;
				inp_d3num <= inp_d2num;
				inp_d3cnt <= inp_d2cnt;
				inp_d3seq <= inp_d2seq;
				inp_d3loc <= inp_d2loc;
				inp_d1off <= loc_ooff;
				inp_d1shi <= loc_oshi;
			end if;

			inp_stage(3) <= inp_stage(2);
			if inp_stage(3) and not cnp_busy then
				if inp_d3num = 1 then
					first_wdf <= inp_d1wdf;
				elsif inp_d3num /= 0 then
					wdf_wren <= true;
					wdf_wpos <= inp_d4loc;
					if inp_d2off = inp_d1off then
						wdf_iwdf <= inp_d1wdf;
					else
						wdf_iwdf <= first_wdf;
						first_wdf <= inp_d1wdf;
					end if;
				end if;
				inp_d4num <= inp_d3num;
				inp_d4cnt <= inp_d3cnt;
				inp_d4seq <= inp_d3seq;
				inp_d4loc <= inp_d3loc;
				inp_d2wdf <= inp_d1wdf;
				inp_d2off <= inp_d1off;
				inp_d2shi <= inp_d1shi;
			end if;

			inp_stage(4) <= inp_stage(3);
			if inp_stage(4) and not cnp_busy then
				if inp_d4num = inp_d4cnt then
					wdf_wren <= false;
				end if;
				rol_shift <= inp_d2shi;
				rol_isoft <= var_ovar;
				bnl_rpos <= inp_d4loc;
				inp_d5num <= inp_d4num;
				inp_d5cnt <= inp_d4cnt;
				inp_d5seq <= inp_d4seq;
				inp_d5loc <= inp_d4loc;
				inp_d3wdf <= inp_d2wdf;
				inp_d3off <= inp_d2off;
				inp_d3shi <= inp_d2shi;
			end if;

			inp_stage(5) <= inp_stage(4);
			if inp_stage(5) and not cnp_busy then
				inp_d6num <= inp_d5num;
				inp_d6cnt <= inp_d5cnt;
				inp_d6seq <= inp_d5seq;
				inp_d6loc <= inp_d5loc;
				inp_d4wdf <= inp_d3wdf;
				inp_d4off <= inp_d3off;
				inp_d4shi <= inp_d3shi;
			end if;

			inp_stage(6) <= inp_stage(5);
			if inp_stage(6) and not cnp_busy then
				if inp_d4off = code_vectors-1 and inp_d4shi = 1 then
					prev_val <= rol_osoft(rol_osoft'low);
					sub_isft <= soft_scalar'high & rol_osoft(rol_osoft'low+1 to rol_osoft'high);
				else
					sub_isft <= rol_osoft;
				end if;
				if inp_d6seq = 0 then
					sub_isgn <= (others => false);
					sub_imag <= (others => 0);
				else
					sub_isgn <= bnl_osgn;
					sub_imag <= bnl_omag;
				end if;
				inp_d7num <= inp_d6num;
				inp_d7cnt <= inp_d6cnt;
				inp_d7seq <= inp_d6seq;
				inp_d7loc <= inp_d6loc;
				inp_d5wdf <= inp_d4wdf;
				inp_d5off <= inp_d4off;
				inp_d5shi <= inp_d4shi;
			end if;

			inp_stage(7) <= inp_stage(6);
			if inp_stage(7) and not cnp_busy then
				inp_d8num <= inp_d7num;
				inp_d8cnt <= inp_d7cnt;
				inp_d8seq <= inp_d7seq;
				inp_d8loc <= inp_d7loc;
				inp_d6wdf <= inp_d5wdf;
				inp_d6off <= inp_d5off;
				inp_d6shi <= inp_d5shi;
			end if;

			inp_stage(8) <= inp_stage(7);
			if inp_stage(8) and not cnp_busy then
				cnp_istart <= inp_d8num = 0;
				cnp_icount <= inp_d8cnt;
				cnp_isft <= sub_osft;
				cnp_iseq <= inp_d8seq;
				cnp_iloc <= inp_d8loc;
				cnp_iwdf <= inp_d6wdf;
				cnp_ioff <= inp_d6off;
				cnp_ishi <= inp_d6shi;
			end if;

--			report boolean'image(cnp_istart) & HT & boolean'image(cnp_busy) & HT & integer'image(cnp_iseq) & HT & integer'image(cnp_icount) & HT & integer'image(cnp_iloc) & HT & integer'image(cnp_ioff) & HT & integer'image(cnp_ishi) & HT & boolean'image(cnp_iwdf) & HT &
--				integer'image(cnp_isft(0)) & HT & integer'image(cnp_isft(1)) & HT & integer'image(cnp_isft(2)) & HT & integer'image(cnp_isft(3)) & HT & integer'image(cnp_isft(4));

--			report boolean'image(cnp_ostart) & HT & boolean'image(cnp_busy) & HT & integer'image(cnp_oseq) & HT & integer'image(cnp_ocount) & HT & integer'image(cnp_oloc) & HT & integer'image(cnp_ooff) & HT & integer'image(cnp_oshi) & HT & boolean'image(cnp_owdf) & HT &
--				integer'image(cnp_osft(0)) & HT & integer'image(cnp_osft(1)) & HT & integer'image(cnp_osft(2)) & HT & integer'image(cnp_osft(3)) & HT & integer'image(cnp_osft(4)) & HT &
--				boolean'image(cnp_osgn(0)) & HT & boolean'image(cnp_osgn(1)) & HT & boolean'image(cnp_osgn(2)) & HT & boolean'image(cnp_osgn(3)) & HT & boolean'image(cnp_osgn(4)) & HT &
--				integer'image(cnp_omag(0)) & HT & integer'image(cnp_omag(1)) & HT & integer'image(cnp_omag(2)) & HT & integer'image(cnp_omag(3)) & HT & integer'image(cnp_omag(4));

			if cnp_ostart then
				out_num <= 0;
				out_cnt <= cnp_ocount;
				out_stage(0) <= true;
			elsif out_num < out_cnt then
				out_num <= out_num + 1;
				if out_num+1 = out_cnt then
					out_stage(0) <= false;
				end if;
			end if;

			if out_stage(0) then
				add_isft <= cnp_osft;
				add_isgn <= cnp_osgn;
				add_imag <= cnp_omag;
				out_d1wdf <= cnp_owdf;
				out_d1off <= cnp_ooff;
				out_d1shi <= cnp_oshi;
				bnl_wpos <= cnp_oloc;
				bnl_wren <= cnp_oseq = 0 or not cnp_owdf;
				if not cnp_owdf then
					bnl_isgn <= cnp_osgn;
					bnl_imag <= cnp_omag;
				elsif cnp_oseq = 0 then
					bnl_isgn <= (others => false);
					bnl_imag <= (others => 0);
				end if;
			else
				bnl_wren <= false;
			end if;

			out_stage(1) <= out_stage(0);
			if out_stage(1) then
				out_d2off <= out_d1off;
				out_d2shi <= out_d1shi;
				out_d2wdf <= out_d1wdf;
			end if;

			out_stage(2) <= out_stage(1);
			if out_stage(2) then
				ror_shift <= out_d2shi;
				if out_d2off = code_vectors-1 and out_d2shi = 1 then
					ror_isoft <= prev_val & add_osft(add_osft'low+1 to add_osft'high);
				else
					ror_isoft <= add_osft;
				end if;
				out_d3off <= out_d2off;
				out_d3wdf <= out_d2wdf;
			end if;

			out_stage(3) <= out_stage(2);
			if out_stage(3) then
				out_d4off <= out_d3off;
				out_d4wdf <= out_d3wdf;
			end if;

			out_stage(4) <= out_stage(3);
			if out_stage(4) then
				var_ivar <= ror_osoft;
				var_wpos <= out_d4off;
				var_wren <= not out_d4wdf;
			end if;

			out_stage(5) <= out_stage(4);
			if out_stage(5) and not out_stage(4) then
				var_wren <= false;
				if not inp_stage(inp_stage'high) then
					busy <= false;
				end if;
			end if;
		end if;
	end process;
end rtl;


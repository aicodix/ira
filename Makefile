
GHDL = ghdl

.PHONY: run
run: cnp_expected.txt dec_expected.txt cnp_output.txt dec_output.txt

.PHONY: vcd
vcd: cnp_vector_tb.vcd dec_vector_tb.vcd

.PRECIOUS: cnp_output.txt
cnp_output.txt: cnp_vector_tb cnp_input.txt
	$(GHDL) -r --workdir=work $<

.PRECIOUS: dec_output.txt
dec_output.txt: dec_vector_tb dec_input.txt
	$(GHDL) -r --workdir=work $<

.PRECIOUS: cnp_vector_tb.vcd
cnp_vector_tb.vcd: cnp_vector_tb cnp_input.txt
	$(GHDL) -r --workdir=work $< --vcd=$@

.PRECIOUS: dec_vector_tb.vcd
dec_vector_tb.vcd: dec_vector_tb dec_input.txt
	$(GHDL) -r --workdir=work $< --vcd=$@

work/ldpc.o: ldpc.vhd
work/table.o: table.vhd work/ldpc.o
work/add_scalar.o: add_scalar.vhd work/ldpc.o
work/add_vector.o: add_vector.vhd work/ldpc.o work/add_scalar.o
work/bnl_scalar.o: bnl_scalar.vhd work/ldpc.o
work/bnl_vector.o: bnl_vector.vhd work/ldpc.o work/bnl_scalar.o
work/cnt_vector.o: cnt_vector.vhd work/ldpc.o work/table.o
work/fub_scalar.o: fub_scalar.vhd work/ldpc.o
work/buf_vector.o: buf_vector.vhd work/ldpc.o work/fub_scalar.o
work/loc_vector.o: loc_vector.vhd work/ldpc.o work/table.o
work/rol_vector.o: rol_vector.vhd work/ldpc.o
work/ror_vector.o: ror_vector.vhd work/ldpc.o
work/var_scalar.o: var_scalar.vhd work/ldpc.o
work/var_vector.o: var_vector.vhd work/ldpc.o work/var_scalar.o
work/wdf_vector.o: wdf_vector.vhd work/ldpc.o
work/cnp_vector.o: cnp_vector.vhd work/ldpc.o work/buf_vector.o
work/dec_vector.o: dec_vector.vhd work/ldpc.o work/table.o work/loc_vector.o work/wdf_vector.o work/var_vector.o work/cnt_vector.o work/bnl_vector.o work/cnp_vector.o work/rol_vector.o work/ror_vector.o work/add_vector.o work/add_vector.o
work/cnp_vector_tb.o: cnp_vector_tb.vhd work/ldpc.o work/cnp_vector.o
work/dec_vector_tb.o: dec_vector_tb.vhd work/ldpc.o work/dec_vector.o

work/%.o: %.vhd
	$(GHDL) -a --workdir=work $<

cnp_vector_tb: work/cnp_vector_tb.o
dec_vector_tb: work/dec_vector_tb.o

%_tb: work/%_tb.o
	$(GHDL) -e --workdir=work $@

work/check_table_txt: check_table_txt.cc ldpc.hh
work/generate_cnp_input_txt: generate_cnp_input_txt.cc ldpc.hh
work/generate_dec_input_txt: generate_dec_input_txt.cc ldpc.hh
work/generate_cnp_expected_txt: generate_cnp_expected_txt.cc ldpc.hh cnp_reference.hh exclusive_reduce.hh
work/generate_dec_expected_txt: generate_dec_expected_txt.cc ldpc.hh dec_reference.hh cnp_reference.hh exclusive_reduce.hh
work/generate_table_vhd: generate_table_vhd.cc ldpc.hh

work/%: %.cc | work
	$(CXX) $< -o $@

cnp_input.txt: work/generate_cnp_input_txt
	work/generate_cnp_input_txt

cnp_expected.txt: cnp_input.txt table.txt work/generate_cnp_expected_txt
	work/generate_cnp_expected_txt

dec_input.txt: work/generate_dec_input_txt
	work/generate_dec_input_txt

dec_expected.txt: dec_input.txt table.txt work/generate_dec_expected_txt
	work/generate_dec_expected_txt

table.vhd: table.txt work/check_table_txt work/generate_table_vhd
	work/check_table_txt
	work/generate_table_vhd

work:
	mkdir $@

.PHONY: clean
clean:
	rm -rf work *.o *_tb *.vcd


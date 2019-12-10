
GHDL = /opt/ghdl/bin/ghdl

.PHONY: run
run: dec_expected.txt dec_output.txt

.PHONY: vcd
vcd: dec_vector_tb.vcd

work/work-obj93.cf: *.vhd | work
	$(GHDL) -i --workdir=work $?

.PRECIOUS: dec_output.txt
dec_output.txt: dec_vector_tb dec_input.txt
	$(GHDL) -r --workdir=work $<

.PRECIOUS: dec_vector_tb.vcd
dec_vector_tb.vcd: dec_vector_tb dec_input.txt
	$(GHDL) -r --workdir=work $< --vcd=$@

.PRECIOUS: dec_vector_tb
dec_vector_tb: work/work-obj93.cf
	$(GHDL) -m --workdir=work $@

.PRECIOUS: work/check_table_txt
work/check_table_txt: check_table_txt.cc ldpc.hh | work
	$(CXX) $< -o $@

.PRECIOUS: work/generate_dec_input_txt
work/generate_dec_input_txt: generate_dec_input_txt.cc ldpc.hh | work
	$(CXX) $< -o $@

.PRECIOUS: work/generate_dec_expected_txt
work/generate_dec_expected_txt: generate_dec_expected_txt.cc *.hh | work
	$(CXX) $< -o $@

.PRECIOUS: work/generate_table_vhd
work/generate_table_vhd: generate_table_vhd.cc ldpc.hh | work
	$(CXX) $< -o $@

.PRECIOUS: dec_input.txt
dec_input.txt: | work/generate_dec_input_txt
	work/generate_dec_input_txt

.PRECIOUS: dec_expected.txt
dec_expected.txt: dec_input.txt table.txt | work/generate_dec_expected_txt
	work/generate_dec_expected_txt

.PRECIOUS: table.vhd
table.vhd: table.txt | work/check_table_txt work/generate_table_vhd
	work/check_table_txt
	work/generate_table_vhd

work:
	mkdir $@

.PHONY: clean
clean:
	rm -rf work *.o *_tb *.vcd


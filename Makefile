
GHDL = /opt/ghdl/bin/ghdl

.PHONY: run
run: soft_output.txt

.PHONY: vcd
vcd: dec_vector_tb.vcd

work/work-obj93.cf: *.vhd | work
	$(GHDL) -i --workdir=work $?

.PRECIOUS: soft_output.txt
soft_output.txt: dec_vector_tb soft_input.txt
	$(GHDL) -r --workdir=work $<

.PRECIOUS: dec_vector_tb.vcd
dec_vector_tb.vcd: dec_vector_tb soft_input.txt
	$(GHDL) -r --workdir=work $< --vcd=$@

.PRECIOUS: dec_vector_tb
dec_vector_tb: work/work-obj93.cf
	$(GHDL) -m --workdir=work $@

.PRECIOUS: work/generate_random_noise
work/generate_random_noise: generate_random_noise.cc *.hh | work
	$(CXX) $< -o $@

.PRECIOUS: work/generate_table_vhd
work/generate_table_vhd: generate_table_vhd.cc | work
	$(CXX) $< -o $@

.PRECIOUS: soft_input.txt
soft_input.txt: work/generate_random_noise
	work/generate_random_noise

.PRECIOUS: table.vhd
table.vhd: table.txt work/generate_table_vhd
	work/generate_table_vhd

work:
	mkdir $@

.PHONY: clean
clean:
	rm -rf work *.o *_tb *.vcd


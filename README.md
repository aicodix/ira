
SISO vector decoder for IRA-LDPC codes in VHDL

### Quick start

Prerequisites:

* [GHDL](https://github.com/ghdl/ghdl) to simulate VHDL.
* [GNU Make](https://www.gnu.org/software/make/) to use the [Makefile](Makefile) for building.
* [GTKWave](http://gtkwave.sourceforge.net/) to view the waveforms generated by the simulation.
* C++ compiler to build the test vector generators.

Run ```make``` to build and simulate. Compare resulting ```soft_output.txt``` with ```soft_expected.txt```.

Run ```make vcd``` to generate waveforms and watch them via ```gtkwave dec_vector_tb.vcd```.

### TODO

* Interleave parity part of message here?
* Tool for generating code table entries
* Tool for enforcing below rules for code table entries
* Interface for switching or replacing code table
* Shortening the pipeline if timing analysis allows it
* Self-Corrected Min-Sum
* Can the interface be improved?

### DONE

* Write disable flags to resolve write conflicts with DDSMs
* Reference decoder in C++
* Tool for checking code table entries for data hazards

### [ldpc.vhd](ldpc.vhd)

LDPC decoder configuration

### [ldpc.hh](ldpc.hh)

LDPC decoder configuration

### [table.txt](table.txt)

Transformed and manipulated DVB T2 B7 code table for vector length of 15:

* Rows are sorted by location offsets to keep same offsets consecutive.
* Above sorting helps maximally spacing out same offsets on consecutive columns.
* Manually swapped columns to avoid same offsets on consecutive columns.

The following rules must apply to the table for the decoder to work correctly:

* Rows containing DDSMs must keep locations with same offset consecutive.
* Order of location offsets must avoid data hazards caused by the pipeline.
* Optional: Keep same count rows consecutive to avoid pipeline stalls.

### [table.vhd](table.vhd)

code table generated from [table.txt](table.txt) by [generate_table_vhd.cc](generate_table_vhd.cc)

### [dec_vector_tb.vhd](dec_vector_tb.vhd)

testbench for the decoder

### [dec_vector.vhd](dec_vector.vhd)

SISO vector decoder for IRA-LDPC codes

### [cnp_vector.vhd](cnp_vector.vhd)

vector check node processor

Look in [cnp](https://github.com/aicodix/cnp) repository for testbench.

### [buf_vector.vhd](buf_vector.vhd)

buffer for the vector check node processor

### [generate_soft_input_txt.cc](generate_soft_input_txt.cc)

Generate [soft_input.txt](soft_input.txt) from random noise

### [generate_soft_expected_txt.cc](generate_soft_expected_txt.cc)

Generate [soft_expected.txt](soft_expected.txt) decoded from [soft_input.txt](soft_input.txt)

### [generate_table_vhd.cc](generate_table_vhd.cc)

Generate [table.vhd](table.vhd) from [table.txt](table.txt)

### [add_scalar.vhd](add_scalar.vhd)

scalar saturating addition

### [add_vector.vhd](add_vector.vhd)

vector saturating addition

### [rol_vector.vhd](rol_vector.vhd)

rotate left vector elements

### [ror_vector.vhd](ror_vector.vhd)

rotate right vector elements

### [bnl_scalar.vhd](bnl_scalar.vhd)

scalar bit node links

### [bnl_vector.vhd](bnl_vector.vhd)

vector bit node links

### [cnt_vector.vhd](cnt_vector.vhd)

counts for the vector decoder

### [loc_vector.vhd](loc_vector.vhd)

locations for the vector decoder

### [var_scalar.vhd](var_scalar.vhd)

scalar variable nodes

### [var_vector.vhd](var_vector.vhd)

vector variable nodes

### [wdf_vector.vhd](wdf_vector.vhd)

write disable flags for the vector decoder

### [exclusive_reduce.hh](exclusive_reduce.hh)

Reduce N times while excluding ith input element

It computes the following, but having only O(N) complexity and using O(1) extra storage:

```
	output[0] = input[1];
	output[1] = input[0];
	for (int i = 2; i < N; ++i)
		output[i] = op(input[0], input[1]);
	for (int i = 0; i < N; ++i)
		for (int j = 2; j < N; ++j)
			if (i != j)
				output[i] = op(output[i], input[j]);
```

### [cnp_reference.hh](cnp_reference.hh)

Check node processor reference code

### [dec_reference.hh](dec_reference.hh)

IRA-LDPC decoder reference code

### [check_table_txt.hh](check_table_txt.hh)

check table.txt for data hazards


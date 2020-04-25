# Setting variable for design_name. (top module name)
set design_name $env(DESIGN_NAME);

## For NCSUFreePDK45nm library
set search_path [ list . \
                  /home/scf-22/ee577/NCSU45PDK/FreePDK45/osu_soc/lib/files \
		/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver ]
set target_library { gscl45nm.db }
set link_library [list * gscl45nm.db]


# Reading source verilog file.
# copy your verilog file into ./src/ before synthesis.
read_verilog ./netlist/$design_name.syn.v ;

# Setting $design_name as current working design.
# Use this command before setting any constraints.
current_design $design_name ;

# Linking your design into the cells in standard cell libraries.
# This command checks whether your design can be compiled
link ;

# Create a clock with period of 17ns.
create_clock -name clk -period 4 -waveform [list 0 2] [get_ports clk]

set_multicycle_path 5 -setup -from [get_pins processor_0/ID_EXM_reg_reg_*_/CLK] -through [get_pins processor_0/alu_exm/do[*]];
set_multicycle_path 4 -hold -from [get_pins processor_0/ID_EXM_reg_reg_*_/CLK] -through [get_pins processor_0/alu_exm/do[*]];

set_multicycle_path 5 -setup -from [get_pins processor_1/ID_EXM_reg_reg_*_/CLK] -through [get_pins processor_1/alu_exm/do[*]];
set_multicycle_path 4 -hold -from [get_pins processor_1/ID_EXM_reg_reg_*_/CLK] -through [get_pins processor_1/alu_exm/do[*]];

set_multicycle_path 5 -setup -from [get_pins processor_2/ID_EXM_reg_reg_*_/CLK] -through [get_pins processor_2/alu_exm/do[*]];
set_multicycle_path 4 -hold -from [get_pins processor_2/ID_EXM_reg_reg_*_/CLK] -through [get_pins processor_2/alu_exm/do[*]];

set_multicycle_path 5 -setup -from [get_pins processor_3/ID_EXM_reg_reg_*_/CLK] -through [get_pins processor_3/alu_exm/do[*]];
set_multicycle_path 4 -hold -from [get_pins processor_3/ID_EXM_reg_reg_*_/CLK] -through [get_pins processor_3/alu_exm/do[*]];

set_input_delay -max 1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]];
set_output_delay -max 1.0 -clock clk [all_outputs];

set_clock_latency -source 0.5 [get_ports clk];

read_sdf netlist/$design_name.sdf ;

# Generating timing report of the synthezied design.
report_timing > report/$design_name.timing ;

report_constraints -all_violators > report/$design_name.violation ;

# Report timing of each type of timing path
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins] > report/$design_name.all_timing ;
report_timing -from [all_inputs] -to [all_registers -data_pins] >> report/$design_name.all_timing ;
report_timing -from [all_registers -clock_pins] -to [all_outputs] >> report/$design_name.all_timing ;
report_timing -from [all_inputs] -to [all_outputs] >> report/$design_name.all_timing ;

exit ;


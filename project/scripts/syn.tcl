######################################################################
#
# EE-577b 2019 FALL
# : DesignCompiler synthesis script
#   modified by Huimei Cheng
#
# use this script as a template for synthesizing combinational logic
#
######################################################################

# Setting variable for design_name. (top module name)
set design_name $env(DESIGN_NAME);

## For NCSUFreePDK45nm library
set search_path [ list . \
                  /home/scf-22/ee577/NCSU45PDK/FreePDK45/osu_soc/lib/files \
		/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver ]
set target_library { gscl45nm.db }
set synthetic_library [list dw_foundation.sldb standard.sldb ]
set link_library [list * gscl45nm.db dw_foundation.sldb standard.sldb]

#set verilogout_no_tri true

# Reading source verilog file.
# copy your verilog file into ./src/ before synthesis.
read_verilog ./src/cardinal_cmp.v;
read_verilog ./src/cardinal_cpu.v;
read_verilog ./src/alu.v;
read_verilog ./src/register_file.v;
read_verilog ./src/gold_ring.v;
read_verilog ./src/gold_router.v;
read_verilog ./src/cardinal_nic.v;
read_verilog ./src/rotating_prioritizer.v;
read_verilog ./src/buffer_1loc.v;

# Setting $design_name as current working design.
# Use this command before setting any constraints.
current_design $design_name ;

# If you have multiple instances of the same module,
# use this so that DesignCompiler optimizes each instance separately.
uniquify ;

# Linking your design into the cells in standard cell libraries.
# This command checks whether your design can be compiled
link ;

# Clock contraints
create_clock [get_ports clk]  -period 3.0  -waveform {0 1.50};

## Set multi-cycle path for ALU
set_multicycle_path 5 -setup -through [get_pins processor_0/alu_exm/do[*]];
set_multicycle_path 4 -hold -through [get_pins processor_0/alu_exm/do[*]];

set_multicycle_path 5 -setup -through [get_pins processor_1/alu_exm/do[*]];
set_multicycle_path 4 -hold -through [get_pins processor_1/alu_exm/do[*]];

set_multicycle_path 5 -setup -through [get_pins processor_2/alu_exm/do[*]];
set_multicycle_path 4 -hold -through [get_pins processor_2/alu_exm/do[*]];

set_multicycle_path 5 -setup -through [get_pins processor_3/alu_exm/do[*]];
set_multicycle_path 4 -hold -through [get_pins processor_3/alu_exm/do[*]];

# Setting timing constraints for combinational logic.
# Specifying maximum delay from inputs to outputs
#set_max_delay 3.0 -to [all_outputs];
#set_max_delay 3.0 -from [all_inputs];

# Set input delay and output delay
set_input_delay -max 1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]];
set_output_delay -max 1.0 -clock clk [all_outputs];

# Set clock source latency
set_clock_latency -source 0.5 [get_ports clk];

# Set max area to 0
set_max_area 0; # force dc to optimize area as much as possible

# "check_design" checks the internal representation of the
# current design for consistency and issues error and
# warning messages as appropriate.
check_design > report/$design_name.check_design ;

# Perforing synthesis and optimization on the current_design.
compile_ultra ;

# For better synthesis result, use "compile_ultra" command.
# compile_ultra is doing automatic ungrouping during optimization,
# therefore sometimes it's hard to figure out the critical path 
# from the synthesized netlist.
# So, use "compile" command for now.

# Writing the synthesis result into Synopsys db format.
# You can read the saved db file into DesignCoimpiler later using
# "read_db" command for further analysis (timing, area...).
#write -xg_force_db -format db -hierarchy -out db/$design_name.db ;

# Generating timing and are report of the synthezied design.
report_timing > report/$design_name.timing ;
report_area > report/$design_name.area ;
report_power > report/$design_name.power ;

# Writing synthesized gate-level verilog netlist.
# This verilog netlist will be used for post-synthesis gate-level simulation.
change_names -rules verilog -hierarchy ;
write -format verilog -hierarchy -out netlist/$design_name.syn.v ;

# Writing Standard Delay Format (SDF) back-annotation file.
# This delay information can be used for post-synthesis simulation.
write_sdf netlist/$design_name.sdf;
write_sdc netlist/$design_name.sdc


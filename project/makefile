###########################################################################
# This is a general purpose makefile to compile and run                   #
# Cadence NCSIM simulations                                               #
#                                                                         #
# To compile                                                              #
# ----------                                                              #
# %> make                                                                 #
#                                                                         #
# To run simulation in console mode                                       #
# ---------------------------------                                       #
# %> make sim                                                             #
#                                                                         #
# To run simulation in gui mode                                           #
# -----------------------------                                           #
# %> make simg                                                            #
#                                                                         #
# Directory Stucture                                                      #
# ------------------                                                      #
# This makefile assumes the following directory structure :               #
#                                                                         #
# ./        -- current directory, simulation is going to run from here    #
# ./work    -- Cadence work library to compile the design                 #
# ./design  -- holds all design verilog files                             #
# ./tb      -- holds testbench file(s)                                    #
# ./scripts -- holds tcl run scripts for simulation control               #
# ./reports -- keep all required log output/ pdfs files in this directory #
# ./include -- All other files required for simulations                   #
###########################################################################
#                                                                          
# Setup environment variables to point the Cadence instal directories
# and license files etc                                               
# source ~ee577/vlsi_tools.csh                    

# Setting 'TOP' variable
###########################################################################
#
# Processor Makefile
#
###########################################################################

# Top module of CPU
TOP = tb_cmp

# List of the design files
#DESIGN_FILES = ./netlist/cardinal_cmp.syn.v
DESIGN_FILES = ./design/cardinal_cmp.v

# List of the testbench files
TB_FILES = ./tb/$(TOP).v

INCLUDE_DIRECTORY = ./include

## Include Synopsys DesignWare Library
INCLUDE_DW_DIR = /usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver ## modified!!!!

# GUI simulation script file
SIM_SCRIPT_FILE_GUI = ./scripts/runscript.tcl

# Non GUI simulation script file
SIM_SCRIPT_FILE_NO_GUI = ./scripts/runscript_nogui.tcl

# ncvlog switch 
NCVLOG_SWITCHES = \
	-64BIT \
	-STATUS \
	-UPDATE \
	-incdir $(INCLUDE_DIRECTORY) \
	-MESSAGES \
	-incdir $(INCLUDE_DW_DIR)

#ncelab switches
NCELAB_SWITCHES = \
	-64BIT \
	-ACCESS +rwc \
	-NCFATAL INVSUP \
	-NCFATAL CUNOTB \
	-ERRORMAX 5 \
	-UPDATE \
	-TIMESCALE '1ns/10ps' \
	-NOLOG

#	-MESSAGES
#	-LIBVERBOSE

# ncsim simulation switches for console simulation
NCSIM_SWITCHES_NO_GUI = \
	-64BIT \
	-STATUS \
	-NOCOPYRIGHT \
	-MESSAGES \
	-NCFATAL INVSUP \
	-NOWARN DLBRLK \
	-NOLOG \
	-NOKEY

#	-SDF_NO_WARNINGS \
#	-TCL \
#	-INPUT $(SIM_SCRIPT_FILE_NO_GUI)

# ncsim switches for GUI simulations
NCSIM_SWITCHES_GUI = \
	-64BIT \
	-STATUS \
	-NOCOPYRIGHT \
	-MESSAGES \
	-NCFATAL INVSUP \
	-NOWARN DLBRLK \
	-TCL \
	-NOLOG \
	-NOKEY \
	-GUI

#	-INPUT $(SIM_SCRIPT_FILE_GUI) \

all : elab~

# analyze all the design and testbench files
ana~ : clean $(DESIGN_FILES)
	for f in $(DESIGN_FILES); do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	for f in $(TB_FILES);     do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	@touch ana~

# elaborate the top module
elab~ : ana~
	ncelab $(NCELAB_SWITCHES) work.$(TOP)
	@touch elab~

# run simulation without gui
sim : ana~ elab~
	ncsim $(NCSIM_SWITCHES_NO_GUI) work.$(TOP)

# run simulation with gui
simg : elab~
	ncsim $(NCSIM_SWITCHES_GUI) work.$(TOP)

# Just run the simulations without building
run : 
	ncsim $(NCSIM_SWITCHES_NO_GUI) work.$(TOP)

# clean the library to have a clean start
clean :
	@rm -rf `find . -name '*~'`
	@rm -rf work INCA_*
	@rm -rf ncsim*
	@rm -rf *.log *.mr *.pvl *.syn *.svf
	@mkdir work
	@echo 'All set for a clean start'

# create directory structure
dir :
	@mkdir work
	@mkdir design
	@mkdir tb
	@mkdir scripts
	@mkdir reports
	@echo 'Directory structure for simulation is created'

# create the basic cds.lib file
cds.lib :
	@echo 'DEFINE work work' > cds.lib

# create a blank hdl.var
hdl.var :
	@echo '# Hello Cadence' > hdl.var

# create cds.lib hdl.var and work dir for simulation - setup for simulation
init :	cds.lib hdl.var
	@mkdir work
	@echo 'Created work/ cds.lib hdl.var for simulation'

copy:
	@rm -rf ./src
	@mkdir ./src
	@cp ./design/*.v ./src/

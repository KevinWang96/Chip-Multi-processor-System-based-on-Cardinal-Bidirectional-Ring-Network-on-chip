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
#
# To run synthesis                                                        #
# -----------------------------                                           #
# %> make syn                                                             #
# TO use another TOP module name via commandline, you can use             #
# make TOP=<NewTopModuleName> sim                                         #
# make TOP=<NewTopModuleName> simg                                        #
#                                                                         #
# Directory Stucture                                                      #
# ------------------                                                      #
# This makefile assumes the following directory structure :               #
#                                                                         #
# ./        -- current directory, simulation is going to run from here    #
# ./work    -- Cadence work library to compile the design                 #
# ./design  -- holds all design verilog files                             #
# ./tb      -- holds testbench file(s)                                    #
# ./netlist -- netlists generated from synthesis/Place Route              #
# ./include -- files included in the verilog files using include command  #
# ./scripts -- holds tcl run scripts for simulation control               #
# ./reports -- holds all the reports from simulation                      #
#                                                                         #
###########################################################################
#                                                                          
# Setup environment variables to point the Cadence instal directories      
# and license files etc                                                      


# top level module
TOP = PISO_tb_syn
TOP_SYN = PISO_tb_syn
DESIGN_NAME = PISO

# List of the design files
DESIGN_FILES = ./design/*.v
NETLIST_FILES = ./netlist/*.v

# List of the testbench files
TB_FILES = ./tb/*.v

INCLUDE_DIRECTORY = ./include

# GUI simulation script file
SIM_SCRIPT_FILE_GUI = ./scripts/runscript.tcl

# Non GUI simulation script file
SIM_SCRIPT_FILE_NO_GUI = ./scripts/runscript_nogui.tcl

# ncvlog switch 
NCVLOG_SWITCHES = \
	-STATUS \
	-MESSAGES \
	-UPDATE \
	-INCDIR $(INCLUDE_DIRECTORY)

#ncelab switches
NCELAB_SWITCHES = \
	-ACCESS +rwc \
	-NCFATAL INVSUP \
	-NCFATAL CUNOTB \
	-ERRORMAX 5 \
	-UPDATE \
	-MESSAGES \
	-TIMESCALE '1ns/10ps' \
	-LIBVERBOSE

# ncsim simulation switches for console simulation
NCSIM_SWITCHES_NO_GUI = \
	-STATUS \
	-NOCOPYRIGHT \
	-MESSAGES \
	-NCFATAL INVSUP \
	-NOWARN DLBRLK \
	-TCL \
	-NOLOG \
	-NOKEY \
	-INPUT $(SIM_SCRIPT_FILE_NO_GUI)

# ncsim switches for GUI simulations
NCSIM_SWITCHES_GUI = \
	-STATUS \
	-NOCOPYRIGHT \
	-MESSAGES \
	-NCFATAL INVSUP \
	-NOWARN DLBRLK \
	-TCL \
	-NOLOG \
	-NOKEY \
	-INPUT $(SIM_SCRIPT_FILE_GUI) \
	-GUI

export

all : clean elab~ sim

# analyze all the design and testbench files
ana~ : $(DESIGN_FILES)
	for f in $(DESIGN_FILES); do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	for f in $(TB_FILES);     do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	@touch ana~

ana_syn~ : $(NETLIST_FILES)
	for f in $(NETLIST_FILES); do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	for f in $(TB_FILES);     do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	@touch ana_syn~

# elaborate the top module
elab~ : ana~
	ncelab $(NCELAB_SWITCHES) work.$(TOP)
	@touch elab~

elab_syn~ : ana_syn~
	ncelab $(NCELAB_SWITCHES) work.$(TOP_SYN)
	@touch elab_syn~

# run simulation without gui
sim : clean elab~
	ncsim $(NCSIM_SWITCHES_NO_GUI) work.$(TOP)

# run simulation with gui
simg : clean elab~
	ncsim $(NCSIM_SWITCHES_GUI) work.$(TOP)

sim_syn : clean elab_syn~
	ncsim $(NCSIM_SWITCHES_NO_GUI) work.$(TOP_SYN)

# run simulation with gui
simg_syn : clean elab_syn~
	ncsim $(NCSIM_SWITCHES_GUI) work.$(TOP_SYN)

syn:
	dc_shell -f scripts/syn.tcl -output_log_file dc.log

# clean the library to have a clean start
clean :
	@rm -rf `find . -name '*~'`
	@rm -rf work waves.shm 
	@rm -rf ncsim*
	@rm -rf *.log
	@rm -f default.svf
	@mkdir work
	@echo 'All set for a clean start'

# create directory structure
dir :
	@mkdir work
	@mkdir design
	@mkdir tb
	@mkdir include
	@mkdir scripts
	@mkdir netlist
	@mkdir report
	@echo 'Directory structure for simulation is created'

# create the basic cds.lib file
cds.lib :
	@echo 'DEFINE work work' > cds.lib

# create a blank hdl.var
hdl.var :
	@echo '# Hello Cadence' > hdl.var

init : dir cds.lib hdl.var
	@touch AUTHORS
	@echo 'Initialized the directory for simulation'


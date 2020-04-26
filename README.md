<!--
 * @Author: Yihao Wang
 * @Date: 2020-04-25 18:11:14
 * @LastEditTime: 2020-04-25 18:30:55
 * @LastEditors: Please set LastEditors
 * @Description: README.md for entire project
 * @FilePath: /EE577b_final_project/README.md
 -->
 Chip Multi-processor System based on Cardinal Bidirectional Ring network-on-chip
 --------------------------------------------------------------------------------

./Docs                      All documents and spec files related to this project;

./project/design            All design source files;
./project/include           Related library files (gscl45nm) and simulation models used in simulation;
./project/netlist           Netlist file (.v), standard delay files (.sdf) and contraints files (.sdc) generated by Design; Compiler;
./project/pnr               Screenshot and log file of Cadence Innovus (P & R);
./project/report            Timing, area, power and also design checking log file generated by Design Compiler;
./project/scripts           Tcl scripts used by NC-Sim and Design Compiler;
./project/src               Source file used by Design Compiler to do logic synthesis;
./project/tb                Testbench file for individual modules;
./project/test_cases        Test_cases used by run.csh to function testing of top CMP module;
./project/work              Not applied;
./peoject/makefile          Makefile used to do simulation for RTL design (pre-simulation) and netlist (post-simulation);
./project/makefile_disable  Makefile used to do automatic simulation, synthesis and static timing analysis;
./project/run.csh           Csh scripts used to simulate the top cardinal_cmp.v or cardinal_cmp_syn.design

./setup_v1908.csh           Used to set all lab environments out project depends on


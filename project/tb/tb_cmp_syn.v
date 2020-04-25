/////////////////////////////////////////////////////////
// Filename       	: cpu_tb.v 				  
// Description    	: Cardinal Processor Simulation Testbenc
// Author         	: Praveen Sharma							  
// Fixed dataIn, dataOut port for DMEM.
// Fixed $readmemh statement for DM.fill
// Fixed minor bugs, related to signal names
/////////////////////////////////////////////////////////
// Test Bench for the Cardinal Processor RTL Verification

`timescale 1ns/10ps

//Define the clock cycle
`define CYCLE_TIME 4.05

// Include Files
// `include "./design/cardinal_cmp.v"
// `include "./design/alu.v"
// `include "./design/buffer_1loc.v"
// `include "./design/gold_ring.v"
// `include "./design/gold_router.v"
// `include "./design/cardinal_nic.v"
// `include "./design/cardinal_cpu.v"
// `include "./design/register_file.v"
// `include "./design/rotating_prioritizer.v"

`include "./netlist/cardinal_cmp.syn.v"

// Memory Files
`include "./include/dmem.v"
`include "./include/imem.v"
`include "./include/gscl45nm.v"

// Register File
//`include "./design/REGFILE32x64.v"

//Design File
//`include "./design/cpu.v"
//`include "./design/cardinal_nic.v"
//`include "./design/cardinal_ring.v"
//`include "./design/cardinal_router.v"

// This testbench instantiates the following modules:
// a. 64-bit Variable width Cardinal Processor as CPU, 
// b. 256 X 32 bit word Instruction memory
// c. 256 X 64 bit word Data memory

module tb_cmp_syn;
reg CLK, RESET;

wire [0:31] node0_pc_out;
wire [0:31] node0_inst_in;
wire [0:31] node0_addr_out;
wire [0:63] node0_d_out, node0_d_in;
wire node0_memEn, node0_memWrEn;

wire [0:1] node0_addr_nic;
wire [0:63] node0_din_nic, node0_dout_nic;
wire node0_nicEn, node0_nicWrEn;

wire [0:31] node1_pc_out;
wire [0:31] node1_inst_in;
wire [0:31] node1_addr_out;
wire [0:63] node1_d_out, node1_d_in;
wire node1_memEn, node1_memWrEn;

wire [0:1] node1_addr_nic;
wire [0:63] node1_din_nic, node1_dout_nic;
wire node1_nicEn, node1_nicWrEn;

wire [0:31] node2_pc_out;
wire [0:31] node2_inst_in;
wire [0:31] node2_addr_out;
wire [0:63] node2_d_out, node2_d_in;
wire node2_memEn, node2_memWrEn;

wire [0:1] node2_addr_nic;
wire [0:63] node2_din_nic, node2_dout_nic;
wire node2_nicEn, node2_nicWrEn;

wire [0:31] node3_pc_out;
wire [0:31] node3_inst_in;
wire [0:31] node3_addr_out;
wire [0:63] node3_d_out, node3_d_in;
wire node3_memEn, node3_memWrEn;

wire [0:1] node3_addr_nic;
wire [0:63] node3_din_nic, node3_dout_nic;
wire node3_nicEn, node3_nicWrEn;


integer dmem0_dump_file;		// Channel Descriptor for DMEM0 final dump
integer dmem1_dump_file;		// Channel Descriptor for DMEM1 final dump
integer dmem2_dump_file;		// Channel Descriptor for DMEM2 final dump
integer dmem3_dump_file;		// Channel Descriptor for DMEM3 final dump
integer i;
integer cycle_number;

//// ******************** Module Instantiations ******************** \\\\

// Instruction Memory Instance
imem IM_node0 (
	.memAddr		(node0_pc_out[22:29]),	// Only 8-bits are used in this project
	.dataOut		(node0_inst_in)		// 32-bit  Instruction
	);
	
imem IM_node1 (
	.memAddr		(node1_pc_out[22:29]),	// Only 8-bits are used in this project
	.dataOut		(node1_inst_in)		// 32-bit  Instruction
	);

imem IM_node2 (
	.memAddr		(node2_pc_out[22:29]),	// Only 8-bits are used in this project
	.dataOut		(node2_inst_in)		// 32-bit  Instruction
	);

imem IM_node3 (
	.memAddr		(node3_pc_out[22:29]),	// Only 8-bits are used in this project
	.dataOut		(node3_inst_in)		// 32-bit  Instruction
	);
// Data Memory Instance
dmem DM_node0 (
	.clk 		(CLK),				// System Clock
	.memEn		(node0_memEn),			// data-memory enable (to avoid spurious reads)
	.memWrEn	(node0_memWrEn),		// data-memory Write Enable
	.memAddr	(node0_addr_out[24:31]),	// 8-bit Memory address
	.dataIn		(node0_d_out),			// 64-bit data to data-memory
	.dataOut	(node0_d_in)			// 64-bit data from data-memory
	);	
 
 dmem DM_node1 (
	.clk 		(CLK),				// System Clock
	.memEn		(node1_memEn),			// data-memory enable (to avoid spurious reads)
	.memWrEn	(node1_memWrEn),		// data-memory Write Enable
	.memAddr	(node1_addr_out[24:31]),	// 8-bit Memory address
	.dataIn		(node1_d_out),			// 64-bit data to data-memory
	.dataOut	(node1_d_in)			// 64-bit data from data-memory
	);

dmem DM_node2 (
	.clk 		(CLK),				// System Clock
	.memEn		(node2_memEn),			// data-memory enable (to avoid spurious reads)
	.memWrEn	(node2_memWrEn),		// data-memory Write Enable
	.memAddr	(node2_addr_out[24:31]),	// 8-bit Memory address
	.dataIn		(node2_d_out),			// 64-bit data to data-memory
	.dataOut	(node2_d_in)			// 64-bit data from data-memory
	);

dmem DM_node3 (
	.clk 		(CLK),				// System Clock
	.memEn		(node3_memEn),			// data-memory enable (to avoid spurious reads)
	.memWrEn	(node3_memWrEn),		// data-memory Write Enable
	.memAddr	(node3_addr_out[24:31]),	// 8-bit Memory address
	.dataIn		(node3_d_out),			// 64-bit data to data-memory
	.dataOut	(node3_d_in)			// 64-bit data from data-memory
	);
	
cardinal_cmp CMP(
	.clk(CLK),
	.reset(RESET),
	
	.node0_inst_in	(node0_inst_in	),
	.node0_d_in	(node0_d_in	),
	.node0_pc_out  	(node0_pc_out  	),
	.node0_d_out   	(node0_d_out   	),
	.node0_addr_out	(node0_addr_out	),
	.node0_memWrEn	(node0_memWrEn	),
	.node0_memEn    (node0_memEn    ),

	.node1_inst_in  (node1_inst_in  ),
	.node1_d_in     (node1_d_in     ),
	.node1_pc_out   (node1_pc_out   ),
	.node1_d_out    (node1_d_out    ),
	.node1_addr_out (node1_addr_out ),
	.node1_memWrEn  (node1_memWrEn  ),
	.node1_memEn    (node1_memEn    ),
	
	.node2_inst_in  (node2_inst_in  ),
	.node2_d_in     (node2_d_in     ),
	.node2_pc_out   (node2_pc_out   ),
	.node2_d_out    (node2_d_out    ),
	.node2_addr_out (node2_addr_out ),
	.node2_memWrEn  (node2_memWrEn  ),
	.node2_memEn    (node2_memEn    ),

	.node3_inst_in  (node3_inst_in  ),
	.node3_d_in     (node3_d_in     ),
	.node3_pc_out   (node3_pc_out   ),
	.node3_d_out    (node3_d_out    ),
	.node3_addr_out (node3_addr_out ),
	.node3_memWrEn  (node3_memWrEn  ),
	.node3_memEn    (node3_memEn    )
	);
	
always #(`CYCLE_TIME / 2) CLK <= ~CLK;	

initial begin
    #50000
    $finish;
end
	
initial
begin
	$readmemh("cmp_test.imem.0.fill", IM_node0.MEM); 	// loading instruction memory into node0
	$readmemh("cmp_test.imem.1.fill", IM_node1.MEM); 	// loading instruction memory into node1
	$readmemh("cmp_test.imem.2.fill", IM_node2.MEM); 	// loading instruction memory into node2
	$readmemh("cmp_test.imem.3.fill", IM_node3.MEM); 	// loading instruction memory into node3

	$readmemh("cmp_test.dmem.0.fill", DM_node0.MEM); 	// loading data memory into node0
	$readmemh("cmp_test.dmem.1.fill", DM_node1.MEM); 	// loading data memory into node1
	$readmemh("cmp_test.dmem.2.fill", DM_node2.MEM); 	// loading data memory into node2
	$readmemh("cmp_test.dmem.3.fill", DM_node3.MEM); 	// loading data memory into node3

	// $readmemh("cmp_test.nic.0.fill", CMP.NIC_NODE0.MEM);	// loading dummy nic 0 memory
	// $readmemh("cmp_test.nic.1.fill", CMP.NIC_NODE1.MEM);	// loading dummy nic 1 memory
	// $readmemh("cmp_test.nic.2.fill", CMP.NIC_NODE2.MEM);	// loading dummy nic 2 memory
	// $readmemh("cmp_test.nic.3.fill", CMP.NIC_NODE3.MEM);	// loading dummy nic 3 memory
	
	CLK <= 0;				// initialize Clock
	RESET <= 1'b1;				// reset the CPU 
	repeat(5) @(negedge CLK);		// wait for 5 clock cycles
	RESET <= 1'b0;				// de-activate reset signal after 5ns

	// Convention for the last instruction
	// We would have a last instruction NOP  => 32'h00000000
	wait (node0_inst_in == 32'h00000000 && node1_inst_in == 32'h00000000 && node2_inst_in == 32'h00000000 && node3_inst_in == 32'h00000000);
	// Let us see how much did you stall
	$display("The program completed in %d cycles", cycle_number);
	// Let us now flush the pipe line
	repeat(30) @(negedge CLK);  // wait for all instruction finished ///////////// modified
	// Open file for output
	dmem0_dump_file = $fopen("cmp_test.dmem0.dump"); // assigning the channel descriptor for output file
	dmem1_dump_file = $fopen("cmp_test.dmem1.dump"); // assigning the channel descriptor for output file
	dmem2_dump_file = $fopen("cmp_test.dmem2.dump"); // assigning the channel descriptor for output file
	dmem3_dump_file = $fopen("cmp_test.dmem3.dump"); // assigning the channel descriptor for output file

	// Let us now dump all the locations of the data memory now
	for (i=0; i<128; i=i+1) 
	begin
		$fdisplay(dmem0_dump_file, "Memory location #%d : %h ", i, DM_node0.MEM[i]);
		$fdisplay(dmem1_dump_file, "Memory location #%d : %h ", i, DM_node1.MEM[i]);
		$fdisplay(dmem2_dump_file, "Memory location #%d : %h ", i, DM_node2.MEM[i]);
		$fdisplay(dmem3_dump_file, "Memory location #%d : %h ", i, DM_node3.MEM[i]);
	end
	$fclose(dmem0_dump_file);
	$fclose(dmem1_dump_file);
	$fclose(dmem2_dump_file);
	$fclose(dmem3_dump_file);
	$finish;
	
end // initial begin
	
//// ******************** Cycle Counter ******************** \\\\

always @ (posedge CLK)
begin
	if (RESET)
		cycle_number <= 0;
	else
		cycle_number <= cycle_number + 1;
end

initial 
begin
	$sdf_annotate("./netlist/cardinal_cmp.sdf", CMP,,"sdf.log","MAXIMUM","1.0:1.0:1.0", "FROM_MAXIMUM");
	$enable_warnings;
	$log("ncsim.log");//outputs the log in console to file
end

endmodule


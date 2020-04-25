/////////////////////////////////////////////////////////////////////
// Project      : EE577B Spring2015 Cardinal SoC
// Filename     : dmem.v
// Description  : Data Memory For Cardinal Processor 
// Author       : Aditya Deshpande
// Date Created : 03/06/2015 
// Version      : ver2
// Last Modified by : Aditya 
// Update Log   : 
// ver2: updated name for MemoryWriteEnable signal
//
/////////////////////////////////////////////////////////////////////
`timescale 1ns/10ps

module dmem (clk, memEn, memWrEn, memAddr, dataIn, dataOut);
	input          clk;       // System Clock
	input          memEn;     // Memory Enable
	input          memWrEn;   // Memory Write Enable
	input  [0:7]   memAddr;   // Memory Read/Write Address (8-bit)
	input  [0:63]  dataIn;    // Memory WRITE Data
	output [0:63]  dataOut;   // Memory READ Output

	// Memory Declaration
	reg [0:63] MEM[0:255];    // 64-wide, 256-deep memory
	
	// Registered Inputs
	reg r_memEn;
	reg [0:7] r_memAddr;

	// READ Operation
	assign dataOut = r_memEn ? MEM[r_memAddr] : 64'd0;
	
	// Input Registers
	always @(posedge clk) begin
		r_memEn <= memEn;
		r_memAddr <= memAddr;
	end
	
	// Synchronous WRITE Operation
	always @(posedge clk) begin
		if (memEn & memWrEn) begin
			MEM[memAddr] <= dataIn;
		end
	end
endmodule


/////////////////////////////////////////////////////////////////////
// Project      : EE577B Spring2015 Cardinal SoC
// Filename     : imem.v
// Description  : Instruction Memory For Cardinal Processor 
// Author       : Aditya Deshpande
// Date Created : 03/06/2015 
// Version      : ver2
// Last Modified by : Aditya 
// Update Log   :
//  updated dataOut vector field to [0:31] from [0:63]
//
/////////////////////////////////////////////////////////////////////
`timescale 1ns/10ps

module imem (memAddr, dataOut);
	input  [0:7]   memAddr;   // Memory Read Address (8-bit)
	output [0:31]  dataOut;   // Memory READ Output Data

	// Memory Declaration
	reg [0:31] MEM[0:255];    // 32-wide, 256-deep memory

	// Asynchronous READ Operation
	assign dataOut = MEM[memAddr];
	
endmodule


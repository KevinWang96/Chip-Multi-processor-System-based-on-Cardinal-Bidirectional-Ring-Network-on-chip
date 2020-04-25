`timescale 1ns/1ps

`include "./include/gscl45nm.v"

module PISO_tb_syn();

	reg[7:0] d;
	reg clk, reset;
	wire q;
	
	PISO freq1 (d, clk, reset, q);

	initial
	begin
				clk = 1'b1;
				reset = 1'b1;
				d = 8'b11101001;
		#2.5	reset = 1'b0;
		#10		reset = 1'b1;
		#2		$finish;
	end
	
	always
	begin
		#0.5 clk <= ~clk;
	end
	
	initial begin
	$sdf_annotate("./netlist/PISO.sdf", freq1,,"sdf.log","MAXIMUM","1.0:1.0:1.0", "FROM_MAXIMUM");
	$enable_warnings;
	$log("ncsim.log");
	end
	

endmodule
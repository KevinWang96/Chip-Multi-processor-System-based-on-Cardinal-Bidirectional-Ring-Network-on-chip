`timescale 1ns/1ps

module PISO_tb();

	reg[7:0] d;
	reg clk, reset;
	wire q;
	
	PISO p0 (d, clk, reset, q);

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

endmodule
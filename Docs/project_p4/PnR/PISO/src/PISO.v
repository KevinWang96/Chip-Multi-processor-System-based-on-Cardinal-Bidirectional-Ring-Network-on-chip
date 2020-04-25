`timescale 1ns/1ps

module PISO (d, clk, reset, q);

	parameter n = 8;
	
	input[n-1:0] d;
	input clk, reset;
	
	output q;
	
	reg q;
	
	reg[n-1:0] temp;
	
	always @ (posedge clk)
	begin
		if(reset == 1'b1)
		begin
			temp <= d;
			q <= 1'b0;
		end
		
		else
		begin
			q <= temp[0];
			temp <= {1'b0, temp[n-1:1]};
		end
	
	end
endmodule
	
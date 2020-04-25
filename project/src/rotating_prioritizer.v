/*
 * @Author: Yihao Wang
 * @Date: 2020-03-09 22:27:43
 * @LastEditTime: 2020-03-31 00:16:39
 * @LastEditors: Please set LastEditors
 * @Description: Rotating prioritizer that can support 2 input request
 * @FilePath: /EE577b_final_project/project_p1/design/rotating_prioritizer.v
 */
module rotating_prioritizer 
#(
	parameter initial_value = 1 // request 0 has the highest priority after reseting
)
(
	input clk, reset, // sync hign active reset
	input polarity, // used to tracking the priority order for two virtual channel
	input rq_0, rq_1, // input request 0 and request 1
	output reg gt_0, gt_1 // granted request 0 and granted request 1
);

	// register the last granted request when confliction happen and decrease its priority in the next clock
	// _v0: for virtual channel 0
	// _v1: for virtual channel 1
	reg last_gt_v0, last_gt_v1; 

	// Fixed prioritizer 
	// rq_n_f is the input of fixed prioritizer
	// gt_n_f is the oitput of fixed prioritizer
	//rq_0_f has the highest priority
	reg rq_0_f, rq_1_f;
	reg gt_0_f, gt_1_f;

	always @(*)
	begin
		if(rq_0_f == 1) 
		begin
			gt_0_f = 1;
			gt_1_f = 0;
		end
		else
		begin
			gt_0_f = 0;
			gt_1_f = rq_1_f;
		end
	end

	// input and output barrel shifter
	always @(*)
	begin
		if(polarity == 1)
			if(last_gt_v1 == 1) 
			begin
				{rq_0_f, rq_1_f} = {rq_0, rq_1}; // switch
				{gt_0, gt_1} = {gt_0_f, gt_1_f}; // output as it is
			end
			else 
			begin
				{rq_1_f, rq_0_f} = {rq_0, rq_1}; // switch
				{gt_1, gt_0} = {gt_0_f, gt_1_f}; // output as it is
			end
		else // polarity == 0
			if(last_gt_v0 == 1) 
			begin
				{rq_0_f, rq_1_f} = {rq_0, rq_1}; // switch
				{gt_0, gt_1} = {gt_0_f, gt_1_f}; // output as it is
			end
			else 
			begin
				{rq_1_f, rq_0_f} = {rq_0, rq_1}; // switch
				{gt_1, gt_0} = {gt_0_f, gt_1_f}; // output as it is
			end	
	end	

	// register the current granted request
	always @(posedge clk)
	begin
		if(reset) 
		begin
			last_gt_v0 <= initial_value;
			last_gt_v1 <= initial_value;
		end
		else
		begin
			if(polarity == 1)
				if((rq_0 == 0) || (rq_1 == 0)) // once no contention happens, we need to reset the priority order
					last_gt_v1 <= initial_value;
				else
				begin
					// both gt_0 and gt_1 can not be 1 at the same time
					if(gt_0) last_gt_v1 <= 0;
					if(gt_1) last_gt_v1 <= 1;
				end

			else // if polarity == 0
				if((rq_0 == 0) || (rq_1 == 0)) // once no contention happens, we need to reset the priority order
					last_gt_v0 <= initial_value;
				else
				begin
					if(gt_0) last_gt_v0 <= 0;
					if(gt_1) last_gt_v0 <= 1;
				end

		end
	end

endmodule
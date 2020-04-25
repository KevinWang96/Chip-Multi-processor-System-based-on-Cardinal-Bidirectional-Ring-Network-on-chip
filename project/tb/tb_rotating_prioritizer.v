/*
 * @Author: Yihao Wang
 * @Date: 2020-03-09 20:46:57
 * @LastEditTime: 2020-03-15 22:48:08
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: /EE577b_final_project/project_p1/tb/tb_rotating_prioritizer.v
 */
`timescale 1ns/1ps

module tb_rotating_prioritizer;
    reg rq_0, rq_1;
    reg clk, reset;
    wire gt_0, gt_1;

    parameter CLK_CYCLE = 5;

    //dut
    rotating_prioritizer
    #(
        .initial_value(0)
    )
    dut
    (
        .clk(clk),
        .reset(reset),
        .rq_0(rq_0),
        .rq_1(rq_1),
        .gt_0(gt_0),
        .gt_1(gt_1)    
    );

    always #(0.5 * CLK_CYCLE) clk = ~clk;

    initial
    begin
        reset = 1;
        clk = 1;
        #(3 * CLK_CYCLE)
        reset = 0;

        rq_0 = 1;
        rq_1 = 1;

        #(20 * CLK_CYCLE)
        $finish;
    end
endmodule   
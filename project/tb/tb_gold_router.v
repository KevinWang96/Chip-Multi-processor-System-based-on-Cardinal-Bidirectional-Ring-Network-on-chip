/*
 * @Author: Yihao Wang
 * @Date: 2020-03-09 20:46:57
 * @LastEditTime: 2020-03-23 13:04:19
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: /EE577b_final_project/project_p1/tb/tb_gold_router.v
 */
`timescale 1ns/1ps
module tb_gold_router;

    parameter PAC_SIZE = 64;
    parameter CLK_CYCLE = 5;

    reg clk, polarity, reset;

    reg cwsi, ccwsi, pesi;
    wire cwri, ccwri, peri;
    reg [PAC_SIZE - 1:0] cwdi, ccwdi, pedi;

    reg cwro, ccwro, pero;
    wire cwso, ccwso, peso;
    wire [PAC_SIZE - 1:0] cwdo, ccwdo, pedo;

    gold_router
    #(
        .PACKET_SIZE(PAC_SIZE)
    )
    dut
    (
        .clk(clk), .reset(reset), .polarity(polarity),
        .cwsi(cwsi), .cwri(cwri), .cwdi(cwdi),
        .ccwsi(ccwsi), .ccwri(ccwri), .ccwdi(ccwdi),
        .pesi(pesi), .peri(peri), .pedi(pedi),
        .cwso(cwso), .cwro(cwro), .cwdo(cwdo),
        .ccwso(ccwso), .ccwro(ccwro), .ccwdo(ccwdo),
        .peso(peso), .pero(pero), .pedo(pedo)
    );

    always #(0.5 * CLK_CYCLE) clk = ~ clk;

    always @(posedge clk)
    begin
        if(reset) polarity <= 0;
        else polarity <= ~ polarity;
    end

    
    initial
    begin : test 
        integer i;
        clk = 1;
        reset = 1;
        cwsi = 0;
        ccwsi = 0;
        pesi = 0;
        cwro = 1;
        ccwro = 1;
        pero = 1;

        #(3.1 * CLK_CYCLE)
        for(i = 0; i < 20; i = i + 1)
        begin
            reset = 0;
    
            ccwsi = 1;
            ccwdi = {1'b0, 1'b1, 6'b0, 8'b1111_1111, 48'b11111};
            ccwdi[63] = {i + 1};// vc
            ccwdi[55-:8] = 1; // hop
            ccwdi[62] = 0; // dir

            pesi = 1;
            pedi = {1'b0, 1'b1, 6'b0, 8'b1111_1111, 48'b0};
            pedi[63] = {i + 1}; // vc
            pedi[55-:8] = 0; // hop
            pedi[62] = 1; // dir

            #(CLK_CYCLE);
        end

        #(10 * CLK_CYCLE) 
        $finish;

    end

endmodule
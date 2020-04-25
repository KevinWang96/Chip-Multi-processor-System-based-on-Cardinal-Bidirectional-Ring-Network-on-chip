`timescale 1ns/1ps
`define ADDR_WIDTH 5
`define DATA_WIDTH 64
`define CLK_CYCLE 3
/*
 * @Author: Yihao Wang
 * @Date: 2020-03-19 19:48:43
 * @LastEditTime: 2020-03-21 18:55:35
 * @LastEditors: Please set LastEditors
 * @Description: Testbench for Register File
 * @FilePath: /EE577b_final_project/project_p2/tb/tb_register_file.v
 */
 module tb_register_file;
    
    reg clk, reset;
    reg WrEn; // write enable 
    reg [0:2] sel; // ppp value
    reg [0:`DATA_WIDTH - 1] wr_data;
    reg [0:`ADDR_WIDTH - 1] rd_addr_0, rd_addr_1, wr_addr;
    wire [0:`DATA_WIDTH - 1] rd_data_0, rd_data_1;

    always #(0.5 * `CLK_CYCLE) clk = ~ clk;

    // Instantiation of DUT
    register_file register_file_dut
    (
        .clk(clk),
        .reset(reset),
        .we(WrEn),
        .sel(sel),
        .data_in(wr_data),
        .addr_wr(wr_addr),
        .addr_rd_0(rd_addr_0),
        .addr_rd_1(rd_addr_1),
        .data_out_0(rd_data_0),
        .data_out_1(rd_data_1)
    );

    integer out_file;
    initial 
    begin : test 
        integer count;
        reg [0:63] initial_data;

        out_file = $fopen("RF_contents.res","w");
        
        reset = 1;
        clk = 1;
        #(`CLK_CYCLE) 

        reset = 0;
        
        initial_data = 64'hffff_ffff_ffff_ffff;
        WrEn = 0;
        sel = 3'b000;
        #(0.2 * `CLK_CYCLE)

        // Writes the content of RF into files
        for(count = 0; count < 2 ** `ADDR_WIDTH; count = count + 1)
        begin
            rd_addr_0 = count;
            #(0.3 * `CLK_CYCLE)
            $fdisplay(out_file, "$%1d : %h", count, rd_data_0);
            #(0.7 * `CLK_CYCLE);
        end

        // Tests internal forwarding
        WrEn = 1;
        for(count = 0; count < 2 ** `ADDR_WIDTH; count = count + 1)
        begin
            wr_addr = count;
            wr_data = initial_data;
            rd_addr_0 = count;
            rd_addr_1 = count;
            #(`CLK_CYCLE);
        end

        // Tests selective writing
        initial_data = 64'h1111_1111_1111_1111;
        for(count = 0; count < 2 ** `ADDR_WIDTH; count = count + 1)
        begin
            sel = count;
            wr_addr = count;
            wr_data = initial_data;
            rd_addr_0 = count;
            rd_addr_1 = count;
            #(`CLK_CYCLE);
        end        

        // Writes the content of RF into files
        for(count = 0; count < 2 ** `ADDR_WIDTH; count = count + 1)
        begin
            rd_addr_0 = count;
            #(0.1 * `CLK_CYCLE)
            $fdisplay(out_file, "$%1d : %h", count, rd_data_0);
        end

        #(5 * `CLK_CYCLE) 
        $fclose(out_file);
        $finish;
    end

 endmodule
 `undef ADDR_WIDTH
 `undef DATA_WIDTH
 `undef CLK_CYCLE
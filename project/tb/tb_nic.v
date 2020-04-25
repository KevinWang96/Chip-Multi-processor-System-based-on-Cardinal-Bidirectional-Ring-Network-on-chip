`timescale 1ns/1ps
/*
 * @Author: Yihao Wang
 * @Date: 2020-03-15 16:44:21
 * @LastEditTime: 2020-03-15 20:55:46
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: /EE577b_final_project/project_p1/tb/tb_nic
 */
 module tb_nic;
    parameter DATA_WIDTH = 64;
    parameter CLK_CYCLE = 4;
    parameter NUM_OF_PAC = 10000; // how many packets will be sent

    reg clk, reset; // sync high active reset
    // Ports from router side
    reg net_ro, net_polarity, net_si;
    reg [0:DATA_WIDTH - 1] net_di;
    wire net_so, net_ri;
    wire [0:DATA_WIDTH - 1] net_do;

    // Ports from router side
    reg [0:1] addr;
    reg [0:DATA_WIDTH - 1] d_in;
    reg nicEn, nicEnWr;
    wire [0:DATA_WIDTH - 1] d_out;

    // Instantiation of DUT
    nic_design #(
        .PACKET_SIZE(DATA_WIDTH)
    )
    nic_design_dut
    (
        .clk(clk),
        .reset(reset),
        .net_so(net_so),
        .net_ro(net_ro),
        .net_do(net_do),
        .net_polarity(net_polarity),
        .net_si(net_si),
        .net_ri(net_ri),
        .net_di(net_di),
        .addr(addr),
        .d_in(d_in),
        .d_out(d_out),
        .nicEn(nicEn),
        .nicEnWr(nicEnWr)
    );

    // Generates clock signal
    always #(0.5 * CLK_CYCLE) clk = ~ clk;

    // Generates polarity signal
    always @(posedge clk)
    begin
        if(reset) net_polarity <= 0;
        else net_polarity <= ~ net_polarity;
    end


    integer data_received_pe, data_received_router;

    initial
    begin
        data_received_pe = $fopen("data_received_pe.res", "w"); // report data received in processor side
        data_received_router = $fopen("data_received_router.res", "w"); // report data received in router side
    end

    // a flag used to indicate if data sending from router finished
    // if send_finish == 1, data sending from processor started
    reg send_finish; 
    initial 
    begin : test
        integer i;
        clk = 1;
        reset = 1;

        nicEn = 1; // always reading
        nicEnWr = 0;

        net_ro = 0;
        net_si = 0;

        send_finish = 0;

        #(3.5 * CLK_CYCLE) 
        reset = 0;

        // sending data from router side
        for(i = 0; i < NUM_OF_PAC; i = i + 1)
        begin
            wait(net_ri == 1)
            #(0.1 * CLK_CYCLE)
            net_si = 1;
            net_di = i;
            #(CLK_CYCLE)
            net_si = 0;
        end

        #(10 * CLK_CYCLE);
        send_finish = 1; // change flag
        #(10 * CLK_CYCLE);

        // sending data from processor side
        i = 0;
        while(i < NUM_OF_PAC)
        begin
            #(0.1 * CLK_CYCLE)
            addr = 2'b11;
            #(0.1 * CLK_CYCLE)

            if(d_out[63] == 0) // checking status reg of output buffer
            begin
                addr = 2'b10;
                nicEnWr = 1;
                d_in = i;
                d_in[0] = i % 2; // change the vc bit to test conditional sending to router
                i = i + 1;
            end
            #(0.8 * CLK_CYCLE)
            nicEnWr = 0;
        end
        
        #(10 * CLK_CYCLE)
        $fclose(data_received_pe | data_received_router);
        $finish;
    end

    // Reveiving data at processor side
    initial 
    begin : loop_1
        #(3.5 * CLK_CYCLE)
        forever 
        begin 
        
            if(send_finish == 1)
                disable loop_1; // if data sending from router finished, disable this block

            addr = 2'b01;
            #(0.1 * CLK_CYCLE) 

            if(d_out[63] == 1) //check the status reg of input buffer
            begin
                addr = 2'b00;
                #(0.1 * CLK_CYCLE)
                $fdisplay(data_received_pe, "%1d", d_out[32:63]);
            end
            else #(0.1 * CLK_CYCLE);

            #(0.8 * CLK_CYCLE);
        end
    end

    //Receiving data from router side
    initial
    begin
        #(3.5 * CLK_CYCLE)
        forever @(posedge clk)
        begin
            net_ro = 1;
            #(0.1 * CLK_CYCLE)
            if(net_so == 1)
                $fdisplay(data_received_router, "%1d", net_do[32:63]);
        end
    end

 endmodule
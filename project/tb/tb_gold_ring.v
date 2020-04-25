/*
 * @Author: Yihao Wang
 * @Date: 2020-03-10 16:21:02
 * @LastEditTime: 2020-03-16 01:04:13
 * @LastEditors: Please set LastEditors
 * @Description: Testbench for gold ring NoC
 * @FilePath: /EE577b_final_project/project_p1/tb/tb_gold_ring.v
 */
`timescale 1ns/1ps
/*
    Gather testbench to test Gold Ring NoC system
*/
module tb_gold_ring;

    parameter PACKET_SIZE = 64;
    parameter CLK_CYCLE = 4; // default clock cycle is 4ns

    parameter NUM_OF_CYCLE = 10000; // One cycle inclues phase 0 to phase 3

    // The ID of each process element
    localparam  PE_0 = 0,
                PE_1 = 1,
                PE_2 = 2,
                PE_3 = 3;


    reg clk, reset;
    wire polarity_0, polarity_1, polarity_2, polarity_3;

    // Ports of device 0:
    reg pesi_0, pero_0;
    wire [PACKET_SIZE - 1:0] pedi_0;
    wire peri_0, peso_0;
    wire [PACKET_SIZE - 1:0] pedo_0;
    // Decode each 64bits packet
    reg pedi_0_vc, pedi_0_dir;
    reg [5:0] pedi_0_res;
    reg [7:0] pedi_0_hop;
    reg [15:0] pedi_0_src;
    reg [31:0] pedi_0_payload;
    assign pedi_0 = {pedi_0_vc, pedi_0_dir, pedi_0_res, pedi_0_hop, pedi_0_src, pedi_0_payload};

    wire pedo_0_vc, pedo_0_dir;
    wire [5:0] pedo_0_res;
    wire [7:0] pedo_0_hop;
    wire [15:0] pedo_0_src;
    wire [31:0] pedo_0_payload;
    assign {pedo_0_vc, pedo_0_dir, pedo_0_res, pedo_0_hop, pedo_0_src, pedo_0_payload} = pedo_0;


    // Ports of device 1:
    reg pesi_1, pero_1;
    wire [PACKET_SIZE - 1:0] pedi_1;
    wire peri_1, peso_1;
    wire [PACKET_SIZE - 1:0] pedo_1;
    // Decode each 64bits packet
    reg pedi_1_vc, pedi_1_dir;
    reg [5:0] pedi_1_res;
    reg [7:0] pedi_1_hop;
    reg [15:0] pedi_1_src;
    reg [31:0] pedi_1_payload;
    assign pedi_1 = {pedi_1_vc, pedi_1_dir, pedi_1_res, pedi_1_hop, pedi_1_src, pedi_1_payload};

    wire pedo_1_vc, pedo_1_dir;
    wire [5:0] pedo_1_res;
    wire [7:0] pedo_1_hop;
    wire [15:0] pedo_1_src;
    wire [31:0] pedo_1_payload;
    assign {pedo_1_vc, pedo_1_dir, pedo_1_res, pedo_1_hop, pedo_1_src, pedo_1_payload} = pedo_1;


    // Ports of device 2:
    reg pesi_2, pero_2;
    wire [PACKET_SIZE - 1:0] pedi_2;
    wire peri_2, peso_2;
    wire [PACKET_SIZE - 1:0] pedo_2;
    // Decode each 64bits packet
    reg pedi_2_vc, pedi_2_dir;
    reg [5:0] pedi_2_res;
    reg [7:0] pedi_2_hop;
    reg [15:0] pedi_2_src;
    reg [31:0] pedi_2_payload;
    assign pedi_2 = {pedi_2_vc, pedi_2_dir, pedi_2_res, pedi_2_hop, pedi_2_src, pedi_2_payload};

    wire pedo_2_vc, pedo_2_dir;
    wire [5:0] pedo_2_res;
    wire [7:0] pedo_2_hop;
    wire [15:0] pedo_2_src;
    wire [31:0] pedo_2_payload;
    assign {pedo_2_vc, pedo_2_dir, pedo_2_res, pedo_2_hop, pedo_2_src, pedo_2_payload} = pedo_2;


    // Ports of device 3:
    reg pesi_3, pero_3;
    wire [PACKET_SIZE - 1:0] pedi_3;
    wire peri_3, peso_3;
    wire [PACKET_SIZE - 1:0] pedo_3;
    // Decode each 64bits packet
    reg pedi_3_vc, pedi_3_dir;
    reg [5:0] pedi_3_res;
    reg [7:0] pedi_3_hop;
    reg [15:0] pedi_3_src;
    reg [31:0] pedi_3_payload;
    assign pedi_3 = {pedi_3_vc, pedi_3_dir, pedi_3_res, pedi_3_hop, pedi_3_src, pedi_3_payload};

    wire pedo_3_vc, pedo_3_dir;
    wire [5:0] pedo_3_res;
    wire [7:0] pedo_3_hop;
    wire [15:0] pedo_3_src;
    wire [31:0] pedo_3_payload;
    assign {pedo_3_vc, pedo_3_dir, pedo_3_res, pedo_3_hop, pedo_3_src, pedo_3_payload} = pedo_3;


    // Generate clock signal
    always #(0.5 * CLK_CYCLE) clk = ~ clk;

    // Instantiate the DUT:
    gold_ring #(
        .PAC_SIZE(PACKET_SIZE)
    )
    gold_ring_dut 
    (
        .clk(clk), .reset(reset),

        .node0_polarity(polarity_0), .node1_polarity(polarity_1), 
        .node2_polarity(polarity_2), .node3_polarity(polarity_3),
    
        .node0_pesi(pesi_0), .node0_peri(peri_0), .node0_pedi(pedi_0), 
        .node0_peso(peso_0), .node0_pero(pero_0), .node0_pedo(pedo_0),

        .node1_pesi(pesi_1), .node1_peri(peri_1), .node1_pedi(pedi_1), 
        .node1_peso(peso_1), .node1_pero(pero_1), .node1_pedo(pedo_1),

        .node2_pesi(pesi_2), .node2_peri(peri_2), .node2_pedi(pedi_2), 
        .node2_peso(peso_2), .node2_pero(pero_2), .node2_pedo(pedo_2),

        .node3_pesi(pesi_3), .node3_peri(peri_3), .node3_pedi(pedi_3), 
        .node3_peso(peso_3), .node3_pero(pero_3), .node3_pedo(pedo_3)
    );


    // Send data in phase k and return the status:
    // 0: not finished
    // 1: finished
    task send_data;
    input [1:0] phase;
    output status;
    begin : send
        status = 0; // not finished


        // Send data from PE 0
        wait (!polarity_0 && peri_0)
        if(phase != PE_0) // avoiding send data to itself
        begin
            pedi_0_res = phase; // used reserved field to store phase ID
            pedi_0_src = PE_0; // set the source to 0
            pedi_0_vc = 0;

            case(phase)
                PE_1 :
                begin
                    pedi_0_dir = 0; // clockwise
                    pedi_0_hop = 8'b0000_0001;
                    pedi_0_payload = PE_1;
                end
                PE_2 :
                begin
                    pedi_0_dir = 0; // clockwise
                    pedi_0_hop = 8'b0000_0011;
                    pedi_0_payload = PE_2;
                end
                PE_3 :
                begin
                    pedi_0_dir = 1; // counter clockwise
                    pedi_0_hop = 8'b0000_0001;
                    pedi_0_payload = PE_3;
                end
            endcase

            pesi_0 = 1;
            #(CLK_CYCLE)
            pesi_0 = 0;
        end

        // Send data from PE 1
        wait (!polarity_1 && peri_1)
        if(phase != PE_1)
        begin
            pedi_1_res = phase; // used reserved field to store phase ID
            pedi_1_src = PE_1; // set the source to 1
            pedi_1_vc = 0;

            case(phase)
                PE_0 :
                begin
                    pedi_1_dir = 1; // counter clockwise
                    pedi_1_hop = 8'b0000_0001;
                    pedi_1_payload = PE_0;
                end
                PE_2 :
                begin
                    pedi_1_dir = 0; // clockwise
                    pedi_1_hop = 8'b0000_0001;
                    pedi_1_payload = PE_2;
                end
                PE_3 :
                begin
                    pedi_1_dir = 0; // clockwise
                    pedi_1_hop = 8'b0000_0011;
                    pedi_1_payload = PE_3;
                end
            endcase

            pesi_1 = 1;
            #(CLK_CYCLE)
            pesi_1 = 0;
        end

        // Send data from PE 2
        wait (polarity_2 && peri_2)
        if(phase != PE_2) // avoiding send data to itself
        begin
            pedi_2_res = phase; // used reserved field to store phase ID
            pedi_2_src = PE_2; // set the source to 2
            pedi_2_vc = 1;

            case(phase)
                PE_0 :
                begin
                    pedi_2_dir = 0; // clockwise
                    pedi_2_hop = 8'b0000_0011;
                    pedi_2_payload = PE_0;
                end
                PE_1 :
                begin
                    pedi_2_dir = 1; // counter clockwise
                    pedi_2_hop = 8'b0000_0001;
                    pedi_2_payload = PE_1;
                end
                PE_3 :
                begin
                    pedi_2_dir = 0; // clockwise
                    pedi_2_hop = 8'b0000_0001;
                    pedi_2_payload = PE_3;
                end
            endcase

            pesi_2 = 1;
            #(CLK_CYCLE)
            pesi_2 = 0;
        end

        // Send data from PE 3
        wait (polarity_3 && peri_3)
        if(phase != PE_3) // avoiding send data to itself
        begin
            pedi_3_res = phase; // used reserved field to store phase ID
            pedi_3_src = PE_3; // set the source to 3
            pedi_3_vc = 1;

            case(phase)
                PE_0 :
                begin
                    pedi_3_dir = 0; // clockwise
                    pedi_3_hop = 8'b0000_0001;
                    pedi_3_payload = PE_0;
                end
                PE_1 :
                begin
                    pedi_3_dir = 0; // clockwise
                    pedi_3_hop = 8'b0000_0011;
                    pedi_3_payload = PE_1;
                end
                PE_2 :
                begin
                    pedi_3_dir = 1; // counter clockwise
                    pedi_3_hop = 8'b0000_0001;
                    pedi_3_payload = PE_2;
                end
            endcase

            pesi_3 = 1;
            #(CLK_CYCLE)
            pesi_3 = 0;
        end

        status = 1;// finished!
    end
    endtask


    // out_file is used to log arriving packets of each node
    // time_file is used to log start and end times of each phase
    integer out_file_0, out_file_1, out_file_2, out_file_3, time_file;
    initial
    begin
        out_file_0 = $fopen("gather_phase0.res", "w");
        out_file_1 = $fopen("gather_phase1.res", "w");
        out_file_2 = $fopen("gather_phase2.res", "w");
        out_file_3 = $fopen("gather_phase3.res", "w");
        time_file = $fopen("start_end_time.out", "w");
    end


    initial
    begin : test
        // Cycle means we do total four phases in one cycle
        // and do the next four phased in next cycle
        // How many cycles do we do depends on parameter NUM_OF_CYCLE
        integer cycle_ptr;
        integer phase_ptr;
        clk = 1;
        reset = 1;

        pesi_0 = 0;
        pesi_1 = 0;
        pesi_2 = 0;
        pesi_3 = 0;

        pero_0 = 1;
        pero_1 = 1;
        pero_2 = 1;
        pero_3 = 1;

        #(3.5 * CLK_CYCLE)
        reset = 0;
    
        for(cycle_ptr = 0; cycle_ptr < NUM_OF_CYCLE; cycle_ptr = cycle_ptr + 1)
        begin
            for(phase_ptr = 0; phase_ptr < 4; phase_ptr = phase_ptr + 1)
            begin : for_loop
                reg status;
                $fdisplay(time_file, "Phase %1d started at %1d ns", phase_ptr, $time);
                send_data(phase_ptr, status);
                $fdisplay(time_file, "Phase %1d ended at %1d ns", phase_ptr, $time);
            end
        end

        #(100 * NUM_OF_CYCLE * CLK_CYCLE)
        $fclose(out_file_0 | out_file_1 | out_file_2 | out_file_3 | time_file);
        $finish;

    end


    // Receive data in device 0;
    always @(posedge clk)
    begin
        if(!reset && peso_0)
            $fdisplay(out_file_0, "Phase = %1d, Time = %1dns, vc = %b, dir = %b, Destination = %1d, Source = %1d, Packet Value = %h", 
                        pedo_0_res, $time, pedo_0_vc, pedo_0_dir, pedo_0_payload, pedo_0_src, pedo_0);
    end

    // Receive data in device 1;
    always @(posedge clk)
    begin
        if(!reset && peso_1)
            $fdisplay(out_file_1, "Phase = %1d, Time = %1dns, vc = %b, dir = %b, Destination = %1d, Source = %1d, Packet Value = %h", 
                        pedo_1_res, $time, pedo_1_vc, pedo_1_dir, pedo_1_payload, pedo_1_src, pedo_1);
    end

    // Receive data in device 2;
    always @(posedge clk)
    begin
        if(!reset && peso_2)
            $fdisplay(out_file_2, "Phase = %1d, Time = %1dns, vc = %b, dir = %b, Destination = %1d, Source = %1d, Packet Value = %h", 
                        pedo_2_res, $time, pedo_2_vc, pedo_2_dir, pedo_2_payload, pedo_2_src, pedo_2);
    end  

    // Receive data in device 3;
    always @(posedge clk)
    begin
        if(!reset && peso_3)
            $fdisplay(out_file_3, "Phase = %1d, Time = %1dns, vc = %b, dir = %b, Destination = %1d, Source = %1d, Packet Value = %h", 
                        pedo_3_res, $time, pedo_3_vc, pedo_3_dir, pedo_3_payload, pedo_3_src, pedo_3);
    end


endmodule

/*
 * @Author: Yihao Wang
 * @Date: 2020-03-09 20:46:57
 * @LastEditTime: 2020-04-07 01:15:12
 * @LastEditors: Please set LastEditors
 * @Description: Cardinal network interface component, 
                which is to be used as a building block of a 4-core chip multiprocessor
 * @FilePath: /EE577b_final_project/project_p2/design/nic.v
 */
module cardinal_nic
#(
    parameter PACKET_SIZE = 64
)
(
    input clk, reset, // sync hign active reset
    
    //Ports with processor
    input [0:1] addr, //Specify the memory address mapped registers in the NIC
    input [0:PACKET_SIZE - 1] d_in, //Input packet from the PE to be injected into the network
    output reg [0:PACKET_SIZE - 1] d_out, //Content of the register specified by addr[1:0]
    input nicEn, //Enable signal to the NIC. If not asserted, d_out port assumes 64’h0000_0000.
    input nicEnWr, //Write enable signal to the NIC. If asserted along with nicEn , the data on the d_in port is written into the network output channel

    //Ports with router interconnect
    input net_si, //Send handshaking signal for the network input channel
    output reg net_ri, //Ready handshaking signal for the network input channel
    input [0:PACKET_SIZE - 1] net_di, //Packet data for the network input channel

    output reg net_so, //Send handshaking signal for the network output channel
    input net_ro, //Ready handshaking signal for the network output channel
    output reg [0:PACKET_SIZE - 1] net_do, //Packet data for the network output channel
    input net_polarity //Polarity input from the router connected to the NIC
);
    //Signals needed by two buffer
    reg [0:PACKET_SIZE - 1] in_buf_di, out_buf_di; //data input of input and output channel buffer
    wire [0:PACKET_SIZE - 1] in_buf_do, out_buf_do; //data output of input and output channel buffer   
    wire in_buf_status, out_buf_status; //the value of status register of input channel buffer and output channel buffer
    reg in_buf_re, out_buf_re; //read enable for input channel buffer and output channel buffer
    reg in_buf_we, out_buf_we; //write enable for input channel buffer and output channel buffer 

//-----------------------------------------------------------------------------------------------------------------------
    //Instantiate two 1 location buffer for both input and output channel buffer
    // the buffer of network input channel
    buffer_1loc in_buf 
    (
        .clk(clk),
        .reset(reset),
        .data_in(in_buf_di),
        .data_out(in_buf_do),
        .re(in_buf_re),
        .we(in_buf_we),
        .full(in_buf_status), //the value of status signal is equal to full signal
        .empty() 
    );

    // the buffer of network output channel
    buffer_1loc out_buf 
    (
        .clk(clk),
        .reset(reset),
        .data_in(out_buf_di),
        .data_out(out_buf_do),
        .re(out_buf_re),
        .we(out_buf_we),
        .full(out_buf_status), //the value of status signal is equal to full signal
        .empty() 
    );
//-----------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------------
    //Processor reading and writing logic
    always @(*)
    begin
        //initial value to avoid latch
        out_buf_we = 0;
        in_buf_re = 0;
        d_out = 0; //If not asserted, d_out port assumes 64’h0000_0000.

        out_buf_di = d_in;

        if(nicEn == 1)
        begin
            if(nicEnWr == 1) // nicEnWr == 1, nicEn == 1, writing output buffer
            begin
                if(addr == 2'b10)
                    //when buffer is full, this writing won't destroy the data inside buffer 
                    //even if write enable is 1, because logic inside the buffer will check the 
                    //value of full and avoid an ilegal writing
                    out_buf_we = 1; 
            end
            else //nicEnWr == 0, nicEn == 1, reading operation based on addr
            begin
                case(addr)
                    2'b00 : // read input channel buffer
                    begin
                        in_buf_re = 1;
                        d_out = in_buf_do;
                    end
                    2'b01 : // read input channel status register
                        d_out[63] = in_buf_status;
                    2'b11 : // read output channel status register
                        d_out[63] = out_buf_status;
                endcase
            end
        end
        
    end
//-----------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------------
    // Receiving data from router
    always @(*)
    begin
        in_buf_di = net_di;

        if(in_buf_status == 0)  net_ri = 1;
        else net_ri = 0;

        if((in_buf_status == 0) && (net_si == 1)) in_buf_we = 1;
        else in_buf_we = 0;
    end
//-----------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------------
    // Sending data from NiC to router
    always @(*)
    begin
        net_do = out_buf_do;
        net_so = 0;

        if((out_buf_status == 1) && (net_ro == 1))
        begin
            // when polarity == 1, even virtual channel is used externally
            // only packet with vc = 0 can enter virtual channel 0, vice versa
            if((net_polarity == 1)  && (out_buf_do[0] == 0)) // note: bit 0 is VC bit
                net_so = 1;
            if((net_polarity == 0) && (out_buf_do[0] == 1))
                net_so = 1;
        end

        if((net_so == 1) && ( net_ro == 1)) out_buf_re = 1;
        else out_buf_re = 0;
    end
//-----------------------------------------------------------------------------------------------------------------------

endmodule
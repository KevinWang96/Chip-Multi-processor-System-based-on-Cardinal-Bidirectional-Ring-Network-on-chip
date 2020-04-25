/*
 * @Author: Yihao Wang
 * @Date: 2020-03-09 22:27:43
 * @LastEditTime: 2020-04-07 00:24:34
 * @LastEditors: Please set LastEditors
 * @Description: Ring NoC Rounter
 * @FilePath: /EE577b_final_project/project_p1/design/gold_router.v
 */
module gold_router 
#(
    parameter PACKET_SIZE = 64 // we assume that phit = flit = packet size
)
(
    input clk, reset, polarity, // sync high active reset

    input cwsi, // clockwise input channel send signal
    output reg cwri, // clockwise input ready signal
    input [PACKET_SIZE - 1:0] cwdi, // clockwise input channel data_in 

    input ccwsi, // counter clockwise input channel send signal
    output reg ccwri, // counter clockwise input ready signal
    input [PACKET_SIZE - 1:0] ccwdi, // counter clockwise input channel data_in

    input pesi, // process element input channel send signal
    output reg peri, // process element input channel ready signal
    input [PACKET_SIZE - 1:0] pedi, // process element input channel data_in 

    output cwso, // clockwise output channel send signal
    input cwro, // clockwise output channel ready signal
    output [PACKET_SIZE - 1:0] cwdo, // clockwise output channel data_out

    output ccwso, // counter clockwise output channel send signal
    input ccwro, // counter clockwise output channel ready signal
    output [PACKET_SIZE - 1:0] ccwdo, // counter clockwise output channel data_out

    output peso, // process element output channel send signal
    input pero, // process element output channel ready signal
    output [PACKET_SIZE - 1:0] pedo // process element output channel data_out
);

//-----------------------------------------------------------------------------------------------------------------------
    // Six input buffers (3 physical channels x 2 virtual channels)
    // For example: full_cwi_v0 means full signal of buffer in cwi virtual channel 0
    wire full_cwi_v0, full_cwi_v1, full_ccwi_v0, full_ccwi_v1, full_pei_v0, full_pei_v1;
    wire empty_cwi_v0, empty_cwi_v1, empty_ccwi_v0, empty_ccwi_v1, empty_pei_v0, empty_pei_v1;
    reg re_cwi_v0, re_cwi_v1, re_ccwi_v0, re_ccwi_v1, re_pei_v0, re_pei_v1;
    reg we_cwi_v0, we_cwi_v1, we_ccwi_v0, we_ccwi_v1, we_pei_v0, we_pei_v1;
    wire [PACKET_SIZE - 1:0] do_cwi_v0, do_cwi_v1, do_ccwi_v0, do_ccwi_v1, do_pei_v0, do_pei_v1;

    buffer_1loc buf_cwi_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_cwi_v0),
        .empty(empty_cwi_v0),
        .re(re_cwi_v0),
        .we(we_cwi_v0),
        .data_in(cwdi),
        .data_out(do_cwi_v0)
    );

    buffer_1loc buf_cwi_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_cwi_v1),
        .empty(empty_cwi_v1),
        .re(re_cwi_v1),
        .we(we_cwi_v1),
        .data_in(cwdi),
        .data_out(do_cwi_v1)
    );

    buffer_1loc buf_ccwi_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_ccwi_v0),
        .empty(empty_ccwi_v0),
        .re(re_ccwi_v0),
        .we(we_ccwi_v0),
        .data_in(ccwdi),
        .data_out(do_ccwi_v0)
    );

    buffer_1loc buf_ccwi_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_ccwi_v1),
        .empty(empty_ccwi_v1),
        .re(re_ccwi_v1),
        .we(we_ccwi_v1),
        .data_in(ccwdi),
        .data_out(do_ccwi_v1)
    );

    buffer_1loc buf_pei_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_pei_v0),
        .empty(empty_pei_v0),
        .re(re_pei_v0),
        .we(we_pei_v0),
        .data_in(pedi),
        .data_out(do_pei_v0)
    );   

    buffer_1loc buf_pei_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_pei_v1),
        .empty(empty_pei_v1),
        .re(re_pei_v1),
        .we(we_pei_v1),
        .data_in(pedi),
        .data_out(do_pei_v1)
    ); 
//-----------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------
    // Decode the header of input packets
    // vitual channel bit
    wire vc_cwi, vc_ccwi, vc_pei;
    assign vc_cwi = cwdi[63];
    assign vc_ccwi = ccwdi[63];
    assign vc_pei = pedi[63];
    // Direction bit 
    wire dir_cwi, dir_ccwi, dir_pei;
    assign dir_cwi = cwdi[62];
    assign dir_ccwi = ccwdi[62];
    assign dir_pei = pedi[62];
    // Hop count
    wire [7:0] hop_cwi, hop_ccwi, hop_pei;
    assign hop_cwi = cwdi[55-:8];
    assign hop_ccwi = ccwdi[55-:8];
    assign hop_pei = pedi[55-:8];
    // Source infomation
    wire [15:0] src_cwi, src_ccwi, src_pei;
    assign src_cwi = cwdi[47-:16];
    assign src_ccwi = ccwdi[47-:16];
    assign src_pei = pedi[47-:16];
//-----------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------
    // Logic for write enable signal at input channel buffer
    always @(*)
    begin
        if(polarity == 0)
        begin
            we_cwi_v0 = 0;
            we_ccwi_v0 = 0;
            we_pei_v0 = 0;

            // only when both send and ready asseerted, data can be loaded into input buffer
            if(cwsi && cwri) we_cwi_v1 = 1;
            else we_cwi_v1 = 0;

            if(ccwsi && ccwri) we_ccwi_v1 = 1;
            else we_ccwi_v1 = 0; 

            if(pesi && peri) we_pei_v1 = 1;
            else we_pei_v1 = 0;   
        end
        else
        begin
            we_cwi_v1 = 0;
            we_ccwi_v1 = 0;
            we_pei_v1 = 0;

            if(cwsi && cwri) we_cwi_v0 = 1;
            else we_cwi_v0 = 0;

            if(ccwsi && ccwri) we_ccwi_v0 = 1;
            else we_ccwi_v0 = 0; 

            if(pesi && peri) we_pei_v0 = 1;
            else we_pei_v0 = 0; 
        end 
    end
//-----------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------------------
    // Logic for ready signal at input channel
    // Once the input buffer is empty, it asserted ready 
    always @(*)
    begin
        if(polarity == 0)
        begin
            // hop == 0 is a ilegal case when entering the router
            // we must assume the hop value must be greater than 1 when entering the router
            if(empty_cwi_v1) cwri = 1;
            else cwri = 0;
            
            if(empty_ccwi_v1) ccwri = 1;
            else ccwri = 0;
            
            if(empty_pei_v1) peri = 1; 
            else peri = 0;
        end
        else // if polarity == 1
        begin
            if(empty_cwi_v0) cwri = 1;
            else cwri = 0;
            
            if(empty_ccwi_v0) ccwri = 1;
            else ccwri = 0;
            
            if(empty_pei_v0) peri = 1;
            else peri = 0;
        end
    end
//-----------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------------
    // Six output buffers (3 physical channels x 2 virtual channels)
    // v0 means for virtual channel 0
    // v1 means for virtual channel 1
    wire full_cwo_v0, full_cwo_v1, full_ccwo_v0, full_ccwo_v1, full_peo_v0, full_peo_v1;
    wire empty_cwo_v0, empty_cwo_v1, empty_ccwo_v0, empty_ccwo_v1, empty_peo_v0, empty_peo_v1;
    wire re_cwo_v0, re_cwo_v1, re_ccwo_v0, re_ccwo_v1, re_peo_v0, re_peo_v1;
    reg we_cwo_v0, we_cwo_v1, we_ccwo_v0, we_ccwo_v1, we_peo_v0, we_peo_v1;
    reg [PACKET_SIZE - 1:0] di_cwo_v0, di_cwo_v1, di_ccwo_v0, di_ccwo_v1, di_peo_v0, di_peo_v1;
    wire [PACKET_SIZE - 1:0] do_cwo_v0, do_cwo_v1, do_ccwo_v0, do_ccwo_v1, do_peo_v0, do_peo_v1;

    buffer_1loc buf_cwo_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_cwo_v0),
        .empty(empty_cwo_v0),
        .re(re_cwo_v0),
        .we(we_cwo_v0),
        .data_in(di_cwo_v0),
        .data_out(do_cwo_v0)
    );

    buffer_1loc buf_cwo_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_cwo_v1),
        .empty(empty_cwo_v1),
        .re(re_cwo_v1),
        .we(we_cwo_v1),
        .data_in(di_cwo_v1),
        .data_out(do_cwo_v1)
    );

    buffer_1loc buf_ccwo_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_ccwo_v0),
        .empty(empty_ccwo_v0),
        .re(re_ccwo_v0),
        .we(we_ccwo_v0),
        .data_in(di_ccwo_v0),
        .data_out(do_ccwo_v0)
    );

    buffer_1loc buf_ccwo_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_ccwo_v1),
        .empty(empty_ccwo_v1),
        .re(re_ccwo_v1),
        .we(we_ccwo_v1),
        .data_in(di_ccwo_v1),
        .data_out(do_ccwo_v1)
    );

    buffer_1loc buf_peo_v0
    (
        .clk(clk),
        .reset(reset),
        .full(full_peo_v0),
        .empty(empty_peo_v0),
        .re(re_peo_v0),
        .we(we_peo_v0),
        .data_in(di_peo_v0),
        .data_out(do_peo_v0)
    );   

    buffer_1loc buf_peo_v1
    (
        .clk(clk),
        .reset(reset),
        .full(full_peo_v1),
        .empty(empty_peo_v1),
        .re(re_peo_v1),
        .we(we_peo_v1),
        .data_in(di_peo_v1),
        .data_out(do_peo_v1)
    );  
//-----------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------------
    // Logic for request signals
    // If possible, each input buffer will send requests to the arbitor of one of output buffer
    // If the input buffer is full and target output buffer is empty, the input buffer will send request to that output buffer
    // Based on value of hop counter or dir bit, each input buffer will know who he should send requests to
    reg rq_cwi_cwo, rq_cwi_peo;// rq_cwi_cwo means the requests sent from cwi input buffer to cwo output buffer
    reg rq_ccwi_ccwo, rq_ccwi_peo;
    reg rq_pei_cwo, rq_pei_ccwo;

    always @(*)
    begin
        rq_cwi_cwo = 0;
        rq_cwi_peo = 0;
        rq_ccwi_ccwo = 0;
        rq_ccwi_peo = 0;
        rq_pei_cwo = 0;
        rq_pei_ccwo = 0;

        if(polarity == 0) // if polarity == 0, data in vitual channel 0 will be served internally
        begin
            // bit 48 is LSB of hop counter
            if(full_cwi_v0 && (do_cwi_v0[48] == 1) && empty_cwo_v0) rq_cwi_cwo = 1;
            if(full_cwi_v0 && (do_cwi_v0[48] == 0) && empty_peo_v0) rq_cwi_peo = 1;
            
            if(full_ccwi_v0 && (do_ccwi_v0[48] == 1) && empty_ccwo_v0) rq_ccwi_ccwo = 1;
            if(full_ccwi_v0 && (do_ccwi_v0[48] == 0) && empty_peo_v0) rq_ccwi_peo = 1;

            // if dir = 0, go along clockwise direction, vice versa
            // bit 62 is dir bit
            if(full_pei_v0 && (do_pei_v0[62] == 0) && empty_cwo_v0) rq_pei_cwo = 1;
            if(full_pei_v0 && (do_pei_v0[62] == 1) && empty_ccwo_v0) rq_pei_ccwo = 1;
        end
        else // if polarity == 1, deal with virtual channel 1
        begin
            if(full_cwi_v1 && (do_cwi_v1[48] == 1) && empty_cwo_v1) rq_cwi_cwo = 1;
            if(full_cwi_v1 && (do_cwi_v1[48] == 0) && empty_peo_v1) rq_cwi_peo = 1;
            
            if(full_ccwi_v1 && (do_ccwi_v1[48] == 1) && empty_ccwo_v1) rq_ccwi_ccwo = 1;
            if(full_ccwi_v1 && (do_ccwi_v1[48] == 0) && empty_peo_v1) rq_ccwi_peo = 1;

            if(full_pei_v1 && (do_pei_v1[62] == 0) && empty_cwo_v1) rq_pei_cwo = 1;
            if(full_pei_v1 && (do_pei_v1[62] == 1) && empty_ccwo_v1) rq_pei_ccwo = 1;
        end
    end
//-----------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------------
    // Three rotating prioritizer (arbitor) for three output buffer
    // gt_cwi_cwo == 1 means grant permission to request from cwi input buffer to cwo output buffer
    wire gt_cwi_cwo, gt_cwi_peo; 
    wire gt_ccwi_ccwo, gt_ccwi_peo;
    wire gt_pei_cwo, gt_pei_ccwo;

    rotating_prioritizer #(
        .initial_value(1) // the initial priority order is cw, pe
    )
    arbitor_cwo
    (
        .clk(clk),
        .reset(reset),
        .polarity(polarity),
        .rq_0(rq_cwi_cwo),
        .rq_1(rq_pei_cwo),
        .gt_0(gt_cwi_cwo),
        .gt_1(gt_pei_cwo)
    );

    rotating_prioritizer #(
        .initial_value(1) // the initial priority order is ccw, pe
    )
    arbitor_ccwo
    (
        .clk(clk),
        .reset(reset),
        .polarity(polarity),
        .rq_0(rq_ccwi_ccwo),
        .rq_1(rq_pei_ccwo),
        .gt_0(gt_ccwi_ccwo),
        .gt_1(gt_pei_ccwo)
    );

    rotating_prioritizer #(
        .initial_value(1) // we doesn't care the initial priority oeder
    )
    arbitor_peo
    (
        .clk(clk),
        .reset(reset),
        .polarity(polarity),
        .rq_0(rq_cwi_peo),
        .rq_1(rq_ccwi_peo),
        .gt_0(gt_cwi_peo),
        .gt_1(gt_ccwi_peo)
    );
//-----------------------------------------------------------------------------------------------------------------------

    
//-----------------------------------------------------------------------------------------------------------------------
    // Logic for data transferring
    // Based on which requests are granted by arbitor
    // Once arbitor grants permission for one request, the data can be loaded into output buffer
    always @(*)
    begin
        // Set initial value to avoid latch
        re_cwi_v0 = 0;
        re_cwi_v1 = 0;
        re_ccwi_v0 = 0;
        re_ccwi_v1 = 0;
        re_pei_v0 = 0;
        re_pei_v1 = 0;
        
        we_cwo_v0 = 0;
        we_cwo_v1 = 0;
        we_ccwo_v0 = 0;
        we_ccwo_v1 = 0;
        we_peo_v0 = 0;
        we_peo_v1 = 0;

        di_cwo_v0 = 64'bx;
        di_cwo_v1 = 64'bx;
        di_ccwo_v0 = 64'bx;
        di_ccwo_v1 = 64'bx;
        di_peo_v0 = 64'bx;
        di_peo_v1 = 64'bx;

        if(polarity == 0) // polarity == 0
        begin
            if(gt_cwi_cwo) // if the transferring from cwi to cwo was permitted
            begin
                re_cwi_v0 = 1;
                we_cwo_v0 = 1;
                di_cwo_v0 = do_cwi_v0;// carry data from input buffer to output buffer
                di_cwo_v0[55-:8] = do_cwi_v0[55-:8] >> 1; // right shift hop counter by 1 bit
            end

            if(gt_cwi_peo)
            begin
                re_cwi_v0 = 1;
                we_peo_v0 = 1;
                di_peo_v0 = do_cwi_v0;
                di_peo_v0[55-:8] = do_cwi_v0[55-:8] >> 1;
            end

            if(gt_ccwi_ccwo)
            begin
                re_ccwi_v0 = 1;
                we_ccwo_v0 = 1;
                di_ccwo_v0 = do_ccwi_v0;
                di_ccwo_v0[55-:8] = do_ccwi_v0[55-:8] >> 1;
            end

            if(gt_ccwi_peo)
            begin
                re_ccwi_v0 = 1;
                we_peo_v0 = 1;
                di_peo_v0 = do_ccwi_v0;
                di_peo_v0[55-:8] = do_ccwi_v0[55-:8] >> 1;
            end

            if(gt_pei_cwo)
            begin
                re_pei_v0 = 1;
                we_cwo_v0 = 1;
                di_cwo_v0 = do_pei_v0;
                di_cwo_v0[55-:8] = do_pei_v0[55-:8] >> 1;
            end

            if(gt_pei_ccwo)
            begin
                re_pei_v0 = 1;
                we_ccwo_v0 = 1;
                di_ccwo_v0 = do_pei_v0;
                di_ccwo_v0[55-:8] = do_pei_v0[55-:8] >> 1;
            end
        end
        else // polarity == 1
        begin
            if(gt_cwi_cwo) 
            begin
                re_cwi_v1 = 1;
                we_cwo_v1 = 1;
                di_cwo_v1 = do_cwi_v1;
                di_cwo_v1[55-:8] = do_cwi_v1[55-:8] >> 1;
            end

            if(gt_cwi_peo)
            begin
                re_cwi_v1 = 1;
                we_peo_v1 = 1;
                di_peo_v1 = do_cwi_v1;
                di_peo_v1[55-:8] = do_cwi_v1[55-:8] >> 1;
            end

            if(gt_ccwi_ccwo)
            begin
                re_ccwi_v1 = 1;
                we_ccwo_v1 = 1;
                di_ccwo_v1 = do_ccwi_v1;
                di_ccwo_v1[55-:8] = do_ccwi_v1[55-:8] >> 1;
            end

            if(gt_ccwi_peo)
            begin
                re_ccwi_v1 = 1;
                we_peo_v1 = 1;
                di_peo_v1 = do_ccwi_v1;
                di_peo_v1[55-:8] = do_ccwi_v1[55-:8] >> 1;
            end

            if(gt_pei_cwo)
            begin
                re_pei_v1 = 1;
                we_cwo_v1 = 1;
                di_cwo_v1 = do_pei_v1;
                di_cwo_v1[55-:8] = do_pei_v1[55-:8] >> 1;
            end

            if(gt_pei_ccwo)
            begin
                re_pei_v1 = 1;
                we_ccwo_v1 = 1;
                di_ccwo_v1 = do_pei_v1;
                di_ccwo_v1[55-:8] = do_pei_v1[55-:8] >> 1;
            end
        end
    end
//-----------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------------
    // Logic for data_out port of router
    assign cwdo = (polarity == 0) ? do_cwo_v1 : do_cwo_v0;
    assign ccwdo = (polarity == 0) ? do_ccwo_v1 : do_ccwo_v0;  
    assign pedo = (polarity == 0) ? do_peo_v1 : do_peo_v0;  


    // Logic for send singal at output channel
    // The assertion of send signal depends on ready signal
    assign cwso = (polarity == 0) ? (full_cwo_v1 & cwro) : (full_cwo_v0 & cwro);
    assign ccwso = (polarity == 0) ? (full_ccwo_v1 & ccwro) : (full_ccwo_v0 & ccwro);  
    assign peso = (polarity == 0) ? (full_peo_v1 & pero) : (full_peo_v0 & pero); 


    // Logic for read enable of output buffer
    assign re_cwo_v0 = (polarity == 1) ? (cwso & cwro) : 0;
    assign re_cwo_v1 = (polarity == 0) ? (cwso & cwro) : 0;
    assign re_ccwo_v0 = (polarity == 1) ? (ccwso & ccwro) : 0;  
    assign re_ccwo_v1 = (polarity == 0) ? (ccwso & ccwro) : 0;  
    assign re_peo_v0 = (polarity == 1) ? (peso & pero) : 0;
    assign re_peo_v1 = (polarity == 0) ? (peso & pero) : 0;   
//-----------------------------------------------------------------------------------------------------------------------
endmodule 
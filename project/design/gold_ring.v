
/*
 * @Author: Yihao Wang
 * @Date: 2020-03-09 20:46:57
 * @LastEditTime: 2020-04-20 18:37:55
 * @LastEditors: Please set LastEditors
 * @Description: Cardinal Bidirectional Ring NoC supporting 4 devices
 * @FilePath: /EE577b_final_project/project_p1/design/gold_ring.v
 */
module gold_ring 
#(
    parameter PAC_SIZE = 64
)
(
    input clk, reset, // sync hign active reset

    // Ports with device 0
    input node0_pesi, node0_pero,
    output node0_peri, node0_peso,
    input [PAC_SIZE - 1:0] node0_pedi,
    output [PAC_SIZE - 1:0] node0_pedo,

    // Ports with device 1
    input node1_pesi, node1_pero,
    output node1_peri, node1_peso,
    input [PAC_SIZE - 1:0] node1_pedi,
    output [PAC_SIZE - 1:0] node1_pedo, 

    // Ports with device 2
    input node2_pesi, node2_pero,
    output node2_peri, node2_peso,
    input [PAC_SIZE - 1:0] node2_pedi,
    output [PAC_SIZE - 1:0] node2_pedo,

    // Ports with device 3
    input node3_pesi, node3_pero,
    output node3_peri, node3_peso,
    input [PAC_SIZE - 1:0] node3_pedi,
    output [PAC_SIZE - 1:0] node3_pedo,

    // Polarity output
    output node0_polarity, node1_polarity, node2_polarity, node3_polarity
);

    // Generate the polarity of clock
    reg polarity;
    always @(posedge clk)
    begin
        if(reset) polarity <= 1; // reset to odd  polarity
        else polarity <= ~ polarity;
    end
    
    // Output polarity used by NiC
    assign node0_polarity = polarity;
    assign node1_polarity = polarity;
    assign node2_polarity = polarity;
    assign node3_polarity = polarity;

    // Intermediate wires used to connect each two routers
    wire cwr_0, cwr_1, cwr_2, cwr_3;
    wire cws_0, cws_1, cws_2, cws_3;
    wire [PAC_SIZE - 1:0] cwd_0, cwd_1, cwd_2, cwd_3;
    wire ccwr_0, ccwr_1, ccwr_2, ccwr_3;
    wire ccws_0, ccws_1, ccws_2, ccws_3;
    wire [PAC_SIZE - 1:0] ccwd_0, ccwd_1, ccwd_2, ccwd_3;

//-----------------------------------------------------------------------------------------------------------------------
    //Instantiate four routers and connect them
    gold_router #(
        .PACKET_SIZE(PAC_SIZE)
    )
    router_0
    (
        .clk(clk), .reset(reset), .polarity(node0_polarity),
        .cwsi(cws_3), .cwri(cwr_3), .cwdi(cwd_3),
        .ccwsi(ccws_1), .ccwri(ccwr_1), .ccwdi(ccwd_1),
        .pesi(node0_pesi), .peri(node0_peri), .pedi(node0_pedi),
        .cwso(cws_0), .cwro(cwr_0), .cwdo(cwd_0),
        .ccwso(ccws_0), .ccwro(ccwr_0), .ccwdo(ccwd_0),
        .peso(node0_peso), .pero(node0_pero), .pedo(node0_pedo)
    );

    gold_router #(
        .PACKET_SIZE(PAC_SIZE)
    )
    router_1
    (
        .clk(clk), .reset(reset), .polarity(node1_polarity),
        .cwsi(cws_0), .cwri(cwr_0), .cwdi(cwd_0),
        .ccwsi(ccws_2), .ccwri(ccwr_2), .ccwdi(ccwd_2),
        .pesi(node1_pesi), .peri(node1_peri), .pedi(node1_pedi),
        .cwso(cws_1), .cwro(cwr_1), .cwdo(cwd_1),
        .ccwso(ccws_1), .ccwro(ccwr_1), .ccwdo(ccwd_1),
        .peso(node1_peso), .pero(node1_pero), .pedo(node1_pedo)
    );

    gold_router #(
        .PACKET_SIZE(PAC_SIZE)
    )
    router_2
    (
        .clk(clk), .reset(reset), .polarity(node2_polarity),
        .cwsi(cws_1), .cwri(cwr_1), .cwdi(cwd_1),
        .ccwsi(ccws_3), .ccwri(ccwr_3), .ccwdi(ccwd_3),
        .pesi(node2_pesi), .peri(node2_peri), .pedi(node2_pedi),
        .cwso(cws_2), .cwro(cwr_2), .cwdo(cwd_2),
        .ccwso(ccws_2), .ccwro(ccwr_2), .ccwdo(ccwd_2),
        .peso(node2_peso), .pero(node2_pero), .pedo(node2_pedo)
    );

    gold_router #(
        .PACKET_SIZE(PAC_SIZE)
    )
    router_3
    (
        .clk(clk), .reset(reset), .polarity(node3_polarity),
        .cwsi(cws_2), .cwri(cwr_2), .cwdi(cwd_2),
        .ccwsi(ccws_0), .ccwri(ccwr_0), .ccwdi(ccwd_0),
        .pesi(node3_pesi), .peri(node3_peri), .pedi(node3_pedi),
        .cwso(cws_3), .cwro(cwr_3), .cwdo(cwd_3),
        .ccwso(ccws_3), .ccwro(ccwr_3), .ccwdo(ccwd_3),
        .peso(node3_peso), .pero(node3_pero), .pedo(node3_pedo)
    );
//----------------------------------------------------------------------------------------------------------------------- 

endmodule
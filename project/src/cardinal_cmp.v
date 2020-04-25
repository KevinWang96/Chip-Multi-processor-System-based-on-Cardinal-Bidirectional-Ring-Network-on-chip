`define INST_WIDTH 32
`define DATA_WIDTH 64
`define ADDR_WIDTH 32
/*
 * @Author: Yihao Wang
 * @Date: 2020-03-21 19:36:05
 * @LastEditTime: 2020-04-20 18:37:32
 * @LastEditors: Please set LastEditors
 * @Description: 4-core Cardinal Chip Multi-processor System implemented by 
                    Cardinal Gold Ring NoC, Cardinal Processor
 * @FilePath: /EE577b_final_project/project_p2/design/cardinal_cmp.v
 */
module cardinal_cmp(
    input clk, reset, // sync active high reset
    input [0:`INST_WIDTH - 1] node0_inst_in, node1_inst_in, node2_inst_in, node3_inst_in, // instruction input ports for 4 nodes
    input [0:`DATA_WIDTH - 1] node0_d_in, node1_d_in, node2_d_in, node3_d_in, // data input ports for 4 nodes
    output [0:`ADDR_WIDTH - 1] node0_pc_out, node1_pc_out, node2_pc_out, node3_pc_out, // instruction pointer for 4 nodes
    output [0:`DATA_WIDTH - 1] node0_d_out, node1_d_out, node2_d_out, node3_d_out, // data output ports for 4 nodes
    output [0:`ADDR_WIDTH - 1] node0_addr_out, node1_addr_out, node2_addr_out, node3_addr_out, // addr output ports for 4 nodes
    output node0_memEn, node1_memEn, node2_memEn, node3_memEn, // data memory enbale signal for 4 nodes
    output node0_memWrEn, node1_memWrEn, node2_memWrEn, node3_memWrEn // data memory write enbale signal for 4 nodes
 );

    // Connection between NIC and processor
    wire nic_En_0, nic_En_1, nic_EN_2, nic_En_3;
    wire nic_WrEn_0, nic_WrEn_1, nic_WrEn_2, nic_WrEn_3;
    wire [0:1] nic_addr_0, nic_addr_1, nic_addr_2, nic_addr_3;
    wire [0:`DATA_WIDTH - 1] nic_di_0, nic_di_1, nic_di_2, nic_di_3;
    wire [0:`DATA_WIDTH - 1] nic_do_0, nic_do_1, nic_do_2, nic_do_3;  

    // Conniection between NIC and Ring NoC
    wire net_si_0, net_si_1, net_si_2, net_si_3;
    wire net_ri_0, net_ri_1, net_ri_2, net_ri_3;
    wire [0:`DATA_WIDTH - 1] net_di_0, net_di_1, net_di_2, net_di_3;
    wire net_so_0, net_so_1, net_so_2, net_so_3;
    wire net_ro_0, net_ro_1, net_ro_2, net_ro_3;
    wire [0:`DATA_WIDTH - 1] net_do_0, net_do_1, net_do_2, net_do_3;
    wire net_polarity_0, net_polarity_1, net_polarity_2, net_polarity_3;

    // Instantiation of 4 NICs:
    cardinal_nic nic_0
    (
        .clk(clk),
        .reset(reset),

        .addr(nic_addr_0),
        .d_in(nic_di_0),
        .d_out(nic_do_0),
        .nicEn(nic_En_0),
        .nicEnWr(nic_WrEn_0),
        
        .net_si(net_si_0),
        .net_ri(net_ri_0),
        .net_di(net_di_0),
        
        .net_so(net_so_0),
        .net_ro(net_ro_0),
        .net_do(net_do_0),
        .net_polarity(net_polarity_0)
    );

    cardinal_nic nic_1
    (
        .clk(clk),       
        .reset(reset),

        .addr(nic_addr_1),
        .d_in(nic_di_1),
        .d_out(nic_do_1),
        .nicEn(nic_En_1),
        .nicEnWr(nic_WrEn_1),
        
        .net_si(net_si_1),
        .net_ri(net_ri_1),
        .net_di(net_di_1),
        
        .net_so(net_so_1),
        .net_ro(net_ro_1),
        .net_do(net_do_1),
        .net_polarity(net_polarity_1)
    );

    cardinal_nic nic_2
    (
        .clk(clk),
        .reset(reset),

        .addr(nic_addr_2),
        .d_in(nic_di_2),
        .d_out(nic_do_2),
        .nicEn(nic_En_2),
        .nicEnWr(nic_WrEn_2),
        
        .net_si(net_si_2),
        .net_ri(net_ri_2),
        .net_di(net_di_2),
        
        .net_so(net_so_2),
        .net_ro(net_ro_2),
        .net_do(net_do_2),
        .net_polarity(net_polarity_2)
    );

    cardinal_nic nic_3
    (
        .clk(clk),
        .reset(reset),

        .addr(nic_addr_3),
        .d_in(nic_di_3),
        .d_out(nic_do_3),
        .nicEn(nic_En_3),
        .nicEnWr(nic_WrEn_3),
        
        .net_si(net_si_3),
        .net_ri(net_ri_3),
        .net_di(net_di_3),
        
        .net_so(net_so_3),
        .net_ro(net_ro_3),
        .net_do(net_do_3),
        .net_polarity(net_polarity_3)
    );

    // Instantiation of 4 processor cores
    cardinal_cpu processor_0
    (
        .clk(clk),
        .reset(reset),
        
        .instr_addr(node0_pc_out),
        .instr_in(node0_inst_in),

        .dmem_addr(node0_addr_out),
        .dmem_data_out(node0_d_out),
        .dmem_data_in(node0_d_in),
        .dmem_En(node0_memEn),
        .dmem_WrEn(node0_memWrEn),

        .nic_addr(nic_addr_0),
        .nic_data_out(nic_di_0),
        .nic_data_in(nic_do_0),
        .nic_En(nic_En_0),
        .nic_WrEn(nic_WrEn_0) 
    );

    cardinal_cpu processor_1
    (
        .clk(clk),
        .reset(reset),
        
        .instr_addr(node1_pc_out),
        .instr_in(node1_inst_in),

        .dmem_addr(node1_addr_out),
        .dmem_data_out(node1_d_out),
        .dmem_data_in(node1_d_in),
        .dmem_En(node1_memEn),
        .dmem_WrEn(node1_memWrEn),

        .nic_addr(nic_addr_1),
        .nic_data_out(nic_di_1),
        .nic_data_in(nic_do_1),
        .nic_En(nic_En_1),
        .nic_WrEn(nic_WrEn_1) 
    );

    cardinal_cpu processor_2
    (
        .clk(clk),
        .reset(reset),
        
        .instr_addr(node2_pc_out),
        .instr_in(node2_inst_in),

        .dmem_addr(node2_addr_out),
        .dmem_data_out(node2_d_out),
        .dmem_data_in(node2_d_in),
        .dmem_En(node2_memEn),
        .dmem_WrEn(node2_memWrEn),

        .nic_addr(nic_addr_2),
        .nic_data_out(nic_di_2),
        .nic_data_in(nic_do_2),
        .nic_En(nic_En_2),
        .nic_WrEn(nic_WrEn_2) 
    ); 

    cardinal_cpu processor_3
    (
        .clk(clk),
        .reset(reset),
        
        .instr_addr(node3_pc_out),
        .instr_in(node3_inst_in),

        .dmem_addr(node3_addr_out),
        .dmem_data_out(node3_d_out),
        .dmem_data_in(node3_d_in),
        .dmem_En(node3_memEn),
        .dmem_WrEn(node3_memWrEn),

        .nic_addr(nic_addr_3),
        .nic_data_out(nic_di_3),
        .nic_data_in(nic_do_3),
        .nic_En(nic_En_3),
        .nic_WrEn(nic_WrEn_3) 
    );   

    // Instantiation of Ring NoC:
    gold_ring ring_0
    (
        .clk(clk),
        .reset(reset),

        .node0_pesi(net_so_0),
        .node0_peri(net_ro_0),
        .node0_pedi(net_do_0),
        .node0_peso(net_si_0),
        .node0_pero(net_ri_0),
        .node0_pedo(net_di_0),
        .node0_polarity(net_polarity_0),

        .node1_pesi(net_so_1),
        .node1_peri(net_ro_1),
        .node1_pedi(net_do_1),
        .node1_peso(net_si_1),
        .node1_pero(net_ri_1),
        .node1_pedo(net_di_1),
        .node1_polarity(net_polarity_1),  

        .node2_pesi(net_so_2),
        .node2_peri(net_ro_2),
        .node2_pedi(net_do_2),
        .node2_peso(net_si_2),
        .node2_pero(net_ri_2),
        .node2_pedo(net_di_2),
        .node2_polarity(net_polarity_2),    

        .node3_pesi(net_so_3),
        .node3_peri(net_ro_3),
        .node3_pedi(net_do_3),
        .node3_peso(net_si_3),
        .node3_pero(net_ri_3),
        .node3_pedo(net_di_3),
        .node3_polarity(net_polarity_3)
    );
    
endmodule
`undef DATA_WIDTH
`undef INST_WIDTH
`undef ADDR_WIDTH
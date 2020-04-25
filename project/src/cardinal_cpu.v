/*
 * @Author: Yihao Wang
 * @Date: 2020-03-12 02:04:23
 * @LastEditTime: 2020-04-20 18:37:44
 * @LastEditors: Please set LastEditors
 * @Description: Cardinal Processor with 32-bit address, 32-bit instruction and 64-bit data
 * @FilePath: /EE577b_final_project/project_p2/design/processor_top.v
 */
 module cardinal_cpu (
     clk, reset, instr_in, dmem_data_in, nic_data_in,
     instr_addr, dmem_addr, dmem_data_out, dmem_En, dmem_WrEn, nic_addr, nic_data_out, nic_En, nic_WrEn
 );
    input clk, reset; // sync high active reset
    output [0:31] instr_addr; // address of instruction cache
    input [0:31] instr_in; // instruction input from instruction cache

    output [0:31] dmem_addr; // address from processor, which is used to access memory 
    output [0:63] dmem_data_out; // data output from processor to data memory 

    output dmem_En, dmem_WrEn; // enbale signal of data memory
    input [0:63] dmem_data_in; // data input from data memory

    output [0:1] nic_addr; // address from processor, which is used to access nic
    output [0:63] nic_data_out; // data output from processor to data nic

    output nic_En, nic_WrEn; // enbale signal of nic to processor
    input [0:63] nic_data_in; // data input from nic to processor


    // global signals
    wire stall; // stall singal, which will hold the entire pipeline if stall is 1
    reg Br_taken; // if Br_taken == 1, it means a branch is taken and flushing is needed
    reg [0:31] Br_addr; // branch address

    // 6-bit opcode definition
    localparam  R_TYPE_ALU = 6'b101010, // R-type ALU operations
                R_TYPE_BEZ = 6'b100010, // branch equal zero
                R_TYPE_BNEZ = 6'b100011, // branch not equal zero
                R_TYPE_NOP = 6'b111100, // NOP
                M_TYPE_LD = 6'b100000, // load
                M_TYPE_SD = 6'b100001; // store

    // selective execution mode
    localparam  ppp_a_mode = 3'b000,
                ppp_u_mode = 3'b001,
                ppp_d_mode = 3'b010,
                ppp_e_mode = 3'b011,
                ppp_o_mode = 3'b100;

// Definition of ALU function code
    localparam  VAND = 6'b000001,
                VOR = 6'b000010,
                VXOR = 6'b000011,
                VNOT = 6'b000100,
                VMOV = 6'b000101, // only carry di_A to output
                VADD = 6'b000110,
                VSUB = 6'b000111,
                VMULEU = 6'b001000,
                VMULOU = 6'b001001,
                VSLL = 6'b001010,
                VSRL = 6'b001011,
                VSRA = 6'b001100,
                VRTTH = 6'b001101,
                VDIV = 6'b001110,
                VMOD = 6'b001111, 
                VSQEU = 6'b010000,
                VSQOU = 6'b010001,
                VSQRT = 6'b010010;

//-----------------------------------------------------------------------------------------------------------------------
// IF stage:

    // Updating pc
    reg [0:31] pc; // program counter
    reg [0:31] IF_ID_reg; // IF and ID stage register
    // the priority of control signal is: reset, stall, Br_taken
    always @(posedge clk)
    begin
        if(reset) pc <= 0; // during boot up
        else
            if(stall) pc <= pc;
            else
                if(Br_taken) pc <= Br_addr;
                else pc <= pc + 4; // increments by 4 every clock
    end

    assign instr_addr = pc;


    // Updating IF/ID stage register
    always @(posedge clk)
    begin
        if(reset) IF_ID_reg <= 0; 
        else
            if(stall) IF_ID_reg <= IF_ID_reg;
            else 
                if(Br_taken) IF_ID_reg[0:5] <= R_TYPE_NOP; // flush IF/ID register by making it a NOP
                else IF_ID_reg <= instr_in;
    end


//-----------------------------------------------------------------------------------------------------------------------
// ID stage:

    // Instruction decode
    // Decodes each field
    wire [0:5] opcode_id;
    wire [0:4] rD_id, rA_id, rB_id;
    wire [0:2] ppp_id;
    wire [0:1] ww_id;
    wire [0:5] func_code_id; // function code
    wire [0:15] imm_addr_id; // immediate address
    
    assign opcode_id = IF_ID_reg[0:5];
    assign rD_id = IF_ID_reg[6:10];
    assign rA_id = IF_ID_reg[11:15];
    assign rB_id = IF_ID_reg[16:20];
    assign ppp_id = (opcode_id == M_TYPE_LD) ? 3'b000 : IF_ID_reg[21:23]; // if there is LD, ppp will always be 3'b000
    assign ww_id = IF_ID_reg[24:25];
    assign func_code_id = IF_ID_reg[26:31];
    assign imm_addr_id = IF_ID_reg[16:31];


    // Instantiation of Register File
    reg [0:4] RF_rd_addr_0, RF_rd_addr_1; // read address of two read port of RegFile
    wire [0:63] RF_rd_do_0, RF_rd_do_1; // read data of two read port of RegFile

    wire RF_WrEn_wb; // write enbale of register file from WB stage
    wire [0:2] ppp_wb; // ppp signal of register file from WB stage
    wire [0:4] RF_wr_addr_wb; // write addr of register file from WB stage
    wire [0:63] RF_wr_di_wb; // write data of register file from WB stage

    register_file RegFile
    (
        .clk(clk),
        .reset(reset),
        
        .we(RF_WrEn_wb),
        .data_in(RF_wr_di_wb),
        .sel(ppp_wb),  
        .addr_wr(RF_wr_addr_wb),
        
        .addr_rd_0(RF_rd_addr_0),
        .addr_rd_1(RF_rd_addr_1),
        .data_out_0(RF_rd_do_0),
        .data_out_1(RF_rd_do_1)
    );


    // Control unit to generate control signals in ID stage
    // Control signal inclue dmem_En, dmem_WrEn, nic_En, nic_WrEn, RF_we
    reg dmem_En_id, dmem_WrEn_id, nic_En_id, nic_WrEn_id, RF_WrEn_id;
    always @(*)
    begin
        // default value
        dmem_En_id = 0;
        dmem_WrEn_id = 0;
        nic_En_id = 0;
        nic_WrEn_id = 0;
        RF_WrEn_id = 0;

        // if ilegal instruction is execute, we will disable all control signals
        // Note that: if a R-type want to write $0, we also assert RF_WrEn!!
        case(opcode_id)
            R_TYPE_ALU :
                RF_WrEn_id = 1;
            M_TYPE_LD : 
            begin
                RF_WrEn_id = 1;
                if(imm_addr_id[0:1] == 2'b11) nic_En_id = 1;
                else dmem_En_id = 1;
            end
            M_TYPE_SD :
                if(imm_addr_id[0:1] == 2'b11)
                begin
                    nic_En_id = 1;
                    nic_WrEn_id = 1;
                end
                else
                begin
                    dmem_En_id = 1;
                    dmem_WrEn_id = 1;
                end
        endcase
    end

    // Intent to stall
    // If there is a SD or a LD (rD is not $0), we have the intent to stall in next stage
    // this signal is used to control the stall flag register
    wire intent_to_stall_id;
    assign intent_to_stall_id = ((opcode_id == M_TYPE_SD) || ((opcode_id == M_TYPE_LD) && (rD_id != 0)));

    // Intention for 5-clock ALU stall
    // For DIV, SQRT,
    wire intent_to_alu_stall5_id;
    assign intent_to_alu_stall5_id = ( (opcode_id == R_TYPE_ALU) && ((func_code_id == VDIV) || (func_code_id == VSQRT))  && (rD_id != 0) ) ? 1'b1 : 1'b0;

    // Intention for 4-clock ALU stall
    // For MULT, SQ, MOD, 
    wire intent_to_alu_stall4_id;
    assign intent_to_alu_stall4_id = ( (opcode_id == R_TYPE_ALU) 
        && ((func_code_id == VMULEU) || (func_code_id == VMULOU) || (func_code_id == VMOD) || (func_code_id == VSQEU) || (func_code_id == VSQOU))  
            && (rD_id != 0) ) ? 1'b1 : 1'b0;

    // Intention for 3-clock ALU stall
    // For ADD, SUB, SRL, SLL, SRA 
    wire intent_to_alu_stall3_id;
    assign intent_to_alu_stall3_id = ( (opcode_id == R_TYPE_ALU) 
        && ((func_code_id == VADD) || (func_code_id == VSUB) || (func_code_id == VSLL) || (func_code_id == VSRL) || (func_code_id == VSRA))  
            && (rD_id != 0) ) ? 1'b1 : 1'b0;

    // Generates register file read address of port 0 and port 1
    always @(*)
    begin
        RF_rd_addr_1 = rB_id;
        
        if((opcode_id == M_TYPE_SD) || (opcode_id == R_TYPE_BEZ) || (opcode_id == R_TYPE_BNEZ))
            RF_rd_addr_0 = rD_id;
        else
            RF_rd_addr_0 = rA_id;
    end


    // Hazards detecter
    // Note: we compare the rD of senior and rA or rB of junior in ID stage,
    //      then carry this 1-bit comparing result to EX_MEM stage and then used
    //      to forward data.
    reg hazard_det_rA_id, hazard_det_rB_id;
    wire RF_WrEn_exm;
    wire [0:4] rD_exm;
    always @(*)
    begin
        hazard_det_rA_id = 0;
        hazard_det_rB_id = 0;
        // we nned to check whether rD of senior is 0 or not
        if((RF_WrEn_exm == 1) && (rD_exm != 0))
        begin
            if(rD_exm == RF_rd_addr_0)
                hazard_det_rA_id = 1;
            if(rD_exm == RF_rd_addr_1)
                hazard_det_rB_id = 1;
        end
    end


    // Forwarding MUX in ID stage
    // This MUX forwards data from EX_MEM stage to ID stage
    reg [0:63] RF_rd_do_0_mux, RF_rd_do_1_mux; // the output of forwarding MUX in ID stage
    reg [0:63] RF_wr_di_exm; // output of register file write data MUX in EX_MEM stage
    wire [0:2] ppp_exm;
    always @(*)
    begin
        RF_rd_do_0_mux = RF_rd_do_0;
        RF_rd_do_1_mux = RF_rd_do_1;

        if(hazard_det_rA_id == 1)
            case(ppp_exm)
                ppp_a_mode :
                    RF_rd_do_0_mux[0:63] = RF_wr_di_exm[0:63];
                ppp_u_mode :
                    RF_rd_do_0_mux[0:31] = RF_wr_di_exm[0:31];
                ppp_d_mode :
                    RF_rd_do_0_mux[32:63] = RF_wr_di_exm[32:63];
                ppp_e_mode :
                begin
                    RF_rd_do_0_mux[0:7] = RF_wr_di_exm[0:7];
                    RF_rd_do_0_mux[16:23] = RF_wr_di_exm[16:23];
                    RF_rd_do_0_mux[32:39] = RF_wr_di_exm[32:39];
                    RF_rd_do_0_mux[48:55] = RF_wr_di_exm[48:55];
                end
                ppp_o_mode :
                begin
                    RF_rd_do_0_mux[8:15] = RF_wr_di_exm[8:15];
                    RF_rd_do_0_mux[24:31] = RF_wr_di_exm[24:31];
                    RF_rd_do_0_mux[40:47] = RF_wr_di_exm[40:47];
                    RF_rd_do_0_mux[56:63] = RF_wr_di_exm[56:63];
                end
            endcase

        if(hazard_det_rB_id == 1)
            case(ppp_exm)
                ppp_a_mode :
                    RF_rd_do_1_mux[0:63] = RF_wr_di_exm[0:63];
                ppp_u_mode :
                    RF_rd_do_1_mux[0:31] = RF_wr_di_exm[0:31];
                ppp_d_mode :
                    RF_rd_do_1_mux[32:63] = RF_wr_di_exm[32:63];
                ppp_e_mode :
                begin
                    RF_rd_do_1_mux[0:7] = RF_wr_di_exm[0:7];
                    RF_rd_do_1_mux[16:23] = RF_wr_di_exm[16:23];
                    RF_rd_do_1_mux[32:39] = RF_wr_di_exm[32:39];
                    RF_rd_do_1_mux[48:55] = RF_wr_di_exm[48:55];
                end
                ppp_o_mode :
                begin
                    RF_rd_do_1_mux[8:15] = RF_wr_di_exm[8:15];
                    RF_rd_do_1_mux[24:31] = RF_wr_di_exm[24:31];
                    RF_rd_do_1_mux[40:47] = RF_wr_di_exm[40:47];
                    RF_rd_do_1_mux[56:63] = RF_wr_di_exm[56:63];
                end
            endcase
    end


    // Generates Br_taken and Br_addr 
    always @(*)
    begin
        Br_taken = 0;
        Br_addr = {32'b0, imm_addr_id};

        if((opcode_id == R_TYPE_BEZ) && (RF_rd_do_0_mux == 0))
            Br_taken = 1;
        
        if((opcode_id == R_TYPE_BNEZ) && (RF_rd_do_0_mux != 0))
            Br_taken = 1;
    end

    // Shadow register to solve stalling of input register of data memory
    // Because input register of data register doesn't have enable signal
    reg [0:97] shadow_reg;
    always @(posedge clk)
    begin
        if(reset) shadow_reg <= 0;
        else
        begin 
            if(stall) shadow_reg <= shadow_reg;
            else
            begin
                shadow_reg[0] <= dmem_WrEn_id;
                shadow_reg[1] <= dmem_En_id;
                shadow_reg[2:33] <= {16'b0, imm_addr_id};
                shadow_reg[34:97] <= RF_rd_do_0_mux;
            end
        end
    end

    // Generates the control signals, data input, address of external data memory
    // If stall is active, it will fetch data from shadow register
    assign dmem_En = (stall == 1) ? shadow_reg[1] : dmem_En_id;
    assign dmem_WrEn = (stall == 1) ? shadow_reg[0] : dmem_WrEn_id;
    assign dmem_addr = (stall == 1) ? shadow_reg[2:33] : {16'b0, imm_addr_id};
    assign dmem_data_out = (stall == 1) ? shadow_reg[34:97] : RF_rd_do_0_mux;


    // ID/EX_MEM stage register
    reg [0:154] ID_EXM_reg;

    always @(posedge clk)
    begin
        if(reset)
            ID_EXM_reg <= 0;
        else
            if(stall) ID_EXM_reg <= ID_EXM_reg;
            else
            begin
                ID_EXM_reg[0:63] <= RF_rd_do_0_mux;
                ID_EXM_reg[64:127] <= RF_rd_do_1_mux;
                ID_EXM_reg[128] <= intent_to_stall_id;
                ID_EXM_reg[129:133] <= rD_id;
                ID_EXM_reg[134:136] <= ppp_id;
                ID_EXM_reg[137:138] <= ww_id;
                ID_EXM_reg[139:144] <= func_code_id;
                ID_EXM_reg[145:146] <= imm_addr_id[14:15];
                ID_EXM_reg[147:151] <= {dmem_En_id, dmem_WrEn_id, nic_En_id, nic_WrEn_id, RF_WrEn_id};
                ID_EXM_reg[152] <= intent_to_alu_stall5_id;
                ID_EXM_reg[153] <= intent_to_alu_stall4_id;
                ID_EXM_reg[154] <= intent_to_alu_stall3_id;
            end
    end

//-----------------------------------------------------------------------------------------------------------------------
// EX_MEM stage:
    
    wire dmem_En_exm, dmem_WrEn_exm, nic_En_exm, nic_WrEn_exm;
    wire intent_to_stall_exm, intent_to_alu_stall5_exm, intent_to_alu_stall4_exm, intent_to_alu_stall3_exm;
    wire [0:63] RF_rd_do_0_exm, RF_rd_do_1_exm; // two ALU data input
    wire [0:5] func_code_exm;
    wire [0:1] ww_exm;
    wire [0:1] nic_addr; // address for nic

    assign intent_to_stall_exm = ID_EXM_reg[128];
    assign rD_exm = ID_EXM_reg[129:133];
    assign ppp_exm = ID_EXM_reg[134:136];
    assign ww_exm = ID_EXM_reg[137:138];
    assign func_code_exm = ID_EXM_reg[139:144];
    assign nic_addr = ID_EXM_reg[145:146]; // address of NIC
    assign nic_data_out = ID_EXM_reg[0:63]; // data input of NIC
    assign {dmem_En_exm, dmem_WrEn_exm, nic_En_exm, nic_WrEn_exm, RF_WrEn_exm} = ID_EXM_reg[147:151];
    assign intent_to_alu_stall5_exm = ID_EXM_reg[152];
    assign intent_to_alu_stall4_exm = ID_EXM_reg[153];
    assign intent_to_alu_stall3_exm = ID_EXM_reg[154];

    // ouput nic control signals
    assign nic_En = nic_En_exm;
    assign nic_WrEn = nic_WrEn_exm;
    

    // Instantiation of ALU
    wire [0:63] ALU_di_A, ALU_di_B, ALU_res_exm; // ALU inputs and results
    assign {ALU_di_A, ALU_di_B} = ID_EXM_reg[0:127];
    alu alu_exm
    (
        .di_A(ALU_di_A),
        .di_B(ALU_di_B),
        .func_code(func_code_exm),
        .subfield_sel(ww_exm),
        .do(ALU_res_exm)
    );


    // Generates stall_for_mem signal
    // If there is a LD or SD in EX_MEM stage, we should stall the whole pipeline
    // we use a flag to achieve 1 clocks stalling
    reg stall_reg_for_mem;
    reg stall_for_mem; // stall signal for memory access
    always @(posedge clk)
    begin
        if(reset) stall_reg_for_mem <= 0;
        else
            // if there is a LD, and the rD is $0, we don't need to stall
            if(intent_to_stall_exm == 1) 
                stall_reg_for_mem <= ~ stall_reg_for_mem;
    end
    
    // if we find a LD(rD is not $0) or a SD, and if flag is 0, we need enble stall signal
    always @(*)
    begin
        stall_for_mem = 0;
        if((intent_to_stall_exm == 1) && (stall_reg_for_mem == 0))
            stall_for_mem = 1;
    end

    // Generates 5-clock stall_for_alu signal
    // For complex ALU operation, using 5-clock stalling like DIV and SQRT
    reg [0:2] stall5_reg_for_alu;
    reg stall5_for_alu;
    // 5-stage counter: 0 -> 1 -> 2 -> 3 -> 4 -> 0 ..
    always @(posedge clk)
    begin   
        if(reset) stall5_reg_for_alu <= 0;
        else
        begin
            if(intent_to_alu_stall5_exm == 1) 
            begin
                if(stall5_reg_for_alu == 4) stall5_reg_for_alu <= 0;
                else stall5_reg_for_alu <= stall5_reg_for_alu + 1;
            end
        end
    end
    always @(*)
    begin
        stall5_for_alu = 0;
        if( (intent_to_alu_stall5_exm == 1) && 
            ( (stall5_reg_for_alu == 0) || (stall5_reg_for_alu == 1) || (stall5_reg_for_alu == 2) || (stall5_reg_for_alu == 3)))
            stall5_for_alu = 1;
    end


    // Generates 4-clock stall_for_alu signal
    // For complex ALU operation, using 4-clock stalling, like MULT, MOD, SQ
    reg [0:1] stall4_reg_for_alu;
    reg stall4_for_alu;
    // 4-stage counter: 0 -> 1 -> 2 -> 3 -> 0 ..
    always @(posedge clk)
    begin   
        if(reset) stall4_reg_for_alu <= 0;
        else
            if(intent_to_alu_stall4_exm == 1) stall4_reg_for_alu <= stall4_reg_for_alu + 1;
    end
    always @(*)
    begin
        stall4_for_alu = 0;
        if( (intent_to_alu_stall4_exm == 1) && 
            ( (stall4_reg_for_alu == 0) || (stall4_reg_for_alu == 1) || (stall4_reg_for_alu == 2) ) )
            stall4_for_alu = 1;
    end


    // Generates 3-clock stall_for_alu signal
    // For complex ALU operation, using 3-clock stalling, like ADD, SUB, SLL, SRL, SRA
    reg [0:1] stall3_reg_for_alu;
    reg stall3_for_alu;
    // 3-stage counter: 0 -> 1 -> 2 -> 0 ..
    always @(posedge clk)
    begin   
        if(reset) stall3_reg_for_alu <= 0;
        else
        begin
            if(intent_to_alu_stall3_exm == 1) 
            begin
                if(stall3_reg_for_alu == 2) stall3_reg_for_alu <= 0;
                else stall3_reg_for_alu <= stall3_reg_for_alu + 1;
            end
        end
    end
    always @(*)
    begin
        stall3_for_alu = 0;
        if( (intent_to_alu_stall3_exm == 1) && 
            ( (stall3_reg_for_alu == 0) || (stall3_reg_for_alu == 1) ))
            stall3_for_alu = 1;
    end


    // Generates stall signal
    assign stall = (stall5_for_alu || stall4_for_alu || stall3_for_alu || stall_for_mem) ? 1'b1 : 1'b0;


    // Register File write data MUX
    // write data may from ALU results. NIC and Data Memory
    always @(*)
    begin
        RF_wr_di_exm = ALU_res_exm; // default value
        if(dmem_En_exm == 1) RF_wr_di_exm = dmem_data_in[0:63];
        else 
            if(nic_En_exm == 1) RF_wr_di_exm = nic_data_in[0:63];
    end


    // EX_MEM/WB stage register
    reg [0:72] EXM_WB_stage;
    always @(posedge clk)
    begin
        if(reset)
            EXM_WB_stage <= 0;
        else 
        if(stall) 
            EXM_WB_stage[64] <= 0; // if stall, insert bubble into next stage
        else
        begin
            EXM_WB_stage[0:63] <= RF_wr_di_exm[0:63];
            EXM_WB_stage[64] <= RF_WrEn_exm;
            EXM_WB_stage[65:67] <= ppp_exm;
            EXM_WB_stage[68:72] <= rD_exm;
        end
    end

//-----------------------------------------------------------------------------------------------------------------------
// WB stage:

    assign RF_WrEn_wb = EXM_WB_stage[64];
    assign RF_wr_addr_wb = EXM_WB_stage[68:72];
    assign ppp_wb = EXM_WB_stage[65:67];
    assign RF_wr_di_wb = EXM_WB_stage[0:63];

//-----------------------------------------------------------------------------------------------------------------------
 endmodule
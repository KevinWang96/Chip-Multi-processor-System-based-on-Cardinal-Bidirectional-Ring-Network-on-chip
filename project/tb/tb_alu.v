`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW01_addsub.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW02_mult.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_div.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_sqrt.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_shifter.v"
`timescale 1ns/1ps
`define DATA_WIDTH 64
`define FUNC_CODE_WIDTH 6
`define SEL_WIDTH 2
/*
 * @Author: Yihao Wang
 * @Date: 2020-03-20 21:53:37
 * @LastEditTime: 2020-03-24 16:00:58
 * @LastEditors: Please set LastEditors
 * @Description: Testbench for ALU
 * @FilePath: /EE577b_final_project/project_p2/tb/tb_alu.v
 */
 module tb_alu;
    reg [0:`DATA_WIDTH - 1] di_A, di_B;
    reg [0:`FUNC_CODE_WIDTH - 1] func_code;
    reg [0:`SEL_WIDTH - 1] subfield_sel;
    wire [0:`DATA_WIDTH - 1] do;

    // Definition of function code
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

    // Participation field select mode
    localparam  b_mode = 2'b00, // byte mode
                h_mode = 2'b01, // half word mode
                w_mode = 2'b10, // word mode
                d_mode = 2'b11; // double word mode

    // Instantiation of DUT:
    alu alu_dut
    (
        .di_A(di_A),
        .di_B(di_B),
        .func_code(func_code),
        .subfield_sel(subfield_sel),
        .do(do)
    );

    integer out_file;
    initial 
    begin
        out_file = $fopen("alu.res", "w");
//-----------------------------------------------------------------------------------------------------------------------
// ADD:
        #10
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'b1;
        func_code = VADD;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "ADD: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do);

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'b1;
        func_code = VADD;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "ADD: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do);     

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'b1;
        func_code = VADD;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "ADD: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do);

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'b1;
        func_code = VADD;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "ADD: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do); 

//-----------------------------------------------------------------------------------------------------------------------
// SUB:
        di_A = 64'h0;
        di_B = 64'b1;
        func_code = VSUB;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "SUB: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do);

        di_A = 64'h0;
        di_B = 64'b1;
        func_code = VSUB;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "SUB: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do);     

        di_A = 64'h0;
        di_B = 64'b1;
        func_code = VSUB;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "SUB: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do);

        di_A = 64'h0;
        di_B = 64'b1;
        func_code = VSUB;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "SUB: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do); 

//-----------------------------------------------------------------------------------------------------------------------
// AND:
        di_A = 64'hf0_f0_f0_f0_f0_f0_f0_f0;
        di_B = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VAND;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "AND: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do);
//-----------------------------------------------------------------------------------------------------------------------
// OR:
        di_A = 64'hf0_f0_f0_f0_f0_f0_f0_f0;
        di_B = 64'b0;
        func_code = VOR;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "OR: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do);     
//-----------------------------------------------------------------------------------------------------------------------
// XOR:        
        di_A = 64'h0;
        di_B = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VXOR;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "XOR: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do);
//-----------------------------------------------------------------------------------------------------------------------
// NOT:
        di_A = 64'h0;
        di_B = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VNOT;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "NOT: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 
//-----------------------------------------------------------------------------------------------------------------------
// MOV:
        di_A = 64'h12_34_56_78_9a_bc_de_f0;
        di_B = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VMOV;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "MOV: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do); 

//-----------------------------------------------------------------------------------------------------------------------
// MULEU:
        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULEU;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "MULEU: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULEU;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "MULEU: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULEU;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "MULEU: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do); 

//-----------------------------------------------------------------------------------------------------------------------
// MULOU:
        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULOU;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "MULOU: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULOU;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "MULOU: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VMULOU;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "MULOU: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do);

//-----------------------------------------------------------------------------------------------------------------------
// SQEU:
        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQEU;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "SQEU: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQEU;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "SQEU: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQEU;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "SQEU: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do);

//-----------------------------------------------------------------------------------------------------------------------
// SQOU:
        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQOU;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "SQOU: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQOU;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "SQOU: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h01_02_03_04_05_06_07_08;
        di_B = 64'h01_02_03_04_05_06_07_08;
        func_code = VSQOU;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "SQOU: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do);

//-----------------------------------------------------------------------------------------------------------------------
// DIV:
        di_A = 64'ha5_a5_a5_a5_a5_a5_a5_a5;
        di_B = 64'h99_99_99_99_99_99_99_99;
        func_code = VDIV;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "DIV: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VDIV;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "DIV: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VDIV;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "DIV: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VDIV;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "DIV: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do); 

//-----------------------------------------------------------------------------------------------------------------------
// MOD:
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "MOD: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "MOD: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "MOD: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "MOD: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do); 

//-----------------------------------------------------------------------------------------------------------------------
// SQRT:
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'hx;
        func_code = VSQRT;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "SQRT: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'hx;
        func_code = VSQRT;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "SQRT: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do);  

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'hx;
        func_code = VSQRT;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "SQRT: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'hx;
        func_code = VSQRT;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "SQRT: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do); 

//-----------------------------------------------------------------------------------------------------------------------
// MOD:
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "MOD: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "MOD: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "MOD: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        di_B = 64'h02_02_02_02_02_02_02_02;
        func_code = VMOD;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "MOD: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do); 

//-----------------------------------------------------------------------------------------------------------------------
// SLL:
        di_B = 64'hf4_f4_f4_f4_f4_f4_f4_f4; // shift 4 bits
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSLL;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "SLL: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b", di_A, di_B, subfield_sel, do, alu_dut.shift_value_b_0); 

        di_B = 64'hf8_f8_f8_f8_f8_f8_f8_f8; // shift 8 bits
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSLL;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "SLL: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b", di_A, di_B, subfield_sel, do, alu_dut.shift_value_h_0);   

        di_B = 64'hf0_f0_f0_f0_f0_f0_f0_f0; // shift 16 bits
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSLL;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "SLL: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b", di_A, di_B, subfield_sel, do, alu_dut.shift_value_w_0); 

        di_B = 64'he0_e0_e0_e0_e0_e0_e0_e0; // shift 32 bits
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSLL;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "SLL: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b\n", di_A, di_B, subfield_sel, do, alu_dut.shift_value_d_0);  

//-----------------------------------------------------------------------------------------------------------------------
// SRL:
        di_B = 64'hf4_f4_f4_f4_f4_f4_f4_f4; // shift 4 bits
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSRL;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "SRL: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b", di_A, di_B, subfield_sel, do, alu_dut.shift_value_b_0); 

        di_B = 64'hf8_f8_f8_f8_f8_f8_f8_f8; // shift 8 bits
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSRL;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "SRL: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b", di_A, di_B, subfield_sel, do, alu_dut.shift_value_h_0); 

        di_B = 64'hf0_f0_f0_f0_f0_f0_f0_f0; // shift 16 bits
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSRL;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "SRL: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b", di_A, di_B, subfield_sel, do, alu_dut.shift_value_w_0); 

        di_B = 64'he0_e0_e0_e0_e0_e0_e0_e0; // shift 32 bits
        di_A = 64'hff_ff_ff_ff_ff_ff_ff_ff;
        func_code = VSRL;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "SRL: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b\n", di_A, di_B, subfield_sel, do, alu_dut.shift_value_d_0); 

//-----------------------------------------------------------------------------------------------------------------------
// SRA:
        di_B = 64'hf4_f4_f4_f4_f4_f4_f4_f4; // shift 4 bits
        di_A = 64'h80_80_80_80_80_80_80_80;
        func_code = VSRA;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "SRA: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b", di_A, di_B, subfield_sel, do, alu_dut.shift_value_b_0); 

        di_B = 64'hf8_f8_f8_f8_f8_f8_f8_f8; // shift 8 bits
        di_A = 64'h80_80_80_80_80_80_80_80;
        func_code = VSRA;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "SRA: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b", di_A, di_B, subfield_sel, do, alu_dut.shift_value_h_0); 

        di_B = 64'hf0_f0_f0_f0_f0_f0_f0_f0; // shift 16 bits
        di_A = 64'h80_80_80_80_80_80_80_80;
        func_code = VSRA;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "SRA: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b", di_A, di_B, subfield_sel, do, alu_dut.shift_value_w_0); 

        di_B = 64'he0_e0_e0_e0_e0_e0_e0_e0; // shift 32 bits
        di_A = 64'h80_80_80_80_80_80_80_80;
        func_code = VSRA;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "SRA: di_A = %h, di_B = %h, ww = %b, do = %h, sh = %b\n", di_A, di_B, subfield_sel, do, alu_dut.shift_value_d_0);  

//-----------------------------------------------------------------------------------------------------------------------
// RTTH:
        di_A = 64'h00_01_02_03_04_05_06_07;
        di_B = 64'bx;
        func_code = VRTTH;
        subfield_sel = b_mode;
        #1 
        $fdisplay(out_file, "RTTH: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h00_01_02_03_04_05_06_07;
        di_B = 64'bx;
        func_code = VRTTH;
        subfield_sel = h_mode;
        #1 
        $fdisplay(out_file, "RTTH: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h00_01_02_03_04_05_06_07;
        di_B = 64'bx;
        func_code = VRTTH;
        subfield_sel = w_mode;
        #1 
        $fdisplay(out_file, "RTTH: di_A = %h, di_B = %h, ww = %b, do = %h", di_A, di_B, subfield_sel, do); 

        di_A = 64'h00_01_02_03_04_05_06_07;
        di_B = 64'bx;
        func_code = VRTTH;
        subfield_sel = d_mode;
        #1 
        $fdisplay(out_file, "RTTH: di_A = %h, di_B = %h, ww = %b, do = %h\n", di_A, di_B, subfield_sel, do);
//-----------------------------------------------------------------------------------------------------------------------

        #10
        $fclose(out_file);
        $finish;

    end
 endmodule


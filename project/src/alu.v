// Includes simulation model of DesignWare. 
// If do synthesis, please comments all simulation model
// `include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW01_addsub.v"
// `include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW02_mult.v"
// `include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_div.v"
// `include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_sqrt.v"
// `include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_shifter.v"
`define DATA_WIDTH 64
/*
 * @Author: Yihao Wang, Aditya Pharande
 * @Date: 2020-03-11 20:02:17
 * @LastEditTime: 2020-04-26 01:13:05
 * @LastEditors: Please set LastEditors
 * @Description: 
        64-bit ALU supporting variable-width operations
        Using Synopsys DesignWare for implementation
        Supported operations:
            Binary operations;
            Shift operations;
            Arithmetic operations;
            Special operations (move, rotate)
 * @FilePath: /EE577b_final_project/project_p2/design/alu.v
 */
 module alu (do, di_A, di_B, func_code, subfield_sel);
    input [0:`DATA_WIDTH - 1] di_A, di_B; // Data input A and data input B
    input [0:5] func_code; // 6-bit function code used to control the function of ALU
    input [0:1] subfield_sel; // 2-bit subfield select signal
    output reg [0:`DATA_WIDTH - 1] do; // data output

    localparam TC = 1'b0; // 0: means operands are unsigned number, 1: signed number operands

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


//-----------------------------------------------------------------------------------------------------------------------
// Adders array supporting 64-bit VADD, VSUB
// also supporting selective execution based on subfield_sel 
// Design Ware used: eight 8-bit DW01_addsub
    wire [0:7] ci, co;
    wire add_sub; // 1 means subtraction, 0 means addition
    wire [0:63] sum_diff;

    assign add_sub = (func_code == VADD) ? 1'b0 : 1'b1;

    DW01_addsub #(
        .width(8)
    )
    addsub_0
    (
        .A(di_A[0:7]),
        .B(di_B[0:7]),
        .CI(ci[0]),
        .CO(co[0]),
        .ADD_SUB(add_sub),
        .SUM(sum_diff[0:7])
    );

    DW01_addsub #(
        .width(8)
    )
    addsub_1
    (
        .A(di_A[8:15]),
        .B(di_B[8:15]),
        .CI(ci[1]),
        .CO(co[1]),
        .ADD_SUB(add_sub),
        .SUM(sum_diff[8:15])
    );

    DW01_addsub #(
        .width(8)
    )
    addsub_2
    (
        .A(di_A[16:23]),
        .B(di_B[16:23]),
        .CI(ci[2]),
        .CO(co[2]),
        .ADD_SUB(add_sub),
        .SUM(sum_diff[16:23])
    );

    DW01_addsub #(
        .width(8)
    )
    addsub_3
    (
        .A(di_A[24:31]),
        .B(di_B[24:31]),
        .CI(ci[3]),
        .CO(co[3]),
        .ADD_SUB(add_sub),
        .SUM(sum_diff[24:31])
    );

    DW01_addsub #(
        .width(8)
    )
    addsub_4
    (
        .A(di_A[32:39]),
        .B(di_B[32:39]),
        .CI(ci[4]),
        .CO(co[4]),
        .ADD_SUB(add_sub),
        .SUM(sum_diff[32:39])
    );

    DW01_addsub #(
        .width(8)
    )
    addsub_5
    (
        .A(di_A[40:47]),
        .B(di_B[40:47]),
        .CI(ci[5]),
        .CO(co[5]),
        .ADD_SUB(add_sub),
        .SUM(sum_diff[40:47])
    );

    DW01_addsub #(
        .width(8)
    )
    addsub_6
    (
        .A(di_A[48:55]),
        .B(di_B[48:55]),
        .CI(ci[6]),
        .CO(co[6]),
        .ADD_SUB(add_sub),
        .SUM(sum_diff[48:55])
    );

    DW01_addsub #(
        .width(8)
    )
    addsub_7
    (
        .A(di_A[56:63]),
        .B(di_B[56:63]),
        .CI(ci[7]),
        .CO(co[7]),
        .ADD_SUB(add_sub),
        .SUM(sum_diff[56:63])
    );
    
    // Conditionaly connecting each 8-bit adder/subtractor
    assign ci[0] = (subfield_sel == b_mode) ? 1'b0 : co[1];
    assign ci[1] = ((subfield_sel == b_mode) || (subfield_sel == h_mode)) ? 1'b0 : co[2];
    assign ci[2] = (subfield_sel == b_mode) ? 1'b0 : co[3];
    assign ci[3] = ((subfield_sel == b_mode) || (subfield_sel == h_mode) || (subfield_sel == w_mode)) ? 1'b0 : co[4];
    assign ci[4] = (subfield_sel == b_mode) ? 1'b0 : co[5];
    assign ci[5] = ((subfield_sel == b_mode) || (subfield_sel == h_mode)) ? 1'b0 : co[6];
    assign ci[6] = (subfield_sel == b_mode) ? 1'b0 : co[7];
    assign ci[7] = 1'b0;


//-----------------------------------------------------------------------------------------------------------------------
// Multiplier Array supporting VMULEU, VMULOU, VSQEU, VSQOU 
// Design Ware used:    four 8-bit DW02_mult
//                      two 16-bit DW02_mult
//                      one 32-bit DW02_mult

    reg [0:31] mult_di_A, mult_di_B;
    wire [0:64] product_b, product_h, product_w; // product of byte mode, half byte mode and word mode

    // Assign different parts to multiplier input
    // For example:
    //     If there is byte mode VMULEU, we assign even bytes to multiplier input
    //     If there is byte mode VMULOU, we assign odd bytes to multiplier input  
    always @(*)
    begin
        mult_di_A = 32'bx;
        mult_di_B = 32'bx;
        
        case(func_code)
            VMULEU :
                case(subfield_sel) 
                    b_mode : 
                    begin
                        mult_di_A = {di_A[0:7], di_A[16:23], di_A[32:39], di_A[48:55]};
                        mult_di_B = {di_B[0:7], di_B[16:23], di_B[32:39], di_B[48:55]};
                    end
                    h_mode :
                    begin
                        mult_di_A = {di_A[0:15], di_A[32:47]};
                        mult_di_B = {di_B[0:15], di_B[32:47]};
                    end
                    w_mode :
                    begin
                        mult_di_A = di_A[0:31];
                        mult_di_B = di_B[0:31];
                    end
                endcase

            VMULOU :
                case(subfield_sel) 
                    b_mode : 
                    begin
                        mult_di_A = {di_A[8:15], di_A[24:31], di_A[40:47], di_A[56:63]};
                        mult_di_B = {di_B[8:15], di_B[24:31], di_B[40:47], di_B[56:63]};
                    end
                    h_mode :
                    begin
                        mult_di_A = {di_A[16:31], di_A[48:63]};
                        mult_di_B = {di_B[16:31], di_B[48:63]};
                    end
                    w_mode :
                    begin
                        mult_di_A = di_A[32:63];
                        mult_di_B = di_B[32:63];
                    end
                endcase

            VSQEU :
                case(subfield_sel) 
                    b_mode : 
                    begin
                        mult_di_A = {di_A[0:7], di_A[16:23], di_A[32:39], di_A[48:55]};
                        mult_di_B = {di_A[0:7], di_A[16:23], di_A[32:39], di_A[48:55]};
                    end
                    h_mode : 
                    begin
                        mult_di_A = {di_A[0:15], di_A[32:47]};
                        mult_di_B = {di_A[0:15], di_A[32:47]};
                    end
                    w_mode : 
                    begin
                        mult_di_A = di_A[0:31];
                        mult_di_B = di_A[0:31];
                    end
                endcase

            VSQOU :
                case(subfield_sel) 
                    b_mode : 
                    begin
                        mult_di_A = {di_A[8:15], di_A[24:31], di_A[40:47], di_A[56:63]};
                        mult_di_B = {di_A[8:15], di_A[24:31], di_A[40:47], di_A[56:63]};
                    end
                    h_mode : 
                    begin
                        mult_di_A = {di_A[16:31], di_A[48:63]};
                        mult_di_B = {di_A[16:31], di_A[48:63]};
                    end
                    w_mode : 
                    begin
                        mult_di_A = di_A[32:63];
                        mult_di_B = di_A[32:63];
                    end
                endcase
        endcase
    end

    // Instantiation of Multiplier array:
    //     For byte mode:
    DW02_mult #(
        .A_width(8),
        .B_width(8)
    )
    mult_b_0
    (
        .A(mult_di_A[0:7]),
        .B(mult_di_B[0:7]),
        .TC(TC),
        .PRODUCT(product_b[0:15])
    );

    DW02_mult #(
        .A_width(8),
        .B_width(8)
    )
    mult_b_1
    (
        .A(mult_di_A[8:15]),
        .B(mult_di_B[8:15]),
        .TC(TC),
        .PRODUCT(product_b[16:31])
    );

    DW02_mult #(
        .A_width(8),
        .B_width(8)
    )
    mult_b_2
    (
        .A(mult_di_A[16:23]),
        .B(mult_di_B[16:23]),
        .TC(TC),
        .PRODUCT(product_b[32:47])
    );

    DW02_mult #(
        .A_width(8),
        .B_width(8)
    )
    mult_b_3
    (
        .A(mult_di_A[24:31]),
        .B(mult_di_B[24:31]),
        .TC(TC),
        .PRODUCT(product_b[48:63])
    );

    //     For half byte mode:
    DW02_mult #(
        .A_width(16),
        .B_width(16)
    )
    mult_h_0
    (
        .A(mult_di_A[0:15]),
        .B(mult_di_B[0:15]),
        .TC(TC),
        .PRODUCT(product_h[0:31])
    );

    DW02_mult #(
        .A_width(16),
        .B_width(16)
    )
    mult_h_1
    (
        .A(mult_di_A[16:31]),
        .B(mult_di_B[16:31]),
        .TC(TC),
        .PRODUCT(product_h[32:63])
    );

    //     For word mode:
    DW02_mult #(
        .A_width(32),
        .B_width(32)
    )
    mult_w_0
    (
        .A(mult_di_A[0:31]),
        .B(mult_di_B[0:31]),
        .TC(TC),
        .PRODUCT(product_w[0:63])
    );

//-----------------------------------------------------------------------------------------------------------------------
// Divider Array supporting VDIV, VMOD
// Design Ware used:    eight 8-bit DW_div
//                      four 16-bit DW_div
//                      two 32-bit DW_div
//                      one 64-bit DW_div

    wire [0:63] divisor, dividend;
    wire [0:63] quotient_b, quotient_h, quotient_w, quotient_d, 
                remainder_b, remainder_h, remainder_w, remainder_d; // quotient_b means quotient for byte mode

    // Assign different parts to divider input
    assign dividend[0:63] = di_A[0:63]; 
    // in order not to generate simulation errors when divisor is 0 
    // if don't use divider, drive all divisor bits to 1
    assign divisor[0:63] = ((func_code == VDIV) || (func_code == VMOD)) ? di_B[0:63] : {64{1'b1}}; 

    // Intantiation of divider array
    //    For byte mode:
    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b_0
    (
        .a(dividend[0:7]),
        .b(divisor[0:7]),
        .quotient(quotient_b[0:7]),
        .remainder(remainder_b[0:7]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b_1
    (
        .a(dividend[8:15]),
        .b(divisor[8:15]),
        .quotient(quotient_b[8:15]),
        .remainder(remainder_b[8:15]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b_2
    (
        .a(dividend[16:23]),
        .b(divisor[16:23]),
        .quotient(quotient_b[16:23]),
        .remainder(remainder_b[16:23]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b_3
    (
        .a(dividend[24:31]),
        .b(divisor[24:31]),
        .quotient(quotient_b[24:31]),
        .remainder(remainder_b[24:31]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b_4
    (
        .a(dividend[32:39]),
        .b(divisor[32:39]),
        .quotient(quotient_b[32:39]),
        .remainder(remainder_b[32:39]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b_5
    (
        .a(dividend[40:47]),
        .b(divisor[40:47]),
        .quotient(quotient_b[40:47]),
        .remainder(remainder_b[40:47]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b_6
    (
        .a(dividend[48:55]),
        .b(divisor[48:55]),
        .quotient(quotient_b[48:55]),
        .remainder(remainder_b[48:55]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b_7
    (
        .a(dividend[56:63]),
        .b(divisor[56:63]),
        .quotient(quotient_b[56:63]),
        .remainder(remainder_b[56:63]),
        .divide_by_0()
    );

    //    For half word mode:
    DW_div #(
        .a_width(16),
        .b_width(16),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_h_0
    (
        .a(dividend[0:15]),
        .b(divisor[0:15]),
        .quotient(quotient_h[0:15]),
        .remainder(remainder_h[0:15]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(16),
        .b_width(16),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_h_1
    (
        .a(dividend[16:31]),
        .b(divisor[16:31]),
        .quotient(quotient_h[16:31]),
        .remainder(remainder_h[16:31]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(16),
        .b_width(16),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_h_2
    (
        .a(dividend[32:47]),
        .b(divisor[32:47]),
        .quotient(quotient_h[32:47]),
        .remainder(remainder_h[32:47]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(16),
        .b_width(16),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_h_3
    (
        .a(dividend[48:63]),
        .b(divisor[48:63]),
        .quotient(quotient_h[48:63]),
        .remainder(remainder_h[48:63]),
        .divide_by_0()
    );

    //    For word mode:
    DW_div #(
        .a_width(32),
        .b_width(32),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_w_0
    (
        .a(dividend[0:31]),
        .b(divisor[0:31]),
        .quotient(quotient_w[0:31]),
        .remainder(remainder_w[0:31]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(32),
        .b_width(32),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_w_1
    (
        .a(dividend[32:63]),
        .b(divisor[32:63]),
        .quotient(quotient_w[32:63]),
        .remainder(remainder_w[32:63]),
        .divide_by_0()
    );

    //    For double word mode:
    DW_div #(
        .a_width(64),
        .b_width(64),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_d_0
    (
        .a(dividend[0:63]),
        .b(divisor[0:63]),
        .quotient(quotient_d[0:63]),
        .remainder(remainder_d[0:63]),
        .divide_by_0()
    );

//-----------------------------------------------------------------------------------------------------------------------
// Sqrt Array supporting VSQRT
// Design Ware used:    eight 8-bit DW_sqrt
//                      four 16-bit DW_sqrt
//                      two 32-bit DW_sqrt
//                      one 64-bit DW_sqrt

    wire [0:63] root_b, root_h, root_w, root_d; // root_b means square root for byte mode

    // Instantiation of square root array
    //    For byte mode:
    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b_0
    (
        .a(di_A[0:7]),
        .root(root_b[4:7])
    );
    assign root_b[0:3] = 0;

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b_1
    (
        .a(di_A[8:15]),
        .root(root_b[12:15])
    );
    assign root_b[8:11] = 0;  

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b_2
    (
        .a(di_A[16:23]),
        .root(root_b[20:23])
    );
    assign root_b[16:19] = 0; 

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b_3
    (
        .a(di_A[24:31]),
        .root(root_b[28:31])
    );
    assign root_b[24:27] = 0; 

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b_4
    (
        .a(di_A[32:39]),
        .root(root_b[36:39])
    );
    assign root_b[32:35] = 0; 

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b_5
    (
        .a(di_A[40:47]),
        .root(root_b[44:47])
    );
    assign root_b[40:43] = 0; 

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b_6
    (
        .a(di_A[48:55]),
        .root(root_b[52:55])
    );
    assign root_b[48:51] = 0; 

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b_7
    (
        .a(di_A[56:63]),
        .root(root_b[60:63])
    );
    assign root_b[56:59] = 0; 

    //    For half word mode:
    DW_sqrt #(
        .width(16),
        .tc_mode(TC)
    )
    DW_sqrt_h_0
    (
        .a(di_A[0:15]),
        .root(root_h[8:15])
    );
    assign root_h[0:7] = 0; 

    DW_sqrt #(
        .width(16),
        .tc_mode(TC)
    )
    DW_sqrt_h_1
    (
        .a(di_A[16:31]),
        .root(root_h[24:31])
    );
    assign root_h[16:23] = 0; 

    DW_sqrt #(
        .width(16),
        .tc_mode(TC)
    )
    DW_sqrt_h_2
    (
        .a(di_A[32:47]),
        .root(root_h[40:47])
    );
    assign root_h[32:39] = 0; 

    DW_sqrt #(
        .width(16),
        .tc_mode(TC)
    )
    DW_sqrt_h_3
    (
        .a(di_A[48:63]),
        .root(root_h[56:63])
    );
    assign root_h[48:55] = 0; 

    //    For word mode:
    DW_sqrt #(
        .width(32),
        .tc_mode(TC)
    )
    DW_sqrt_w_0
    (
        .a(di_A[0:31]),
        .root(root_w[16:31])
    );
    assign root_w[0:15] = 0; 

    DW_sqrt #(
        .width(32),
        .tc_mode(TC)
    )
    DW_sqrt_w_1
    (
        .a(di_A[32:63]),
        .root(root_w[48:63])
    );
    assign root_w[32:47] = 0; 

    //    For double word mode:
    DW_sqrt #(
        .width(64),
        .tc_mode(TC)
    )
    DW_sqrt_d_0
    (
        .a(di_A[0:63]),
        .root(root_d[32:63])
    );
    assign root_d[0:31] = 0; 

//-----------------------------------------------------------------------------------------------------------------------
// Shifter Array supporting VSLL, VSRL, VSRA
// Design Ware used:    eight 8-bit DW_shifter
//                      four 16-bit DW_shifter
//                      two 32-bit DW_shifter
//                      one 64-bit DW_shifter

    // We represent shift value using signed number to achieve left and right shift
    // The length of shift_value should be Log2(data_width) + 1;(inlude sign bit)
    reg [0:3]   shift_value_b_0, shift_value_b_1, shift_value_b_2, shift_value_b_3,
                shift_value_b_4, shift_value_b_5, shift_value_b_6, shift_value_b_7; // shift value for byte mode
    reg [0:4]   shift_value_h_0, shift_value_h_1, shift_value_h_2, shift_value_h_3; // shift value for half word mode
    reg [0:5]   shift_value_w_0, shift_value_w_1; // shift value for word mode
    reg [0:6]   shift_value_d_0; // shift value for double word mode

    // Generates shift value
    always @(*)
    begin
        shift_value_b_0 = 4'bx;
        shift_value_b_1 = 4'bx;
        shift_value_b_2 = 4'bx;
        shift_value_b_3 = 4'bx;
        shift_value_b_4 = 4'bx;
        shift_value_b_5 = 4'bx;
        shift_value_b_6 = 4'bx;
        shift_value_b_7 = 4'bx;

        shift_value_h_0 = 5'bx;
        shift_value_h_1 = 5'bx;
        shift_value_h_2 = 5'bx;
        shift_value_h_3 = 5'bx;

        shift_value_w_0 = 6'bx;
        shift_value_w_1 = 6'bx;

        shift_value_d_0 = 7'bx;

        case(subfield_sel)
            b_mode :
                if(func_code == VSLL)
                begin
                    shift_value_b_0 = {1'b0, di_B[5:7]};
                    shift_value_b_1 = {1'b0, di_B[13:15]};
                    shift_value_b_2 = {1'b0, di_B[21:23]};
                    shift_value_b_3 = {1'b0, di_B[29:31]};
                    shift_value_b_4 = {1'b0, di_B[37:39]};
                    shift_value_b_5 = {1'b0, di_B[45:47]};
                    shift_value_b_6 = {1'b0, di_B[53:55]};
                    shift_value_b_7 = {1'b0, di_B[61:63]};
                end
                else // because right shift, we need to generate 2's complement of shift value
                begin
                    shift_value_b_0 = ({1'b0, di_B[5:7]} ^ 4'b1111) + 1;
                    shift_value_b_1 = ({1'b0, di_B[13:15]} ^ 4'b1111) + 1;
                    shift_value_b_2 = ({1'b0, di_B[21:23]} ^ 4'b1111) + 1;
                    shift_value_b_3 = ({1'b0, di_B[29:31]} ^ 4'b1111) + 1;
                    shift_value_b_4 = ({1'b0, di_B[37:39]} ^ 4'b1111) + 1;
                    shift_value_b_5 = ({1'b0, di_B[45:47]} ^ 4'b1111) + 1;
                    shift_value_b_6 = ({1'b0, di_B[53:55]} ^ 4'b1111) + 1;
                    shift_value_b_7 = ({1'b0, di_B[61:63]} ^ 4'b1111) + 1;
                end
            h_mode :
                if(func_code == VSLL)
                begin
                    shift_value_h_0 = {1'b0, di_B[12:15]};
                    shift_value_h_1 = {1'b0, di_B[28:31]};
                    shift_value_h_2 = {1'b0, di_B[44:47]};
                    shift_value_h_3 = {1'b0, di_B[60:63]};
                end
                else // because right shift, we need to generate 2's complement of shift value
                begin
                    shift_value_h_0 = ({1'b0, di_B[12:15]} ^ 5'b1_1111) + 1;
                    shift_value_h_1 = ({1'b0, di_B[28:31]} ^ 5'b1_1111) + 1;
                    shift_value_h_2 = ({1'b0, di_B[44:47]} ^ 5'b1_1111) + 1;
                    shift_value_h_3 = ({1'b0, di_B[60:63]} ^ 5'b1_1111) + 1;
                end
            w_mode :
                if(func_code == VSLL)
                begin
                    shift_value_w_0 = {1'b0, di_B[27:31]};
                    shift_value_w_1 = {1'b0, di_B[59:63]};
                end
                else // because right shift, we need to generate 2's complement of shift value
                begin
                    shift_value_w_0 = ({1'b0, di_B[27:31]} ^ 6'b11_1111) + 1;
                    shift_value_w_1 = ({1'b0, di_B[59:63]} ^ 6'b11_1111) + 1;
                end 
            d_mode :
                if(func_code == VSLL)
                    shift_value_d_0 = {1'b0, di_B[58:63]};
                else // because right shift, we need to generate 2's complement of shift value
                    shift_value_d_0 = ({1'b0, di_B[58:63]} ^ 7'b111_1111) + 1;
        endcase
    end

    // 1 means: treat data as signed number, 0 means treat data as unsigned number
    // if data is signed number and we want to right shift it, we should do sign extension
    wire data_tc; 
    assign data_tc = (func_code == VSRA) ? 1'b1 : 1'b0;

    // Instantiation of shifter array 
    wire [0:63] shifter_do_b, shifter_do_h, shifter_do_w, shifter_do_d; // outputs
    //    For byte mode:
    DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_b_0
    (
        .data_in(di_A[0:7]),
        .data_tc(data_tc),
        .sh(shift_value_b_0),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_b[0:7])
    );

    DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_b_1
    (
        .data_in(di_A[8:15]),
        .data_tc(data_tc),
        .sh(shift_value_b_1),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_b[8:15])
    );

    DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_b_2
    (
        .data_in(di_A[16:23]),
        .data_tc(data_tc),
        .sh(shift_value_b_2),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_b[16:23])
    );

    DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_b_3
    (
        .data_in(di_A[24:31]),
        .data_tc(data_tc),
        .sh(shift_value_b_3),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_b[24:31])
    );

    DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_b_4
    (
        .data_in(di_A[32:39]),
        .data_tc(data_tc),
        .sh(shift_value_b_4),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_b[32:39])
    );

    DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_b_5
    (
        .data_in(di_A[40:47]),
        .data_tc(data_tc),
        .sh(shift_value_b_5),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_b[40:47])
    );

    DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_b_6
    (
        .data_in(di_A[48:55]),
        .data_tc(data_tc),
        .sh(shift_value_b_6),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_b[48:55])
    );

    DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_b_7
    (
        .data_in(di_A[56:63]),
        .data_tc(data_tc),
        .sh(shift_value_b_7),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_b[56:63])
    );

    //    For half word mode:
    DW_shifter #(
        .data_width(16),
        .sh_width(5), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_h_0
    (
        .data_in(di_A[0:15]),
        .data_tc(data_tc),
        .sh(shift_value_h_0),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_h[0:15])
    );

    DW_shifter #(
        .data_width(16),
        .sh_width(5), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_h_1
    (
        .data_in(di_A[16:31]),
        .data_tc(data_tc),
        .sh(shift_value_h_1),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_h[16:31])
    );

    DW_shifter #(
        .data_width(16),
        .sh_width(5), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_h_2
    (
        .data_in(di_A[32:47]),
        .data_tc(data_tc),
        .sh(shift_value_h_2),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_h[32:47])
    );

    DW_shifter #(
        .data_width(16),
        .sh_width(5), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_h_3
    (
        .data_in(di_A[48:63]),
        .data_tc(data_tc),
        .sh(shift_value_h_3),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_h[48:63])
    );

    //    For word mode:
    DW_shifter #(
        .data_width(32),
        .sh_width(6), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_w_0
    (
        .data_in(di_A[0:31]),
        .data_tc(data_tc),
        .sh(shift_value_w_0),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_w[0:31])
    );

    DW_shifter #(
        .data_width(32),
        .sh_width(6), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_w_1
    (
        .data_in(di_A[32:63]),  
        .data_tc(data_tc),
        .sh(shift_value_w_1),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_w[32:63])
    );

    //    For double word mode:
    DW_shifter #(
        .data_width(64),
        .sh_width(7), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shifter_d_0
    (
        .data_in(di_A[0:63]),
        .data_tc(data_tc),
        .sh(shift_value_d_0),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shifter_do_d[0:63])
    );

//-----------------------------------------------------------------------------------------------------------------------

    // Combinational logic block
    // Output MUX
    always @(*)
    begin
        //initial value to avoid redundant logic
        do = {`DATA_WIDTH{1'bx}};
        
        case(func_code)

            //binary operations
            VAND : 
                do = di_A & di_B;
            VOR :
                do = di_A | di_B;
            VXOR :
                do = di_A ^ di_B;
            VNOT :
                do = ~ di_A;

            // move operation
            VMOV :
                do = di_A;
            
            // arithmetic operations:
            VADD : // add (using Design Ware)
                do[0:63] = sum_diff[0:63];

            VSUB : // subtraction (using Design Ware)
                do[0:63] = sum_diff[0:63];

            VMULEU : //multiplication of even unit
                case(subfield_sel)
                    b_mode : do[0:63] = product_b[0:63];
                    h_mode : do[0:63] = product_h[0:63];
                    w_mode : do[0:63] = product_w[0:63];
                endcase

            VMULOU : // multiplication of odd unit
                case(subfield_sel)
                    b_mode : do[0:63] = product_b[0:63];
                    h_mode : do[0:63] = product_h[0:63];
                    w_mode : do[0:63] = product_w[0:63];
                endcase

            VSQEU : // square operation of even unit
                case(subfield_sel)
                    b_mode : do[0:63] = product_b[0:63];
                    h_mode : do[0:63] = product_h[0:63];
                    w_mode : do[0:63] = product_w[0:63];
                endcase

            VSQOU : // square operation of odd unit
                case(subfield_sel)
                    b_mode : do[0:63] = product_b[0:63];
                    h_mode : do[0:63] = product_h[0:63];
                    w_mode : do[0:63] = product_w[0:63];
                endcase

            VDIV : // division
                case(subfield_sel)
                    b_mode : do[0:63] = quotient_b[0:63];
                    h_mode : do[0:63] = quotient_h[0:63];
                    w_mode : do[0:63] = quotient_w[0:63];
                    d_mode : do[0:63] = quotient_d[0:63];
                endcase

            VMOD : // modular operation
                case(subfield_sel)
                    b_mode : do[0:63] = remainder_b[0:63];
                    h_mode : do[0:63] = remainder_h[0:63];
                    w_mode : do[0:63] = remainder_w[0:63];
                    d_mode : do[0:63] = remainder_d[0:63];
                endcase

            VSQRT : // square root operation
                case(subfield_sel)
                    b_mode : do[0:63] = root_b[0:63];
                    h_mode : do[0:63] = root_h[0:63];
                    w_mode : do[0:63] = root_w[0:63];
                    d_mode : do[0:63] = root_d[0:63];
                endcase

            // shift operations:
            VSLL : // logical left shift
                case(subfield_sel)
                    b_mode : do[0:63] = shifter_do_b[0:63];
                    h_mode : do[0:63] = shifter_do_h[0:63];
                    w_mode : do[0:63] = shifter_do_w[0:63];
                    d_mode : do[0:63] = shifter_do_d[0:63];
                endcase

            VSRL : // logical right shift
                case(subfield_sel)
                    b_mode : do[0:63] = shifter_do_b[0:63];
                    h_mode : do[0:63] = shifter_do_h[0:63];
                    w_mode : do[0:63] = shifter_do_w[0:63];
                    d_mode : do[0:63] = shifter_do_d[0:63];
                endcase
            
            VSRA : // arithmetic right shift
                case(subfield_sel)
                    b_mode : do[0:63] = shifter_do_b[0:63];
                    h_mode : do[0:63] = shifter_do_h[0:63];
                    w_mode : do[0:63] = shifter_do_w[0:63];
                    d_mode : do[0:63] = shifter_do_d[0:63];
                endcase

            VRTTH : // rotate operation
                case(subfield_sel)
                    b_mode :
                    begin
                        do[0:7] = {di_A[4:7], di_A[0:3]};
                        do[8:15] = {di_A[12:15], di_A[8:11]};
                        do[16:23] = {di_A[20:23], di_A[16:19]};
                        do[24:31] = {di_A[28:31], di_A[24:27]};
                        do[32:39] = {di_A[36:39], di_A[32:35]};
                        do[40:47] = {di_A[44:47], di_A[40:43]};
                        do[48:55] = {di_A[52:55], di_A[48:51]};
                        do[56:63] = {di_A[60:63], di_A[56:59]};
                    end
                    h_mode :
                    begin
                        do[0:15] = {di_A[8:15], di_A[0:7]};
                        do[16:31] = {di_A[24:31], di_A[16:23]};
                        do[32:47] = {di_A[40:47], di_A[32:39]};
                        do[48:63] = {di_A[56:63], di_A[48:55]};
                    end
                    w_mode :
                    begin
                        do[0:31] = {di_A[16:31], di_A[0:15]};
                        do[32:63] = {di_A[48:63], di_A[32:47]};
                    end
                    d_mode :
                        do[0:63] = {di_A[32:63], di_A[0:31]};
                endcase
        endcase
    end
//-----------------------------------------------------------------------------------------------------------------------
 endmodule
`undef DATA_WIDTH
/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : K-2015.06-SP5-5
// Date      : Sun Apr  5 12:01:18 2020
/////////////////////////////////////////////////////////////


module PISO ( d, clk, reset, q );
  input [7:0] d;
  input clk, reset;
  output q;
  wire   N10, N11, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14,
         n15, n16, n17, n18, n19, n20, n21, n22;
  wire   [7:0] temp;

  DFFPOSX1 temp_reg_7_ ( .D(N10), .CLK(clk), .Q(temp[7]) );
  DFFPOSX1 temp_reg_6_ ( .D(n1), .CLK(clk), .Q(temp[6]) );
  DFFPOSX1 temp_reg_5_ ( .D(n2), .CLK(clk), .Q(temp[5]) );
  DFFPOSX1 temp_reg_4_ ( .D(n3), .CLK(clk), .Q(temp[4]) );
  DFFPOSX1 temp_reg_3_ ( .D(n4), .CLK(clk), .Q(temp[3]) );
  DFFPOSX1 temp_reg_2_ ( .D(n5), .CLK(clk), .Q(temp[2]) );
  DFFPOSX1 temp_reg_1_ ( .D(n6), .CLK(clk), .Q(temp[1]) );
  DFFPOSX1 temp_reg_0_ ( .D(n7), .CLK(clk), .Q(temp[0]) );
  DFFPOSX1 q_reg ( .D(N11), .CLK(clk), .Q(q) );
  AOI22X1 U13 ( .A(reset), .B(d[6]), .C(temp[7]), .D(n8), .Y(n9) );
  AOI22X1 U14 ( .A(d[5]), .B(reset), .C(temp[6]), .D(n8), .Y(n10) );
  AOI22X1 U15 ( .A(d[4]), .B(reset), .C(temp[5]), .D(n8), .Y(n11) );
  AOI22X1 U16 ( .A(d[3]), .B(reset), .C(temp[4]), .D(n8), .Y(n12) );
  AOI22X1 U17 ( .A(d[2]), .B(reset), .C(temp[3]), .D(n8), .Y(n13) );
  AOI22X1 U18 ( .A(d[1]), .B(reset), .C(temp[2]), .D(n8), .Y(n14) );
  AOI22X1 U19 ( .A(d[0]), .B(reset), .C(temp[1]), .D(n8), .Y(n15) );
  BUFX2 U20 ( .A(n15), .Y(n16) );
  BUFX2 U21 ( .A(n14), .Y(n17) );
  BUFX2 U22 ( .A(n13), .Y(n18) );
  BUFX2 U23 ( .A(n12), .Y(n19) );
  BUFX2 U24 ( .A(n11), .Y(n20) );
  BUFX2 U25 ( .A(n10), .Y(n21) );
  BUFX2 U26 ( .A(n9), .Y(n22) );
  INVX1 U27 ( .A(n16), .Y(n7) );
  INVX1 U28 ( .A(n17), .Y(n6) );
  INVX1 U29 ( .A(n18), .Y(n5) );
  INVX1 U30 ( .A(n19), .Y(n4) );
  INVX1 U31 ( .A(n20), .Y(n3) );
  INVX1 U32 ( .A(n21), .Y(n2) );
  INVX1 U33 ( .A(n22), .Y(n1) );
  INVX1 U34 ( .A(reset), .Y(n8) );
  AND2X1 U35 ( .A(temp[0]), .B(n8), .Y(N11) );
  AND2X1 U36 ( .A(d[7]), .B(reset), .Y(N10) );
endmodule


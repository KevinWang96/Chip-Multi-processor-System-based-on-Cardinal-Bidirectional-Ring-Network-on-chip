`timescale 1ns/100ps
`define ADDR_WIDTH 32
`define DATA_WIDTH 64
`define INST_WIDTH 32
/*
 * @Author: Yihao Wang
 * @Date: 2020-03-22 21:33:45
 * @LastEditTime: 2020-03-29 18:45:12
 * @LastEditors: Please set LastEditors
 * @Description: Testbench for module processor_top
 * @FilePath: /EE577b_final_project/project_p2/tb/tb_processor_top.v
 */
 module tb_processor_top;

   parameter CLK_TIME = 4;

   reg clk, reset;
   wire [0:`INST_WIDTH - 1] inst;
   wire [0:`ADDR_WIDTH - 1] imem_addr, dmem_addr;
   wire [0:1] nic_addr;
   wire [0: `DATA_WIDTH - 1] dmem_di, dmem_do, nic_di, nic_do;
   wire dmem_En, dmem_WrEn, nic_En, nic_WrEn;

   always #(0.5 * CLK_TIME) clk = ~ clk;

   processor_top processor_top_dut
   (
      .clk(clk),
      .reset(reset),

      .instr_addr(imem_addr),
      .instr_in(inst),

      .dmem_addr(dmem_addr[24:31]),
      .dmem_data_out(dmem_di),
      .dmem_En(dmem_En),
      .dmem_WrEn(dmem_WrEn),
      .dmem_data_in(dmem_do),
      
      .nic_addr(nic_addr),
      .nic_data_out(nic_di),
      .nic_En(nic_En),
      .nic_WrEn(nic_WrEn),
      .nic_data_in(nic_do)
   );
    
   imem imem_0
   (
      .memAddr(imem_addr[22:29]), // only need lower 8-bit
      .dataOut(inst)
   );

   dmem dmem_0
   (
      .clk(clk),
      .memEn(dmem_En),
      .memWrEn(dmem_WrEn),
      .memAddr(dmem_addr),
      .dataIn(dmem_di),
      .dataOut(dmem_do)
   );


   reg [0:32] rf_res, dmem_res;
   integer count;
   initial
   begin
      rf_res = $fopen("processor_rf_contents.res", "w");
      dmem_res = $fopen("data_memory_contents.res", "w");
      $readmemh("dmem.fill", dmem_0.MEM);
      $readmemb("imem.fill", imem_0.MEM);

      clk = 1;
      reset = 1;

      #(3.5 * CLK_TIME) 
      reset = 0;

   
      wait (inst == 0);
      repeat (8) #(CLK_TIME);
   
      for(count = 1; count < 32; count = count + 1)
         $fdisplay(rf_res, "%1d: %b", count, processor_top_dut.RegFile.mem[count]);

      for(count = 0; count < 5; count = count + 1)
         $fdisplay(dmem_res, "%1d: %b", count, dmem_0.MEM[count]);
      
      $fclose(rf_res | dmem_res);
      $finish;
   end

   initial
   begin
      #50000
      $fclose(rf_res | dmem_res);
      $finish;
   end   

 endmodule
 `undef DATA_WIDTH
 `undef ADDR_WIDTH
 `undef INST_WIDTH

    


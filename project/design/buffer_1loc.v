/*
 * @Author: Yihao Wang
 * @Date: 2020-03-09 20:46:57
 * @LastEditTime: 2020-04-07 00:39:58
 * @LastEditors: Please set LastEditors
 * @Description: A sync FIFO with only one location 
                Used as input and output buffer of rounter
 * @FilePath: /EE577b_final_project/project_p1/design/buffer_1loc.v
 */
 `define WIDTH 64
module buffer_1loc 
(
    input clk, reset, // sync hign active reset
    input re, we, //read enable and write enable
    input [`WIDTH - 1:0] data_in,
    output [`WIDTH - 1:0] data_out,
    output full, empty
);
    reg [`WIDTH - 1:0] mem; // memory location

    // flag used to represent empty or full
    // 0 means empty
    // 1 means full
    reg flag;
    assign full = flag;
    assign empty = ~flag;

    wire re_ql, we_ql; // qualified write enable or read enable
    assign re_ql = (re & flag);
    assign we_ql = (we & !flag);

    // sequential logic
    always @(posedge clk)
    begin
        if(reset)
        begin
            flag <= 0; // initial state is empty
            mem <= 0;
        end
        else
        begin
            // only one of re_pl and we_pl can be activated at the same clock
            if(re_ql) flag <= 0;

            else if(we_ql)
                begin
                    mem <= data_in;
                    flag <= 1;
                end
        end
    end

    assign data_out = mem;
    
endmodule
`undef WIDTH
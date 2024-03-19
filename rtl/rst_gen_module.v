`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/24 11:36:38
// Design Name: 
// Module Name: rst_gen_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rst_gen_module#(
    parameter P_RST_CYCLE  =  1
)(
    input     i_clk             ,
    output    o_rst  
    );  

reg        ro_rst = 1      ;
reg [15:0] r_cnt  = 0      ;

assign     o_rst = ro_rst  ;

always @(posedge i_clk)begin
    if(r_cnt == P_RST_CYCLE - 1 || P_RST_CYCLE == 0)
        r_cnt <= r_cnt;
    else
        r_cnt <= r_cnt + 1;
end

always @(posedge i_clk)begin
    if(r_cnt == P_RST_CYCLE - 1 || P_RST_CYCLE == 0)
        ro_rst <= 0;
    else
        ro_rst <= 1;
end

endmodule

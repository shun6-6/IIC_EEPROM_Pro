`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/13 11:22:16
// Design Name: 
// Module Name: iic_top_tb
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


module iic_top_tb();

localparam CLK_PERIOD = 20;
localparam      P_ST_IDLE    = 0    ,//状态机-空闲
                P_ST_START   = 1    ,//状态机-起始位
                P_ST_UADDR   = 2    ,//状态机-设备地址
                P_ST_DADDR1  = 3    ,//状态机-数据地址高位
                P_ST_DADDR2  = 4    ,//状态机-数据地址低位
                P_ST_WRITE   = 5    ,//状态机-写数据
                P_ST_REATART = 6    ,//状态机-重启iic总线
                P_ST_READ    = 7    ,//状态机-读数据
                P_ST_WATI    = 8    ,//等待应答后再发生停止位
                P_ST_STOP    = 9    ,//状态机-停止
                P_ST_EMPTY   = 10   ;//空状态

reg clk , rst;

initial begin
    rst = 1;
    #100;
    @(posedge clk) rst = 0;
end

always begin
    clk = 0;
    #(CLK_PERIOD/2);
    clk = 1;
    #(CLK_PERIOD/2);
end

reg  [63:0]     r_monitor_st;

wire            o_iic_scl         ;
wire            io_iic_sda        ;

always @(iic_top_u0.eeprom_drive_u0.iic_drive_u0.r_st_cur)begin
    case(iic_top_u0.eeprom_drive_u0.iic_drive_u0.r_st_cur)
        P_ST_IDLE    : r_monitor_st = "IDLE   ";
        P_ST_START   : r_monitor_st = "START  ";
        P_ST_UADDR   : r_monitor_st = "UADDR  ";
        P_ST_DADDR1  : r_monitor_st = "DADDR1 ";
        P_ST_DADDR2  : r_monitor_st = "DADDR2 ";
        P_ST_WRITE   : r_monitor_st = "WRITE  ";
        P_ST_REATART : r_monitor_st = "REATART";
        P_ST_READ    : r_monitor_st = "READ   ";
        P_ST_WATI    : r_monitor_st = "WATI   ";
        P_ST_STOP    : r_monitor_st = "STOP   ";
        P_ST_EMPTY   : r_monitor_st = "EMPTY  ";
        default      : r_monitor_st = "IDLE   ";
    endcase
end

pullup(io_iic_sda);

iic_top iic_top_u0(
    .i_clk       (clk       ),
    .o_iic_scl   (o_iic_scl ),//IIC时钟线
    .io_iic_sda  (io_iic_sda) //IIC双向数据线
    );

AT24C64 AT24C64_u0(
    .SDA(io_iic_sda),
    .SCL(o_iic_scl ),
    .WP (0)
);

endmodule

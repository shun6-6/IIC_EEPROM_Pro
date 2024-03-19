`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/06 10:46:37
// Design Name: 
// Module Name: sim_iic_TB
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


module sim_iic_TB();

localparam CLK_PERIOD = 20;

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

reg     [6 :0]  i_device_addr     ;
reg     [15:0]  i_operation_addr  ;
reg     [7 :0]  i_operation_len   ;
reg     [1 :0]  i_operation_type  ;
reg             i_operation_valid ;
wire            o_operation_ready ;

reg     [7 :0]  i_write_date      ;
wire            o_write_req       ;
wire    [7 :0]  o_read_date       ;
wire            o_read_valid      ;

wire            o_iic_scl         ;
wire            io_iic_sda        ;

pullup(o_iic_scl );
pullup(io_iic_sda);

initial begin
    i_device_addr     <= 0;
    i_operation_addr  <= 0;
    i_operation_len   <= 0;
    i_operation_type  <= 0;
    i_operation_valid <= 0;   
    i_write_date      <= 0; 
    wait(!rst);
    repeat(10)@(posedge clk) ;
    forever begin
        send_data();
        recv_data(0);
        recv_data(1);
        recv_data(2);
        recv_data(3);
        recv_data(4);
        recv_data(5);
        recv_data(6);
        recv_data(7);
    end
end


iic_drive#(
    .P_ADDR_WIDTH           (16)
) iic_drive_u0( 
    .i_clk                  (clk                ),
    .i_rst                  (rst                ),

    .i_device_addr          (i_device_addr      ),//用户输入设备地址
    .i_operation_addr       (i_operation_addr   ),//用户输入读写数据地址
    .i_operation_len        (i_operation_len    ),//用户输入读写数据长度
    .i_operation_type       (i_operation_type   ),//用户输入读写类型
    .i_operation_valid      (i_operation_valid  ),//用户输入操作有效信号
    .o_operation_ready      (o_operation_ready  ),//用户输出操作准备信号

    .i_write_date           (i_write_date       ),//用户写入数据
    .o_write_req            (o_write_req        ),//用户写数据请求

    .o_read_date            (o_read_date        ),//输出IIC读到的数据
    .o_read_valid           (o_read_valid       ),//数据有效信号

    .o_iic_scl              (o_iic_scl          ),//IIC时钟线
    .io_iic_sda             (io_iic_sda         ) //IIC双向数据线
    );

AT24C64 AT24C64_u0(
    .SDA(io_iic_sda),
    .SCL(o_iic_scl ),
    .WP (0)
);

task send_data();
 begin
     i_device_addr     <= 3;
     i_operation_addr  <= 16'h0000;
     i_operation_len   <= 1;
     i_operation_type  <= 1;
     i_operation_valid <= 1;
     @(posedge clk);
     wait(!o_operation_ready);
     i_device_addr     <= 0;
     i_operation_addr  <= 0;
     i_operation_len   <= 0;
     i_operation_type  <= 0;
     i_operation_valid <= 0;    
     @(posedge clk);
     wait(o_operation_ready);
 end
endtask

task recv_data(input [15:0] read_addr);
 begin
     i_device_addr     <= 3;
     i_operation_addr  <= read_addr;
     i_operation_len   <= 1;
     i_operation_type  <= 2;
     i_operation_valid <= 1;
     @(posedge clk);
     wait(!o_operation_ready);
     i_device_addr     <= 0;
     i_operation_addr  <= 0;
     i_operation_len   <= 0;
     i_operation_type  <= 0;
     i_operation_valid <= 0;    
     @(posedge clk);
     wait(o_operation_ready);
 end
endtask

always @(posedge clk or posedge rst)begin
    if(rst)
        i_write_date <= 'd0;
    else if(o_write_req)
        i_write_date <= 8'haa;
    else
        i_write_date <= i_write_date;
end

endmodule

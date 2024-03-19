`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/06 10:46:13
// Design Name: 
// Module Name: iic_top
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


module iic_top(
    input           i_clk       ,
    output          o_iic_scl   ,//IIC时钟线
    inout           io_iic_sda   //IIC双向数据线
    );

localparam      P_WRITE_NUM = 8;
localparam      P_W         = 1     ,//写数据
                P_R         = 2     ;//读数据

reg  [2 :0]     ri_eeprom_addr          ; 
reg  [15:0]     ri_user_operation_addr  ; 
reg  [1 :0]     ri_user_operation_type  ; 
reg  [7 :0]     ri_user_operation_len   ; 
reg             ri_user_operation_valid ; 
wire            o_user_operation_ready  ;
reg  [7 :0]     ri_user_write_date      ; 
reg             ri_user_write_valid     ; 
reg             ri_user_write_sop       ; 
reg             ri_user_write_eop       ; 
wire [7 :0]     o_user_read_date        ;
wire            o_user_read_valid       ;

reg  [7 :0]     r_write_cnt             ;
reg             r_wr_st                 ;

wire            w_user_active           ;
wire            w_clk_5mhz              ;
wire            w_clk_5mhz_lock         ;
wire            w_clk_125khz            ;
wire            w_clk_125khz_rst        ;


assign w_user_active = ri_user_operation_valid & o_user_operation_ready;

SYSCLK_div SYSCLK_div_5mhz
   (
    .clk_out1               (w_clk_5mhz     ),   
    .locked                 (w_clk_5mhz_lock),       
    .clk_in1                (i_clk          )      
);

CLK_DIV_module#(
    .P_CLK_DIV_CNT          (40) //MAX = 65535
)CLK_DIV_module_U(
    .i_clk                  (w_clk_5mhz      ),
    .i_rst                  (~w_clk_5mhz_lock),
    .o_clk_div              (w_clk_125khz    )
    );

rst_gen_module#(
    .P_RST_CYCLE            (1)  
)rst_gen_module_u0(     
    .i_clk                  (w_clk_125khz    ),
    .o_rst                  (w_clk_125khz_rst)
    ); 

eeprom_drive eeprom_drive_u0(
    .i_clk                  (w_clk_125khz    ),
    .i_rst                  (w_clk_125khz_rst),

    .i_eeprom_addr          (ri_eeprom_addr         ),
    .i_user_operation_addr  (ri_user_operation_addr ),
    .i_user_operation_type  (ri_user_operation_type ),
    .i_user_operation_len   (ri_user_operation_len  ),
    .i_user_operation_valid (ri_user_operation_valid),
    .o_user_operation_ready (o_user_operation_ready ),

    .i_user_write_date      (ri_user_write_date     ),
    .i_user_write_valid     (ri_user_write_valid    ),
    .i_user_write_sop       (ri_user_write_sop      ),
    .i_user_write_eop       (ri_user_write_eop      ),
    .o_user_read_date       (o_user_read_date       ),
    .o_user_read_valid      (o_user_read_valid      ),

    .o_iic_scl              (o_iic_scl ),//IIC时钟线
    .io_iic_sda             (io_iic_sda) //IIC双向数据线
    );

always @(posedge w_clk_125khz or posedge w_clk_125khz_rst)begin
    if(w_clk_125khz_rst)begin
        ri_eeprom_addr          <= 'd0;
        ri_user_operation_addr  <= 'd0;
        ri_user_operation_type  <= 'd0;
        ri_user_operation_len   <= 'd0;
        ri_user_operation_valid <= 'd0;
    end
    else if(o_user_operation_ready && r_wr_st == 0)begin
        ri_eeprom_addr          <= 3'b011;
        ri_user_operation_addr  <= 'd0;
        ri_user_operation_type  <= P_W;
        ri_user_operation_len   <= P_WRITE_NUM;
        ri_user_operation_valid <= 'd1;
    end
    else if(o_user_operation_ready && r_wr_st == 1)begin
        ri_eeprom_addr          <= 3'b011;
        ri_user_operation_addr  <= 'd0;
        ri_user_operation_type  <= P_R;
        ri_user_operation_len   <= P_WRITE_NUM;
        ri_user_operation_valid <= 'd1;
    end
    else begin
        ri_eeprom_addr          <= 'd0;
        ri_user_operation_addr  <= 'd0;
        ri_user_operation_type  <= 'd0;
        ri_user_operation_len   <= 'd0;
        ri_user_operation_valid <= 'd0;
    end
end

always @(posedge w_clk_125khz or posedge w_clk_125khz_rst)begin
    if(w_clk_125khz_rst)
        ri_user_write_date <= 'd0;
    else if(ri_user_write_valid)
        ri_user_write_date <= ri_user_write_date + 1;
    else
        ri_user_write_date <= ri_user_write_date;
end 
  
always @(posedge w_clk_125khz or posedge w_clk_125khz_rst)begin
    if(w_clk_125khz_rst)
        ri_user_write_sop <= 'd0;
    else if(w_user_active && ri_user_operation_type == P_W)
        ri_user_write_sop <= 'd1;
    else
        ri_user_write_sop <= 'd0;
end 

always @(posedge w_clk_125khz or posedge w_clk_125khz_rst)begin
    if(w_clk_125khz_rst)
        ri_user_write_valid <= 'd0;
    else if(ri_user_write_eop)
        ri_user_write_valid <= 'd0;
    else if(w_user_active && ri_user_operation_type == P_W)
        ri_user_write_valid <= 'd1;
    else
        ri_user_write_valid <= ri_user_write_valid;
end 

always @(posedge w_clk_125khz or posedge w_clk_125khz_rst)begin
    if(w_clk_125khz_rst)
        ri_user_write_eop <= 'd0;
    // else if((w_user_active || ri_user_write_valid) && r_write_cnt == P_WRITE_NUM - 2)
    //     ri_user_write_eop <= 'd1;
    else if(w_user_active && P_WRITE_NUM == 1)
        ri_user_write_eop <= 'd1;//write 1 byte
    else if(ri_user_write_valid && r_write_cnt == P_WRITE_NUM - 2)
        ri_user_write_eop <= 'd1;//write over 1 byte
    else
        ri_user_write_eop <= 'd0;
end 

always @(posedge w_clk_125khz or posedge w_clk_125khz_rst)begin
    if(w_clk_125khz_rst)
        r_write_cnt <= 'd0;
    else if(r_write_cnt == P_WRITE_NUM - 1)
        r_write_cnt <= 'd0;
    else if(ri_user_write_valid)
        r_write_cnt <= r_write_cnt + 1'd1;
    else
        r_write_cnt <= r_write_cnt;
end 

always @(posedge w_clk_125khz or posedge w_clk_125khz_rst)begin
    if(w_clk_125khz_rst)
        r_wr_st <= 'd0;
    else if(w_user_active)
        r_wr_st <= r_wr_st + 1'd1;
    else
        r_wr_st <= r_wr_st;
end 

endmodule

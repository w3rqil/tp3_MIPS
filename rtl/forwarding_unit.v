module forwarding_unit
#(
    parameter NB_ADDR = 5,
    parameter NB_FW   = 2
)
(
    input wire clk,
    input wire i_rst_n,
    input wire i_stall,
    input wire i_halt,

    input wire [NB_ADDR-1 : 0]  i_rs_IFID       ,
    input wire [NB_ADDR-1 : 0]  i_rt_IFID       ,

    input wire [NB_ADDR-1 : 0]  i_rd_IDEX       ,
    input wire [NB_ADDR-1 : 0]  i_rd_EX_MEMWB   ,

    input wire                  i_wr_WB         ,
    input wire                  i_wr_MEM        ,
    output reg [NB_FW  -1 : 0]  o_fw_b          ,
    output reg [NB_FW  -1 : 0]  o_fw_a

);



    always @(*) begin : fwd_ctrl
        o_fw_a =    ((i_rd_IDEX     == i_rs_IFID) && i_wr_WB )  ? 2'b11 :
                    ((i_rd_EX_MEMWB == i_rs_IFID) && i_wr_MEM)  ? 2'b10 :
                                                                  2'b00 ;

        o_fw_b =    ((i_rd_IDEX     == i_rt_IFID) && i_wr_WB ) ? 2'b11 :
                    ((i_rd_EX_MEMWB == i_rt_IFID) && i_wr_MEM) ? 2'b10 :
                                                                 2'b00 ;
    end


endmodule

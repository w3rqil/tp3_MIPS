module xilinx_one_port_ram_async
#(
    parameter NB_DATA = 32,
    parameter NB_REGS = 32,
    parameter NB_ADDR = 12
)(
    input wire clk                                                                              ,
    input wire i_rst_n                                                                          ,
    input wire i_we                                                                             ,
    input wire [NB_DATA-1:0] i_data                                                             ,
    input wire [NB_ADDR-1:0] i_addr_w                                                           ,
    //input wire [NB_ADDR-1:0] i_addr_a,
    //input wire [NB_ADDR-1:0] i_addr_b,
    output wire [NB_DATA-1:0] o_data
);
    localparam DATA_WIDTH = NB_DATA/4                                                           ;

    reg [DATA_WIDTH-1:0] regs [2**NB_ADDR-1:0]                                                  ; 

    always @(posedge clk) begin

        else if(i_we) begin
            regs[i_addr_w  ] <= i_data[NB_DATA-1: NB_DATA - 1 - DATA_WIDTH  ]                   ;
            regs[i_addr_w+1] <= i_data[23       :   16                      ]                   ;
            regs[i_addr_w+2] <= i_data[15       :   8                       ]                   ;
            regs[i_addr_w+3] <= i_data[7        :   0                       ]                   ;
        end
    end

    assign o_data = {regs[i_addr_w], regs[i_addr_w+1], regs[i_addr_w+2], regs[i_addr_w+3]}      ;

endmodule
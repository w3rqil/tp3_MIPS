module xilinx_one_port_ram_async
#(
    parameter NB_DATA = 32,    // Data width for a single read/write operation
    parameter NB_ADDR = 8      // Address width
)(
    input  wire clk                         ,
    //input  wire i_rst_n                     ,
    input  wire i_we                        , //! Write enable signal
    input  wire [NB_DATA-1:0] i_data        , //! 32-bit input data
    input  wire [NB_ADDR-1:0] i_addr_w      , //! Byte-addressable
    output wire [NB_DATA-1:0] o_data          //! 32-bit output data
);

    // Memory array with 8-bit chunks
    reg [7:0] memory [0:(2**NB_ADDR)-1];

    // Writing 32-bit data in 8-bit chunks
    always @(posedge clk) begin
        if (i_we) begin
            memory[i_addr_w ]     <= i_data[31:24]       ; // MSB
            memory[i_addr_w +1] <= i_data[23:16]       ;
            memory[i_addr_w +2] <= i_data[15 :8]       ;
            memory[i_addr_w +3] <= i_data[7  :0]       ;   // LSB

        end
    end

    // Reading 32-bit data by combining 8-bit chunks
    assign o_data = {memory[i_addr_w], memory[i_addr_w + 1], memory[i_addr_w + 2], memory[i_addr_w + 3]};

endmodule

module instruction_decode
#(

)(
    input wire          clk                 ,
    input wire          i_rst_n             ,
    input wire [31:0]   i_instruction       ,
    input wire [31:0]   i_pcounter4         ,
    input wire          i_we_wb             ,
    input wire          i_wr_addr           ,
    input wire [31:0]   i_wr_data_WB        ,
    input wire          i_stall             ,
    //
    //
    output reg [4:0]    o_rs                ,
    output reg [4:0]    o_rt                ,
    output reg [4:0]    o_rd                ,

    output reg [31:0]   o_reg_DA              ,
    output reg [31:0]   o_reg_DB              ,

    output reg [15:0]   o_immediat            ,
    output reg [5 :0]   o_opcode              ,
    output reg [4 :0]   o_shamt               ,
    output reg [4 :0]   o_func                ,
    output reg [15:0]   o_addr  

);

    wire [31:0] wire_D1, wire_D2;
    wire [4 :0] rs, rt, rd;
    register_file #()
    regFile1(
        .clk        (clk        )           ,
        .i_rst_n    (i_rst_n    )           ,
        .i_we       (i_we       )           ,
        .i_wr_addr  (i_wr_addr  )           ,
        .i_wr_data  (i_pcounter4)           ,
        .i_rd_addr1 ()  ,
        .i_rd_addr2 ()  ,
        .o_rd_data1 (wire_D1)  ,
        .o_rd_data2 (wire_D2)
    );

    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            
        end else begin
            o_reg_DA <= wire_D1;
            o_reg_DB <= wire_D2;
            o_rd     <= rd;
            o_rs     <= rs;
            o_rt     <= rt;
            o_immediat <= i_instruction [15:0];
            o_opcode   <= i_instruction [31:25];
            o_shamt    <= i_instruction [10:6 ];
            o_func     <= i_instruction [5 :0];
            o_addr     <= i_instruction [15:0];



        end
    end

    assign rs = i_instruction[25:21];
    assign rt = i_instruction[20:16];
    assign rd = i_instruction[15:11];

endmodule

module instruction_decode
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 5,
    parameter NB_REG  = 1
)(
    input wire          clk                             ,
    input wire          i_rst_n                         ,
    input wire [NB_DATA-1:0]   i_instruction                   ,
    input wire [NB_DATA-1:0]   i_pcounter4                     ,
    input wire          i_we_wb                         ,
    input wire          i_we                            ,
    input wire          i_wr_addr                       ,
    input wire [NB_DATA-1:0]   i_wr_data_WB                    ,
    input wire          i_stall                         ,
    //      
    //      
    output reg [4:0]    o_rs                            ,
    output reg [4:0]    o_rt                            ,
    output reg [4:0]    o_rd                            ,

    output reg [NB_DATA-1:0]   o_reg_DA                        ,
    output reg [NB_DATA-1:0]   o_reg_DB                        ,

    output reg [NB_DATA-1:0]   o_immediat                     ,
    output reg [5 :0]   o_opcode                        ,
    output reg [4 :0]   o_shamt                         ,
    output reg [4 :0]   o_func                          ,
    output reg [15:0]   o_addr                          ,//jmp

    //ctrl unit
    output wire         o_jump                          , 
    output wire         o_branch                        , 
    output wire         o_regDst                        , 
    output wire         o_mem2Reg                       , 
    output wire         o_memRead                       , 
    output wire         o_memWrite                      , 
    output wire         o_immediate                      , 
    output wire         o_regWrite                      ,
    output wire [1:0]   o_aluSrc                        ,
    output wire [1:0]   o_aluOp

);

    wire [NB_DATA-1:0] wire_D1, wire_D2;
    wire [4 :0] rs, rt, rd;
    reg  [15:0] r_immediate;

    // ---- ctrl unit ----
    //reg [5:0] reg_opcode, reg_funct;
    wire w_jump, w_branch, w_regDst, w_mem2Reg, w_memRead, w_memWrite, w_immediate, w_regWrite;
    wire [1:0] w_aluSrc, w_aluOp;


    register_file #()
    regFile1(
        .clk        (clk        )                       ,
        .i_rst_n    (i_rst_n    )                       ,
        .i_we       (i_we       )                       , // todo: poner en 0
        .i_wr_addr  (i_wr_addr  )                       , // todo: poner en 0
        .i_wr_data  (i_pcounter4)                       ,
        .i_rd_addr1 (rs)                                ,
        .i_rd_addr2 (rt)                                ,
        .o_rd_data1 (wire_D1)                           ,
        .o_rd_data2 (wire_D2)
    );

    control_unit #()
    controlU1
    (
        .clk        (clk        ),
        .i_rst_n    (i_rst_n    ),
        .i_opcode   (o_opcode   ),
        .i_funct    (o_func     ),
        //
        .o_jump     (w_jump     ),
        .o_aluSrc   (w_aluSrc   ),
        .o_aluOp    (w_aluOp    ),
        .o_branch   (w_branch   ),
        .o_regDst   (w_regDst   ),
        .o_mem2Reg  (w_mem2Reg  ),
        .o_regWrite (w_regWrite ),
        .o_memWrite (w_memWrite ),
        .o_immediate(w_immediate)
    );

    sign_extension #()
    se1
    (
        .i_immediate_flag   (w_immediate),
        .i_immediate_value  (r_immediate),

        .o_data             (o_immediat)
    );

    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            o_reg_DA <= 32'b0                               ;
            o_reg_DB <= 32'b0                               ;
            o_rd     <= 5'b0                                ;
            o_rs     <= 5'b0                                ;
            o_rt     <= 5'b0                                ;
            r_immediate<= 16'b0                             ;
            o_opcode   <= 6'b0                              ;
            o_shamt    <= 5'b0                              ;
            o_func     <= 6'b0                              ;
            o_addr     <= 16'b0                             ;

        end else begin
            if(!i_stall) begin
                o_reg_DA <= wire_D1                         ;
                o_reg_DB <= wire_D2                         ;
                o_rd     <= rd                              ;
                o_rs     <= rs                              ;
                o_rt     <= rt                              ;
                r_immediate<= i_instruction [15:0   ]       ;
                o_opcode   <= i_instruction [31:25  ]       ;
                o_shamt    <= i_instruction [10:6   ]       ;
                o_func     <= i_instruction [5 :0   ]       ;
                o_addr     <= i_instruction [15:0   ]       ;
                
                o_immediat <= w_immediate                   ;
            // ctrl unit
            //reg_opcode <= i_instruction [31:25  ]       ;
            //reg_funct  <= i_instruction [5:0    ]       ;
            end

        end
    end

    assign o_jump     = w_jump                              ;
    assign o_branch   = w_branch                            ;
    assign o_regDst   = w_regDst                            ;
    assign o_mem2Reg  = w_mem2Reg                           ;
    assign o_memRead  = w_memRead                           ;
    assign o_memWrite = w_memWrite                          ;
//assign o_immediat= w_immediate                         ;
    assign o_regWrite = w_regWrite                          ;
    assign o_aluSrc   = w_aluSrc                            ;
    assign o_aluOp    = w_aluOp                             ;

    assign rs = i_instruction[25:21]                        ;
    assign rt = i_instruction[20:16]                        ;
    assign rd = i_instruction[15:11]                        ;

endmodule

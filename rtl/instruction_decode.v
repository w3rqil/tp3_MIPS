module instruction_decode
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 5,
    parameter NB_REG  = 1
)(
    input wire                 clk                      ,
    input wire                 i_rst_n                  ,
    input wire [NB_DATA-1:0]   i_instruction            ,
    input wire [NB_DATA-1:0]   i_pcounter4              ,
    input wire                 i_we_wb                  ,
    input wire                 i_we                     ,
    input wire [NB_ADDR-1:0]   i_wr_addr                ,
    input wire [NB_DATA-1:0]   i_wr_data_WB             ,
    input wire                 i_stall                  ,
    //      
    //      
    output reg [4:0]    o_rs                            ,
    output reg [4:0]    o_rt                            ,
    output reg [4:0]    o_rd                            ,

    output reg [NB_DATA-1:0]   o_reg_DA                 ,
    output reg [NB_DATA-1:0]   o_reg_DB                 ,

    output reg [NB_DATA-1:0]   o_immediate              ,
    output reg [5 :0]           o_opcode                ,
    output reg [4 :0]           o_shamt                 ,
    output reg [5 :0]           o_func                  ,
    output reg [15:0]           o_addr                  ,
    output reg [31:0]           o_addr2jump             ,
    output reg [1: 0]           o_jump_cases            ,
    //ctrl unit
    output reg                  o_jump                  , 
    output reg                  o_branch                , 
    output reg                  o_regDst                , 
    output reg                  o_mem2Reg               , 
    output reg                  o_memRead               , 
    output reg                  o_memWrite              , 
    output reg                  o_immediate_flag        , 
    output reg                  o_sign_flag             ,
    output reg                  o_regWrite              ,
    output reg [1:0]            o_aluSrc                ,
    output reg [1:0]            o_width                 ,
    output reg [1:0]            o_aluOp

);

    wire [NB_DATA-1:0] wire_D1, wire_D2                 ;
    wire [4 :0] rs, rt, rd                              ;
    reg  [15:0] r_immediate                             ;
    parameter [5:0] 
                    JR_TYPE     = 6'b001000             ,
                    JARL_TYPE   = 6'b001001             ,
                    R_TYPE      = 6'b000000             ,
                    BEQ_TYPE    = 6'b000100             ,
                    J_TYPE      = 6'b000010             ,
                    JAL_TYPE    = 6'b000011             ,
                    BNE_TYPE    = 6'b000101             ;

    // ---- ctrl unit ----
    //reg [5:0] reg_opcode, reg_funct;
    wire w_jump, w_branch, w_regDst, w_mem2Reg, w_memRead, w_memWrite, w_immediate, w_regWrite, w_sign_flag;
    wire [1:0] w_aluSrc, w_aluOp, w_width;
    wire [NB_DATA -1: 0] w_immediat;

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
        .clk        (clk        )                       ,
        .i_rst_n    (i_rst_n    )                       ,
        .i_opcode   (o_opcode   )                       ,
        .i_funct    (o_func     )                       ,

        .o_jump     (w_jump     )                       ,
        .o_aluSrc   (w_aluSrc   )                       ,
        .o_aluOp    (w_aluOp    )                       ,
        .o_branch   (w_branch   )                       ,
        .o_regDst   (w_regDst   )                       ,
        .o_mem2Reg  (w_mem2Reg  )                       ,
        .o_regWrite (w_regWrite )                       ,
        .o_memRead  (w_memRead  )                       ,
        .o_memWrite (w_memWrite )                       ,
        .o_width    (w_width    )                       ,
        .o_sign_flag(w_sign_flag)                       ,
        .o_immediate(w_immediate)
    );

    sign_extension #()
    se1
    (
        .i_immediate_flag   (w_immediate)               ,
        .i_immediate_value  (r_immediate)               ,
        .o_data             (w_immediat)
    );


    always @(*) begin : jumps
        if(w_jump || w_branch) begin // the following will execute only when a jump opcode is detected
            o_jump = 1'b0                                                                   ;
            case (o_opcode) 
                R_TYPE: begin //jr o jalr
                    
                    
                    o_jump = 1'b1                                                           ;
                    o_addr2jump = wire_D1                                                   ; //RA
                    
                    
                end
                BEQ_TYPE: begin
                    if(wire_D1 == wire_D2) begin
                        o_jump = 1'b1                                                       ;
                        o_addr2jump = i_pcounter4 + (w_immediat << 2) + 4                   ;
                    end
                end
                BNE_TYPE: begin
                    if(wire_D1 != wire_D2) begin
                        o_jump = 1'b1                                                       ;
                        o_addr2jump = i_pcounter4 + (w_immediat << 2) + 4                   ;
                    end
                end
                JAL_TYPE: begin
                    o_jump = 1'b1                                                           ;
                    o_jump_addr = {i_pcounter4[31:28], i_instruction[25:0], 2'b00}          ;
                end
                J_TYPE: begin
                    o_jump = 1'b1                                                           ;
                    o_jump_addr = {i_pcounter4[31:28], i_instruction[25:0], 2'b00}          ;
                end
            endcase
        end
    end

    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            o_reg_DA <= 32'b0                                                               ;
            o_reg_DB <= 32'b0                                                               ;
            o_rd     <= 5'b0                                                                ;
            o_rs     <= 5'b0                                                                ;
            o_rt     <= 5'b0                                                                ;
            r_immediate<= 16'b0                                                             ;
            o_opcode   <= 6'b0                                                              ;
            o_shamt    <= 5'b0                                                              ;
            o_func     <= 6'b0                                                              ;
            o_addr     <= 16'b0                                                             ;

        end else begin
            if(!i_stall) begin
                o_reg_DA = ((o_opcode == JAL_TYPE) || (o_func == JARL_TYPE) )? 
                                                                    i_pcounter4             : 
                                                                    wire_D1                 ;

                o_reg_DB   <= ((o_opcode == JAL_TYPE) || (o_func == JARL_TYPE) )?         
                                                                    32'd4                   : 
                                                                    wire_D1                 ;
                o_rd       <= rd                              ;
                o_rs       <= ((o_opcode == JAL_TYPE) || (o_func == JARL_TYPE) )? 0 : rs    ;
                o_rt       <= (o_opcode == JAL_TYPE)? 5'b11111 : rt                         ; //register 31 reserved for jal
                r_immediate<= i_instruction [15:0   ]                                       ;
                o_opcode   <= i_instruction [31:26  ]                                       ;
                o_shamt    <= i_instruction [10:6   ]                                       ;
                o_func     <= i_instruction [5 :0   ]                                       ;
                o_addr     <= i_instruction [15:0   ]                                       ;
                
                o_immediate <= w_immediat                                                   ;

                o_jump     <= w_jump                                                        ;
                o_branch   <= w_branch                                                      ;   
                o_regDst   <= w_regDst                                                      ;
                o_mem2Reg  <= w_mem2Reg                                                     ;
                o_memRead  <= w_memRead                                                     ;
                o_memWrite <= w_memWrite                                                    ;
                o_immediate_flag<= w_immediate                                              ;
                o_regWrite <= w_regWrite                                                    ;
                o_aluSrc   <= w_aluSrc                                                      ;
                o_aluOp    <= w_aluOp                                                       ;
                o_width    <= w_width                                                       ;
                o_sign_flag<= w_sign_flag                                                   ;

                o_rs <= i_instruction[25:21]                                                ;
                o_rt <= i_instruction[20:16]                                                ;
                o_rd <= i_instruction[15:11]                                                ;

            // ctrl unit
            //reg_opcode <= i_instruction [31:25  ]       ;
            //reg_funct  <= i_instruction [5:0    ]       ;
            end
        end
    end
/*
    assign o_jump     = w_jump                              ;
    assign o_branch   = w_branch                            ;
    assign o_regDst   = w_regDst                            ;
    assign o_mem2Reg  = w_mem2Reg                           ;
    assign o_memRead  = w_memRead                           ;
    assign o_memWrite = w_memWrite                          ;
    assign o_immediate_flag= w_immediate                    ;
    assign o_regWrite = w_regWrite                          ;
    assign o_aluSrc   = w_aluSrc                            ;
    assign o_aluOp    = w_aluOp                             ;
    assign o_width    = w_width                             ;

    assign rs = i_instruction[25:21]                        ;
    assign rt = i_instruction[20:16]                        ;
    assign rd = i_instruction[15:11]                        ;
    */

endmodule

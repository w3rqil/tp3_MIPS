module instruction_execute
#(
    parameter NB_DATA = 8
)
(
    input wire                  clk                             ,
    input wire                  i_rst_n                         ,
    input wire                  i_stall                         ,
    input wire                  i_halt                          ,

    input wire [4:0]            o_rs                            ,
    input wire [4:0]            o_rt                            ,
    input wire [4:0]            o_rd                            ,

    input wire [NB_DATA-1:0]    i_reg_DA                        ,
    input wire [NB_DATA-1:0]    i_reg_DB                        ,

    input wire [NB_DATA-1:0]    i_immediate                     ,
    input wire [5 :0]           i_opcode                        ,
    input wire [4 :0]           i_shamt                         ,
    input wire [5 :0]           i_func                          ,
    input wire [15:0]           i_addr                          ,//jmp

    //ctrl unit
    input wire                  i_jump                          , 
    input wire                  i_branch                        , 
    input wire                  i_regDst                        , 
    input wire                  i_mem2Reg                       , 
    input wire                  i_memRead                       , 
    input wire                  i_memWrite                      , 
    input wire                  i_immediate_flag                , 
    input wire                  i_regWrite                      ,
    input wire [1:0]            i_aluSrc                        ,
    input wire [1:0]            i_aluOp                         ,

    //fwd unit
    input wire [1:0]            i_fw_a                          ,
    input wire [1:0]            i_fw_b                          ,
    
    
    // ctrl signals
    output reg                  o_mem2reg                       ,
    output reg                  o_memRead                       ,
    output reg                  o_memWrite                      ,
    output reg                  o_regWrite                      ,
    output reg [1:0]            o_aluSrc                        ,
    output reg                  o_jump                          ,

    output reg [4:0]            o_write_reg                     ,
    output reg [2:1]            o_aluOP                         ,
    output reg [NB_DATA-1:0]    o_result                        

);

    localparam [2:1]
                ADDI    = 3'b000;
                ANDI    = 3'b100;
                ORI     = 3'b101;
                XORI    = 3'b110;
                SLTI    = 3'b010;
                LUI     = 3'b111;

    localparam [1:0]
                    LOAD_STORE = 2'b00,
                    BRANCH     = 2'b01,
                    R_TYPE     = 2'b10,
                    I_TYPE     = 2'b11;

    reg [5:0] opcode;
    reg [NB_DATA-1:0] alu_datoA, alu_datoB;
    reg [NB_DATA-1:0] alu_result;

    // state machine for alu
    always(*) begin: alu_ctrl

        case(i_aluOP)
            LOAD_STORE: begin
                opcode = ADD;
            end
            BRANCH: begin
                // sub
                // to do
            end
            R_TYPE: begin
                // and
                opcode = i_func;
    
            end
            I_TYPE: begin
                // or
                opcode = i_opcode;
            end
            default: begin
                // nop
                opcode= 6'b0;
            end
        endcase
    end

    always @(*) begin: mux1_datoA
        case(i_fw_a)
            2'b00: begin
                // datoA = reg[rs]
                alu_datoA = i_reg_DA;
            end
            2'b10: begin
                // datoA = datoB
                //alu_datoA = i_output_MEMWB
            end
            2'b11: begin
                // datoA = datoB
                //alu_datoA = i_output_EXMEM
            end
            default: begin
                // nop
                alu_datoA = 8'b0;
            end
        endcase
    end


    
    always @(*) begin: mux2_datoB
        case(i_fw_b)
            2'b00: begin
                // datoB = reg[rt]
                alu_datoB = i_reg_DB;
            end
            2'b10: begin
                // datoB = datoB
                //alu_datoB = i_output_MEMWB
            end
            2'b11: begin
                // datoB = datoB
                //alu_datoB = i_output_EXMEM
            end
            default: begin
                // nop
                alu_datoB = 8'b0;
            end
        endcase

        if(i_immediate_flag) alu_datoB = i_immediate;

    end
    
    always @(*) begin: mux3
        // when asserted The register destination number for the Write register 
        // comes from the rd field
        // when deasserted The register destination number for the Write register
        // comes from the rt field
        if(!i_rst_n) begin
            o_write_reg = 5'b0;
        end else begin
            o_write_reg = i_regDst ? i_rt : i_rd;
        end
    end
    
    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            o_mem2reg <= 1'b0                                       ;
            o_memRead <= 1'b0                                       ;
            o_memWrite<= 1'b0                                       ;
            o_regWrite<= 1'b0                                       ;
            o_aluSrc  <= 2'b00                                      ;
            o_aluOP   <= 3'b000                                     ;
            o_result  <= 8'b0                                       ;
        end else begin
            o_mem2reg   <= i_mem2Reg                                ;
            o_memRead   <= i_memRead                                ;
            o_memWrite  <= i_memWrite                               ;
            o_regWrite  <= i_regWrite                               ;
            o_aluSrc    <= i_aluSrc                                 ;
            o_aluOP     <= opcode                                   ;
            o_result    <= alu_result                               ;
        end else begin
            
        end
    end

    alu #(
        .NB_DATA(NB_DATA        ),
        .NB_OP  (6              )
    ) alu1
    (
        .clk    (clk            ),
        .i_rst_n(i_rst_n        ),
        .i_op   (opcode         ),
        .i_datoA(alu_datoA      ),
        .i_datoB(alu_datoB      ),
        .o_result(alu_result    )
    );


endmodule

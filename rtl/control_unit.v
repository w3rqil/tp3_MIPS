module control_unit
#(

)(
    input wire clk,
    input wire i_rst_n,
    input wire [5:0] i_opcode       , //[31:26] instruction
    input wire [5:0] i_funct        , // for R-type [5:0] field



    //output
    output wire         o_jump      , //! Controls whether a jump should be performed
    output wire [1:0]   o_aluSrc    , 
    output wire [1:0]   o_aluOp     ,
    output wire         o_branch    ,
    output wire         o_regDst    , //! dst reg for the wb stage
    output wire         o_mem2Reg   , //! ctrl src of data to wb to register_file
    output wire         o_regWrite  , //! write enable for register file
    output wire         o_memRead   , //! enable reading
    output wire         o_memWrite  , //! enable writinh to memory (1: Memory write is enabled (used for sw))
    output wire         o_immediate
);  
    
    localparam [5:0]
                    R_TYPE  = 6'b000000,
                    LW_TYPE = 6'b100011,
                    SW_TYPE = 6'b101011,
                    BEQ_TYPE= 6'b000100,
                    ADDI_TYPE= 6'b000100,
                    J_TYPE  = 6'b000010;

    reg r_jump, r_ALUSrc, r_branch, r_regDst, r_mem2Reg, r_regWrite, r_memRead, r_memWrite, r_immediate;
    reg [1:0] r_aluOP;
    always @(*) begin

        case (i_opcode)
            R_TYPE: begin
                r_regDst    = 1'b1      ;
                r_ALUSrc    = 1'b0      ;
                r_mem2Reg   = 1'b0      ;
                r_regWrite  = 1'b1      ;
                r_memRead   = 1'b0      ;
                r_memWrite  = 1'b0      ;
                r_branch    = 1'b0      ;
                r_jump      = 1'b0      ;
                r_aluOP     = 2'b10     ;
            end
            LW_TYPE: begin
                r_regDst    = 1'b0      ;
                r_ALUSrc    = 1'b1      ;
                r_mem2Reg   = 1'b1      ;
                r_regWrite  = 1'b1      ;
                r_memRead   = 1'b1      ;
                r_memWrite  = 1'b0      ;
                r_branch    = 1'b0      ;
                r_jump      = 1'b0      ;
                r_aluOP     = 2'b00     ;
            end
            SW_TYPE: begin
                r_regDst    = 1'b0      ; //x
                r_ALUSrc    = 1'b1      ;
                r_mem2Reg   = 1'b0      ; //x
                r_regWrite  = 1'b0      ;
                r_memRead   = 1'b0      ;
                r_memWrite  = 1'b1      ;
                r_branch    = 1'b0      ;
                r_jump      = 1'b0      ;
                r_aluOP     = 2'b00     ;
            end
            BEQ_TYPE: begin
                r_regDst    = 1'b0      ; //x
                r_ALUSrc    = 1'b0      ;
                r_mem2Reg   = 1'b0      ; //x
                r_regWrite  = 1'b0      ;
                r_memRead   = 1'b0      ;
                r_memWrite  = 1'b0      ;
                r_branch    = 1'b1      ;
                r_jump      = 1'b0      ;
                r_aluOP     = 2'b01     ;
            end
            ADDI_TYPE: begin
                r_regDst    = 1'b0      ;
                r_ALUSrc    = 1'b1      ;
                r_mem2Reg   = 1'b0      ;
                r_regWrite  = 1'b1      ;
                r_memRead   = 1'b0      ;
                r_memWrite  = 1'b0      ;
                r_branch    = 1'b0      ;
                r_jump      = 1'b0      ;
                r_aluOP     = 2'b00     ;
            end
            J_TYPE: begin
                r_regDst    = 1'b0      ; //x
                r_ALUSrc    = 1'b0      ; //x
                r_mem2Reg   = 1'b0      ; //x
                r_regWrite  = 1'b0      ;
                r_memRead   = 1'b0      ;
                r_memWrite  = 1'b0      ;
                r_branch    = 1'b0      ;
                r_jump      = 1'b1      ;
                r_aluOP     = 2'b00     ; //x
            end
            default: begin
                r_regDst    = 1'b0      ; 
                r_ALUSrc    = 1'b0      ; 
                r_mem2Reg   = 1'b0      ; 
                r_regWrite  = 1'b0      ;
                r_memRead   = 1'b0      ;
                r_memWrite  = 1'b0      ;
                r_branch    = 1'b0      ;
                r_jump      = 1'b0      ;
                r_aluOP     = 2'b00     ; 
            end
        endcase
    end

    assign o_aluOp         = r_aluOP            ;
    assign o_aluSrc        = r_ALUSrc           ;
    assign o_branch        = r_branch           ;
    assign o_immediate     = r_immediate        ;
    assign o_jump          = r_jump             ;
    assign o_mem2Reg       = r_mem2Reg          ;
    assign o_memRead       = r_memRead          ;
    assign o_memWrite      = r_memWrite         ;
    assign o_regDst        = r_regDst           ;
    assign o_regWrite      = r_regWrite         ;

endmodule

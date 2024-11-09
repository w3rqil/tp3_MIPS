module alu
#(
    parameter NB_DATA   = 8, //! BITs de datos y LEDs
    parameter NB_OP     = 6  //! BITs de operaciones
)
(
    input   wire    signed [NB_DATA-1:0]   i_datoA                                              , //! Dato de entrada
    input   wire    signed [NB_DATA-1:0]   i_datoB                                              , //! Dato de entrada
    input   wire           [NB_OP - 1:0]   i_operation                                          , //! Operación a realizar    
    input   wire    signed [ 4       :0]   i_shamt                                              , //! Shift amount
    output  wire    signed [NB_DATA-1:0]   o_data                                                 //! output  
);

    reg signed [NB_DATA-1:0] result                                                             ; //! Resultado de la operación
    reg        [NB_DATA-1:0] result_U                                                           ; //! Resultado de la operación unsigned
    wire                     is_unsigned                                                        ; //! Señal para saber si es unsigned
    wire       [NB_DATA-1:0] dato_A_u = i_datoA                                                 ; //! Dato A unsigned
    wire       [NB_DATA-1:0] dato_B_u = i_datoB                                                 ; //! Dato B unsigned
    
    localparam [NB_OP-1:0] //! Operation cases
        IDLE_OP = 6'b111111                                                                     ,  
        ADD_OP  = 6'b100000                                                                     , //! R-type add operation
        SUB_OP  = 6'b100010                                                                     , //! R-type sub operation
        SLL_OP  = 6'b000000                                                                     , //! R-type sll operation
        SRL_OP  = 6'b000010                                                                     , //! R-type srl operation
        SRA_OP  = 6'b000011                                                                     , //! R-type sra operation
        SLLV_OP = 6'b000100                                                                     , //! R-type sllv operation
        SRLV_OP = 6'b000110                                                                     , //! R-type srlv operation
        SRAV_OP = 6'b000111                                                                     , //! R-type srav operation
        ADDU_OP = 6'b100001                                                                     , //! R-type addu operation 
        SUBU_OP = 6'b100011                                                                     , //! R-type subu operation
        AND_OP  = 6'b100100                                                                     , //! R-type and operation  
        OR_OP   = 6'b100101                                                                     , //! R-type or operation
        XOR_OP  = 6'b100110                                                                     , //! R-type xor operation
        NOR_OP  = 6'b100111                                                                     , //! R-type nor operation
        SLT_OP  = 6'b101010                                                                     , //! R-type slt operation
        SLTU_OP = 6'b101011                                                                     , //! R-type sltu operation
    
        ADDI_OP  = 6'b001000                                                                    , //! I-type add operation
        ADDIU_OP = 6'b001001                                                                    , //! I-type addiu operation
        ANDI_OP  = 6'b001100                                                                    , //! I-type and operation
        ORI_OP   = 6'b001101                                                                    , //! I-type or operation
        XORI_OP  = 6'b001110                                                                    , //! I-type xor operation
        LUI_OP   = 6'b001111                                                                    , //! I-type lui operation
        SLTI_OP  = 6'b001010                                                                    , //! I-type slti operation
        SLTIU_OP = 6'b001011                                                                    ; //! I-type sltiu operation


    always @(*) begin
        result = 0;
        result_U = 0;
        case(i_operation)
            ADD_OP:   result   = i_datoA + i_datoB                                                  ;
            SUB_OP:   result   = i_datoA - i_datoB                                                  ;
            SLL_OP:   result   = i_datoB << i_shamt                                                 ;
            SRL_OP:   result   = i_datoB >> i_shamt                                                 ;
            SRA_OP:   result   = i_datoB >>> i_shamt                                                ;      
            SLLV_OP:  result   = i_datoB << i_datoA                                                 ;      
            SRLV_OP:  result   = i_datoB >> i_datoA                                                 ;      
            SRAV_OP:  result   = i_datoB >>> i_datoA                                                ;
            ADDU_OP:  result_U = dato_A_u + dato_B_u                                                ;
            SUBU_OP:  result_U = dato_A_u - dato_B_u                                                ;
            AND_OP:   result   = i_datoA & i_datoB                                                  ;
            OR_OP:    result   = i_datoA | i_datoB                                                  ;
            XOR_OP:   result   = i_datoA ^ i_datoB                                                  ;
            NOR_OP:   result   = ~(i_datoA | i_datoB)                                               ;        
            SLT_OP:   result   = (i_datoA < i_datoB) ? 1 : 0                                        ;
            SLTU_OP:  result_U = (dato_A_u < dato_B_u) ? 1 : 0                                      ;
            ADDI_OP:  result   = i_datoA + i_datoB                                                  ;
            ADDIU_OP: result_U = dato_A_u + dato_B_u                                                ;
            ANDI_OP:  result   = i_datoA & i_datoB                                                  ;
            ORI_OP:   result   = i_datoA | i_datoB                                                  ;
            XORI_OP:  result   = i_datoA ^ i_datoB                                                  ;
            LUI_OP:   result   = i_datoB << 16                                                      ;
            SLTI_OP:  result   = (i_datoA < i_datoB) ? 1 : 0                                        ;
            SLTIU_OP: result_U = (dato_A_u < dato_B_u) ? 1 : 0                                      ;                                   
            default: begin
                result   = result                                                                   ;
                result_U = result_U                                                                 ;
            end   
        endcase
    end
                          
    assign is_unsigned = (i_operation == ADDU_OP) || (i_operation == SUBU_OP) || (i_operation == SLTU_OP)
    || (i_operation == SLTIU_OP) || (i_operation == ADDIU_OP);
    assign o_data = is_unsigned ? result_U : result                                             ;


endmodule

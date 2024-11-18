module uart_interface
#(
    NB_DATA   = 8                                                           , //! number bits data
    NB_STOP   = 16                                                          , //! stops at 16 count                               
    NB_32     = 32                                                          , //! parameter for 32 bits
    NB_5      = 5                                                           , //! parameter for 5 bits
    NB_STATES = 4                                                           , //! number of states
    NB_IF_ID  = 96                                                          , //! number of bits for IF_ID
    NB_ID_EX  = 160                                                         , //! number of bits for ID_EX
    NB_EX_MEM = 32                                                          , //! number of bits for EX_MEM
    NB_MEM_WB = 64                                                          , //! number of bits for MEM_WB
    NB_CONTROL = 16                                                           //! number of bits for CONTROL 

)(
    input       wire                            clk                         , //! project clock

    // Tx Rx
    input       wire signed [NB_DATA - 1 : 0]   i_rx                        , //! Input from UART_RX module
    input       wire                            i_rxDone                    , //! UART_RX done bit
    input       wire                            i_txDone                    , //! UART_TX done bit
    input       wire                            i_rst_n                     , //! negative edge reset
    output      wire                            o_tx_start                  ,
    output      wire        [NB_DATA - 1 : 0]   o_data                      , //! Output for UART_TX module

    // Pipeline
    input       wire                            i_end                       , //! End of the program

    // IF_ID
    input       wire        [NB_32 -1 : 0]      i_addr_registers            , //! Register address
    input       wire        [NB_32 -1 : 0]      i_data_registers            , //! Register data
    input       wire        [NB_32 -1 : 0]      i_program_counter           , //! Program counter
    //ID_EX
    input       wire        [NB_32 -1 : 0]      i_register_A                , //! Register A
    input       wire        [NB_32 -1 : 0]      i_register_B                , //! Register B
    input       wire        [6     -1 : 0]      i_opcode                    , //! Opcode
    input       wire        [NB_5  -1 : 0]      i_rs                        , //! rs
    input       wire        [NB_5  -1 : 0]      i_rt                        , //! rt
    input       wire        [NB_5  -1 : 0]      i_rd                        , //! rd
    input       wire        [NB_5  -1 : 0]      i_shamt                     , //! shamt
    input       wire        [6     -1 : 0]      i_funct                     , //! funct
    input       wire        [16    -1 : 0]      i_immediate                 , //! immediate
    input       wire        [26    -1 : 0]      i_jump_address              , //! jump address
    //EX_MEM
    input       wire        [NB_32 -1 : 0]      i_alu_result                , //! ALU result
    //MEM_WB
    input       wire        [NB_32 -1 : 0]      i_data_memory               , //! Memory data
    input       wire        [NB_32 -1 : 0]      i_addr_memory               , //! Memory address
    //Control
    input       wire                            i_jump                      , //! Jump
    input       wire                            i_branch                    , //! Branch
    input       wire                            i_regDst                    , //! RegDst
    input       wire                            i_memToReg                  , //! MemToReg
    input       wire                            i_memRead                   , //! MemRead
    input       wire                            i_memWrite                  , //! MemWrite
    input       wire                            i_inmediate_flag            , //! Inmediate flag
    input       wire                            i_sign_flag                 , //! Sign flag
    input       wire                            i_regWrite                  , //! RegWrite
    input       wire        [2     -1 : 0]      i_aluSrc                    , //! ALU source
    input       wire        [2     -1 : 0]      i_width                     , //! ALU operation
    input       wire        [2     -1 : 0]      i_aluOp                     , //! ALU operation                                      

    // Output
    output      wire        [NB_32 - 1 : 0]     o_instruction               , //! instruction received  
    output      wire        [NB_32 - 1 : 0]     o_instruction_address       , //! address where the instruction is going to be stored
    output      wire                            o_valid                     , //! enable to write
    output      wire                            o_step                      , //! Step for debug mode
    output      wire                            o_start                     , //! Start program for continous mode
    
    // Borrar
    output      wire        [NB_32:0]           o_done_counter              , // sacar esto
    output      wire        [NB_32:0]           o_next_done_counter         , // sacar esto
    output      wire        [NB_STATES-1:0]     o_state                     , //! Output state for UART_TX module;
    output      wire        [NB_IF_ID   -1 : 0] o_concatenated_data_IF_ID     , //! Output data for IF_ID
    output      wire        [NB_ID_EX   -1 : 0] o_concatenated_data_ID_EX     , //! Output data for ID_EX
    output      wire        [NB_EX_MEM  -1 : 0] o_concatenated_data_EX_MEM    , //! Output data for EX_MEM
    output      wire        [NB_MEM_WB  -1 : 0] o_concatenated_data_MEM_WB    , //! Output data for MEM_WB
    output      wire        [NB_CONTROL -1 : 0] o_concatenated_data_CONTROL     //! Output data for CONTROL
);

    // Estados de la máquina de estados
    localparam [NB_STATES -1 : 0] 
    IDLE                  = 4'b0001, 
    PARSE                 = 4'b0010, //! Recibe la instruccion del RX de a 1 byte y cuando esta listo pasa a STOP y valid se pone en 1
    DEBUG_STATE           = 4'b0011, //! Manda señal de step y se envian todos los datos por uart en cada step
    CONTINOUS_STATE       = 4'b0100, //! Se ejecuta todo el programa y luego se envian los datos por uart
    SEND_IF_ID_STATE      = 4'b0101, //! Se envian los datos de IF_ID
    SEND_ID_EX_STATE      = 4'b0110, //! Se envian los datos de ID_EX
    SEND_EX_MEM_STATE     = 4'b0111, //! Se envian los datos de EX_MEM
    SEND_MEM_WB_STATE     = 4'b1000, //! Se envian los datos de MEM_WB
    SEND_CONTROL_STATE    = 4'b1001; //! Se envian los datos de control  

    localparam [7:0]
    RECEIVING_INSTRUCTION = 8'b00000001,
    DEBUG_MODE            = 8'b00000010,
    CONTINOUS_MODE        = 8'b00000100,
    STEP_MODE             = 8'b00001000,
    END_DEBUG_MODE        = 8'b00010000;
    // SENDING_LATCHES       = 8'b00100000,
    // SENDING_REGISTERS     = 8'b01000000,
    // SENDING_MEMORY        = 8'b10000000;

    localparam HALT_INSTR = 32'hffffffff;

    reg [NB_STATES -1 : 0]  state, next_state                                           ;
    reg [NB_32     -1 : 0]  done_counter,next_done_counter                              ;
    reg                     valid, next_valid                                           ;
    reg                     tx_start, next_tx_start                                     ;
    reg [NB_32 - 1 : 0]     instruction_address, next_instruction_address               ;   //! address donde se va a guardar la instrucción           
    reg [NB_32 - 1 : 0]     instruction_register, next_instruction_register             ;   //! instrucción recibida  
    reg                     step, next_step                                             ;
    reg                     debug_flag, next_debug_flag                                 ;
    reg                     start, next_start                                           ; 
    reg [NB_IF_ID   -1 : 0] concatenated_data_IF_ID, next_concatenated_data_IF_ID       ;
    reg [NB_ID_EX   -1 : 0] concatenated_data_ID_EX, next_concatenated_data_ID_EX       ;
    reg [NB_EX_MEM  -1 : 0] concatenated_data_EX_MEM, next_concatenated_data_EX_MEM     ;
    reg [NB_MEM_WB  -1 : 0] concatenated_data_MEM_WB, next_concatenated_data_MEM_WB     ;
    reg [NB_CONTROL -1 : 0] concatenated_data_CONTROL, next_concatenated_data_CONTROL   ;  
    reg [NB_DATA    -1 : 0] tx_data, next_tx_data                                       ; //! data to be sent 

    // wire signed [NB_DATA - 1 : 0]  leds_reg                                 ;

    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state <= IDLE                                                   ;
            done_counter <= 0                                               ;
            valid <= 0                                                      ;                                                    
            tx_start <= 0                                                   ;
            instruction_address <= 0                                        ;
            instruction_register <= 0                                       ;
            step <= 0                                                       ;
            debug_flag <= 0                                                 ;
            start <= 0                                                      ;
            concatenated_data_IF_ID <= 0                                    ;
            concatenated_data_ID_EX <= 0                                    ;
            concatenated_data_EX_MEM <= 0                                   ;
            concatenated_data_MEM_WB <= 0                                   ;
            concatenated_data_CONTROL <= 0                                  ;
            tx_data <= 0                                                    ;
        end else begin              
            state <= next_state                                             ;
            done_counter <= next_done_counter                               ;
            valid <= next_valid                                             ;                                                 
            tx_start <= next_tx_start                                       ;
            instruction_address <= next_instruction_address                 ;  
            instruction_register <= next_instruction_register               ;
            step <= next_step                                               ;
            debug_flag <= next_debug_flag                                   ;
            start <= next_start                                             ;
            concatenated_data_IF_ID <= next_concatenated_data_IF_ID         ;
            concatenated_data_ID_EX <= next_concatenated_data_ID_EX         ;
            concatenated_data_EX_MEM <= next_concatenated_data_EX_MEM       ;
            concatenated_data_MEM_WB <= next_concatenated_data_MEM_WB       ;
            concatenated_data_CONTROL <= next_concatenated_data_CONTROL     ;
            tx_data <= next_tx_data                                         ;
        end
    end

    always @(*) begin
        next_state = state                                          ;
        next_done_counter = done_counter                            ;
        next_valid = 0                                              ;
        next_tx_start = tx_start                                    ;
        next_instruction_address = instruction_address              ;
        next_instruction_register = instruction_register            ;
        next_step = step                                            ;
        next_debug_flag = debug_flag                                ;
        next_start = start                                          ; 
        next_concatenated_data_IF_ID = concatenated_data_IF_ID      ;
        next_concatenated_data_ID_EX = concatenated_data_ID_EX      ;
        next_concatenated_data_EX_MEM = concatenated_data_EX_MEM    ;
        next_concatenated_data_MEM_WB = concatenated_data_MEM_WB    ;
        next_concatenated_data_CONTROL = concatenated_data_CONTROL  ;
        next_tx_data = tx_data                                      ;

        case (state)
            IDLE: begin
                if (i_rxDone) begin 
                    case(i_rx)
                        RECEIVING_INSTRUCTION: next_state  = PARSE              ;
                        DEBUG_MODE:            next_state  = DEBUG_STATE        ; 
                        CONTINOUS_MODE:        next_state  = CONTINOUS_STATE    ; 

                        default:                next_state = IDLE               ;
                    endcase
                    
                end else begin                  
                    next_state = IDLE                                       ;
                    next_done_counter = 0                                   ;
                    next_valid = 0                                          ;
                    next_tx_start = 0                                       ; // Asegúrate de que tx_start se restablezca
                    next_instruction_register = 0                           ;
                    next_instruction_address = 0                            ;
                    next_step = 0                                           ;
                    next_debug_flag = 0                                     ;
                    next_start = 0                                          ;
                    next_concatenated_data_IF_ID = {
                        i_addr_registers, 
                        i_data_registers, 
                        i_program_counter
                    };
                    next_concatenated_data_ID_EX = {
                        i_register_A, 
                        i_register_B, 
                        i_opcode, 
                        i_rs, 
                        i_rt, 
                        i_rd, 
                        i_shamt, 
                        i_funct, 
                        i_immediate, 
                        i_jump_address
                    };
                    next_concatenated_data_EX_MEM = {
                        i_alu_result
                    };
                    next_concatenated_data_MEM_WB = {
                        i_data_memory, 
                        i_addr_memory
                    };
                    next_concatenated_data_CONTROL = {
                        i_jump, 
                        i_branch, 
                        i_regDst, 
                        i_memToReg, 
                        i_memRead, 
                        i_memWrite, 
                        i_inmediate_flag, 
                        i_sign_flag, 
                        i_regWrite, 
                        i_aluSrc, 
                        i_width, i_aluOp
                    };
                    next_tx_data = 0                                        ;
                end
            end

            PARSE: begin
                if (i_rxDone) begin // Recibe la instrucción de 32 bits, un byte a la vez
                    next_done_counter = done_counter + 1;
                    next_instruction_register = {instruction_register[24:0], i_rx}; // Se van concatenando los datos
                end
                if (done_counter == 4) begin
                    if (instruction_register == HALT_INSTR) begin
                        next_state = IDLE;
                    end else begin
                        next_valid = 1; // se habilita para escribir
                        next_instruction_address = instruction_address + 4;                        
                    end
                    next_done_counter = 0;
                end
            end

            DEBUG_STATE: begin
                if(i_rxDone) begin
                    next_debug_flag = 1;
                    case(i_rx)
                        STEP_MODE: begin
                            next_step = 1;
                            next_state = SEND_IF_ID_STATE;
                        end
                        END_DEBUG_MODE: begin
                            next_debug_flag = 0;
                            next_state = SEND_IF_ID_STATE; // que igual se manden los registros xlas
                        end
                        default: begin
                            next_step = 0;
                        end
                    endcase
                end
            end

            CONTINOUS_STATE: begin
                next_start = 1;
                if(i_end) begin
                    next_state = SEND_IF_ID_STATE;
                end
            end

            SEND_IF_ID_STATE: begin
                if (i_txDone) begin
            
                    next_tx_start = 1;
                    next_tx_data = concatenated_data_IF_ID[done_counter * 8 +: 8];
                    next_done_counter = done_counter + 1;
            
                    if (done_counter == 11) begin
                        next_state = SEND_ID_EX_STATE;
                        next_done_counter = 0;
                        next_tx_start = 0;
                    end
                end
            end
            
            SEND_ID_EX_STATE: begin
                if (i_txDone) begin
                               
                    next_tx_start = 1;
                    next_tx_data = concatenated_data_ID_EX[done_counter * 8 +: 8];
                    next_done_counter = done_counter + 1;
            
                    if (done_counter == 19) begin
                        next_state = SEND_EX_MEM_STATE;
                        next_done_counter = 0;
                        next_tx_start = 0;
                    end
                end
            end
            
            SEND_EX_MEM_STATE: begin
                if (i_txDone) begin
            
                    next_tx_start = 1;
                    next_tx_data = concatenated_data_EX_MEM[done_counter * 8 +: 8];
                    next_done_counter = done_counter + 1;
            
                    if (done_counter == 3) begin
                        next_state = SEND_MEM_WB_STATE;
                        next_done_counter = 0;
                        next_tx_start = 0;
                    end
                end
            end
            
            SEND_MEM_WB_STATE: begin
                if (i_txDone) begin
            
                    next_tx_start = 1;
                    next_tx_data = concatenated_data_MEM_WB[done_counter * 8 +: 8];
                    next_done_counter = done_counter + 1;
            
                    if (done_counter == 7) begin
                        next_state = SEND_CONTROL_STATE;
                        next_done_counter = 0;
                        next_tx_start = 0;
                    end
                end
            end
            
            SEND_CONTROL_STATE: begin
                if (i_txDone) begin

                    next_tx_start = 1;
                    next_tx_data = concatenated_data_CONTROL[done_counter * 8 +: 8];
                    next_done_counter = done_counter + 1;
            
                    if (done_counter == 1) begin
                        if (debug_flag) begin
                            next_state = DEBUG_STATE;
                        end else begin
                            next_state = IDLE;
                        end
                        next_done_counter = 0;
                        next_tx_start = 0;
                    end
                end
            end
            

            default: begin
                next_state                     = next_state                     ;
                next_valid                     = next_valid                     ;
                next_done_counter              = next_done_counter              ;
                next_tx_start                  = next_tx_start                  ;
                next_instruction_address       = next_instruction_address       ;
                next_instruction_register      = next_instruction_register      ;
                next_step                      = next_step                      ;
                next_debug_flag                = next_debug_flag                ;
                next_start                     = next_start                     ;
                next_concatenated_data_IF_ID   = next_concatenated_data_IF_ID   ;
                next_concatenated_data_ID_EX   = next_concatenated_data_ID_EX   ;
                next_concatenated_data_EX_MEM  = next_concatenated_data_EX_MEM  ;
                next_concatenated_data_MEM_WB  = next_concatenated_data_MEM_WB  ;
                next_concatenated_data_CONTROL = next_concatenated_data_CONTROL ;
                next_tx_data                   = next_tx_data                   ;
            end
        endcase
    end

        // assign
        assign o_instruction            = instruction_register          ; // Se pasa la instrucción que se recibe
        assign o_instruction_address    = instruction_address           ; // No entiendo bien xq se pasa el address
        assign o_valid                  = valid                         ; // Se habilita para que se escriba en el IF
        assign o_tx_start               = tx_start                      ;
        assign o_data                   = tx_data                       ;
        assign o_step                   = step                          ;
        assign o_start                  = start                         ;
        assign o_state                  = state                         ; // Despues sacarlo de aca
        assign o_done_counter           = done_counter                  ; // Despues sacarlo de aca
        assign o_next_done_counter      = next_done_counter             ; // Despues sacarlo de aca
        assign o_concatenated_data_IF_ID  = next_concatenated_data_IF_ID ; // Despues sacarlo de aca
        assign o_concatenated_data_ID_EX  = next_concatenated_data_ID_EX ; // Despues sacarlo de aca
        assign o_concatenated_data_EX_MEM = next_concatenated_data_EX_MEM; // Despues sacarlo de aca
        assign o_concatenated_data_MEM_WB = next_concatenated_data_MEM_WB; // Despues sacarlo de aca
        assign o_concatenated_data_CONTROL = next_concatenated_data_CONTROL; // Despues sacarlo de aca
    endmodule
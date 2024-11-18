module uart_interface
#(
    NB_DATA   = 8                                                            , //! number bits data
    NB_STOP   = 16                                                           , //! stops at 16 count                               
    NB_32     = 32                                                           , //! parameter for 32 bits
    NB_IF_ID  = 64                                                           , //! VER ESTE VALOR
    NB_ID_EX  = 168                                                          , //! VER ESTE VALOR
    NB_EX_MEM = 88                                                           , //! VER ESTE VALOR                                           
    NB_MEM_WB = 80                                                             //! VER ESTE VALOR
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
    input       wire        [NB_32 -1 : 0]      i_data_memory               , //! Data memory
    input       wire        [NB_32 -1 : 0]      i_data_registers            , //! Registers
    input       wire        [NB_IF_ID -1 : 0]   i_if_id                     , //! IF/ID pipeline register
    input       wire        [NB_ID_EX -1 : 0]   i_id_ex                     , //! ID/EX pipeline register
    input       wire        [NB_EX_MEM -1 : 0]  i_ex_mem                    , //! EX/MEM pipeline register
    input       wire        [NB_MEM_WB -1 : 0]  i_mem_wb                    , //! MEM/WB pipeline register

    output      wire        [NB_32 - 1 : 0]     o_instruction               , //! instruction received  
    output      wire        [NB_32 - 1 : 0]     o_instruction_address       , //! address where the instruction is going to be stored
    output      wire                            o_valid                     , //! enable to write
    output      wire                            o_step                      , //! Step for debug mode
    output      wire                            o_start                       //! Start program for continous mode
    
    // Borrar
    output      wire        [NB_32:0]           o_done_counter              , // sacar esto
    output      wire        [NB_32:0]           o_next_done_counter         , // sacar esto
    output      wire        [2:0]               o_state                     , //! Output state for UART_TX module;
);

    // Estados de la máquina de estados
    localparam [2:0] 
    IDLE                  = 3'b001, 
    PARSE                 = 3'b010, //! Recibe la instruccion del RX de a 1 byte y cuando esta listo pasa a STOP y valid se pone en 1
    DEBUG_STATE           = 3'b011, //! Manda señal de step y se envian todos los datos por uart en cada step
    CONTINOUS_STATE       = 3'b100, //! Se ejecuta todo el programa y luego se envian los datos por uart
    LATCHES_STATE         = 3'b101, //! Se envian los datos de los latches
    REGISTERS_STATE       = 3'b110, //! Se envian los datos de los registros
    MEMORY_STATE          = 3'b111; //! Se envian los datos de la memoria

    localparam [7:0]
    RECEIVING_INSTRUCTION = 8'b00000001,
    DEBUG_MODE            = 8'b00000010,
    CONTINOUS_MODE        = 8'b00000100,
    STEP_MODE             = 8'b00001000,
    END_DEBUG_MODE        = 8'b00010000;
    SENDING_LATCHES       = 8'b00100000;
    SENDING_REGISTERS     = 8'b01000000;
    SENDING_MEMORY        = 8'b10000000;

    localparam HALT_INSTR = 32'hffffffff;

    reg [2:0]               state, next_state                               ;
    reg [2:0]               done_counter,next_done_counter                  ;
    reg                     valid, next_valid                               ;
    reg                     tx_start, next_tx_start                         ;
    reg [NB_32 - 1 : 0]     instruction_address, next_instruction_address   ;   //! address donde se va a guardar la instrucción           
    reg [NB_32 - 1 : 0]     instruction_register, next_instruction_register ;   //! instrucción recibida  
    reg                     step, next_step                                 ;
    reg                     debug_flag, next_debug_flag                     ;
    reg                     start, next_start                               ;    

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
        end
    end

    always @(*) begin
        next_state = state;
        next_done_counter = done_counter;
        next_valid = 0;
        next_tx_start = tx_start;
        next_instruction_address = instruction_address;
        next_instruction_register = instruction_register;
        next_step = step;
        next_debug_flag = debug_flag;
        next_start = start;

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
                            next_state = LATCHES_STATE;
                        end
                        END_DEBUG_MODE: begin
                            next_debug_flag = 0;
                            next_state = LATCHES_STATE; // que igual se manden los registros xlas
                        end
                        default: begin
                            next_step = 0;
                        end
                    endcase
                end
            end

            CONTINOUS_STATE: begin
                if(i_end) begin
                    next_state = LATCHES_STATE;
                end
            end

            LATCHES_STATE: begin
                


                next_state = REGISTERS_STATE;
            end

            REGISTERS_STATE: begin
                next_state = MEMORY_STATE;
            end

            MEMORY_STATE: begin
                if(debug_flag) begin
                    next_state = DEBUG_STATE;
                end else begin
                    next_state = IDLE; 
                end
            end

            default: begin
                next_state                  = next_state                ;
                next_valid                  = next_valid                ;
                next_done_counter           = next_done_counter         ;
                next_tx_start               = next_tx_start             ;
                next_instruction_address    = next_instruction_address  ;
                next_instruction_register   = next_instruction_register ;
                next_step                   = next_step                 ;
                next_debug_flag             = next_debug_flag           ;
                next_start                  = next_start                ;
            end
        endcase
    end

        // assign
        assign o_instruction            = instruction_register          ; // Se pasa la instrucción que se recibe
        assign o_instruction_address    = instruction_address           ; // No entiendo bien xq se pasa el address
        assign o_valid                  = valid                         ; // Se habilita para que se escriba en el IF
        assign o_tx_start               = tx_start                      ;
        assign o_state                  = state                         ; // Despues sacarlo de aca
        assign o_done_counter           = done_counter                  ; // Despues sacarlo de aca
        assign o_next_done_counter      = next_done_counter             ; // Despues sacarlo de aca
    endmodule
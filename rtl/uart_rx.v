/*
    
    Secuencia de estados Rx
    ◼ Asumiendo N bits de datos, M bits de Stop.
        1) Esperar a que la señal de entrada sea 0, momento en el
        que inicia el bit de Start. Iniciar el Tick Counter. ---> state0

        2) Cuando el contador llega a 7, la señal de entrada está en
        el punto medio del bit de Start. Reinicar el contador. ---> state1
        
        3) Cuando el contador llega a 15, la señal de entrada avanza
        1 bit, y alcanza la mitad del primer bit de datos. Tomar este
        valor e ingresarlo en un shift register. Reinicar el contador.---> state2
        
        4) Repetir el paso 3 N-1 veces para tomar los bits restantes.
        
        5) Si se usa bit de paridad, repetir el paso 3 una vez mas.
        
        6) Reperir el paso 3 M veces, para obtener los bits de Stop. --->state3
*/

module uart_rx
#(
    parameter NB_DATA  = 8                                                    ,
    parameter NB_STOP  = 16 //stops at 16 count
)(
    input   wire                    clk                             ,
    input   wire                    i_rst_n                         ,
    input   wire                    i_tick                          ,
    input   wire                    i_data                          , //! i_rx
    output  wire [NB_DATA - 1 : 0]  o_data                          ,
    output  wire                    o_rxdone
);


    reg [3:0]   tick_counter                                        ; //! tick counter
    reg [3:0]   next_tick_counter                                   ; //! next value of tick_counter

    reg [3:0]                     state, next_state                 ;

    reg [3:0]   recBits                                             ; //! received bits
    reg [3:0]   next_recBits                                        ;

    reg [NB_DATA-1:0]             recByte                           ; //! received frame
    reg [NB_DATA-1:0]             next_recByte                      ;

    reg                           done_bit, next_done_bit           ;

    localparam [3:0]    //! states
                    IDLE    = 4'b0001,
                    START   = 4'b0010,
                    RECEIVE = 4'b0100,
                    STOP    = 4'b1000; 


    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state <= IDLE                                           ;
            tick_counter <= 0                                       ;
            recBits  <= 0                                           ;
            recByte  <= 8'b00000000                                 ;
            done_bit <= 0                                           ;
        end else begin              
            state <= next_state                                     ;
            tick_counter <= next_tick_counter                       ;
            recBits <= next_recBits                                 ;
            recByte <= next_recByte                                 ;
            done_bit <= next_done_bit;

        end
    end

    // state machine
    always @(*) begin
        next_state = state;
        next_tick_counter = tick_counter;
        next_recBits = recBits;
        next_recByte = recByte;
        next_done_bit = done_bit; 

        case (state) 
            IDLE: begin
                next_done_bit = 0; 
                if(!i_data) begin
                    next_state = START                              ;
                    next_tick_counter = 0                           ;
                end
            end
            START: begin
                if(i_tick) begin
                    if(tick_counter == 7) begin
                        next_state        = RECEIVE                 ;
                        next_tick_counter = 0                       ;
                        next_recBits      = 0                       ;
                        
                    end else begin 
                        next_tick_counter = tick_counter + 1        ;
                    end
                end
            end
            RECEIVE: begin
                if(i_tick) begin
                    if(tick_counter == 15) begin 
                        next_tick_counter = 0                       ;
                        next_recByte = {i_data, recByte[NB_DATA-1:1]}    ; // shiftregister
                        if(recBits == (NB_DATA-1)) begin 
                            next_state = STOP                       ;
                        end else begin 
                            next_recBits = recBits + 1              ;
                        end
                    end else begin 
                        next_tick_counter = tick_counter + 1        ;
                    end
                end
                
            end
            STOP: begin
                if(i_tick) begin
                    if(tick_counter == (NB_STOP-1)) begin
                        next_state = IDLE                           ;
                        if(i_data) next_done_bit = 1                ;
                    end else begin
                        next_tick_counter = tick_counter + 1        ;
                    end
                end
                
            end
            default: begin 
                next_state = IDLE                                   ;

            end
        endcase
    end

    assign o_data   = recByte   ; // output frame
    assign o_rxdone = done_bit  ;
    
//    function integer clogb2;
//    input integer value;
//    for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
//        value = value >> 1;
//    end
//    endfunction

endmodule

module uart_tx
#(
    parameter NB_DATA = 8,
    parameter NB_STOP = 16
)(
    input   wire                    clk                                  ,
    input   wire                    i_rst_n                              ,
    input   wire                    i_tick                               ,
    input   wire                    i_start_tx                           ,
    input   wire [NB_DATA - 1 : 0]  i_data                               ,
    output  wire                    o_txdone                             ,
    output  wire                    o_data

);


    reg [3:0]   tick_counter                                            ; //! tick counter
    reg [3:0]   next_tick_counter                                       ; //! next value of tick_counter

    reg [3:0]                     state, next_state                     ;

    reg [2:0]   txBits                                                  ; //! txeived bits clogb2(NB_DATA-1)
    reg [2:0]   next_txBits                                             ;
    
    reg [NB_DATA-1:0]             txByte                                ; //! txeived frame
    reg [NB_DATA-1:0]             next_txByte                           ;
    
    reg                           done_bit, next_done_bit               ;
    reg                           tx_reg, next_tx                       ;
    
    //reg [3:0] state;
    localparam [3:0]    //! states
                    IDLE     = 4'b0001,
                    START    = 4'b0010,
                    TRANSMIT = 4'b0100,
                    STOP     = 4'b1000; 



    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state <= IDLE                                               ;
            tick_counter <= 0                                           ;
            txBits  <= 0                                                ;
            txByte  <= 0                                                ;
            done_bit <= 0                                               ;
            tx_reg <= 1'b1                                              ;
        end else begin                  
            state <= next_state                                         ;
            tick_counter <= next_tick_counter                           ;
            txBits <= next_txBits                                       ;
            txByte <= next_txByte                                       ;
            tx_reg <= next_tx                                           ;
            done_bit <= next_done_bit                                   ;

        end
    end

    always @(*) begin
        next_done_bit = 1'b0                                            ;
        next_state = state                                              ;
        next_tick_counter = tick_counter                                ;
        next_txBits = txBits                                            ;
        next_txByte = txByte                                            ;
        next_tx = tx_reg                                                ;
        
        case (state)
            IDLE: begin
                next_tx = 1'b1                                          ;
                if(i_start_tx) begin
                    next_state = START                                  ;
                    next_tick_counter = 0                               ;
                    next_txByte = i_data                                ; //loads the buffer
                end
            end

            START: begin
                next_tx = 1'b0                                          ;
                if(i_tick) begin
                    if(tick_counter == (NB_STOP -1)) begin

                        next_state = TRANSMIT                           ;
                        next_tick_counter = 0                           ;
                        next_txBits = 0                                 ; 

                    end else begin
                        next_tick_counter = tick_counter + 1            ;
                    end
                end
            end

            TRANSMIT: begin
                next_tx = txByte[0]                                     ;
                if(i_tick) begin 
                    if(tick_counter == (NB_STOP - 1)) begin
                        next_tick_counter = 0                           ;
                        next_txByte = txByte >> 1                       ;
                        if(txBits == (NB_DATA -1)) begin
                            next_state = STOP                           ;

                        end else begin
                            next_txBits = txBits + 1                    ;
                        end
                    end else begin
                        next_tick_counter = tick_counter + 1            ;
                    end
                end
            end

            STOP: begin 
                next_tx= 1'b1                                           ;
                if(i_tick) begin
                    if(tick_counter == (NB_STOP-1)) begin
                        next_state = IDLE                               ;
                        next_done_bit = 1'b1                            ;
                    end
                    else begin 
                        next_tick_counter = tick_counter + 1            ;
                    end
                end
            end
            default: begin
                next_state          = IDLE                              ;

            end

        endcase
    end


    assign o_data = tx_reg                                              ;
    assign o_txdone = done_bit                                          ;

endmodule

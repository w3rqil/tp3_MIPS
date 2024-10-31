module baudrate_generator
#(
    parameter BAUD_RATE = 19200,
    parameter CLK_FREQ = 100_000_000,
    parameter OVERSAMPLING = 16
   // parameter NB_COUNTER = 8

)(
    input   wire clk                                                    ,
    input   wire i_rst_n                                                ,
    output  wire o_tick                                                   //! tick que se genera cada NC_PER_TICK

);
localparam NC_PER_TICK = CLK_FREQ / BAUD_RATE / OVERSAMPLING        ;
localparam NB_COUNTER = 8;
reg [NB_COUNTER:0] counter                                            ;

always @(posedge clk or negedge i_rst_n) begin
    if(!i_rst_n) begin 
        counter <= {NB_COUNTER {1'b0}}                                  ;
    end else begin
        if(counter == NC_PER_TICK) counter <= {NB_COUNTER {1'b0}}       ;
        else                       counter <= counter + 1               ;
    end
end

assign o_tick = (counter == NC_PER_TICK)                               ;

  
endmodule
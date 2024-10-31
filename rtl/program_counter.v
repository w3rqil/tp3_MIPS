module program_counter 
#(
    parameter NB_WIDTH = 32

)(
    input   wire                    clk             ,
    input   wire                    i_rst_n         ,
    input   wire    [NB_WIDTH-1:0]  i_addr2jump     ,
    input   wire                    i_valid         ,
    output  reg     [NB_WIDTH-1:0]  o_pcounter      ,
    output  reg     [NB_WIDTH-1:0]  o_pcounter4     ,
    input   wire                    i_halt          ,
    input   wire                    i_stall
);


    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            o_pcounter  <= 0                        ;
            o_pcounter4 <= 0                        ;
        end
        else if (!i_halt && !i_stall) begin
            if(i_valid) begin
                o_pcounter  <= i_addr2jump          ;
                o_pcounter4 <= i_addr2jump + 4      ;
            end else begin
                o_pcounter  <= o_pcounter           ;
                o_pcounter4 <= o_pcounter4          ;
            end
        end
    end

endmodule
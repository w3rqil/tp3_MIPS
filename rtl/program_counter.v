module program_counter 
#(
    parameter NB_WIDTH = 32
)(
    input   wire                    clk,
    input   wire                    i_rst_n,
    input   wire    [NB_WIDTH-1:0]  i_addr2jump,
    input   wire                    i_valid,   // pc <= addr2jump (for jumps)
    output  reg     [NB_WIDTH-1:0]  o_pcounter,
    output  wire     [NB_WIDTH-1:0] o_pcounter4, // Change to wire
    input   wire                    i_halt,
    input   wire                    i_stall
);

    // o_pcounter4 is always o_pcounter + 4
    assign o_pcounter4 = o_pcounter + 4;

    always @(posedge clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_pcounter <= 0;        // Reset PC to 0
        end
        else if (!i_halt && !i_stall) begin
            if (i_valid) begin
                // Jump to address in i_addr2jump
                o_pcounter <= i_addr2jump;
            end else begin
                // Normal increment by 4
                o_pcounter <= o_pcounter + 4;
            end
        end
    end
endmodule

module program_counter (
    input   wire                    clk,
    input   wire                    i_rst_n,
    input   wire    [32-1:0]  i_addr2jump,
    input   wire                    i_jump,   // pc <= addr2jump (for jumps)
    output  reg     [32-1:0]  o_pcounter,
    output  reg     [32-1:0] o_pcounter4, // Change to wire
    
    input   wire                    i_halt,
    input   wire                    i_stall
);

    // o_pcounter4 is always o_pcounter + 4
    //assign o_pcounter4 = o_pcounter + 4;

    always @(posedge clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_pcounter <= 32'b0;        // Reset PC to 0
            o_pcounter4 <=4;
        end
        else if (!i_halt && !i_stall) begin
            if (i_jump) begin
                // Jump to address in i_addr2jump
                o_pcounter <= i_addr2jump;
            end else begin
                // Normal increment by 4
                o_pcounter <= o_pcounter + 4;
                o_pcounter4 <= o_pcounter + 8;
            end
        end
    end
endmodule

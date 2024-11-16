`timescale 1ns/1ps

module tb_instruction_fetch;

    // Parameters and Registers for Inputs
    reg clk;
    reg i_rst_n;
    reg i_jump;
    reg i_we;
    reg [31:0] i_addr2jump;
    reg [31:0] i_instr_data;
    reg i_halt;
    reg i_stall;

    // Outputs
    wire [31:0] o_pcounter4;
    wire [31:0] o_pcounter;
    wire [31:0] o_instruction;

    // Instantiate the instruction_fetch module
    instruction_fetch uut (
        .clk         (clk),
        .i_rst_n     (i_rst_n),
        .i_jump     (i_jump),
        .i_we        (i_we),
        .i_addr2jump (i_addr2jump),
        .i_instr_data(i_instr_data),
        .i_halt      (i_halt),  
        .i_stall     (i_stall),
        .o_pcounter4 (o_pcounter4),
        .o_instruction(o_instruction),
        .o_pcounter    (o_pcounter)
    );

    // Clock Generation
    initial clk = 0;
    always #10 clk = ~clk;  // 10ns clock period

    // Test sequence
    initial begin
        // Initialize Inputs
        i_rst_n = 0;
        i_jump = 0;
        i_we = 0;
        i_addr2jump = 0;
        i_instr_data = 0;
        i_halt = 0;
        i_stall = 0;
        #200;

        // Reset sequence
        repeat(5) @(posedge clk);
        i_rst_n = 1;

        i_we = 1;
        i_instr_data = 32'h88888888;
        @(posedge clk);
        i_we = 0;

        i_we = 1;
        i_instr_data = 32'hFFFFFFFF;
        @(posedge clk);
        i_we = 0;

        i_we = 1;
        i_instr_data = 32'hA8A8A8A8;
        @(posedge clk);
        i_we = 0;

        i_we = 1;
        i_instr_data = 32'hAAAAAAAA;
        @(posedge clk);
        i_we = 0;

        i_we = 1;
        i_instr_data = 32'h0000FFFF;
        @(posedge clk);
        i_we = 0;

        // Sequential fetch tests starting from address 0x00 without using display
        @(posedge clk);
        i_rst_n = 0; 
        @(posedge clk);
        i_rst_n = 1;
        repeat(3) @(posedge clk);

        // jump to 0xC0
        i_addr2jump = 32'h40;
        i_jump = 1;
        @(posedge clk);
        i_jump = 0;

        @(posedge clk);
        //i_rst_n = 0; 
        @(posedge clk); 
        i_rst_n = 1;

        // stall
        i_stall = 1;
        @(posedge clk);
        i_stall = 0;

        repeat(12) @(posedge clk);
        $stop;

    end

endmodule

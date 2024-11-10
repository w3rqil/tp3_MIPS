`timescale 1ns/1ps

module tb_instruction_fetch;

    // Parameters and Registers for Inputs
    reg clk;
    reg i_rst_n;
    reg i_valid;
    reg i_we;
    reg [31:0] i_addr2jump;
    reg [31:0] i_instr_data;
    reg i_halt;
    reg i_stall;

    // Outputs
    wire [31:0] o_pcounter4;
    wire [31:0] o_instruction;

    // Instantiate the instruction_fetch module
    instruction_fetch uut (
        .clk         (clk),
        .i_rst_n     (i_rst_n),
        .i_valid     (i_valid),
        .i_we        (i_we),
        .i_addr2jump (i_addr2jump),
        .i_instr_data(i_instr_data),
        .i_halt      (i_halt),
        .i_stall     (i_stall),
        .o_pcounter4 (o_pcounter4),
        .o_instruction(o_instruction)
    );

    // Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns clock period

    // Test sequence
    initial begin
        // Initialize Inputs
        i_rst_n = 0;
        i_valid = 0;
        i_we = 0;
        i_addr2jump = 0;
        i_instr_data = 0;
        i_halt = 0;
        i_stall = 0;

        // Reset sequence
        #15 i_rst_n = 1;

        i_we = 1;
        i_instr_data = 32'h88888888;
        #10;
        i_we = 0;

        i_we = 1;
        i_instr_data = 32'hFFFFFFFF;
        #10;
        i_we = 0;

        i_we = 1;
        i_instr_data = 32'hA8A8A8A8;
        #10;
        i_we = 0;

        i_we = 1;
        i_instr_data = 32'hAAAAAAAA;
        #10;
        i_we = 0;

        i_we = 1;
        i_instr_data = 32'h0000FFFF;
        #10;
        i_we = 0;



        // Re-reset to ensure program counter starts from 0x00 for fetch
        #20;
        i_rst_n = 0; 
        #10; 
        i_rst_n = 1;
        $display("Program Counter reset to 0. Beginning fetch sequence...");

        // Sequential fetch tests starting from address 0x00 without using display
        #30;

        #20;
        i_rst_n = 0; 
        #10; 
        i_rst_n = 1;

        // jump to 0xC0
        i_addr2jump = 32'h10;
        i_valid = 1;
        #10;
        i_valid = 0;

        #20;
        i_rst_n = 0; 
        #10; 
        i_rst_n = 1;

        // stall
        i_stall = 1;
        #10;
        i_stall = 0;

    end

endmodule

`timescale 1ns / 1ps

module tb_program_counter;

    // Parameters
    localparam NB_WIDTH = 32;

    // Inputs
    reg clk;
    reg i_rst_n;
    reg [NB_WIDTH-1:0] i_addr2jump;
    reg i_jump;
    reg i_halt;
    reg i_stall;

    // Outputs
    wire [NB_WIDTH-1:0] o_pcounter;
    wire [NB_WIDTH-1:0] o_pcounter4;

    // Instantiate the program_counter module
    program_counter  uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_addr2jump(i_addr2jump),
        .i_jump(i_jump),
        .o_pcounter(o_pcounter),
        //.o_pcounter4(o_pcounter4),
        .i_halt(i_halt),
        .i_stall(i_stall)
    );

    // Clock generation
    always #10 clk = ~clk; // 10ns clock period
    

    // Test procedure
    initial begin
        // Initialize inputs
        clk = 0;
        i_rst_n = 0;
        i_jump = 0;
        i_addr2jump = 0;
        i_halt = 0;
        i_stall = 1;
        #100

        // Apply reset and observe the initial state
        @(posedge clk);
        i_rst_n = 1;
        
        // Add a delay right after reset to observe the initial PC value
        
        //$display("After reset: PC = %h, PC+4 = %h", o_pcounter, o_pcounter4);

        // ** Test 1: Normal increment (PC + 4) **
        // Expected behavior: PC should start at 0 and increment by 4
        i_halt = 0;
        i_stall = 0;
        i_jump = 0;
        
        //$display("Test 1: PC = %h, PC+4 = %h", o_pcounter, o_pcounter4);
        
        repeat (5) @(posedge clk);
        //$display("Test 1 (next cycle): PC = %h, PC+4 = %h", o_pcounter, o_pcounter4);

        // ** Test 2: Jump to address 0x20 **
        // Expected behavior: PC should jump to 0x20, and PC+4 should be 0x24
        //i_jump = 1;
        i_addr2jump = 32'h00000020;
        @(posedge clk);
        i_jump = 0; // Reset valid signal
        //$display("Test 2: Jump to 0x20, PC = %h, PC+4 = %h", o_pcounter, o_pcounter4);

        // ** Test 3: Halt signal **
        // Expected behavior: PC should remain at its current value when halted
        //i_halt = 1;
        @(posedge clk);
        //$display("Test 3: Halt, PC = %h, PC+4 = %h", o_pcounter, o_pcounter4);
        
        // Release halt
        i_halt = 0;
        @(posedge clk);
        //$display("Test 3 (after halt release): PC = %h, PC+4 = %h", o_pcounter, o_pcounter4);

        // ** Test 4: Stall signal **
        // Expected behavior: PC should hold its current value while stalled
        //i_stall = 1;
        @(posedge clk);
        //$display("Test 4: Stall, PC = %h, PC+4 = %h", o_pcounter, o_pcounter4);

        // Release stall
        i_stall = 0;
        @(posedge clk);
        //$display("Test 4 (after stall release): PC = %h, PC+4 = %h", o_pcounter, o_pcounter4);
        repeat(10) @(posedge clk);
        // End of simulation
        $stop;
    end
endmodule

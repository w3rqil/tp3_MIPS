`timescale 1ns / 1ps

module tb_write_back;

    // Parameters
    parameter NB_DATA = 32;
    parameter NB_ADDR = 5;
    parameter NB_REG  = 1;

    // Inputs (reg)
    reg clk;
    reg [NB_DATA-1: 0] i_reg_read;
    reg [NB_DATA-1: 0] i_ALUresult;
    reg [4:0] i_reg2write;
    reg i_mem2reg;
    reg i_regWrite;

    // Outputs (wire)
    wire [NB_DATA-1: 0] o_write_data;
    wire [4:0] o_reg2write;
    wire o_regWrite;

    // Instantiate the write_back module
    write_back #(
        .NB_DATA(NB_DATA),
        .NB_ADDR(NB_ADDR),
        .NB_REG(NB_REG)
    ) uut (
        .i_reg_read(i_reg_read),
        .i_ALUresult(i_ALUresult),
        .i_reg2write(i_reg2write),
        .i_mem2reg(i_mem2reg),
        .i_regWrite(i_regWrite),
        .o_write_data(o_write_data),
        .o_reg2write(o_reg2write),
        .o_regWrite(o_regWrite)
    );

    
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 100 MHz clock
    end
    

    // Test procedure
    initial begin
        // Initialize inputs
        i_reg_read = 32'h00000000;
        i_ALUresult = 32'h00000000;
        i_reg2write = 5'd0;
        i_mem2reg = 0;
        i_regWrite = 0;
        #200;

        // Wait for a short time and then apply stimulus
        @(posedge clk);
        
        // Test Case 1: Write ALU result
        i_ALUresult = 32'h12345678;
        i_mem2reg = 0;  // Select ALU result
        i_regWrite = 1; // Enable write
        i_reg2write = 5'd10;
        @(posedge clk);
        $display("Test Case 1: Write ALU result");
        $display("o_write_data = %h, o_reg2write = %d, o_regWrite = %b", o_write_data, o_reg2write, o_regWrite);

        // Test Case 2: Write data from memory
        i_reg_read = 32'h87654321;
        i_mem2reg = 1;  // Select data from memory
        i_regWrite = 1; // Enable write
        i_reg2write = 5'd15;
        @(posedge clk);
        $display("Test Case 2: Write data from memory");
        $display("o_write_data = %h, o_reg2write = %d, o_regWrite = %b", o_write_data, o_reg2write, o_regWrite);

        // Test Case 3: Disable write
        i_regWrite = 0; // Disable write
        @(posedge clk);
        $display("Test Case 3: Disable write");
        $display("o_write_data = %h, o_reg2write = %d, o_regWrite = %b", o_write_data, o_reg2write, o_regWrite);

        // End of simulation
        $stop;
    end

endmodule

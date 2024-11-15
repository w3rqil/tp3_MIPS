`timescale 1ns / 1ps

module tb_instruction_execute;

    // Testbench parameters
    parameter NB_DATA = 32;

    // Clock and reset signals
    reg clk;
    reg i_rst_n;

    // Input signals
    reg i_stall;
    reg i_halt;
    reg [4:0] i_rs;
    reg [4:0] i_rt;
    reg [4:0] i_rd;
    reg [NB_DATA-1:0] i_reg_DA;
    reg [NB_DATA-1:0] i_reg_DB;
    reg [NB_DATA-1:0] i_immediate;
    reg [5:0] i_opcode;
    reg [4:0] i_shamt;
    reg [5:0] i_func;
    reg [15:0] i_addr;
    
    // Control unit signals
    reg i_jump;
    reg i_branch;
    reg i_regDst;
    reg i_mem2Reg;
    reg i_memRead;
    reg i_memWrite;
    reg i_immediate_flag;
    reg i_regWrite;
    reg [1:0] i_aluSrc;
    reg [1:0] i_aluOP;
    reg [1:0] i_width;
    reg i_sign_flag;

    // Forwarding unit signals
    reg [1:0] i_fw_a;
    reg [1:0] i_fw_b;

    // Output signals
    wire o_mem2reg;
    wire o_memRead;
    wire o_memWrite;
    wire o_regWrite;
    wire [1:0] o_aluSrc;
    wire o_jump;
    wire o_sign_flag;
    wire [1:0] o_width;
    wire [4:0] o_write_reg;
    wire [2:1] o_aluOP;
    wire [NB_DATA-1:0] o_data4Mem;
    wire [NB_DATA-1:0] o_result;

    // Instantiate the instruction_execute module
    instruction_execute #(
        .NB_DATA(NB_DATA)
    ) uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_stall(i_stall),
        .i_halt(i_halt),
        .i_rs(i_rs),
        .i_rt(i_rt),
        .i_rd(i_rd),
        .i_reg_DA(i_reg_DA),
        .i_reg_DB(i_reg_DB),
        .i_immediate(i_immediate),
        .i_opcode(i_opcode),
        .i_shamt(i_shamt),
        .i_func(i_func),
        .i_addr(i_addr),
        .i_jump(i_jump),
        .i_branch(i_branch),
        .i_regDst(i_regDst),
        .i_mem2Reg(i_mem2Reg),
        .i_memRead(i_memRead),
        .i_memWrite(i_memWrite),
        .i_immediate_flag(i_immediate_flag),
        .i_regWrite(i_regWrite),
        .i_aluSrc(i_aluSrc),
        .i_aluOP(i_aluOP),
        .i_width(i_width),
        .i_sign_flag(i_sign_flag),
        .i_fw_a(i_fw_a),
        .i_fw_b(i_fw_b),
        .o_mem2reg(o_mem2reg),
        .o_memRead(o_memRead),
        .o_memWrite(o_memWrite),
        .o_regWrite(o_regWrite),
        .o_aluSrc(o_aluSrc),
        .o_jump(o_jump),
        .o_sign_flag(o_sign_flag),
        .o_width(o_width),
        .o_write_reg(o_write_reg),
        .o_aluOP(o_aluOP),
        .o_data4Mem(o_data4Mem),
        .o_result(o_result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end

    // Test procedure
    initial begin
        // Initialize inputs
        i_rst_n = 0;
        i_stall = 0;
        i_halt = 0;
        i_rs = 5'd0;
        i_rt = 5'd0;
        i_rd = 5'd0;
        i_reg_DA = 32'd0;
        i_reg_DB = 32'd0;
        i_immediate = 32'd0;
        i_opcode = 6'd0;
        i_shamt = 5'd0;
        i_func = 6'd0;
        i_addr = 16'd0;
        i_jump = 0;
        i_branch = 0;
        i_regDst = 0;
        i_mem2Reg = 0;
        i_memRead = 0;
        i_memWrite = 0;
        i_immediate_flag = 0;
        i_regWrite = 0;
        i_aluSrc = 2'b00;
        i_aluOP = 2'b00;
        i_width = 2'b00;
        i_sign_flag = 0;
        i_fw_a = 2'b00;
        i_fw_b = 2'b00;

        // Apply reset
        #10 i_rst_n = 1;
        // i_rst_n = 0;
        
        // Example stimulus
        #10;
        i_reg_DA = 32'd10; // dato A
        i_reg_DB = 32'd5; // dato B
        i_opcode = 6'b000000;  // R-type op-code
        i_func = 6'b100000;    // ADD function code for R-type
        i_aluOP = 2'b10;       // R-type operation
        // i_rs = 5'd1;    
        // i_rt = 5'd1;
        // i_rd = 5'd1;
        // i_regDst = 1;
        // i_regWrite = 0;

        #20;
        #10;
        i_immediate_flag = 1;
        i_reg_DA = 32'h000000F0; // dato A
        i_reg_DB = 32'h00000001; // dato B
        i_opcode = 6'b001000;  // ADDI op-code
        i_immediate = 32'h0000000F; // immediate value
        i_aluOP = 2'b11;       // I-type operation
        // Further test cases can be added here

        #100;
        $stop;  // End simulation
    end

endmodule

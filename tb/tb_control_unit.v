`timescale 1ns / 1ps

module tb_control_unit;

    // Parameters
    parameter NB_OP = 6;

    // Inputs
    reg clk;
    reg i_rst_n;
    reg [NB_OP-1:0] i_opcode;
    reg [NB_OP-1:0] i_funct;

    // Outputs
    wire o_jump;
    wire [1:0] o_aluSrc;
    wire [1:0] o_aluOp;
    wire o_branch;
    wire o_regDst;
    wire o_mem2Reg;
    wire o_regWrite;
    wire o_memRead;
    wire o_memWrite;
    wire [1:0] o_width;
    wire o_sign_flag;
    wire o_immediate;

    // Instantiate the control_unit module
    control_unit #(
        .NB_OP(NB_OP)
    ) uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_opcode(i_opcode),
        .i_funct(i_funct),
        .o_jump(o_jump),
        .o_aluSrc(o_aluSrc),
        .o_aluOp(o_aluOp),
        .o_branch(o_branch),
        .o_regDst(o_regDst),
        .o_mem2Reg(o_mem2Reg),
        .o_regWrite(o_regWrite),
        .o_memRead(o_memRead),
        .o_memWrite(o_memWrite),
        .o_width(o_width),
        .o_sign_flag(o_sign_flag),
        .o_immediate(o_immediate)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 10ns clock period
    end

    // Test procedure
    initial begin
        // Initialize inputs
        i_rst_n = 0;
        i_opcode = 0;
        i_funct = 0;

        // Apply reset
        #200;
        i_rst_n = 1;

        // Test R-type instruction
        i_opcode = 6'b000000; // R_TYPE
        i_funct = 6'b100000;  // ADD function (example)
        @(posedge clk);
        $display("R_TYPE: o_regDst=%b, o_aluOp=%b, o_regWrite=%b", o_regDst, o_aluOp, o_regWrite);

        // Test LW instruction
        i_opcode = 6'b100011; // LW_TYPE
        @(posedge clk);
        $display("LW: o_memRead=%b, o_mem2Reg=%b, o_aluSrc=%b, o_regWrite=%b", o_memRead, o_mem2Reg, o_aluSrc, o_regWrite);

        // Test SW instruction
        i_opcode = 6'b101011; // SW_TYPE
        @(posedge clk);
        $display("SW: o_memWrite=%b, o_aluSrc=%b", o_memWrite, o_aluSrc);

        // Test BEQ instruction
        i_opcode = 6'b000100; // BEQ_TYPE
        @(posedge clk);
        $display("BEQ: o_branch=%b, o_aluOp=%b", o_branch, o_aluOp);

        // Test ADDI instruction
        i_opcode = 6'b001000; // ADDI_TYPE
        @(posedge clk);
        $display("ADDI: o_aluSrc=%b, o_regWrite=%b, o_immediate=%b", o_aluSrc, o_regWrite, o_immediate);

        // Test ORI instruction
        i_opcode = 6'b001101; // ORI_TYPE
        @(posedge clk);
        $display("ORI: o_aluOp=%b, o_immediate=%b, o_regWrite=%b", o_aluOp, o_immediate, o_regWrite);

        // Test J instruction
        i_opcode = 6'b000010; // J_TYPE
        @(posedge clk);
        $display("J: o_jump=%b", o_jump);

        // Test LUI instruction
        i_opcode = 6'b001111; // LUI_TYPE
        @(posedge clk);
        $display("LUI: o_immediate=%b, o_sign_flag=%b", o_immediate, o_sign_flag);

        // Test LB instruction
        i_opcode = 6'b100000; // LB_TYPE
        @(posedge clk);
        $display("LB: o_memRead=%b, o_width=%b, o_sign_flag=%b", o_memRead, o_width, o_sign_flag);

        // End simulation
        $stop;
    end
endmodule

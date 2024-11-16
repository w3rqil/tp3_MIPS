`timescale 1ns/1ps

module tb_instruction_decode;

    // Clock and reset signals
    reg clk;
    reg i_rst_n;

    // Inputs to the instruction decode module
    reg [31:0] i_instruction;
    reg [31:0] i_pcounter4;
    reg        i_we_wb;
    reg        i_we;
    reg [4:0]  i_wr_addr;
    reg [31:0] i_wr_data_WB;
    reg        i_stall;

    // Outputs from the instruction decode module
    wire [4:0] o_rs;
    wire [4:0] o_rt;
    wire [4:0] o_rd;
    wire [31:0] o_reg_DA;
    wire [31:0] o_reg_DB;
    wire [31:0] o_immediate;
    wire [5:0] o_opcode;
    wire [4:0] o_shamt;
    wire [5:0] o_func;
    wire [15:0] o_addr;
    wire o_jump;
    wire o_branch;
    wire o_regDst;
    wire o_mem2Reg;
    wire o_memRead;
    wire o_memWrite;
    wire o_immediate_flag;
    wire o_regWrite;
    wire [1:0] o_aluSrc;
    wire [1:0] o_aluOp;

    // Instantiate the DUT (Device Under Test)
    instruction_decode uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_instruction(i_instruction),
        .i_pcounter4(i_pcounter4),
        .i_we_wb(i_we_wb),
        .i_we(i_we),
        .i_wr_addr(i_wr_addr),
        .i_wr_data_WB(i_wr_data_WB),
        .i_stall(i_stall),
        .o_rs(o_rs),
        .o_rt(o_rt),
        .o_rd(o_rd),
        .o_reg_DA(o_reg_DA),
        .o_reg_DB(o_reg_DB),
        .o_immediate(o_immediate),
        .o_opcode(o_opcode),
        .o_shamt(o_shamt),
        .o_func(o_func),
        .o_addr(o_addr),
        .o_jump(o_jump),
        .o_branch(o_branch),
        .o_regDst(o_regDst),
        .o_mem2Reg(o_mem2Reg),
        .o_memRead(o_memRead),
        .o_memWrite(o_memWrite),
        .o_immediate_flag(o_immediate_flag),
        .o_regWrite(o_regWrite),
        .o_aluSrc(o_aluSrc),
        .o_aluOp(o_aluOp)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize inputs
        i_rst_n = 0;
        i_instruction = 32'h0000_0000;
        i_pcounter4 = 32'h0000_0004;
        i_we_wb = 0;
        i_we = 0;
        i_wr_addr = 0;
        i_wr_data_WB = 0;
        i_stall = 0;
        #200

        // Reset sequence
        @(posedge clk);
        i_rst_n = 1;
        @(posedge clk);

        // Apply test cases
        /*
        opcode: 000000
        rs: 00001
        rt: 00010
        rd: 00011
        shamt: 00000
        func: 100001
        */
        i_instruction = 32'b000000_00001_00010_00011_00000_100001; // ADDU $3, $1, $2
        @(posedge clk);
        i_instruction = 32'b001000_10001_00010_0000000000000100; // ADDI $2, $1, 4
        @(posedge clk);
        i_instruction = 32'b000010_00000000000000000000010000; // J 16
        repeat(2) @(posedge clk);

        // End simulation
        $stop;
    end

endmodule

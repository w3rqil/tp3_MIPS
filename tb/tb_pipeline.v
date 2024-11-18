`timescale 1ns / 1ps

module pipeline_tb;

    // Parameters
    localparam NB_DATA = 32;
    localparam NB_ADDR = 5;

    // Inputs
    reg clk;
    reg i_rst_n;
    reg i_we_IF;
    reg [31:0] i_instruction_data;
    reg i_halt;

    // Outputs
    wire o_jump;
    wire o_branch;
    wire o_regDst;
    wire o_mem2reg;
    wire o_memRead;
    wire o_memWrite;
    wire o_immediate_flag;
    wire o_sign_flag;
    wire o_regWrite;
    wire [1:0] o_aluSrc;
    wire [1:0] o_width;
    wire [1:0] o_aluOp;
    wire [NB_DATA-1:0] o_addr2jump;
    wire [NB_DATA-1:0] o_reg_DA;
    wire [NB_DATA-1:0] o_reg_DB;
    wire [5:0] o_opcode;
    wire [5:0] o_func;
    wire [4:0] o_shamt;
    wire [NB_ADDR-1:0] o_rs;
    wire [NB_ADDR-1:0] o_rd;
    wire [NB_ADDR-1:0] o_rt;
    wire [15:0] o_immediate;
    wire [NB_DATA-1:0] o_ALUresult;
    wire [1:0] o_fwA;
    wire [1:0] o_fwB;
    wire [31:0] o_data2mem;
    wire [7:0] o_dataAddr;
    wire [NB_DATA-1:0] o_write_dataWB2ID;
    wire [NB_ADDR-1:0] o_reg2writeWB2ID;
    wire o_write_enable;

    // Instantiate the Unit Under Test (UUT)
    pipeline uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_we_IF(i_we_IF),
        .i_instruction_data(i_instruction_data),
        .i_halt(i_halt),
        .o_jump(o_jump),
        .o_branch(o_branch),
        .o_regDst(o_regDst),
        .o_mem2reg(o_mem2reg),
        .o_memRead(o_memRead),
        .o_memWrite(o_memWrite),
        .o_immediate_flag(o_immediate_flag),
        .o_sign_flag(o_sign_flag),
        .o_regWrite(o_regWrite),
        .o_aluSrc(o_aluSrc),
        .o_width(o_width),
        .o_aluOp(o_aluOp),
        .o_addr2jump(o_addr2jump),
        .o_reg_DA(o_reg_DA),
        .o_reg_DB(o_reg_DB),
        .o_opcode(o_opcode),
        .o_func(o_func),
        .o_shamt(o_shamt),
        .o_rs(o_rs),
        .o_rd(o_rd),
        .o_rt(o_rt),
        .o_immediate(o_immediate),
        .o_ALUresult(o_ALUresult),
        .o_fwA(o_fwA),
        .o_fwB(o_fwB),
        .o_data2mem(o_data2mem),
        .o_dataAddr(o_dataAddr),
        .o_write_dataWB2ID(o_write_dataWB2ID),
        .o_reg2writeWB2ID(o_reg2writeWB2ID),
        .o_write_enable(o_write_enable)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Clock with a period of 10ns
    end

    // Test sequence
    initial begin
        // Initialize inputs
        i_rst_n = 0;
        i_we_IF = 0;
        i_instruction_data = 32'b0;
        i_halt = 0;

        // Apply reset
        @(posedge clk);
        i_rst_n = 1;
        @(posedge clk);

        // Load the first instruction
        i_instruction_data = 32'b000000_00001_00010_00011_00000_100000; // ADD $3, $1, $2
        i_we_IF = 1;
        @(posedge clk);
        i_we_IF = 0;
        @(posedge clk);

        // // Load the second instruction
        // i_instruction_data = 32'b100011_00001_00010_0000000000000100; // LW $2, 4($1)
        // i_we_IF = 1;
        // @(posedge clk);
        // i_we_IF = 0;
        // @(posedge clk);

        // // Load the third instruction
        // i_instruction_data = 32'b101011_00001_00010_0000000000001000; // SW $2, 8($1)
        // i_we_IF = 1;
        // @(posedge clk);
        // i_we_IF = 0;
        // @(posedge clk);

        // Simulate halt signal
        i_halt = 1;
        @(posedge clk);
        i_halt = 0;

        // Wait and observe outputs
        repeat (10) @(posedge clk);
        $stop;
    end

endmodule

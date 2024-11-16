`timescale 1ns/1ps

module tb_if_id;

    // Clock and reset signals
    reg clk;
    reg i_rst_n;

    // Inputs to the instruction_fetch module
    reg i_jump;
    reg i_we;
    reg [31:0] i_addr2jump;
    reg [31:0] i_instr_data;
    reg i_halt;
    reg i_stall;

    // Inputs to the instruction_decode module
    reg [31:0] i_instruction;
    reg [31:0] i_pcounter4;
    reg        i_we_wb;
    reg        i_we;
    reg [4:0] i_wr_addr;
    reg [31:0] i_wr_data_WB;

    // Outputs from the instruction_decode module
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

    // Outputs from the instruction_fetch module
    wire [31:0] o_pcounter4;
    wire [31:0] o_instruction;

    // Instantiate the instruction_fetch module
    instruction_fetch IF_uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_jump(i_jump),
        .i_we(i_we),
        .i_addr2jump(i_addr2jump),
        .i_instr_data(i_instr_data),
        .i_halt(i_halt),
        .i_stall(i_stall),
        .o_pcounter4(o_pcounter4),
        .o_instruction(o_instruction)
    );

    // Instantiate the instruction_decode module
    instruction_decode ID_uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_instruction(o_instruction),
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

    // Clock Generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 10ns clock period
    end

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
        i_instruction = 0;
        i_pcounter4 = 32'h0000_0004;
        i_we_wb = 0;
        i_wr_addr = 0;
        i_wr_data_WB = 0;
        #200

        // Reset sequence
        @(posedge clk);
        i_rst_n = 1;
        @(posedge clk);

                    // Se escriben instrucciones en la memoria de instrucciones
        i_we = 1;
        i_instr_data = 32'b000000_00001_00010_00011_00000_100001; //
        @(posedge clk);
        i_we = 0;

        i_we = 1;
        i_instr_data = 32'b001000_10001_00010_0000000000000100;
        @(posedge clk);
        i_we = 0;

        i_we = 1;
        i_instr_data = 32'b000010_00000000000000000000010000;
        @(posedge clk);
        i_we = 0;

        // i_we = 1;
        // i_instr_data = 32'hAAAAAAAA;
        // @(posedge clk);
        // i_we = 0;

        // i_we = 1;
        // i_instr_data = 32'h0000FFFF;
        // @(posedge clk);
        // i_we = 0;

        // Se leen las instrucciones de la memoria de instrucciones
        @(posedge clk); 
        i_rst_n = 0; 
        @(posedge clk); 
        i_rst_n = 1;
        repeat(16) @(posedge clk);

        // End simulation
        $stop;
    end

endmodule
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
    wire o_immediat;
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
        .o_immediat(o_immediat),
        .o_regWrite(o_regWrite),
        .o_aluSrc(o_aluSrc),
        .o_aluOp(o_aluOp)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize inputs
        i_rst_n = 0;
        i_instruction = 0;
        i_pcounter4 = 32'h0000_0004;
        i_we_wb = 0;
        i_we = 0;
        i_wr_addr = 0;
        i_wr_data_WB = 0;
        i_stall = 0;

        // Reset sequence
        #10;
        i_rst_n = 1;
        #10;

        // Apply test cases
        test_r_type();
        test_i_type();
        test_j_type();

        // End simulation
        $stop;
    end

    // Task for testing R-type instructions
    task test_r_type();
        begin
            $display("Testing R-type instruction...");
            i_instruction = 32'b000000_00001_00010_00011_00000_100000; // ADD $3, $1, $2
            #10;
            check_results(6'b000000, 5'd1, 5'd2, 5'd3, 5'd0, 6'b100000);
        end
    endtask

    // Task for testing I-type instructions
    task test_i_type();
        begin
            $display("Testing I-type instruction...");
            i_instruction = 32'b001000_00001_00010_0000000000000100; // ADDI $2, $1, 4
            #10;
            check_results(6'b001000, 5'd1, 5'd2, 5'd0, 5'd0, 6'b000000);
        end
    endtask

    // Task for testing J-type instructions
    task test_j_type();
        begin
            $display("Testing J-type instruction...");
            i_instruction = 32'b000010_00000000000000000000010000; // J 16
            #10;
            check_results(6'b000010, 5'd0, 5'd0, 5'd0, 5'd0, 6'b000000);
        end
    endtask

    // Task to check results against expected values
    task check_results;
        input [5:0] exp_opcode;
        input [4:0] exp_rs;
        input [4:0] exp_rt;
        input [4:0] exp_rd;
        input [4:0] exp_shamt;
        input [5:0] exp_func;

        begin
            // Check the opcode, rs, rt, rd, shamt, and function code
            if (o_opcode !== exp_opcode) $display("Error: Opcode mismatch. Expected %b, Got %b", exp_opcode, o_opcode);
            if (o_rs !== exp_rs) $display("Error: RS mismatch. Expected %d, Got %d", exp_rs, o_rs);
            if (o_rt !== exp_rt) $display("Error: RT mismatch. Expected %d, Got %d", exp_rt, o_rt);
            if (o_rd !== exp_rd) $display("Error: RD mismatch. Expected %d, Got %d", exp_rd, o_rd);
            if (o_shamt !== exp_shamt) $display("Error: Shamt mismatch. Expected %d, Got %d", exp_shamt, o_shamt);
            if (o_func !== exp_func) $display("Error: Func mismatch. Expected %b, Got %b", exp_func, o_func);
            $display("Test case passed.\n");
        end
    endtask

endmodule

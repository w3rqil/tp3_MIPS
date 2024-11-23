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
    reg [31:0] i_inst_addr;
    // Instantiate the Unit Under Test (UUT)
    pipeline uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_we_IF(i_we_IF),
        .i_instruction_data(i_instruction_data),
        .i_halt(i_halt),
        .i_inst_addr(i_inst_addr),
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

   // Helper task to check register values and print results
    task check_register;
        input [NB_ADDR-1:0] reg_addr;
        input [NB_DATA-1:0] expected_value;
        begin
            @(posedge clk);
            if (o_reg2writeWB2ID == reg_addr && o_write_enable) begin
                if (o_write_dataWB2ID !== expected_value) begin
                    $display("ERROR: Register R%d expected: 0x%h, got: 0x%h", reg_addr, expected_value, o_write_dataWB2ID);
                end else begin
                    $display("PASS: Register R%d = 0x%h", reg_addr, o_write_dataWB2ID);
                end
            end
        end
    endtask
    `define TEST_ITYPE
// `define TEST_JTYPE
//    `define TEST_RTYPE
    `ifdef TEST_ITYPE
    // Test sequence
        initial begin
            // Initialize inputs
            i_rst_n = 0;
            i_we_IF = 0;
            i_instruction_data = 32'h0000;
            i_inst_addr = 32'h0000;
            i_halt = 1'b1;
            #200

            // Load instructions into memory
            @(posedge clk);
            i_we_IF = 1;
            repeat(3) @(posedge clk);
            
            // Instruction 1: ADDI R1, R0, 15 (Load the value 15 into R1)
            i_instruction_data = 32'b001000_00000_00001_0000000000001111; // ADDI R1, R0, 15
            i_inst_addr = 32'h0004;
            @(posedge clk);


            // Instruction 2: SB R1, 0(R0) (Store byte from R1 to memory address R0 + 0)
            i_instruction_data = 32'b101000_00000_00001_0000000000000000; // SB R1, 0(R0)
            i_inst_addr = 32'h0008;
            i_we_IF = 1;
            @(posedge clk);


            // Instruction 3: ADDI R2, R1, 7 (Load the value R1 + 7 into R2)
            i_instruction_data = 32'b001000_00001_00010_0000000000000111; // ADDI R2, R1, 7
            i_inst_addr = 32'h000c;
            i_we_IF = 1;
            @(posedge clk);


            // Instruction 4: SB R2, 8(R0) (Store byte from R2 to memory address R0 + 8)
            i_instruction_data = 32'b101000_00000_00010_0000000000001000; // SB R2, 8(R0)
            i_inst_addr = 32'h0010;
            i_we_IF = 1;
            @(posedge clk);
    

            // Instruction 5: LB R3, 8(R0) (Load byte from memory address R0 + 8 into R3)
            i_instruction_data = 32'b100000_00000_00011_0000000000001000; // LB R3, 8(R0)
            i_inst_addr = 32'h0014;
            i_we_IF = 1;
            @(posedge clk);
            

            // Instruction 6: ANDI R4, R3, 11 (R4 = R3 & 11)
            i_instruction_data = 32'b001100_00011_00100_0000000000001011; // ANDI R4, R3, 11
            i_inst_addr = 32'h0018;
            // IF2ID -> rs = 00011
            // IF2ID -> rt = 00100

            // // ID2EX -> rt = 00011
            // // ID2EX -> memRead = 1

             i_we_IF = 1;
            @(posedge clk);


            // Instruction 7: ADDI R4, R4, 272 (R4 = R4 + 272)
            i_instruction_data = 32'b001000_00100_00100_0000000100010000; // ADDI R4, R4, 272
            i_inst_addr = 32'h001c;
            i_we_IF = 1;
            @(posedge clk);
            

    /*
            // Instruction 8: SH R4, 12(R0) (Store halfword from R4 to memory address R0 + 12)
            i_instruction_data = 32'b101001_00000_00100_0000000000001100; // SH R4, 12(R0)
            i_we_IF = 1;
            @(posedge clk);


            // Instruction 9: ORI R5, R4, 10 (R5 = R4 | 10)
            i_instruction_data = 32'b001101_00100_00101_0000000000001010; // ORI R5, R4, 10
            i_we_IF = 1;
            @(posedge clk);


            // Instruction 10: SW R5, 24(R0) (Store word from R5 to memory address R0 + 24)
            i_instruction_data = 32'b101011_00000_00101_0000000000011000; // SW R5, 24(R0)
            i_we_IF = 1;
            @(posedge clk);


            // Instruction 11: BEQ R5, R4, 2 (Branch if R5 == R4, offset 2 instructions)
            i_instruction_data = 32'b000100_00101_00100_0000000000000010; // BEQ R5, R4, 2
            i_we_IF = 1;
            @(posedge clk);


            // Instruction 12: ADDI R6, R0, 20 (Load the value 20 into R6)
            i_instruction_data = 32'b001000_00000_00110_0000000000010100; // ADDI R6, R0, 20
            i_we_IF = 1;
            @(posedge clk);


            // Instruction 13: BNE R6, R2, 2 (Branch if R6 != R2, offset 2 instructions)
            i_instruction_data = 32'b000101_00110_00010_0000000000000010; // BNE R6, R2, 2
            i_we_IF = 1;
            @(posedge clk);

            // Instruction 14: ADDI R6, R0, 30 (Load the value 30 into R6)
            i_instruction_data = 32'b001000_00000_00110_0000000000011110; // ADDI R6, R0, 30
            i_we_IF = 1;
            @(posedge clk);
*/
            // Se desactiva la escritura
            i_we_IF = 0;
            @(posedge clk);
    
            // Apply second reset to execute instructions
            i_rst_n = 0;
            @(posedge clk);
            i_rst_n = 1;
            i_halt = 0;
            @(posedge clk);
            $display("-----------------------------------------------------------------------------------------------");
            $display(" START");
            $display("-----------------------------------------------------------------------------------------------");


            // Wait and observe outputs
            repeat (50) @(posedge clk);
            $display("-----------------------------------------------------------------------------------------------");
            $display(" C'EST FINI.");
            $display("-----------------------------------------------------------------------------------------------");
            $stop;
        end
    `elsif TEST_JTYPE
        initial begin
            // Initialize inputs
            i_rst_n = 0;
            i_we_IF = 0;
            i_instruction_data = 32'b0;
            i_halt = 1'b0;
            #200

            // Load instructions into memory
            @(posedge clk);
            i_rst_n = 1;
            //@(posedge clk);

            // Instruction 1: ADDI R1, R0, 15 (Load the value 15 into R1)
            i_instruction_data = 32'b001000_00000_00001_0000000000001111; // ADDI R1, R0, 15
            i_we_IF = 1;
            @(posedge clk);

            // Instruction 2: JALR R2, R1 (Jump to R1, store PC+4 in R2)
            i_instruction_data = 32'b000000_00001_00000_00010_00000_001001; // JALR R2, R1
            i_we_IF = 1;
            @(posedge clk);

            // Instruction 3: NOP
//            i_instruction_data = 32'b000000_00000_00000_00000_00000_000000; // NOP
//            i_we_IF = 1;
//            @(posedge clk);
//
//            // Instruction 4: NOP
//            i_instruction_data = 32'b000000_00000_00000_00000_00000_000000; // NOP
//            i_we_IF = 1;
//            @(posedge clk);

            // Instruction 5: J 10 (Jump to address 10)
            i_instruction_data = 32'b000010_00000000000000000000001010; // J 10
            i_we_IF = 1;
            @(posedge clk);

            // Instruction 6: ADDI R3, R1, 100 (R3 = R1 + 100)
            i_instruction_data = 32'b001000_00001_00011_0000000001100100; // ADDI R3, R1, 100
            i_we_IF = 1;
            @(posedge clk);

            // Instruction 7: JR R2 (Jump to R2)
            i_instruction_data = 32'b000000_00010_00000_00000_00000_001000; // JR R2
            i_we_IF = 1;
            @(posedge clk);

            // Instruction 8: HALT (Stop execution)
            i_instruction_data = 32'b111111_00000_00000_00000_00000_000000; // HALT
            i_we_IF = 1;
            @(posedge clk);

            // Stop writing instructions
            i_we_IF = 0;
            @(posedge clk);

            // Apply second reset to execute instructions
            i_rst_n = 0;
            @(posedge clk);
            i_rst_n = 1;
            @(posedge clk);

            $display("-----------------------------------------------------------------------------------------------");
            $display(" START EXECUTION");
            $display("-----------------------------------------------------------------------------------------------");

            // Wait and observe outputs
            repeat (50) @(posedge clk);

            $display("-----------------------------------------------------------------------------------------------");
            $display(" EXECUTION COMPLETE.");
            $display("-----------------------------------------------------------------------------------------------");
            $stop;
        end

    `endif

endmodule
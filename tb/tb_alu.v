`timescale 1ns / 1ps

module alu_tb;

    // Testbench Parameters
    parameter NB_DATA = 8;
    parameter NB_OP = 6;

    // Inputs
    reg signed [NB_DATA-1:0] i_datoA;
    reg signed [NB_DATA-1:0] i_datoB;
    reg [NB_OP-1:0] i_operation;
    reg signed [4:0] i_shamt;

    // Outputs
    wire signed [NB_DATA-1:0] o_data;

    // Instantiate the ALU
    alu #(
        .NB_DATA(NB_DATA),
        .NB_OP(NB_OP)
    ) uut (
        .i_datoA(i_datoA),
        .i_datoB(i_datoB),
        .i_operation(i_operation),
        .i_shamt(i_shamt),
        .o_data(o_data)
    );

    // Test Procedure
    initial begin
        // Initialize inputs
        i_datoA = 0;
        i_datoB = 0;
        i_operation = 6'b000000;
        i_shamt = 0;

        // Wait for global reset
        #10;

        // Test Case 1: ADD Operation
        i_datoA = 8'h05;     // 5
        i_datoB = 8'h03;     // 3
        i_operation = 6'b100000; // ADD_OP
        #10;
        $display("ADD_OP: %d + %d = %d", i_datoA, i_datoB, o_data);

        // Test Case 2: SUB Operation
        i_datoA = 8'h07;     // 7
        i_datoB = 8'h02;     // 2
        i_operation = 6'b100010; // SUB_OP
        #10;
        $display("SUB_OP: %d - %d = %d", i_datoA, i_datoB, o_data);

        // Test Case 3: SLL (Shift Left Logical)
        i_datoB = 8'h01;     // 1
        i_shamt = 3;         // Shift by 3
        i_operation = 6'b000000; // SLL_OP
        #10;
        $display("SLL_OP: %b << %b = %b", i_datoB, i_shamt, o_data);

        // Test Case 4: SRL (Shift Right Logical)
        i_datoB = 8'h08;     // 8
        i_shamt = 2;         // Shift by 2
        i_operation = 6'b000010; // SRL_OP
        #10;
        $display("SRL_OP: %b >> %b = %b", i_datoB, i_shamt, o_data);

        // Test Case 5: SRA (Shift Right Arithmetic)
        i_datoB = -8'h08;    // -8
        i_shamt = 2;         // Shift by 2
        i_operation = 6'b000011; // SRA_OP
        #10;
        $display("SRA_OP: %b >>> %b = %b", i_datoB, i_shamt, o_data);

        // Test Case 6: SLLV (Shift Left Logical Variable)
        i_datoA = 8'h03;     // 3
        i_datoB = 8'h01;     // 1
        i_operation = 6'b000100; // SLLV_OP
        #10;
        $display("SLLV_OP: %b << %b = %b", i_datoB, i_datoA, o_data);

        // Test Case 7: SRLV (Shift Right Logical Variable)
        i_datoA = 8'h03;     // 3
        i_datoB = 8'h08;     // 8
        i_operation = 6'b000110; // SRLV_OP
        #10;
        $display("SRLV_OP: %b >> %b = %b", i_datoB, i_datoA, o_data);

        // Test Case 8: SRAV (Shift Right Arithmetic Variable)
        i_datoA = 8'h03;     // 3
        i_datoB = -8'h08;    // -8
        i_operation = 6'b000111; // SRAV_OP
        #10;
        $display("SRAV_OP: %b >>> %b = %b", i_datoB, i_datoA, o_data);

        // Test Case 9: ADDU Operation
        i_datoA = 8'h05;     // 5
        i_datoB = 8'h03;     // 3
        i_operation = 6'b100001; // ADDU_OP
        #10;
        $display("ADDU_OP: %d + %d = %d", i_datoA, i_datoB, o_data);

        // Test Case 10: SUBU Operation
        i_datoA = 8'h07;     // 7
        i_datoB = 8'h02;     // 2
        i_operation = 6'b100011; // SUBU_OP
        #10;
        $display("SUBU_OP: %d - %d = %d", i_datoA, i_datoB, o_data);

        // Test Case 11: AND Operation
        i_datoA = 8'h0F;     // 15
        i_datoB = 8'hF0;     // 240
        i_operation = 6'b100100; // AND_OP
        #10;
        $display("AND_OP: %b & %b = %b", i_datoA, i_datoB, o_data);

        // Test Case 12: OR Operation
        i_datoA = 8'h0F;     // 15
        i_datoB = 8'hF0;     // 240
        i_operation = 6'b100101; // OR_OP
        #10;
        $display("OR_OP: %b | %b = %b", i_datoA, i_datoB, o_data);

        // Test Case 13: XOR Operation
        i_datoA = 8'h0F;     // 15
        i_datoB = 8'hF0;     // 240
        i_operation = 6'b100110; // XOR_OP
        #10;
        $display("XOR_OP: %b ^ %b = %b", i_datoA, i_datoB, o_data);

        // Test Case 14: NOR Operation
        i_datoA = 8'h0F;     // 15
        i_datoB = 8'hF0;     // 240
        i_operation = 6'b100111; // NOR_OP
        #10;
        $display("NOR_OP: ~(%b | %b) = %b", i_datoA, i_datoB, o_data);

        // Test Case 15: SLT (Set Less Than) Operation
        i_datoA = 8'h01;     // 1
        i_datoB = 8'h02;     // 2
        i_operation = 6'b101010; // SLT_OP
        #10;
        $display("SLT_OP: %d < %d = %d", i_datoA, i_datoB, o_data);

        // Test Case 16: SLTU (Set Less Than Unsigned) Operation
        i_datoA = 8'hFF;     // 255 (unsigned)
        i_datoB = 8'h01;     // 1
        i_operation = 6'b101011; // SLTU_OP
        #10;
        $display("SLTU_OP: %d < %d = %d", i_datoA, i_datoB, o_data);

        // 

        // End of Test
        $stop;
    end

endmodule

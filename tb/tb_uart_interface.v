`timescale 1ns / 1ps

module uart_interface_tb;

    // Parameters
    localparam NB_DATA = 8;
    localparam NB_STOP = 16;
    localparam NB_32 = 32;
    localparam NB_5 = 5;
    localparam NB_STATES = 4;
    localparam NB_IF_ID = 96;
    localparam NB_ID_EX = 160;
    localparam NB_EX_MEM = 32;
    localparam NB_MEM_WB = 64;
    localparam NB_CONTROL = 16;

    // Inputs
    reg clk;
    reg [NB_DATA - 1 : 0] i_rx;
    reg i_rxDone;
    reg i_txDone;
    reg i_rst_n;
    reg i_end;
    reg [NB_32 -1 : 0] i_addr_registers;
    reg [NB_32 -1 : 0] i_data_registers;
    reg [NB_32 -1 : 0] i_program_counter;
    reg [NB_32 -1 : 0] i_register_A;
    reg [NB_32 -1 : 0] i_register_B;
    reg [5:0] i_opcode;
    reg [NB_5 -1 : 0] i_rs;
    reg [NB_5 -1 : 0] i_rt;
    reg [NB_5 -1 : 0] i_rd;
    reg [NB_5 -1 : 0] i_shamt;
    reg [5:0] i_funct;
    reg [15:0] i_immediate;
    reg [25:0] i_jump_address;
    reg [NB_32 -1 : 0] i_alu_result;
    reg [NB_32 -1 : 0] i_data_memory;
    reg [NB_32 -1 : 0] i_addr_memory;
    reg i_jump;
    reg i_branch;
    reg i_regDst;
    reg i_memToReg;
    reg i_memRead;
    reg i_memWrite;
    reg i_inmediate_flag;
    reg i_sign_flag;
    reg i_regWrite;
    reg [1:0] i_aluSrc;
    reg [1:0] i_width;
    reg [1:0] i_aluOp;

    // Outputs
    wire o_tx_start;
    wire [NB_DATA - 1 : 0] o_data;
    wire [NB_32 - 1 : 0] o_instruction;
    wire [NB_32 - 1 : 0] o_instruction_address;
    wire o_valid;
    wire o_step;
    wire o_start;
    wire [NB_32:0] o_done_counter;
    wire [NB_32:0] o_next_done_counter;
    wire [NB_STATES-1:0] o_state;
    wire        [NB_IF_ID   -1 : 0] o_concatenated_data_IF_ID     ; //! Output data for IF_ID
    wire        [NB_ID_EX   -1 : 0] o_concatenated_data_ID_EX     ; //! Output data for ID_EX
    wire        [NB_EX_MEM  -1 : 0] o_concatenated_data_EX_MEM    ; //! Output data for EX_MEM
    wire        [NB_MEM_WB  -1 : 0] o_concatenated_data_MEM_WB    ; //! Output data for MEM_WB
    wire        [NB_CONTROL -1 : 0] o_concatenated_data_CONTROL   ;  //! Output data for CONTROL

    // Instantiate the Unit Under Test (UUT)
    uart_interface #(
        .NB_DATA(NB_DATA),
        .NB_STOP(NB_STOP),
        .NB_32(NB_32),
        .NB_5(NB_5),
        .NB_STATES(NB_STATES),
        .NB_IF_ID(NB_IF_ID),
        .NB_ID_EX(NB_ID_EX),
        .NB_EX_MEM(NB_EX_MEM),
        .NB_MEM_WB(NB_MEM_WB),
        .NB_CONTROL(NB_CONTROL)
    ) uut (
        .clk(clk),
        .i_rx(i_rx),
        .i_rxDone(i_rxDone),
        .i_txDone(i_txDone),
        .i_rst_n(i_rst_n),
        .o_tx_start(o_tx_start),
        .o_data(o_data),
        .i_end(i_end),
        .i_addr_registers(i_addr_registers),
        .i_data_registers(i_data_registers),
        .i_program_counter(i_program_counter),
        .i_register_A(i_register_A),
        .i_register_B(i_register_B),
        .i_opcode(i_opcode),
        .i_rs(i_rs),
        .i_rt(i_rt),
        .i_rd(i_rd),
        .i_shamt(i_shamt),
        .i_funct(i_funct),
        .i_immediate(i_immediate),
        .i_jump_address(i_jump_address),
        .i_alu_result(i_alu_result),
        .i_data_memory(i_data_memory),
        .i_addr_memory(i_addr_memory),
        .i_jump(i_jump),
        .i_branch(i_branch),
        .i_regDst(i_regDst),
        .i_memToReg(i_memToReg),
        .i_memRead(i_memRead),
        .i_memWrite(i_memWrite),
        .i_inmediate_flag(i_inmediate_flag),
        .i_sign_flag(i_sign_flag),
        .i_regWrite(i_regWrite),
        .i_aluSrc(i_aluSrc),
        .i_width(i_width),
        .i_aluOp(i_aluOp),
        .o_instruction(o_instruction),
        .o_instruction_address(o_instruction_address),
        .o_valid(o_valid),
        .o_step(o_step),
        .o_start(o_start),
        .o_done_counter(o_done_counter),
        .o_next_done_counter(o_next_done_counter),
        .o_state(o_state),
        .o_concatenated_data_IF_ID(o_concatenated_data_IF_ID),
        .o_concatenated_data_ID_EX(o_concatenated_data_ID_EX),
        .o_concatenated_data_EX_MEM(o_concatenated_data_EX_MEM),
        .o_concatenated_data_MEM_WB(o_concatenated_data_MEM_WB),
        .o_concatenated_data_CONTROL(o_concatenated_data_CONTROL)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 100 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        i_rst_n = 0;
        i_rx = 0;
        i_rxDone = 0;
        i_txDone = 0;
        i_end = 0;
        i_addr_registers = 32'h00000001;
        i_data_registers = 32'h00000002;
        i_program_counter = 32'h00000003;
        i_register_A = 32'h00000004;
        i_register_B = 32'h00000005;
        i_opcode = 6'b111111;
        i_rs = 5'b00000;
        i_rt = 5'b11111;
        i_rd = 5'b00000;
        i_shamt = 5'b11111;
        i_funct = 6'b000000;
        i_immediate = 16'hFFFF;
        i_jump_address = 26'h0000000;
        i_alu_result = 32'hFFFFFFFF;
        i_data_memory = 32'h00000000;
        i_addr_memory = 32'hFFFFFFFF;
        i_jump = 0;
        i_branch = 1;
        i_regDst = 0;
        i_memToReg = 1;
        i_memRead = 0;
        i_memWrite = 1;
        i_inmediate_flag = 0;
        i_sign_flag = 1;
        i_regWrite = 0;
        i_aluSrc = 2'b11;
        i_width = 2'b00;
        i_aluOp = 2'b11;

        // Reset the design
        @(posedge clk);
        i_rst_n = 1;

        // Simulate receiving an instruction
        @(posedge clk);
        i_rx = 8'b00000001;  //  RECEIVING_INSTRUCTION
        i_rxDone = 1;
        @(posedge clk);
        i_rxDone = 0;
        @(posedge clk);

        // Enviar la primera instrucción: ADDU $3, $1, $2
        send_instruction(32'b000000_00001_00010_00011_00000_100001);
        // // Enviar la segunda instrucción: ADDI $2, $1, 4
        // send_instruction(32'b001000_10001_00010_0000000000000100);
        // // Enviar la tercera instrucción: J 16
        // send_instruction(32'b000010_00000000000000000000010000);
        // Enviar instruccion de halt
        send_instruction(32'hffffffff);

        // Simulate receiving an instruction
        @(posedge clk);
        i_rx = 8'b00000010;  //  DEBUG_MODE
        i_rxDone = 1;
        @(posedge clk);
        i_rxDone = 0;
        @(posedge clk);

        // Simulate receiving an instruction
        @(posedge clk);
        i_rx = 8'b00001000;  //  STEP_MODE
        i_rxDone = 1;
        @(posedge clk);
        i_rxDone = 0;
        @(posedge clk);

        // Simulate sending data over UART
        repeat (50) begin
            @(posedge clk);
            i_txDone = 1;
            @(posedge clk);
            i_txDone = 0;
        end

        @(posedge clk);
        i_rx = 8'b00010000; // END_DEBUG
        i_rxDone = 1;
        @(posedge clk);
        i_rxDone = 0;
        @(posedge clk);

        // Simulate sending data over UART
        repeat (50) begin
            @(posedge clk);
            i_txDone = 1;
            @(posedge clk);
            i_txDone = 0;
        end      

        // End simulation
        #100;
        $stop;
    end

    task send_instruction(input [31:0] instruction);
        integer i;
        begin
            for (i = 3; i >= 0; i = i - 1) begin
                i_rx = instruction[i*8 +: 8]; // Enviar un byte a la vez
                i_rxDone = 1;
                @(posedge clk); // Esperar a que se registre el byte
                i_rxDone = 0;
                @(posedge clk); // Esperar un ciclo de reloj
            end
        end
    endtask

endmodule

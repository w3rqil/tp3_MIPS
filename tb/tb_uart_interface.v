`timescale 1ns/1ps

module uart_interface_tb;

    // Parámetros del módulo
    localparam NB_DATA = 8;
    localparam NB_STOP = 16;
    localparam NB_OP = 6;
    localparam NB_ADDR = 32;

    // Entradas y salidas del módulo de prueba
    reg clk;
    reg signed [NB_DATA - 1 : 0] i_rx;
    reg i_rxDone;
    reg i_txDone;
    reg i_rst_n;
    wire o_tx_start;
    wire [NB_DATA - 1 : 0] o_data;
    wire [32 - 1 : 0] o_instruction, o_instruction_address;
    wire o_valid;
    reg [NB_DATA - 1 : 0] i_result;
    wire [2:0] o_state;
    wire [2:0] o_done_counter, o_next_done_counter;

    // Instancia del módulo uart_interface
    uart_interface #(
        .NB_DATA(NB_DATA),
        .NB_STOP(NB_STOP),
        .NB_OP(NB_OP),
        .NB_ADDR(NB_ADDR)
    ) uut (
        .clk(clk),
        .i_rx(i_rx),
        .i_rxDone(i_rxDone),
        .i_txDone(i_txDone),
        .i_rst_n(i_rst_n),
        .o_tx_start(o_tx_start),
        .o_data(o_data),
        .o_instruction(o_instruction),
        .o_instruction_address(o_instruction_address),
        .o_valid(o_valid),
        .i_result(i_result),
        .o_state(o_state),
        .o_done_counter(o_done_counter),
        .o_next_done_counter(o_next_done_counter)
    );

    // Generación de reloj
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 100MHz clock (10ns period)
    end

    // Inicialización
    initial begin
        // Reset inicial
        i_rst_n = 0;
        i_rx = 0;
        i_rxDone = 0;
        i_txDone = 0;
        i_result = 0;
        @(posedge clk);
        // Esperar unos ciclos de reloj y luego quitar el reset
        // #200;



        i_rst_n = 1;
        @(posedge clk);
        // Enviar instruccion de inicio
        i_rx = 8'b00000001;
        @(posedge clk);
        i_rxDone = 1;
        @(posedge clk);
        i_rxDone = 0;
        @(posedge clk);
        // Enviar la primera instrucción: ADDU $3, $1, $2
        send_instruction(32'b000000_00001_00010_00011_00000_100001);
        // Enviar la segunda instrucción: ADDI $2, $1, 4
        send_instruction(32'b001000_10001_00010_0000000000000100);
        // Enviar la tercera instrucción: J 16
        send_instruction(32'b000010_00000000000000000000010000);
        // Enviar instruccion de halt
        send_instruction(32'hffffffff);

        // Terminar la simulación
        #100;
        $finish;
    end

    // Tarea para enviar instrucciones al módulo
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

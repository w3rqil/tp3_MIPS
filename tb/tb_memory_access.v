`timescale 1ns / 1ps

module tb_memory_access;

    // Parámetros
    parameter NB_DATA = 32;
    parameter NB_ADDR = 5;
    parameter NB_REG = 1;

    // Señales de entrada
    reg clk;
    reg i_rst_n;
    reg i_stall;
    reg i_halt;
    reg [4:0] i_reg2write;
    reg [NB_DATA-1:0] i_result;
    reg [NB_DATA-1:0] i_aluOP;
    reg [1:0] i_width;
    reg i_sign_flag;
    reg i_mem2reg;
    reg i_memRead;
    reg i_memWrite;
    reg i_regWrite;
    reg [1:0] i_aluSrc;
    reg i_jump;
    reg [NB_DATA-1:0] i_data4Mem;

    // Señales de salida
    wire [NB_DATA-1:0] o_reg_read;
    wire [NB_DATA-1:0] o_ALUresult;
    wire [4:0] o_reg2write;
    wire o_mem2reg;
    wire o_regWrite;

    // Instanciar el módulo `memory_access`
    memory_access #(
        .NB_DATA(NB_DATA),
        .NB_ADDR(NB_ADDR),
        .NB_REG(NB_REG)
    ) uut (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_stall(i_stall),
        .i_halt(i_halt),
        .i_reg2write(i_reg2write),
        .i_result(i_result),
        .i_aluOP(i_aluOP),
        .i_width(i_width),
        .i_sign_flag(i_sign_flag),
        .i_mem2reg(i_mem2reg),
        .i_memRead(i_memRead),
        .i_memWrite(i_memWrite),
        .i_regWrite(i_regWrite),
        .i_aluSrc(i_aluSrc),
        .i_jump(i_jump),
        .i_data4Mem(i_data4Mem),
        .o_reg_read(o_reg_read),
        .o_ALUresult(o_ALUresult),
        .o_reg2write(o_reg2write),
        .o_mem2reg(o_mem2reg),
        .o_regWrite(o_regWrite)
    );

    // Generador de reloj
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 100 MHz clock
    end

    // Procedimiento de prueba
    initial begin
        // Inicializar entradas
        i_rst_n = 0;
        i_stall = 0;
        i_halt = 0;
        i_reg2write = 5'd0;
        i_result = 32'd0;
        i_aluOP = 32'd0;
        i_width = 2'b00;
        i_sign_flag = 0;
        i_mem2reg = 0;
        i_memRead = 0;
        i_memWrite = 0;
        i_regWrite = 0;
        i_aluSrc = 2'b00;
        i_jump = 0;
        i_data4Mem = 32'd0;
        #200

        // Aplicar reset
        @(posedge clk);
         i_rst_n = 1;

        // Estímulo de ejemplo
        @(posedge clk);
        i_memWrite = 1;         // Habilitar escritura en memoria
        i_width = 2'b10;        // Escritura de palabra completa
        i_sign_flag = 0;        // Sin signo
        i_data4Mem = 32'hA5A5A5A5;
        i_result = 8'd4;       // Dirección de escritura

        @(posedge clk);
        i_memWrite = 0;         // Deshabilitar escritura
        i_memRead = 1;          // Habilitar lectura de memoria
        i_result = 8'd4;       // Dirección de lectura

        @(posedge clk);
        i_memRead = 0;          // Deshabilitar lectura

        // Otros casos de prueba
        @(posedge clk);
        i_memWrite = 1;
        i_width = 2'b00;        // Escritura de byte
        i_sign_flag = 1;        // Signo habilitado
        i_data4Mem = 32'hFF;
        i_result = 32'd8;

        @(posedge clk);
        i_memWrite = 0;
        i_memRead = 1;
        i_result = 32'd8;

        // Finalizar la simulación
        repeat(2) @(posedge clk);
        $stop;
    end

endmodule

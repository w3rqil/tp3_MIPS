`timescale 1ns/1ps

module tb_top;

    // Parameters
    localparam CLK_PERIOD = 10; // 100MHz clock -> 10ns period

    // DUT signals
    reg clk_100MHz;
    reg i_rst_n;
    reg i_rx;
    wire o_tx;
    reg [7:0] data;
    reg rxDone;

    // Instantiate the DUT (Device Under Test)
    top uut (
        .clk_100MHz (clk_100MHz),
        .i_rst_n    (i_rst_n),
        .i_rx       (i_rx),
        .o_tx       (o_tx),
        .i_data     (data),
        .i_rxDoneTest(rxDone)
    );

    // Clock generation
    initial begin
        clk_100MHz = 1'b0;
        forever #(CLK_PERIOD / 2) clk_100MHz = ~clk_100MHz; // Generate a 100MHz clock
    end

    // Testbench logic
    initial begin
        // Initialization
        i_rst_n = 1'b0; // Start with reset active
        i_rx = 1'b0;    // Idle state for UART receiver

        // Apply reset
        @(posedge clk_100MHz);
        #5; // Small delay
        i_rst_n = 1'b1; // Deactivate reset

        /* //////////////////////////////////////////////////////////////
                SE ENVIA RECEIVING_INSTRUCTION
        */ //////////////////////////////////////////////////////////////
        @(posedge clk_100MHz);
        data = 8'b00000001;
        rxDone = 1'b1;

        @(posedge clk_100MHz);
        rxDone = 1'b0;
        /* //////////////////////////////////////////////////////////////
                SE ENVIA LA INSTRUCCION ADDI R1, R0, 15
        */ //////////////////////////////////////////////////////////////
        @(posedge clk_100MHz);
        data = 8'b00100000;
        rxDone = 1'b1;
        @(posedge clk_100MHz);
        rxDone = 1'b0;

        @(posedge clk_100MHz);
        data = 8'b00000000;
        rxDone = 1'b1;
        @(posedge clk_100MHz);
        rxDone = 1'b0;

        @(posedge clk_100MHz);
        data = 8'b01000000;
        rxDone = 1'b1;
        @(posedge clk_100MHz);
        rxDone = 1'b0;

        @(posedge clk_100MHz);
        data = 8'b00001111;
        rxDone = 1'b1;
        @(posedge clk_100MHz);
        rxDone = 1'b0;

        @(posedge clk_100MHz);
        data = 8'b11111111;
        rxDone = 1'b1;
        @(posedge clk_100MHz);
        rxDone = 1'b0;
        @(posedge clk_100MHz);
        data = 8'b11111111;
        rxDone = 1'b1;
        @(posedge clk_100MHz);
        rxDone = 1'b0;
        @(posedge clk_100MHz);
        data = 8'b11111111;
        rxDone = 1'b1;
        @(posedge clk_100MHz);
        rxDone = 1'b0;
        @(posedge clk_100MHz);
        data = 8'b11111111;
        rxDone = 1'b1;
        @(posedge clk_100MHz);
        rxDone = 1'b0;

        /* //////////////////////////////////////////////////////////////
                SE TESTEA EL MODO CONTINUO
        */ //////////////////////////////////////////////////////////////
        repeat(3) @(posedge clk_100MHz);
        @(posedge clk_100MHz);
        data = 8'b00000100;
        rxDone = 1'b1;
        @(posedge clk_100MHz);
        rxDone = 1'b0;


        // Test case 1: Send a UART byte
        // send_uart_byte(8'h01); // Send 0x55 as UART data (binary: 01010101)
        // data = 8'b00000001;
        // rxDone = 1'b1;


        repeat(16) @(posedge clk_100MHz);
        // Finish simulation
        $stop;
    end

    // Task to send a UART byte
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            // UART Start bit (low)
            i_rx = 1'b0;
            @(posedge clk_100MHz); // Wait one UART bit duration

            // Send 8 data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                i_rx = data[i];
                @(posedge clk_100MHz); // Wait one UART bit duration
            end

            // UART Stop bit (high)
            i_rx = 1'b1;
            @(posedge clk_100MHz); // Wait one UART bit duration
        end
    endtask

    // Task to wait for UART transmission to complete
    task wait_for_tx_done;
        begin
            // Wait until the UART TX signal is done
            @(posedge uut.txDone);
        end
    endtask

endmodule

`timescale 1ns/1ps

module tb_uart_rx;

    // Parameters
    localparam NB_DATA = 32;
    localparam NB_STOP = 16;
    localparam BAUD_RATE  = 19200;
    localparam CLK_FREQ   = 50_000_000;
    localparam OVERSAMPLING = 16;
    // Signals
    reg clk;
    reg i_rst_n;
    reg i_data;
    wire o_tick;
    wire [NB_DATA-1:0] o_data;
    wire o_rxdone;

    // Instantiate the baudrate generator
    baudrate_generator #(
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ),
        .OVERSAMPLING(OVERSAMPLING)
    ) uut_baudrate_generator (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .o_tick(o_tick)
    );

    // Instantiate the UART RX module
    uart_rx #(
        .NB_DATA(NB_DATA),
        .NB_STOP(NB_STOP)
    ) uut_uart_rx (
        .clk(clk),
        .i_rst_n(i_rst_n),
        .i_tick(o_tick),
        .i_data(i_data),
        .o_data(o_data),
        .o_rxdone(o_rxdone)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize signals
        i_rst_n = 0;
        i_data = 1;

        // Apply reset
        #20;
        i_rst_n = 1;
        
        // Wait for a few ticks
        repeat(10) @(posedge o_tick);

        // Send a start bit
        i_data = 0; // Start bit
        repeat(16) @(posedge o_tick);
        
        send_data_bits(32'h20010014);

        // Send stop bits
        i_data = 1;
        repeat(NB_STOP) @(posedge o_tick);

        // Wait for RX done
        // wait(o_rxdone);

        // Check received data
        if (o_data == 8'b10101010) begin
            $display("Test Passed: Received data is correct: %b", o_data);
        end else begin
            $display("Test Failed: Received data is incorrect: %b", o_data);
        end

        // // Wait a bit to observe the DONE state
        // repeat(5) @(posedge o_tick); // You can adjust the number of ticks to observe
        
        $display("Finalizando la simulación en el tiempo: %0t", $time);
        // Finish the simulation
        $finish; // This will stop the simulation
    end

    task send_data_bits (input [NB_DATA-1:0] data);
        integer i;
        for (i = NB_DATA-1; i >= 0; i = i - 1) begin
            i_data = data[i];
            repeat(16) @(posedge o_tick);
        end
    endtask
endmodule

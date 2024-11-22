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
        .o_tx       (o_tx)
        //.i_data     (data),
        //.i_rxDoneTest(rxDone)
    );
    wire tick;
    baudrate_generator #(
        .BAUD_RATE(19200),
        .CLK_FREQ(100_000_000),
        .OVERSAMPLING()
    ) uut_baudrate_generator (
        .clk(clk_100MHz),
        .i_rst_n(i_rst_n),
        .o_tick(tick)
    );

    // Clock generation
    initial begin
        clk_100MHz = 1'b0;
        forever #10 clk_100MHz = ~clk_100MHz; // Generate a 100MHz clock
    end

    task uart_send(input [7:0] data);
        integer i;
        begin
        i_rx = 0; // Start bit
        repeat(16) @(posedge tick);
        for (i = 0; i < 8; i = i + 1) begin
            i_rx = data[i]; // Enviar bit por bit
            repeat(16) @(posedge tick);  // Cada bit tarda 16 ticks
        end
        i_rx = 1; // Stop bit
        repeat(100) @(posedge tick);
        end
    endtask

    task uart_send_instruction(input [31:0] data);
        integer i;
        begin
        i_rx = 0; // Start bit
        repeat(16) #6534;
        for (i = 0; i < 31; i = i + 1) begin
            i_rx = data[i]; // Enviar bit por bit
            repeat(16) @(posedge tick);  // Cada bit tarda 16 ticks
        end
        i_rx = 1; // Stop bit
        repeat(100) #6534; 
        end
    endtask

    // Testbench logic
    initial begin
        // Initialization
        i_rst_n = 1'b0; // Start with reset active
        i_rx = 1'b0;    // Idle state for UART receiver
        // Apply reset
        @(posedge clk_100MHz);
        #5; // Small delay
        i_rst_n = 1'b1; // Deactivate reset
        
        @(posedge clk_100MHz);
        @(posedge clk_100MHz);
        //uart_send(8'b00000100);
        @(posedge clk_100MHz);
        uart_send(8'h01);//start receiving
        // Instruction 1: ADDI R1, R0, 15 (Load the value 15 into R1)
        uart_send(8'b00100000);
        uart_send(8'b00000001);
        uart_send(8'b00000000);
        uart_send(8'b00001111);
        
        //addi 8
        uart_send(8'b00100000);
        uart_send(8'b00000010);
        uart_send(8'b00000000);
        uart_send(8'b00001000);
        

        // Instrucción 3: ADDU R3, R1, R2 (Sumar R1 y R2, guardar el resultado en R3)
        // ADDU R3, R1, R2
        uart_send(8'h00);
        uart_send(8'b00100010);
        uart_send(8'b00011000);
        uart_send(8'b00100001);

        // HALT instruction

        uart_send(8'hFF);
        uart_send(8'hFF);
        uart_send(8'hFF);
        uart_send(8'hFF);

        uart_send(8'h04); //continuous mode

        #5000000;
        /* //////////////////////////////////////////////////////////////
                SE TESTEA EL MODO CONTINUO
        */ //////////////////////////////////////////////////////////////
        repeat(3) @(posedge clk_100MHz);
        
        //rxDone = 1'b1;
        @(posedge clk_100MHz);
        //rxDone = 1'b0;


        // Test case 1: Send a UART byte
        // send_uart_byte(8'h01); // Send 0x55 as UART data (binary: 01010101)
        // data = 8'b00000001;
        // rxDone = 1'b1;


        //repeat(20000) @(posedge clk_100MHz);
        // Finish simulation
        $finish;
    end

    
    

    // Task to wait for UART transmission to complete
    task wait_for_tx_done;
        begin
            // Wait until the UART TX signal is done
            @(posedge uut.txDone);
        end
    endtask

endmodule

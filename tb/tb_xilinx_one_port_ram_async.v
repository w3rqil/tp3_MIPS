`timescale 1ns / 1ps

module tb_xilinx_one_port_ram_async;

    // Parameters for the RAM
    localparam NB_DATA = 32;
    localparam NB_ADDR = 12;

    // Signals
    reg clk;
    reg i_rst_n;
    reg i_we;
    reg [NB_DATA-1:0] i_data;
    reg [NB_ADDR-1:0] i_addr_w;
    wire [NB_DATA-1:0] o_data;

    // Instantiate the RAM module
    xilinx_one_port_ram_async #(
        .NB_DATA(NB_DATA),
        .NB_ADDR(NB_ADDR)
    ) ram_inst (
        .clk(clk),
        //.i_rst_n(i_rst_n),
        .i_we(i_we),
        .i_data(i_data),
        .i_addr_w(i_addr_w),
        .o_data(o_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test procedure
    initial begin
        // Initialize signals
        i_rst_n = 0;
        i_we = 0;
        i_data = 0;
        i_addr_w = 0;

        // Apply reset
        #10;
        i_rst_n = 1;  // Release reset
        #10;

        // *** Test 1: Write complex data patterns to RAM and read back ***
        
        // Write 32'hA5A5A5A5 to address 0x000
        i_we = 1;
        i_addr_w = 12'h000;
        i_data = 32'hA5A5A5A5;
        #10;

        // Write 32'h5A5A5A5A to address 0x004
        i_addr_w = 12'h004;
        i_data = 32'h5A5A5A5A;
        #10;

        // Write 32'hF0F0F0F0 to address 0x008
        i_addr_w = 12'h008;
        i_data = 32'hF0F0F0F0;
        #10;

        // Write 32'h0F0F0F0F to address 0x00C
        i_addr_w = 12'h00C;
        i_data = 32'h0F0F0F0F;
        #10;

        // Disable write enable
        i_we = 0;

        // *** Test 2: Read back the data to verify ***

        // Read from address 0x000
        i_addr_w = 12'h000;
        #10;
        $display("Read from address 0x000: Data = %b (Expected: %b)", o_data, 32'b10100101101001011010010110100101); // Expected: A5A5A5A5

        // Read from address 0x004
        i_addr_w = 12'h004;
        #10;
        $display("Read from address 0x004: Data = %b (Expected: %b)", o_data, 32'b01011010010110100101101001011010); // Expected: 5A5A5A5A

        // Read from address 0x008
        i_addr_w = 12'h008;
        #10;
        $display("Read from address 0x008: Data = %b (Expected: %b)", o_data, 32'b11110000111100001111000011110000); // Expected: F0F0F0F0

        // Read from address 0x00C
        i_addr_w = 12'h00C;
        #10;
        $display("Read from address 0x00C: Data = %b (Expected: %b)", o_data, 32'b00001111000011110000111100001111); // Expected: 0F0F0F0F

        // End of simulation
        $stop;
    end
endmodule

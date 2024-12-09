module instruction_fetch
(
    input wire          clk             ,
    input wire          i_rst_n         ,   
    input wire          i_jump          ,  //! 1= jump asserted | 0= else
    input wire          i_we            ,  //! Write enable for memory initialization only
    input wire [31:0]   i_addr2jump     ,  //! Address for jump
    input wire [31:0]   i_instr_data    ,  //! Data to write if i_we is high
    input wire [31:0]   i_inst_addr     ,  //! address to write instructions
    input wire          i_halt          ,  //! halt -> enable
    input wire          i_stall         ,  //! stall
    output wire [31:0]  o_pcounter4     ,  //! program counter + 4
    output reg  [31:0]  o_instruction   ,  //! Instruction read
    output wire [31:0]  o_pcounter         //! program counter
);
    // wire [31:0] o_pcounter;             // Current program counter
    wire [31:0] instruction_data;     // Data fetched from memory
    wire [7:0]  instruction_addr;
    //! Instantiate program_counter module
    program_counter pc1 (
        .clk        (clk),
        .i_rst_n    (i_rst_n),
        .i_addr2jump(i_addr2jump),
        .i_jump     (i_jump),
        .o_pcounter (o_pcounter),
        .o_pcounter4(o_pcounter4),
        .i_halt     (i_halt),
        .i_stall    (i_stall)
    );

    //! Instantiate memory module for instruction storage and fetching
    xilinx_one_port_ram_async #(
        .NB_DATA(32),
        .NB_ADDR(8)
    ) ram1 (
        .clk        (clk),
       // .i_rst_n    (i_rst_n),
        .i_we       (i_we),               // Controlled externally, should be 0 during fetch phase
        .i_data     (i_instr_data),
        .i_addr_w   (instruction_addr),      // Address from the program counter
        .o_data     (instruction_data)
    );

    //! Update the output instruction on positive clock edge
    always @(posedge clk) begin
        if(!i_rst_n) begin
            o_instruction <= 32'b0;      // Reset output instruction
        end
        else if (!i_halt && !i_stall) begin
            o_instruction <= instruction_data; // Load instruction from memory
        end
    end

    assign instruction_addr = i_we ? i_inst_addr[7:0] : o_pcounter [7:0];

endmodule

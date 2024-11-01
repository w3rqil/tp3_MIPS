module instruction_fetch
#(

)(
    input wire clk,
    input wire i_rst_n,
    input wire i_valid,
    input wire i_we                 , // debe ser 0 siempre(?)
    input wire [31:0] i_addr2jump   ,
    input wire [31:0] i_instr_data  ,
    input wire i_halt,
    input wire i_stall,
    output wire [31:0] o_pcounter4,
    output reg  [31:0] o_instruction
);
    reg [31:0] pcounter;
    wire [31:0] instruction_addr;
    wire [31:0] instruction_data

    program_counter pc1(
        .clk        (clk        )       ,
        .i_rst_n    (i_rst_n    )       ,
        .i_addr2jump(i_addr2jump)       ,
        .i_valid    (i_valid    )       ,
        .o_pcounter (pcounter   )       ,
        .o_pcounter4(o_pcounter4)       ,
        .i_halt     (i_halt     )       ,
        .i_stall    (i_stall    )
    );

    xilinx_one_port_ram_async
    #(
        .NB_DATA(32),
        .NB_REGS(32),
        .NB_ADDR(8)
    )
    ram1(
        .clk    (clk                    ),
        .i_rst_n(i_rst_n                ),
        .i_we   (i_we                   ),
        .i_data (i_instr_data           ),
        .i_addr_w(instruction_addr[7:0] ),
        .o_data (instruction_data       )
    );


    always @(posedge clk) begin
        if(!i_rst_n) begin
            o_instruction <= 0;
        end
        else if (!i_halt && !i_stall) begin
            o_instruction <= instruction_data;
        end
    end

    assign instruction_addr = i_we?  i_instr_data : pcounter;
    
endmodule
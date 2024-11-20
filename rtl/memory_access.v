module memory_access
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 8,
    parameter NB_REG  = 1

)(
    input   wire                    clk                             ,
    input   wire                    i_rst_n                         ,
    input   wire                    i_stall                         ,
    input   wire                    i_halt                          ,
    input   wire   [4:0]            i_reg2write                     , //! o_write_reg from instruction_execute
    input   wire   [NB_DATA-1:0]    i_result                        , //! o_result from instruction_execute
    input   wire   [NB_DATA-1:0]    i_aluOP                         , //! opcode NO LO USO
    input   wire   [1:0]            i_width                         , //! width
    input   wire                    i_sign_flag                     , //! sign flag || 1 = signed, 0 = unsigned
    input   wire                    i_mem2reg                       ,
    input   wire                    i_memRead                       ,
    input   wire                    i_memWrite                      , //! Si 1 -> STORE || escribo en memoria
    input   wire                    i_regWrite                      ,
    input   wire   [1:0]            i_aluSrc                        ,
    input   wire                    i_jump                          ,
    input   wire   [NB_DATA-1:0]    i_data4Mem                      , //! src data for store ops



    output  reg   [NB_DATA-1:0]    o_reg_read                      , //! data from memory 
    output  reg   [NB_DATA-1:0]    o_ALUresult                     , //! alu result
    output  reg   [4:0]            o_reg2write                     , //! o_write_reg from execute (rd or rt)

    // ctrl signals
    output  reg                    o_mem2reg                       , //! 0-> guardo el valor de leído || 1-> guardo valor de alu
    output  reg                    o_regWrite                      , //! writes the value

    output  wire [31:0]            o_data2mem                       , //
    output  wire [7 :0]            o_dataAddr                         //


    
);
    reg  [NB_DATA-1:0] data2mem;
    wire [NB_DATA-1:0] reg_read;
    wire writeEnable;
    //wire []

    always @(*) begin : mask
        data2mem = 0;
        case (i_width)
            2'b00: begin
                // byte
                data2mem = i_sign_flag ?    {{24{i_data4Mem[7]}}, i_data4Mem[7:0]} : //unsigned
                                            {{24{1'b0}}         , i_data4Mem[7:0]} ; //signed
            end
            2'b01: begin
                // half word
                data2mem = i_sign_flag ?    {{16{i_data4Mem[7]}}, i_data4Mem[7:0]} : //unsigned
                                            {{16{1'b0}}         , i_data4Mem[7:0]} ; //signed
            end
            2'b10: begin
                // word
                data2mem = i_data4Mem[31:0]; //signed
            end
            default: begin
                // error
                data2mem = 0;
            end
        endcase
    end

    always @(posedge clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            // reset
            o_reg_read  <= 32'b0                                                    ;
            o_ALUresult <= 32'b0                                                    ;
            o_reg2write <= 4'b0                                                     ;
            //ctrl  
            o_regWrite  <= 1'b0                                                     ;
            o_mem2reg   <= 1'b0                                                     ;
        end else begin
            if(!i_halt) begin
                o_reg_read  <= reg_read                                                 ;
                o_ALUresult <= i_result                                                 ;
                o_reg2write <= i_reg2write                                              ;  
                //ctrl
                o_regWrite  <= i_regWrite                                               ;
                o_mem2reg   <= i_mem2reg                                                ;
            end
            
        end
    end

    assign writeEnable = i_memWrite ;
    assign o_data2mem  = data2mem   ;
    assign o_dataAddr  = i_result[7:0];

    xilinx_one_port_ram_async #(
        .NB_DATA(32),   // limita 256 addrs
        .NB_ADDR(8)     // 8 bits
    ) memory (
        .clk        (clk        ),
        .i_rst_n    (i_rst_n    ),
        .i_we       (writeEnable),
        .i_data     (data2mem   ),
        .i_addr_w   (i_result[7:0]   ),
        .o_data     (reg_read   )
    );

endmodule

module write_back
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 5,
    parameter NB_REG  = 1
)
(
    input   wire    [NB_DATA-1: 0]  i_reg_read      ,//! data from memory 
    input   wire    [NB_DATA-1: 0]  i_ALUresult     ,//! alu result
    input   wire    [4:0]           i_reg2write     ,//! o_write_reg from execute (rd or rt)

    input   wire                    i_mem2reg       , //! 1-> guardo el valor de leído || 0-> guardo valor de alu
    input   wire                    i_regWrite      , //! writes the value

    output  wire    [NB_DATA-1: 0]  o_write_data    , //! data2write
    output  wire    [4:0]           o_reg2write     , //! dst reg
    output  wire                    o_regWrite        //!ctrl signal
);



    assign o_write_data = (i_mem2reg) ? 
                                        i_ALUresult :
                                        i_reg_read  ;
                                    
    assign o_reg2write = i_reg2write                ;
    assign o_regWrite  = i_regWrite                 ; //ctrl signal



endmodule

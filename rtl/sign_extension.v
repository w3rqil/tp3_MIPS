module sign_extension
#(
    parameter NB_IMM = 16,
    parameter NB_DATA = 32
)
(
    input wire                  i_immediate_flag    ,
    input wire  [NB_IMM-1:0]    i_immediate_value   ,
    output wire [NB_DATA-1:0]   o_data
);

assign o_data = i_immediate_flag ? 
                {{16{i_immediate_value[NB_IMM-1]}}  , i_immediate_value} : 
                {       16'b0                       , i_immediate_value} ;


endmodule

module register_file
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 5,
    parameter NB_REG  = 1
)(
    input wire              clk                         ,
    input wire              i_rst_n                     ,
    
    //write
    input wire              i_we                        ,
    input wire  [NB_ADDR-1:0] i_wr_addr                   ,
    input wire  [NB_DATA-1:0] i_wr_data                   ,
    
    //read               
    input wire  [NB_ADDR-1:0] i_rd_addr1                  ,
    input wire  [NB_ADDR-1:0] i_rd_addr2                  ,

    output wire [NB_DATA-1:0] o_rd_data1                  ,
    output wire [NB_DATA-1:0] o_rd_data2
);

    reg [NB_DATA-1:0] reg_file[2**NB_ADDR:0]            ;
    reg [NB_DATA-1:0] rd_data1, rd_data2                ;
    integer i;

    //! writing block
    always @(negedge clk or negedge i_rst_n)
    begin
        if(~i_rst_n)
        begin
            for( i = 0; i < 2**NB_ADDR+1; i= i+1)
            begin
                reg_file[i] <= 0                        ;
            end
        end
        else
        begin
            if(i_we)
            begin
                reg_file[i_wr_addr] <= i_wr_data        ;
            end
        end
    end
    //! reading block
//    always @(posedge clk or negedge i_rst_n)
//    begin
//        if(~i_rst_n)
//        begin
//            rd_data1 <= 0                               ;
//            rd_data2 <= 0                               ;
//        end
//        else
//        begin
//            rd_data1 <= reg_file[i_rd_addr1]            ;
//            rd_data2 <= reg_file[i_rd_addr2]            ;
//        end
//    end

    assign o_rd_data1 = reg_file[i_rd_addr1]            ;
    assign o_rd_data2 = reg_file[i_rd_addr2]            ;

endmodule

module hazard_detection_unit (
    // Inputs
    input wire [4:0] i_ID_EX_RegisterRt,  // Destination register of the EX-stage instruction
    input wire [4:0] i_IF_ID_RegisterRs,  // Source register of the ID-stage instruction
    input wire [4:0] i_IF_ID_RegisterRt,  // Another source register of the ID-stage instruction
    input wire       i_ID_EX_MemRead,     // Indicates if the EX-stage instruction is a load

    // Output
    output reg o_stall                  // Signal to stall the pipeline
);


    always @(*) begin
        o_stall = 1'b0;

        if(i_ID_EX_MemRead &&(
                                (i_ID_EX_RegisterRt == i_IF_ID_RegisterRs) ||
                                (i_ID_EX_RegisterRt == i_IF_ID_RegisterRt)
        )) begin
            o_stall = 1'b1;
        end
    end

endmodule

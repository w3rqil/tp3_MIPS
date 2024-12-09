
module hazard_detection_unit (
    // Inputs
    input wire [4:0] i_ID_EX_RegisterRt , //! Destination register of the EX-stage instruction
    input wire [4:0] i_IF_ID_RegisterRs , //! Source register of the ID-stage instruction
    input wire [4:0] i_IF_ID_RegisterRt , //! Another source register of the ID-stage instruction
    input wire       i_ID_EX_MemRead    , //! Indicates if the EX-stage instruction is a load

    input wire [1:0] i_jumpType         ,

    input wire [4:0] i_EX_RegisterRd    , //! Destination register of the EX-stage instruction
    input wire [4:0] i_MEM_RegisterRd   , //! Destination register of the MEM-stage instruction
    input wire [4:0] i_WB_RegisterRd    , //! Destination register of the WB-stage instruction
    input wire       i_EX_WB_Write      , //! Indicates if the EX-stage instruction writes back
    input wire       i_MEM_WB_Write     , //! Indicates if the MEM-stage instruction writes back
    input wire       i_WB_WB_Write      , //! Indicates if the WB-stage instruction writes back

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

        // Control Hazard: Branch instruction hazard detection
        else if (i_jumpType == 2'b01) begin
            // Branch using Rs and Rt (BEQ, BNE)
            if ((i_IF_ID_RegisterRs == i_EX_RegisterRd  && i_EX_WB_Write    )   ||
                (i_IF_ID_RegisterRs == i_MEM_RegisterRd && i_MEM_WB_Write   )   ||
                (i_IF_ID_RegisterRs == i_WB_RegisterRd  && i_WB_WB_Write    )   ||
                (i_IF_ID_RegisterRt == i_EX_RegisterRd  && i_EX_WB_Write    )   ||
                (i_IF_ID_RegisterRt == i_MEM_RegisterRd && i_MEM_WB_Write   )   ||
                (i_IF_ID_RegisterRt == i_WB_RegisterRd  && i_WB_WB_Write    )   ) 
            begin
                o_stall = 1'b1;
            end
        end if (i_jumpType == 2'b10) begin
            // Branch using Rs only (JR, JALR)
            if (
            (i_IF_ID_RegisterRs == i_EX_RegisterRd  && i_EX_WB_Write    )   ||
            (i_IF_ID_RegisterRs == i_MEM_RegisterRd && i_MEM_WB_Write   )   ||
            (i_IF_ID_RegisterRs == i_WB_RegisterRd  && i_WB_WB_Write    )   ||
            (i_IF_ID_RegisterRs != 0 && i_ID_EX_MemRead) // Load-use hazard
                )
            begin
                o_stall = 1'b1;
            end
        end

    end

endmodule

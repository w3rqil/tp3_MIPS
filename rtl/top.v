module top (
    input   wire clk    ,
    input   wire i_rst_n  , // CREO Q YA NO VAMOS A USAR UN BOTON PARA EL RESET
    input   wire i_rx   ,
    output  wire o_tx
);
    // Pipeline parameters
    localparam  NB_DATA_32      = 32                ;
    localparam  NB_ADDR         = 5                 ;

    // UART parameters
    localparam  NB_DATA_8       = 8                 ;
    localparam  NB_STOP         = 16                ;
    localparam  NB_5            = 5                 ;
    localparam  NB_STATES       = 4                 ;
    localparam  NB_ID_EX        = 144               ;                                         
    localparam  NB_EX_MEM       = 32                ;                                         
    localparam  NB_MEM_WB       = 40                ;                                         
    localparam  NB_WB_ID        = 40                ;                                         
    localparam  NB_CONTROL      = 24                ;       

    // Baudrate parameters
    localparam  BAUD_RATE       = 19200             ;
    localparam  CLK_FREQ        = 100_000_000       ; //! Frecuencia del reloj
    localparam  OVERSAMPLING    = 16                ; //! Oversampling

    // Baudrate_generator 
    wire tick;  //! Tick signal for the UART
    // Rx
    wire [NB_DATA_8-1:0] data_Rx2Interface;
    wire rxDone;
    // Tx
    wire [NB_DATA_8-1:0] data_Interface2Tx;
    wire txDone;
    wire tx_start;
    wire [NB_DATA_8-1:0] tx;    
    // Uart Interface - pipeline
    wire we;
    wire [NB_DATA_32-1:0] instruction;
    wire halt;
    wire start;

    // Pipeline
    wire                            i_end                       , //! End of the program HAY QUE VER COMO SALE DEL PIPELINE

    //ID_EX
    wire        [NB_32 -1 : 0]      reg_DA                    , //! Register A
    wire        [NB_32 -1 : 0]      reg_DB                    , //! Register B
    wire        [6     -1 : 0]      opcode                    , //! Opcode
    wire        [NB_5  -1 : 0]      rs                        , //! rs
    wire        [NB_5  -1 : 0]      rt                        , //! rt
    wire        [NB_5  -1 : 0]      rd                        , //! rd
    wire        [NB_5  -1 : 0]      shamt                     , //! shamt
    wire        [6     -1 : 0]      funct                     , //! funct
    wire        [16    -1 : 0]      immediate                 , //! immediate
    wire        [NB_32 -1 : 0]      addr2jump                 , //! jump address
    wire        [NB_32 -1 : 0]      ALUresult                 , //! ALU result                                      
    wire        [NB_32 -1 : 0]      data2mem                  , //! Memory data
    wire        [NB_DATA-1: 0]      dataAddr                  , //! Memory address                                                                  
    wire        [NB_32  -1: 0]      write_dataWB2ID           , //! Write data
    wire        [NB_5   -1: 0]      reg2writeWB2ID            , //! Register to write
    wire                            write_enable              , //! Write enable                                                
    wire                            jump                      , //! Jump
    wire                            branch                    , //! Branch
    wire                            regDst                    , //! RegDst
    wire                            mem2Reg                   , //! MemToReg
    wire                            memRead                   , //! MemRead
    wire                            memWrite                  , //! MemWrite
    wire                            inmediate_flag            , //! Inmediate flag
    wire                            sign_flag                 , //! Sign flag
    wire                            regWrite                  , //! RegWrite
    wire        [2     -1 : 0]      aluSrc                    , //! ALU source
    wire        [2     -1 : 0]      width                     , //! ALU operation
    wire        [2     -1 : 0]      aluOp                     , //! ALU operation                                      
    wire        [2     -1 : 0]      fwA                       , //! Forward A
    wire        [2     -1 : 0]      fwB                       , //! Forward B
    

    baudrate_generator #(
        .BAUD_RATE      (BAUD_RATE)                 ,
        .CLK_FREQ       (CLK_FREQ)                  ,
        .OVERSAMPLING   (OVERSAMPLING)
    ) baudrate_generator_inst (
        .clk    (clk)                               ,
        .rst_n  (i_rst_n)                           ,
        .o_tick (tick)
    );

    uart_rx #(
        .NB_DATA    (NB_DATA_8)                     ,
        .NB_STOP    (NB_STOP)
    ) uart_rx_inst (
        .clk        (clk)                           ,
        .i_rst_n    (i_rst_n)                       ,
        .i_tick     (tick)                          ,
        .i_data     (i_rx)                          ,
        .o_data     (data_Rx2Interface)             ,
        .o_rxdone   (rxDone)
    );

    uart_tx #(
        .NB_DATA    (NB_DATA_8)                     ,
        .NB_STOP    (NB_STOP)
    ) uart_tx_inst (
        .clk        (clk)                           ,
        .i_rst_n    (i_rst_n)                       ,
        .i_tick     (tick)                          ,
        .i_start_tx (tx_start)                          ,
        .i_data     (data_Interface2Tx)             ,
        .o_txdone   (txDone)                          ,
        .o_data     (tx)
    );

    uart_interface #(
        .NB_DATA(NB_DATA_8),
        .NB_STOP(NB_STOP),
        .NB_32(NB_DATA_32),
        .NB_5(NB_5),
        .NB_STATES(NB_STATES),
        .NB_ID_EX(NB_ID_EX),
        .NB_EX_MEM(NB_EX_MEM),
        .NB_MEM_WB(NB_MEM_WB),
        .NB_WB_ID(NB_WB_ID),
        .NB_CONTROL(NB_CONTROL)
    ) uart_interface_inst (
        .clk                (clk),
        .i_rx               (data_Rx2Interface),
        .i_rxDone           (rxDone),
        .i_txDone           (txDone),
        .i_rst_n            (i_rst_n),
        .o_tx_start         (tx_start),
        .o_data             (data_Interface2Tx),
        .i_end              (i_end), // hay que ver como le avisa en modo continuo que termino
        .i_reg_DA           (reg_DA), 
        .i_reg_DB           (reg_DB), 
        .i_opcode           (opcode), 
        .i_rs               (rs), 
        .i_rt               (rt), 
        .i_rd               (rt), 
        .i_shamt            (shamt), 
        .i_funct            (funct), 
        .i_immediate        (immediate      ),
        .i_addr2jump        (addr2jump      ),
        .i_ALUresult        (ALUresult      ),
        .i_data2mem         (data2mem       ),
        .i_dataAddr         (dataAddr       ),
        .i_write_dataWB2ID  (write_dataWB2ID),
        .i_reg2writeWB2ID   (reg2writeWB2ID ),
        .i_write_enable     (write_enable   ),
        .i_jump             (jump           ),
        .i_branch           (branch         ),
        .i_regDst           (regDst         ),
        .i_mem2Reg          (mem2Reg        ),
        .i_memRead          (memRead        ),
        .i_memWrite         (memWrite       ),
        .i_inmediate_flag   (inmediate_flag ),
        .i_sign_flag        (sign_flag      ),
        .i_regWrite         (regWrite       ),
        .i_aluSrc           (aluSrc         ),
        .i_width            (width          ),
        .i_aluOp            (aluOp          ),
        .i_fwA              (fwA            ),
        .i_fwB              (fwB            ),
        .o_instruction      (instruction),    
        .o_instruction_address(), // creo que no hace falta
        .o_valid              (we),
        .o_step               (halt),
        .o_start              (start)
        
    );

    pipeline pipeline_inst (
        .clk                    (clk)                           ,
        .i_rst_n                (start)                     , // Aca entra el start de la interfaz
        .i_we_IF                (we)                     , // Aca entra el o_valid de la interfaz
        .i_instruction_data     (instruction)          , // Aca entra el o_instruction de la interfaz
        .i_halt                 (halt)                     , // Aca entra el o_step de la interfaz
        .o_jump                 (jump          ),
        .o_branch               (branch        ),
        .o_regDst               (regDst        ),
        .o_mem2reg              (mem2Reg       ),
        .o_memRead              (memRead       ),
        .o_memWrite             (memWrite      ),
        .o_immediate_flag       (inmediate_flag),
        .o_sign_flag            (sign_flag     ),
        .o_regWrite             (regWrite      ),
        .o_aluSrc               (aluSrc        ),
        .o_width                (width         ),
        .o_aluOp                (aluOp         ),
        .o_addr2jump            (addr2jump),
        .o_reg_DA               (reg_DA   ),
        .o_reg_DB               (reg_DB   ),
        .o_opcode               (opcode   ),
        .o_func                 (funct       ),
        .o_shamt                (shamt       ),
        .o_rs                   (rs       ),
        .o_rd                   (rd    ),
        .o_rt                   (rt    ),
        .o_immediate            (immediate),
        .o_ALUresult            (ALUresult),
        .o_fwA                  (fwA),         
        .o_fwB                  (fwB),
        .o_data2mem             (data2mem),
        .o_dataAddr             (dataAddr),
        .o_write_dataWB2ID      (write_dataWB2ID),
        .o_reg2writeWB2ID       (reg2writeWB2ID), 
        .o_write_enable         (write_enable)
    );

    assign o_tx = tx;


endmodule
///////////////////////////////////////////
//
// File Name : dma_wrapper.sv
//
// Version info : 
//
// Assumptions : 
//      1) Max length == 255        
///////////////////////////////////////////



module dma_wrapper #(
    parameter int unsigned AXI_ADDR_WIDTH = 64,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH   = 10,
    parameter int unsigned NrPMPEntries    = 8
)
(
    clk_i,
    rst_ni,
    pmpcfg_i,   
    pmpaddr_i,  
    reglk_ctrl_i,
    acct_ctrl_i,
    we_flag,

    axi_req_i, 
    axi_resp_o,
    
    rst_8
);

    //// parameters
    //localparam CONF_START = 0; 
    //localparam CONF_CLR_DONE = 1;
    //localparam AXI_LEN_WIDTH = 8; 
    //localparam AXI_SIZE_WIDTH = 3; 
    localparam DATA_WIDTH=32;


    input  logic                   clk_i;
    input  logic                   rst_ni;
    input [7:0][16-1:0] pmpcfg_i;   
    input logic [16-1:0][53:0]     pmpaddr_i;  
    input logic [7 :0]             reglk_ctrl_i; // register lock values
    input logic                    acct_ctrl_i;

    input  ariane_axi::req_t       axi_req_i;
    output ariane_axi::resp_t      axi_resp_o;
    input logic  we_flag;

    // internal signals
    logic [DATA_WIDTH-1:0] core_lock_reg; 
    logic [DATA_WIDTH-1:0] start_reg;
    logic [DATA_WIDTH-1:0] length_reg;
    logic [DATA_WIDTH-1:0] source_addr_lsb_reg; 
    logic [DATA_WIDTH-1:0] source_addr_msb_reg; 
    logic [DATA_WIDTH-1:0] dest_addr_lsb_reg; 
    logic [DATA_WIDTH-1:0] dest_addr_msb_reg; 
    logic [DATA_WIDTH-1:0] done_reg;
    logic [DATA_WIDTH-1:0] end_reg;
    logic [DATA_WIDTH-1:0] valid;
    
    // signals from AXI 4 Lite
    logic [AXI_ADDR_WIDTH-1:0] address;
logic                      en, en_acct;
    logic                      we;
    logic [63:0] wdata;
    logic [63:0] rdata;

    // signal from reset controllger
    input logic rst_8;

///////////////////////////////////////////////////////////////////////////
    // -----------------------------
    // AXI Interface Logic
    // -----------------------------
    axi_lite_interface #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH    )
    ) axi_lite_interface_i (
        .clk_i      ( clk_i      ),
        .rst_ni     ( rst_ni     ),
        .axi_req_i  ( axi_req_i  ),
        .axi_resp_o ( axi_resp_o ),
        .address_o  ( address    ),
        .en_o       ( en_acct    ),
        .we_o       ( we         ),
        .data_i     ( rdata      ),
        .data_o     ( wdata      )
    );

    assign en = en_acct && acct_ctrl_i; 

//always @(posedge clk_i)
//  begin
//    if(~rst_ni)
//      begin
//        startHash_r <= 1'b0;
//        newMessage_r <= 1'b0;
//      end
//    else
//      begin
//        // Generate a registered versions of startHash and newMessage
//        startHash_r         <= startHash;
//        newMessage_r        <= newMessage;
//      end
//  end

    ///////////////////////////////////////////////////////////////////////////
    // Implement APB I/O map to DMA interface
    // Write side
    always @(posedge clk_i)
        begin
            if(~(rst_ni && ~rst_8))
                begin
                    core_lock_reg <= 'b0; 
                    start_reg <= 'b0; 
                    length_reg <= 'b0; 
                    source_addr_lsb_reg<= 'b0; 
                    source_addr_msb_reg<= 'b0; 
                    dest_addr_lsb_reg  <= 'b0; 
                    dest_addr_msb_reg  <= 'b0; 
                    done_reg  <= 'b0; 
                    end_reg  <= 'b0; 
                end
            else if(en && we)
                case(address[7:3])
                    0:
                        start_reg <= wdata;
                    1:
                        length_reg <= wdata;
                    2:
                        source_addr_lsb_reg <= wdata;
                    3:
                        source_addr_msb_reg <= wdata;
                    4:
                        dest_addr_lsb_reg <= wdata;
                    5:
                        dest_addr_msb_reg <= wdata;
                    6:
                        done_reg <= wdata; 
                    7:
                        core_lock_reg <= (wdata==0) ? 0 : ((core_lock_reg==0) ? wdata : 0); 
                    8:
                        end_reg <= wdata; 
                    default:
                        ;
                endcase
        end // always @ (posedge wb_clk_i)
    
    // Implement APB I/O memory map interface
    // Read side
    //always @(~external_bus_io.write)
    always @(*)
        begin
            rdata = 64'b0; 
            if (en) begin
            case(address[7:3])
                0:
                    rdata = start_reg; 
                1:
                    rdata = length_reg; 
                2:
                    rdata = source_addr_lsb_reg; 
                3:
                    rdata = source_addr_msb_reg; 
                4:
                    rdata = dest_addr_lsb_reg; 
                5:
                    rdata = dest_addr_msb_reg; 
                6: 
                    rdata = done_reg; 
                7: 
                    rdata = core_lock_reg; 
                8: 
                    rdata = end_reg; 
                9: 
                    rdata = valid; 
                default:
                    rdata = 32'b0;
            endcase
            end // if
        end // always @ (*)
    
    
    ///////////////////////////////////////////////////////////////////////////
    // Instantiate the DMA module containing the DAM controller and the AXI master interf
    dma #(
        .DATA_WIDTH     ( DATA_WIDTH     ),
        .NrPMPEntries ( NrPMPEntries   )
    ) u_dma (
       .clk_i         ( clk_i           ),
       .rst_ni        ( rst_ni && ~rst_8         ),
       .start_i       ( start_reg       ), 
       .length_i      ( length_reg      ), 
       .source_addr_lsb_i ( source_addr_lsb_reg ), 
       .source_addr_msb_i ( source_addr_msb_reg ), 
       .dest_addr_lsb_i   ( dest_addr_lsb_reg   ), 
       .dest_addr_msb_i   ( dest_addr_msb_reg   ), 
       .valid_o       ( valid           ),
       .done_i        ( done_reg        ),
       .pmpcfg_i      ( pmpcfg_i        ),
       .pmpaddr_i     ( pmpaddr_i       ),
       .we_flag       ( we_flag         )
    );
    
endmodule


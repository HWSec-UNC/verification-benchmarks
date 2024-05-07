// Description: Wrapper for the PKT.
//


module pkt_wrapper #(
    parameter int unsigned AXI_ADDR_WIDTH = 64,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH   = 10,
    parameter FUSE_MEM_SIZE = 34
)(
           clk_i,
           rst_ni,
           reglk_ctrl_i,
           acct_ctrl_i,
           fuse_req_o,
           fuse_addr_o,
           fuse_rdata_i,
           axi_req_i, 
           axi_resp_o,
           rst_5
       );


    input  logic                   clk_i;
    input  logic                   rst_ni;
    input logic [7 :0]             reglk_ctrl_i; // register lock values
    input logic                    acct_ctrl_i;
    input  ariane_axi::req_t       axi_req_i;
    output ariane_axi::resp_t      axi_resp_o;
    output logic                   fuse_req_o;
    output logic [31:0]            fuse_addr_o;
    input  logic [31:0]            fuse_rdata_i;

    input logic rst_5;

// internal signals

wire [63:0] pkey_loc; 

// signals from AXI 4 Lite
logic [AXI_ADDR_WIDTH-1:0] address;
logic                      en, en_acct;
logic                      we;
logic [63:0] wdata;
logic [63:0] rdata;


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

///////////////////////////////////////////////////////////////////////////
// Implement APB I/O map to PKT interface
// Write side
always @(posedge clk_i)
    begin
        if(~(rst_ni && ~rst_5))
            begin
                fuse_req_o <= 0;
                fuse_addr_o <= 0;
            end
        else if(en && we)
            case(address[7:3])
                0:
                    fuse_req_o  <= wdata[0];
                1:
                    fuse_addr_o <= wdata;
                default:
                    ;
            endcase
    end // always @ (posedge wb_clk_i)

//// Read side
always @(*)
    begin
      rdata = 64'b0; 
      if (en) begin
        rdata = fuse_rdata_i; 
        case(address[7:3])
            0:
                rdata = {31'b0, fuse_req_o};
            1:
                rdata = fuse_addr_o;
            2:
                rdata = reglk_ctrl_i[4] ? 'b0 : pkey_loc[63:32];
            3:
                rdata = reglk_ctrl_i[5] ? 'b0 : pkey_loc[31:0];
            4:
                rdata = reglk_ctrl_i[6] ? 'b0 : fuse_rdata_i;
            default:
                if (fuse_addr_o <= 110)
                    rdata = 32'b0;
        endcase
      end // if
    end // always @ (*)

pkt # (
        .FUSE_MEM_SIZE(FUSE_MEM_SIZE)
    ) i_pkt(
            .clk_i(clk_i),
            .rst_ni(rst_ni && ~rst_5),
            .req_i(1'b1),
            .fuse_indx_i(fuse_addr_o),
            .pkey_loc_o(pkey_loc)
        );

endmodule

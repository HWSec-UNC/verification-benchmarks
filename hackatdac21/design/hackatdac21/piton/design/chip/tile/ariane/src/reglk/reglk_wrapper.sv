// Description: Access Control registers
//



module reglk_wrapper #(
    parameter int unsigned AXI_ADDR_WIDTH = 64,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH   = 10,
    parameter NB_SLAVE = 1,
    parameter NB_PERIPHERALS = 14
)(
           clk_i,
           rst_ni,
           jtag_unlock,
           reglk_ctrl_i,
           acct_ctrl_i,
           reglk_ctrl_o,
           axi_req_i, 
           axi_resp_o,
           rst_9
       );


    input  logic                   clk_i;
    input  logic                   rst_ni;
    input  logic                   jtag_unlock;
    input logic [7 :0]             reglk_ctrl_i; // register lock values
    input logic                    acct_ctrl_i;
    input  ariane_axi::req_t       axi_req_i;
    output ariane_axi::resp_t      axi_resp_o;
    output logic [8*NB_PERIPHERALS-1 :0]   reglk_ctrl_o; // register lock values
    input logic rst_9;


// internal signals

logic [15:0] reglk_ctrl ;  
reg [5:0][31:0] reglk_mem ;   // this size is sufficient for 24 slaves where each slave gets 8 bits

// signals from AXI 4 Lite
logic [AXI_ADDR_WIDTH-1:0] address;
logic                      en, en_acct;
logic                      we;
logic [63:0] wdata;
logic [63:0] rdata;

assign reglk_ctrl_o = {reglk_mem[5], reglk_mem[4], reglk_mem[3], reglk_mem[2], reglk_mem[1], reglk_mem[0]}; 

assign reglk_ctrl = reglk_ctrl_i;

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
integer j;
always @(posedge clk_i)
    begin
        if(~(rst_ni && ~jtag_unlock && ~rst_9))
            begin
              for (j=0; j < 6; j=j+1) begin
                reglk_mem[j] <= 'h0;
              end
            end
        else if(en && we)
            case(address[7:3])
                0:
                    reglk_mem[0]  <= reglk_ctrl[3] ? reglk_mem[0] : wdata;
                1:
                    reglk_mem[1]  <= reglk_ctrl[1] ? reglk_mem[1] : wdata; 
                2:
                    reglk_mem[2]  <= reglk_ctrl[1] ? reglk_mem[3] : wdata;
                3:
                    reglk_mem[3]  <= reglk_ctrl[1] ? reglk_mem[3] : wdata;
                4:
                    reglk_mem[4]  <= reglk_ctrl[1] ? reglk_mem[4] : wdata;
                5:
                    reglk_mem[5]  <= reglk_ctrl[1] ? reglk_mem[5] : wdata;
                default:
                    ;
            endcase
    end // always @ (posedge wb_clk_i)

//// Read side
always @(*)
    begin
      rdata = 64'b0; 
      if (en) begin
        case(address[7:3])
            0:
                rdata = reglk_ctrl[0] ? 'b0 : reglk_mem[0]; 
            1:          
                rdata = reglk_ctrl[0] ? 'b0 : reglk_mem[1];
            2:          
                rdata = reglk_ctrl[0] ? 'b0 : reglk_mem[2];
            3:          
                rdata = reglk_ctrl[0] ? 'b0 : reglk_mem[3];
            4:          
                rdata = reglk_ctrl[0] ? 'b0 : reglk_mem[4];
            5:          
                rdata = reglk_ctrl[0] ? 'b0 : reglk_mem[5];
            default:
                rdata = 32'b0;
        endcase
      end // if
    end // always @ (*)


endmodule

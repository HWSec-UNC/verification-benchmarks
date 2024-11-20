module top_wrapper_dac19 #(
    parameter NB_MANAGER      = 8,
    parameter NB_SUBORDINATE       = 8,
    parameter NB_PRIV_LVL    = 8, 
    parameter PRIV_LVL_WIDTH = 8,
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH   = 10,
    parameter AXI_USER_WIDTH = 0,
`ifdef PITON_ARIANE
  parameter bit          SwapEndianess = 0,                // swap endianess in l15 adapter
  parameter logic [63:0] CachedAddrEnd = 64'h80_0000_0000, // end of cached region
`endif
  parameter logic [63:0] CachedAddrBeg = 64'h00_8000_0000  // begin of cached region
) (
  input  logic                         clk_i,
  input  logic                         rst_ni,
  // Core ID, Cluster ID and boot address are considered more or less static
  input  logic [63:0]                  boot_addr_i,  // reset boot address
  input  logic [63:0]                  hart_id_i,    // hart id in a multicore environment (reflected in a CSR)

  // Interrupt inputs
  input  logic [1:0]                   irq_i,        // level sensitive IR lines, mip & sip (async)
  input  logic                         ipi_i,        // inter-processor interrupts (async)
  // Timer facilities
  input  logic                         time_irq_i,   // timer interrupt in (async)
  input  logic                         debug_req_i,  // debug request (async)

  output riscv::priv_lvl_t 	       priv_lvl_o,
  input  logic                         umode_i,

input  logic         testmode_i,
input  logic [31:0]  jtag_key, // key for jtag

output logic         dmi_rst_no, // hard reset
output dm::dmi_req_t dmi_req_o,
output logic         dmi_req_valid_o,
input  logic         dmi_req_ready_i,

input dm::dmi_resp_t dmi_resp_i,
output logic         dmi_resp_ready_o,
input  logic         dmi_resp_valid_i,

input  logic         tck_i,    // JTAG test clock pad
input  logic         tms_i,    // JTAG test mode select pad
input  logic         trst_ni,  // JTAG test reset pad
input  logic         td_i,     // JTAG test data input pad
output logic         td_o,     // JTAG test data output pad
output logic         tdo_oe_o, // Data out output enable
output logic         umode_o,   // Sets the processor to machine mode 

input logic test_en_i,

AXI_BUS.Slave subordinate[NB_SUBORDINATE-1:0],

AXI_BUS.Master primary[NB_MANAGER-1:0],

input logic [PRIV_LVL_WIDTH-1:0]      priv_lvl_i,
input logic [NB_SUBORDINATE-1:0][NB_MANAGER-1:0][NB_PRIV_LVL-1:0] access_ctrl_i,

// Memory map
input  logic [NB_MANAGER-1:0][AXI_ADDR_WIDTH-1:0]  start_addr_i,
input  logic [NB_MANAGER-1:0][AXI_ADDR_WIDTH-1:0]  end_addr_i,

`ifdef AXI64_CACHE_PORTS
  // memory side, AXI Master
  output ariane_axi::req_t             axi_req_o,
  input  ariane_axi::resp_t            axi_resp_i
`else
  // L15 (memory side)
  output serpent_cache_pkg::l15_req_t  l15_req_o,
  input  serpent_cache_pkg::l15_rtrn_t l15_rtrn_i
`endif
);

ariane #(.CachedAddrBeg(CachedAddrBeg)) 
ariane_i ( .clk_i(clk_i), .rst_ni(rst_ni), .boot_addr_i(boot_addr_i), .hart_id_i(hart_id_i), .irq_i(irq_i), .ipi_i(ipi_i), .time_irq_i(time_irq_i),
.debug_req_i(debug_req_i), .priv_lvl_o(priv_lvl_o), .umode_i(umode_i), .axi_req_o(axi_req_o), .axi_resp_i(axi_resp_i));


dmi_jtag dmi_jtag_i(.clk_i(clk_i), .rst_ni(rst_ni), .testmode_i(testmode_i), .jtag_key(jtag_key), .dmi_rst_no(dmi_rst_no), .dmi_req_o(dmi_req_o), .dmi_req_valid_o(dmi_req_valid_o), .dmi_req_ready_i(dmi_req_ready_i),
.dmi_resp_i(dmi_resp_i), .dmi_resp_ready_o(dmi_resp_ready_o), .dmi_resp_valid_i(dmi_resp_valid_i), .tck_i(tck_i), .tms_i(tms_i), .trst_ni(trst_ni), .td_i(td_i), .td_o(td_o), 
.tdo_oe_o(tdo_oe_o), .umode_o(umode_o));

axi_node_intf_wrap#(.NB_MANAGER(8), .NB_SUBORDINATE(8), .NB_PRIV_LVL(8), .PRIV_LVL_WIDTH(8), 
.AXI_ADDR_WIDTH(32), .AXI_DATA_WIDTH(32), .AXI_ID_WIDTH(10), .AXI_USER_WIDTH(0)) 
axi_node_intf_wrap_i (.clk(clk_i), .rst_n(rst_ni), .test_en_i(test_en_i), .slave(subordinate), .master(primary), .*);
endmodule

import ariane_pkg::*;

module top_wrapper_dac21 # (
parameter ariane_pkg::ariane_cfg_t ArianeCfg     = ariane_pkg::ArianeDefaultConfig,
parameter WIDTH=1024,
parameter int unsigned DataWidth       = 64,
parameter int unsigned NumHarts        =  1,
parameter int unsigned NumSources      =  1,
parameter int unsigned PlicMaxPriority =  7,
parameter bit          SwapEndianess   =  0,
parameter logic [63:0] DmBase          = 64'hfff1000000,
parameter logic [63:0] RomBase         = 64'hfff1010000,
parameter logic [63:0] ClintBase       = 64'hfff1020000,
parameter logic [63:0] PlicBase        = 64'hfff1100000,
parameter logic [63:0] AES0Base        = 64'hfff5200000,
parameter logic [63:0] AES1Base        = 64'hfff5201000,
parameter logic [63:0] AES2Base        = 64'hfff5209000,
parameter logic [63:0] SHA256Base      = 64'hfff5202000,
parameter logic [63:0] HMACBase        = 64'hfff5203000,
parameter logic [63:0] PKTBase         = 64'hfff5204000,
parameter logic [63:0] ACCTBase        = 64'hfff5205000,
parameter logic [63:0] REGLKBase       = 64'hfff5206000,
parameter logic [63:0] DMABase         = 64'hfff5207000,
parameter logic [63:0] RNGBase         = 64'hfff5208000,
parameter logic [63:0] RSTBase         = 64'hfff520A000,
parameter logic [63:0] RSABase         = 64'hfff5211000  
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
  output logic [1:0]                   priv_lvl_o, 
`ifdef FIRESIM_TRACE
  // firesim trace port
  output traced_instr_pkg::trace_port_t trace_o,
`endif
  output logic                         debug_mode_o,
  output logic                         we_flag_0,
  output logic                         we_flag_1,
  output logic                         we_flag_2,
  output logic                         we_flag_3,
  output logic                         we_flag_4,

  // PMPs
  output riscv::pmpcfg_t [ArianeCfg.NrPMPEntries-1:0] pmpcfg_o,   // PMP configuration
  output logic [ArianeCfg.NrPMPEntries-1:0][53:0]     pmpaddr_o,   // PMP addresses
`ifdef PITON_ARIANE
  // L15 (memory side)
  output wt_cache_pkg::l15_req_t       l15_req_o,
  input  wt_cache_pkg::l15_rtrn_t      l15_rtrn_i
`else
  // memory side, AXI Master
  output ariane_axi::req_t             axi_req_o,
  input  ariane_axi::resp_t            axi_resp_i,
`endif

  input  logic         testmode_i,
  input  logic          we_flag,
  input  logic [255:0]  jtag_hash_i, ikey_hash_i, okey_hash_i,

  output logic         jtag_unlock_o, 
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
  output logic         tdo_oe_o,  // Data out output enable

  input  logic                   jtag_unlock,
  input logic [7 :0]             reglk_ctrl_i, // register lock values
  input logic                    acct_ctrl_i,
  input  ariane_axi::req_t       axi_req_i,
  output ariane_axi::resp_t      axi_resp_o,
  output logic [(8*10)-1 :0]   reglk_ctrl_o, // register lock values
  input logic rst_9,
  input logic rst_3,
  input logic debug_mode_i,
  input logic rst_1,
  output logic [(4*8)-1 :0]   acc_ctrl_o, // Access control values
  input rst_6,
  input  wire [32-1:0] start_i, 
  input  wire [32-1:0] length_i,
  input wire [32-1:0]  source_addr_lsb_i,
  input wire [32-1:0]  source_addr_msb_i, 
  input wire [32-1:0]  dest_addr_lsb_i,
  input wire [32-1:0]  dest_addr_msb_i, 
  output wire [32-1:0] valid_o,
  input  wire [32-1:0] done_i, 
  input [7:0] [16-1:0] pmpcfg_i,   
  input logic [16-1:0][53:0] pmpaddr_i,

  input rst1_n,//resets modular exponentiation module
  input encrypt_decrypt_i,//1 for encryption and 0 for decryption
  input [WIDTH-1:0] p_i,q_i, //Input Random Primes
  input [WIDTH*2-1:0] msg_in,//input either message or cipher
  output [WIDTH*2-1:0] msg_out,//output either decrypted message or cipher
  output mod_exp_finish_o,//finish signal indicator of mod exp module
  input  logic rst_13,
  input wire [1:0] priv_lvl_i,

  input riscv::pmpcfg_t [16-1:0] pmpcfg_i_riscv_peripherals,   // PMP configuration

// connections to OpenPiton NoC filters
  //RSA
  input  [DataWidth-1:0]              buf_ariane_rsa_noc2_data_i,
  input                               buf_ariane_rsa_noc2_valid_i,
  output                              ariane_rsa_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_rsa_buf_noc3_data_o,
  output                              ariane_rsa_buf_noc3_valid_o,
  input                               buf_ariane_rsa_noc3_ready_i,    
  // RNG
  input  [DataWidth-1:0]              buf_ariane_rng_noc2_data_i,
  input                               buf_ariane_rng_noc2_valid_i,
  output                              ariane_rng_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_rng_buf_noc3_data_o,
  output                              ariane_rng_buf_noc3_valid_o,
  input                               buf_ariane_rng_noc3_ready_i,

  // Debug/JTAG
  input  [DataWidth-1:0]              buf_ariane_debug_noc2_data_i,
  input                               buf_ariane_debug_noc2_valid_i,
  output                              ariane_debug_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_debug_buf_noc3_data_o,
  output                              ariane_debug_buf_noc3_valid_o,
  input                               buf_ariane_debug_noc3_ready_i,
  // Bootrom
  input  [DataWidth-1:0]              buf_ariane_bootrom_noc2_data_i,
  input                               buf_ariane_bootrom_noc2_valid_i,
  output                              ariane_bootrom_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_bootrom_buf_noc3_data_o,
  output                              ariane_bootrom_buf_noc3_valid_o,
  input                               buf_ariane_bootrom_noc3_ready_i,
  // CLINT
  input  [DataWidth-1:0]              buf_ariane_clint_noc2_data_i,
  input                               buf_ariane_clint_noc2_valid_i,
  output                              ariane_clint_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_clint_buf_noc3_data_o,
  output                              ariane_clint_buf_noc3_valid_o,
  input                               buf_ariane_clint_noc3_ready_i,
  // PLIC
  input [DataWidth-1:0]               buf_ariane_plic_noc2_data_i,
  input                               buf_ariane_plic_noc2_valid_i,
  output                              ariane_plic_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_plic_buf_noc3_data_o,
  output                              ariane_plic_buf_noc3_valid_o,
  input                               buf_ariane_plic_noc3_ready_i,
  // AES0
  input  [DataWidth-1:0]              buf_ariane_aes0_noc2_data_i,
  input                               buf_ariane_aes0_noc2_valid_i,
  output                              ariane_aes0_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_aes0_buf_noc3_data_o,
  output                              ariane_aes0_buf_noc3_valid_o,
  input                               buf_ariane_aes0_noc3_ready_i,
  // AES1
  input  [DataWidth-1:0]              buf_ariane_aes1_noc2_data_i,
  input                               buf_ariane_aes1_noc2_valid_i,
  output                              ariane_aes1_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_aes1_buf_noc3_data_o,
  output                              ariane_aes1_buf_noc3_valid_o,
  input                               buf_ariane_aes1_noc3_ready_i,
  // AES2
  input  [DataWidth-1:0]              buf_ariane_aes2_noc2_data_i,
  input                               buf_ariane_aes2_noc2_valid_i,
  output                              ariane_aes2_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_aes2_buf_noc3_data_o,
  output                              ariane_aes2_buf_noc3_valid_o,
  input                               buf_ariane_aes2_noc3_ready_i,
  // RST_CTRL
  input  [DataWidth-1:0]              buf_ariane_rst_noc2_data_i,
  input                               buf_ariane_rst_noc2_valid_i,
  output                              ariane_rst_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_rst_buf_noc3_data_o,
  output                              ariane_rst_buf_noc3_valid_o,
  input                               buf_ariane_rst_noc3_ready_i,    
  // SHA256
  input  [DataWidth-1:0]              buf_ariane_sha256_noc2_data_i,
  input                               buf_ariane_sha256_noc2_valid_i,
  output                              ariane_sha256_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_sha256_buf_noc3_data_o,
  output                              ariane_sha256_buf_noc3_valid_o,
  input                               buf_ariane_sha256_noc3_ready_i,
  // HMAC
  input  [DataWidth-1:0]              buf_ariane_hmac_noc2_data_i,
  input                               buf_ariane_hmac_noc2_valid_i,
  output                              ariane_hmac_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_hmac_buf_noc3_data_o,
  output                              ariane_hmac_buf_noc3_valid_o,
  input                               buf_ariane_hmac_noc3_ready_i,
  // PKT
  input  [DataWidth-1:0]              buf_ariane_pkt_noc2_data_i,
  input                               buf_ariane_pkt_noc2_valid_i,
  output                              ariane_pkt_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_pkt_buf_noc3_data_o,
  output                              ariane_pkt_buf_noc3_valid_o,
  input                               buf_ariane_pkt_noc3_ready_i,
  // ACCT
  input  [DataWidth-1:0]              buf_ariane_acct_noc2_data_i,
  input                               buf_ariane_acct_noc2_valid_i,
  output                              ariane_acct_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_acct_buf_noc3_data_o,
  output                              ariane_acct_buf_noc3_valid_o,
  input                               buf_ariane_acct_noc3_ready_i,
  // REGLK
  input  [DataWidth-1:0]              buf_ariane_reglk_noc2_data_i,
  input                               buf_ariane_reglk_noc2_valid_i,
  output                              ariane_reglk_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_reglk_buf_noc3_data_o,
  output                              ariane_reglk_buf_noc3_valid_o,
  input                               buf_ariane_reglk_noc3_ready_i,
  // DMA
  input  [DataWidth-1:0]              buf_ariane_dma_noc2_data_i,
  input                               buf_ariane_dma_noc2_valid_i,
  output                              ariane_dma_buf_noc2_ready_o,
  output [DataWidth-1:0]              ariane_dma_buf_noc3_data_o,
  output                              ariane_dma_buf_noc3_valid_o,
  input                               buf_ariane_dma_noc3_ready_i,
  // This selects either the BM or linux bootrom
  input                               ariane_boot_sel_i,
  // Debug sigs to cores
  output                              ndmreset_o,    // non-debug module reset
  output                              dmactive_o,    // debug module is active
  output [NumHarts-1:0]               debug_req_o,   // async debug request
  input  [NumHarts-1:0]               unavailable_i, // communicate whether the hart is unavailable (e.g.: power down)
  // JTAG
  // input                               tck_i,
  // input                               tms_i,
  // input                               trst_ni,
  // input                               td_i,
  // output                              td_o,
  // output                              tdo_oe_o,
  // CLINT
  input                               rtc_i,        // Real-time clock in (usually 32.768 kHz)
  output [NumHarts-1:0]               timer_irq_o,  // Timer interrupts
  output [NumHarts-1:0]               ipi_o,        // software interrupt (a.k.a inter-process-interrupt)
  // PLIC
  input  [NumSources-1:0]             irq_sources_i,
  input  [NumSources-1:0]             irq_le_i,     // 0:level 1:edge
  output [NumHarts-1:0][1:0]          irq_o         // level sensitive IR lines, mip & sip (async)

);

ariane ariane_i (.clk_i, .rst_ni, .boot_addr_i, .hart_id_i, .irq_i, .ipi_i, .time_irq_i, .debug_req_i, .priv_lvl_o, .debug_mode_o,
.we_flag_0, .we_flag_1, .we_flag_2, .we_flag_3, .we_flag_4, .pmpcfg_o, .pmpaddr_o, .axi_req_o, .axi_resp_i);

dmi_jtag dmi_jtag_i (.clk_i, .rst_ni, .testmode_i, .we_flag, .jtag_hash_i(jtag_hash_i), .ikey_hash_i(ikey_hash_i), .okey_hash_i(okey_hash_i), .jtag_unlock_o(jtag_unlock_o), 
.dmi_rst_no(dmi_rst_no), .dmi_req_o(dmi_req_o), .dmi_req_valid_o(dmi_req_valid_o), .dmi_req_ready_i(dmi_req_ready_i), .dmi_resp_i(dmi_resp_i), .dmi_resp_ready_o(dmi_resp_ready_o), .dmi_resp_valid_i(dmi_resp_valid_i) ,.tck_i(tck_i), .tms_i(tms_i), .trst_ni(trst_ni), .td_i(td_i), .td_o(td_o), .tdo_oe_o(tdo_oe_o));

reglk_wrapper reglk_wrapper_i (.clk_i, .rst_ni, .jtag_unlock, .reglk_ctrl_i, .acct_ctrl_i, .axi_req_i, .axi_resp_o, .reglk_ctrl_o, .rst_9);

sha256_wrapper sha256_wrapper_i (.clk_i, .rst_ni, .reglk_ctrl_i, .acct_ctrl_i, .axi_req_i, .axi_resp_o, .rst_3);

aes0_wrapper aes0_wrapper_i (.clk_i, .rst_ni, .reglk_ctrl_i, .acct_ctrl_i, .debug_mode_i, .axi_req_i, .axi_resp_o, .rst_1);

acct_wrapper#(.NB_SLAVE(32)) acct_wrapper_i (.clk_i, .rst_ni, .reglk_ctrl_i, .acct_ctrl_i, .axi_req_i, .axi_resp_o, .acc_ctrl_o, .we_flag, .rst_6);

dma dma_i (.clk_i, .rst_ni, .start_i, .length_i, .source_addr_lsb_i, .source_addr_msb_i, .dest_addr_lsb_i, .dest_addr_msb_i, .valid_o, .done_i, .pmpcfg_i, .pmpaddr_i, .we_flag);

rsa_top#(.WIDTH(64)) rsa_top_i (.clk(clk_i), .rst_n(rst_ni), .rst1_n, .encrypt_decrypt_i, .p_i, .q_i, .msg_in,  .msg_out, .mod_exp_finish_o);

rsa_wrapper rsa_wrapper_i (.clk_i, .rst_ni, .reglk_ctrl_i, .acct_ctrl_i, .debug_mode_i, .axi_req_i, .axi_resp_o, .rst_13);

riscv_peripherals riscv_peripherals_i ( .*);

endmodule
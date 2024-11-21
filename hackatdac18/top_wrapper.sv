//Analyze the wrapper & all the rtl using the tcl file
//Elaborate only the wrapper
/*top modules:

riscv_core
apb_gpio
periph_bus_wrap
soc_interconnect
apb_node
axi_address_decoder_AR
adbg_tap_top
mux_func
jtag_tap_top

*/

module top_wrapper #(
  parameter N_EXT_PERF_COUNTERS =  0,
  parameter INSTR_RDATA_WIDTH   = 32,
  parameter PULP_SECURE         =  0,
  parameter PULP_CLUSTER        =  1,
  parameter FPU                 =  0,
  parameter SHARED_FP           =  0,
  parameter SHARED_DSP_MULT     =  0,
  parameter SHARED_INT_DIV      =  0,
  parameter SHARED_FP_DIVSQRT   =  0,
  parameter WAPUTYPE            =  0,
  parameter APU_NARGS_CPU       =  3,
  parameter APU_WOP_CPU         =  6,
  parameter APU_NDSFLAGS_CPU    = 15,
  parameter APU_NUSFLAGS_CPU    =  5,

  //apb_gpio parameters
  //parameter APB_ADDR_WIDTH = 12,

  //periph_bus_wrap parameters
  //parameter APB_ADDR_WIDTH = 32,
  //parameter APB_DATA_WIDTH = 32,

  //soc_interconnect parameters
  parameter USE_AXI           = 1,
  //parameter ADDR_WIDTH        = 32,
  parameter N_HWPE_PORTS      = 4,
  parameter N_PRIMARY_32       = 5+N_HWPE_PORTS,
  parameter N_PRIMARY_AXI_64   = 1,
  parameter DATA_WIDTH        = 32,
  parameter BE_WIDTH          = DATA_WIDTH/8,
  parameter ID_WIDTH          = N_PRIMARY_32+N_PRIMARY_AXI_64*4,
  parameter AUX_WIDTH         = 8,
  parameter N_L2_BANKS        = 4,
  parameter N_L2_BANKS_PRI    = 2,
  parameter ADDR_L2_WIDTH     = 12,
  parameter ADDR_L2_PRI_WIDTH = 12,
  parameter ROM_ADDR_WIDTH    = 10,
  // AXI PARAMS
  // 32 bit axi Interface
  parameter AXI_32_ID_WIDTH   = 12,
  parameter AXI_32_USER_WIDTH = 6,
  // 64 bit axi Interface
  parameter AXI_ADDR_WIDTH    = 32,
  parameter AXI_DATA_WIDTH    = 64,
  parameter AXI_STRB_WIDTH    = 8,
  parameter AXI_USER_WIDTH    = 6,
  parameter AXI_ID_WIDTH      = 7,

  //apb_node parameters
  parameter NB_PRIMARY = 8,
  //parameter APB_DATA_WIDTH = 32,
  //parameter APB_ADDR_WIDTH = 32,
  
  //axi_address_decoder_AR parameters
  //parameter  ADDR_WIDTH     = 32,
  parameter  N_INIT_PORT    = 8,
  parameter  N_REGION       = 4

  //adbg_tap_top parameters
  //none

  //rtc_clock parameters
  //none
)

(
input  logic clk_top,
input  logic rstn_top,

//riscv_core signals-------------------------------
  // Clock and Reset
  //input  logic        clk_i,
  //input  logic        rst_ni,

  input  logic        clock_en_i,    // enable clock, otherwise it is gated
  input  logic        test_en_i,     // enable all clock gates for testing

  input  logic        fregfile_disable_i,  // disable the fp regfile, using int regfile instead

  // Core ID, Cluster ID and boot address are considered more or less static
  input  logic [31:0] boot_addr_i,
  input  logic [ 3:0] core_id_i,
  input  logic [ 5:0] cluster_id_i,

  // Instruction memory interface
  output logic                         instr_req_o,
  input  logic                         instr_gnt_i,
  input  logic                         instr_rvalid_i,
  output logic                  [31:0] instr_addr_o,
  input  logic [INSTR_RDATA_WIDTH-1:0] instr_rdata_i,

  // Data memory interface
  output logic        data_req_o,
  input  logic        data_gnt_i,
  input  logic        data_rvalid_i,
  output logic        data_we_o,
  output logic [3:0]  data_be_o,
  output logic [31:0] data_addr_o,
  output logic [31:0] data_wdata_o,
  input  logic [31:0] data_rdata_i,
  input  logic        data_err_i,

  // apu-interconnect
  // handshake signals
  output logic                       apu_primary_req_o,
  output logic                       apu_primary_ready_o,
  input logic                        apu_primary_gnt_i,
  // request channel
  output logic [31:0]                 apu_primary_operands_o [APU_NARGS_CPU-1:0],
  output logic [APU_WOP_CPU-1:0]      apu_primary_op_o,
  output logic [WAPUTYPE-1:0]         apu_primary_type_o,
  output logic [APU_NDSFLAGS_CPU-1:0] apu_primary_flags_o,
  // response channel
  input logic                        apu_primary_valid_i,
  input logic [31:0]                 apu_primary_result_i,
  input logic [APU_NUSFLAGS_CPU-1:0] apu_primary_flags_i,

  // Interrupt inputs
  input  logic        irq_i,                 // level sensitive IR lines
  input  logic [4:0]  irq_id_i,
  output logic        irq_ack_o,
  output logic [4:0]  irq_id_o,
  input  logic        irq_sec_i,

  output logic        sec_lvl_o,

  // Debug Interface
  input  logic        debug_req_i,
  output logic        debug_gnt_o,
  output logic        debug_rvalid_o,
  input  logic [14:0] debug_addr_i,
  input  logic        debug_we_i,
  input  logic [31:0] debug_wdata_i,
  output logic [31:0] debug_rdata_o,
  output logic        debug_halted_o,
  input  logic        debug_halt_i,
  input  logic        debug_resume_i,

  // CPU Control Signals
  input  logic        fetch_enable_i,
  output logic        core_busy_o,

  input  logic [N_EXT_PERF_COUNTERS-1:0] ext_perf_counters_i,

//apb_gpio signals---------------------------------
    //    input  logic                      HCLK,
    //    input  logic                      HRESETn,

    input  logic                      dft_cg_enable_i,

    input  logic [12-1:0] PADDR, //APB_ADDR_WIDTH=12
    input  logic               [31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic               [31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,

    input  logic               [31:0] gpio_in,
    output logic               [31:0] gpio_in_sync,
    output logic               [31:0] gpio_out,
    output logic               [31:0] gpio_dir,
    output logic          [31:0][5:0] gpio_padcfg,
    output logic                      interrupt,

//periph_bus_wrap signals----------------------
    //    input logic    clk_i,
    //    input logic    rst_ni,
    APB_BUS.Slave  apb_subordinate,
    APB_BUS.Master fll_primary,
    APB_BUS.Master gpio_primary,
    APB_BUS.Master udma_primary,
    APB_BUS.Master soc_ctrl_primary,
    APB_BUS.Master adv_timer_primary,
    APB_BUS.Master soc_evnt_gen_primary,
    APB_BUS.Master eu_primary,
    APB_BUS.Master mmap_debug_primary,
    APB_BUS.Master timer_primary,
    APB_BUS.Master hwpe_primary,
    APB_BUS.Master stdout_primary,

//soc_interconnect signals-------------------------
    //input  logic                                                clk,
    //input  logic                                                rst_n,
    input  logic                                                test_en_i_socint,
    output logic [N_L2_BANKS-1:0]     [DATA_WIDTH-1:0]          L2_D_o,
    output logic [N_L2_BANKS-1:0]     [ADDR_L2_WIDTH-1:0]       L2_A_o,
    output logic [N_L2_BANKS-1:0]                               L2_CEN_o,
    output logic [N_L2_BANKS-1:0]                               L2_WEN_o,
    output logic [N_L2_BANKS-1:0]     [BE_WIDTH-1:0]            L2_BE_o,
    output logic [N_L2_BANKS-1:0]     [31:0]                    L2_ID_o,
    input  logic [N_L2_BANKS-1:0]     [DATA_WIDTH-1:0]          L2_Q_i,
    //RISC DATA PORT
    input  logic                                                FC_DATA_req_i,
    input  logic [32-1:0]                               FC_DATA_add_i, //ADDR_WIDTH=32  
    input  logic                                                FC_DATA_wen_i,
    input  logic [DATA_WIDTH-1:0]                               FC_DATA_wdata_i,
    input  logic [BE_WIDTH-1:0]                                 FC_DATA_be_i,
    input  logic [AUX_WIDTH-1:0]                                FC_DATA_aux_i,
    output logic                                                FC_DATA_gnt_o,
    output logic [AUX_WIDTH-1:0]                                FC_DATA_r_aux_o,
    output logic                                                FC_DATA_r_valid_o,
    output logic [DATA_WIDTH-1:0]                               FC_DATA_r_rdata_o,
    output logic                                                FC_DATA_r_opc_o,
    // RISC INSTR PORT
    input  logic                                                FC_INSTR_req_i,
    input  logic [32-1:0]                               FC_INSTR_add_i, //ADDR_WIDTH=32  
    input  logic                                                FC_INSTR_wen_i,
    input  logic [DATA_WIDTH-1:0]                               FC_INSTR_wdata_i,
    input  logic [BE_WIDTH-1:0]                                 FC_INSTR_be_i,
    input  logic [AUX_WIDTH-1:0]                                FC_INSTR_aux_i,
    output logic                                                FC_INSTR_gnt_o,
    output logic [AUX_WIDTH-1:0]                                FC_INSTR_r_aux_o,
    output logic                                                FC_INSTR_r_valid_o,
    output logic [DATA_WIDTH-1:0]                               FC_INSTR_r_rdata_o,
    output logic                                                FC_INSTR_r_opc_o,
    // UDMA TX
    input  logic                                                UDMA_TX_req_i,
    input  logic [32-1:0]                               UDMA_TX_add_i,  //ADDR_WIDTH=32  
    input  logic                                                UDMA_TX_wen_i,
    input  logic [DATA_WIDTH-1:0]                               UDMA_TX_wdata_i,
    input  logic [BE_WIDTH-1:0]                                 UDMA_TX_be_i,
    input  logic [AUX_WIDTH-1:0]                                UDMA_TX_aux_i,
    output logic                                                UDMA_TX_gnt_o,
    output logic [AUX_WIDTH-1:0]                                UDMA_TX_r_aux_o,
    output logic                                                UDMA_TX_r_valid_o,
    output logic [DATA_WIDTH-1:0]                               UDMA_TX_r_rdata_o,
    output logic                                                UDMA_TX_r_opc_o,
    // UDMA RX
    input  logic                                                UDMA_RX_req_i,
    input  logic [32-1:0]                               UDMA_RX_add_i,  //ADDR_WIDTH=32  
    input  logic                                                UDMA_RX_wen_i,
    input  logic [DATA_WIDTH-1:0]                               UDMA_RX_wdata_i,
    input  logic [BE_WIDTH-1:0]                                 UDMA_RX_be_i,
    input  logic [AUX_WIDTH-1:0]                                UDMA_RX_aux_i,
    output logic                                                UDMA_RX_gnt_o,
    output logic [AUX_WIDTH-1:0]                                UDMA_RX_r_aux_o,
    output logic                                                UDMA_RX_r_valid_o,
    output logic [DATA_WIDTH-1:0]                               UDMA_RX_r_rdata_o,
    output logic                                                UDMA_RX_r_opc_o,
    // DBG
    input  logic                                                DBG_RX_req_i,
    input  logic [32-1:0]                               DBG_RX_add_i,   //ADDR_WIDTH=32  
    input  logic                                                DBG_RX_wen_i,
    input  logic [DATA_WIDTH-1:0]                               DBG_RX_wdata_i,
    input  logic [BE_WIDTH-1:0]                                 DBG_RX_be_i,
    input  logic [AUX_WIDTH-1:0]                                DBG_RX_aux_i,
    output logic                                                DBG_RX_gnt_o,
    output logic [AUX_WIDTH-1:0]                                DBG_RX_r_aux_o,
    output logic                                                DBG_RX_r_valid_o,
    output logic [DATA_WIDTH-1:0]                               DBG_RX_r_rdata_o,
    output logic                                                DBG_RX_r_opc_o,
    // HWPE
    input  logic [N_HWPE_PORTS-1:0]                             HWPE_req_i,
    input  logic [N_HWPE_PORTS-1:0]   [32-1:0]          HWPE_add_i, //ADDR_WIDTH=32  
    input  logic [N_HWPE_PORTS-1:0]                             HWPE_wen_i,
    input  logic [N_HWPE_PORTS-1:0]   [DATA_WIDTH-1:0]          HWPE_wdata_i,
    input  logic [N_HWPE_PORTS-1:0]   [BE_WIDTH-1:0]            HWPE_be_i,
    input  logic [N_HWPE_PORTS-1:0]   [AUX_WIDTH-1:0]           HWPE_aux_i,
    output logic [N_HWPE_PORTS-1:0]                             HWPE_gnt_o,
    output logic [N_HWPE_PORTS-1:0]   [AUX_WIDTH-1:0]           HWPE_r_aux_o,
    output logic [N_HWPE_PORTS-1:0]                             HWPE_r_valid_o,
    output logic [N_HWPE_PORTS-1:0]   [DATA_WIDTH-1:0]          HWPE_r_rdata_o,
    output logic [N_HWPE_PORTS-1:0]                             HWPE_r_opc_o,
    // AXI INTERFACE (FROM CLUSTER)
    input  logic [AXI_ADDR_WIDTH-1:0]                           AXI_Subordinate_aw_addr_i,
    input  logic [2:0]                                          AXI_Subordinate_aw_prot_i,
    input  logic [3:0]                                          AXI_Subordinate_aw_region_i,
    input  logic [7:0]                                          AXI_Subordinate_aw_len_i,
    input  logic [2:0]                                          AXI_Subordinate_aw_size_i,
    input  logic [1:0]                                          AXI_Subordinate_aw_burst_i,
    input  logic                                                AXI_Subordinate_aw_lock_i,
    input  logic [3:0]                                          AXI_Subordinate_aw_cache_i,
    input  logic [3:0]                                          AXI_Subordinate_aw_qos_i,
    input  logic [AXI_ID_WIDTH-1:0]                             AXI_Subordinate_aw_id_i,
    input  logic [AXI_USER_WIDTH-1:0]                           AXI_Subordinate_aw_user_i,
    input  logic                                                AXI_Subordinate_aw_valid_i,
    output logic                                                AXI_Subordinate_aw_ready_o,
    // ADDRESS READ CHANNEL
    input  logic [AXI_ADDR_WIDTH-1:0]                           AXI_Subordinate_ar_addr_i,
    input  logic [2:0]                                          AXI_Subordinate_ar_prot_i,
    input  logic [3:0]                                          AXI_Subordinate_ar_region_i,
    input  logic [7:0]                                          AXI_Subordinate_ar_len_i,
    input  logic [2:0]                                          AXI_Subordinate_ar_size_i,
    input  logic [1:0]                                          AXI_Subordinate_ar_burst_i,
    input  logic                                                AXI_Subordinate_ar_lock_i,
    input  logic [3:0]                                          AXI_Subordinate_ar_cache_i,
    input  logic [3:0]                                          AXI_Subordinate_ar_qos_i,
    input  logic [AXI_ID_WIDTH-1:0]                             AXI_Subordinate_ar_id_i,
    input  logic [AXI_USER_WIDTH-1:0]                           AXI_Subordinate_ar_user_i,
    input  logic                                                AXI_Subordinate_ar_valid_i,
    output logic                                                AXI_Subordinate_ar_ready_o,
    // WRITE CHANNEL
    input  logic [AXI_USER_WIDTH-1:0]                           AXI_Subordinate_w_user_i,
    input  logic [AXI_DATA_WIDTH-1:0]                           AXI_Subordinate_w_data_i,
    input  logic [AXI_STRB_WIDTH-1:0]                           AXI_Subordinate_w_strb_i,
    input  logic                                                AXI_Subordinate_w_last_i,
    input  logic                                                AXI_Subordinate_w_valid_i,
    output logic                                                AXI_Subordinate_w_ready_o,
    // WRITE RESPONSE CHANNEL
    output logic [AXI_ID_WIDTH-1:0]                             AXI_Subordinate_b_id_o,
    output logic [1:0]                                          AXI_Subordinate_b_resp_o,
    output logic [AXI_USER_WIDTH-1:0]                           AXI_Subordinate_b_user_o,
    output logic                                                AXI_Subordinate_b_valid_o,
    input  logic                                                AXI_Subordinate_b_ready_i,
    // READ CHANNEL
    output logic [AXI_ID_WIDTH-1:0]                             AXI_Subordinate_r_id_o,
    output logic [AXI_USER_WIDTH-1:0]                           AXI_Subordinate_r_user_o,
    output logic [AXI_DATA_WIDTH-1:0]                           AXI_Subordinate_r_data_o,
    output logic [1:0]                                          AXI_Subordinate_r_resp_o,
    output logic                                                AXI_Subordinate_r_last_o,
    output logic                                                AXI_Subordinate_r_valid_o,
    input  logic                                                AXI_Subordinate_r_ready_i,
    // BRIDGES
    // CH_0 --> APB
    output logic [32-1:0]                               APB_PADDR_o,    //ADDR_WIDTH=32  
    output logic [DATA_WIDTH-1:0]                               APB_PWDATA_o,
    output logic                                                APB_PWRITE_o,
    output logic                                                APB_PSEL_o,
    output logic                                                APB_PENABLE_o,
    input  logic [DATA_WIDTH-1:0]                               APB_PRDATA_i,
    input  logic                                                APB_PREADY_i,
    input  logic                                                APB_PSLVERR_i,
    // CH_1 --> AXI
    // ---------------------------------------------------------
    // AXI TARG Port Declarations ------------------------------
    // ---------------------------------------------------------
    //AXI write address bus -------------- // USED// -----------
    output logic [AXI_32_ID_WIDTH-1:0]                          AXI_Primary_aw_id_o,
    output logic [32-1:0]                               AXI_Primary_aw_addr_o,   //ADDR_WIDTH=32  
    output logic [7:0]                                          AXI_Primary_aw_len_o,
    output logic [2:0]                                          AXI_Primary_aw_size_o,
    output logic [1:0]                                          AXI_Primary_aw_burst_o,
    output logic                                                AXI_Primary_aw_lock_o,
    output logic [3:0]                                          AXI_Primary_aw_cache_o,
    output logic [2:0]                                          AXI_Primary_aw_prot_o,
    output logic [3:0]                                          AXI_Primary_aw_region_o,
    output logic [AXI_32_USER_WIDTH-1:0]                        AXI_Primary_aw_user_o,
    output logic [3:0]                                          AXI_Primary_aw_qos_o,
    output logic                                                AXI_Primary_aw_valid_o,
    input  logic                                                AXI_Primary_aw_ready_i,
    // ---------------------------------------------------------
    //AXI write data bus -------------- // USED// --------------
    output logic [DATA_WIDTH-1:0]                               AXI_Primary_w_data_o,
    output logic [BE_WIDTH-1:0]                                 AXI_Primary_w_strb_o,
    output logic                                                AXI_Primary_w_last_o,
    output logic [AXI_32_USER_WIDTH-1:0]                        AXI_Primary_w_user_o,
    output logic                                                AXI_Primary_w_valid_o,
    input  logic                                                AXI_Primary_w_ready_i,
    // ---------------------------------------------------------
    //AXI write response bus -------------- // USED// ----------
    input  logic [AXI_32_ID_WIDTH-1:0]                          AXI_Primary_b_id_i,
    input  logic [1:0]                                          AXI_Primary_b_resp_i,
    input  logic                                                AXI_Primary_b_valid_i,
    input  logic [AXI_32_USER_WIDTH-1:0]                        AXI_Primary_b_user_i,
    output logic                                                AXI_Primary_b_ready_o,
    // ---------------------------------------------------------
    //AXI read address bus -------------------------------------
    output logic [AXI_32_ID_WIDTH-1:0]                          AXI_Primary_ar_id_o,
    output logic [32-1:0]                               AXI_Primary_ar_addr_o,   //ADDR_WIDTH=32  
    output logic [7:0]                                          AXI_Primary_ar_len_o,
    output logic [2:0]                                          AXI_Primary_ar_size_o,
    output logic [1:0]                                          AXI_Primary_ar_burst_o,
    output logic                                                AXI_Primary_ar_lock_o,
    output logic [3:0]                                          AXI_Primary_ar_cache_o,
    output logic [2:0]                                          AXI_Primary_ar_prot_o,
    output logic [3:0]                                          AXI_Primary_ar_region_o,
    output logic [AXI_32_USER_WIDTH-1:0]                        AXI_Primary_ar_user_o,
    output logic [3:0]                                          AXI_Primary_ar_qos_o,
    output logic                                                AXI_Primary_ar_valid_o,
    input  logic                                                AXI_Primary_ar_ready_i,
    // ---------------------------------------------------------
    //AXI read data bus ----------------------------------------
    input  logic [AXI_32_ID_WIDTH-1:0]                          AXI_Primary_r_id_i,
    input  logic [DATA_WIDTH-1:0]                               AXI_Primary_r_data_i,
    input  logic [1:0]                                          AXI_Primary_r_resp_i,
    input  logic                                                AXI_Primary_r_last_i,
    input  logic [AXI_32_USER_WIDTH-1:0]                        AXI_Primary_r_user_i,
    input  logic                                                AXI_Primary_r_valid_i,
    output logic                                                AXI_Primary_r_ready_o,
    // CH_2 --> ROM
    output logic                                                rom_csn_o,
    output logic [ROM_ADDR_WIDTH-1:0]                           rom_add_o,
    input  logic [DATA_WIDTH-1:0]                               rom_rdata_i,
    // CH_3, CH_4 Private Mem Banks (L2)
    output logic [N_L2_BANKS_PRI-1:0] [DATA_WIDTH-1:0]          L2_pri_D_o,
    output logic [N_L2_BANKS_PRI-1:0] [ADDR_L2_PRI_WIDTH-1:0]   L2_pri_A_o,
    output logic [N_L2_BANKS_PRI-1:0]                           L2_pri_CEN_o,
    output logic [N_L2_BANKS_PRI-1:0]                           L2_pri_WEN_o,
    output logic [N_L2_BANKS_PRI-1:0] [BE_WIDTH-1:0]            L2_pri_BE_o,
    input  logic [N_L2_BANKS_PRI-1:0] [DATA_WIDTH-1:0]          L2_pri_Q_i,

//apb_node-------------------------------------------
    // SUBORDINATE PORT
    input  logic                                     penable_i,
    input  logic                                     pwrite_i,
    input  logic [31:0]                              paddr_i,
    input  logic [31:0]                              pwdata_i,
    output logic [31:0]                              prdata_o,
    output logic                                     pready_o,
    output logic                                     pslverr_o,

    // PRIMARY PORTS
    output logic [NB_PRIMARY-1:0]                     penable_o,
    output logic [NB_PRIMARY-1:0]                     pwrite_o,
    output logic [NB_PRIMARY-1:0][31:0]               paddr_o,
    output logic [NB_PRIMARY-1:0]                     psel_o,
    output logic [NB_PRIMARY-1:0][31:0]               pwdata_o,
    input  logic [NB_PRIMARY-1:0][31:0]               prdata_i,
    input  logic [NB_PRIMARY-1:0]                     pready_i,
    input  logic [NB_PRIMARY-1:0]                     pslverr_i,

    // CONFIGURATION PORT
    input  logic [NB_PRIMARY-1:0][32-1:0] START_ADDR_i,
    input  logic [NB_PRIMARY-1:0][32-1:0] END_ADDR_i,

//axi_address_decoder_AR------------------------------
    //input  logic                                                        clk,
    //input  logic                                                        rst_n,

    input  logic                                                        arvalid_i,
    input  logic [32-1:0]                                       araddr_i, //ADDR_WIDTH=32
    output logic                                                        arready_o,

    output logic [N_INIT_PORT-1:0]                                      arvalid_o,
    input  logic [N_INIT_PORT-1:0]                                      arready_i,

    input  logic [N_REGION-1:0][N_INIT_PORT-1:0][32-1:0]        START_ADDR_i_ar, //ADDR_WIDTH=32
    input  logic [N_REGION-1:0][N_INIT_PORT-1:0][32-1:0]        END_ADDR_i_ar, //ADDR_WIDTH=32
    input  logic [N_REGION-1:0][N_INIT_PORT-1:0]                        enable_region_i,

    input  logic [N_INIT_PORT-1:0]                                      connectivity_map_i,

    output logic                                                        incr_req_o,
    input  logic                                                        full_counter_i,
    input  logic                                                        outstanding_trans_i,

    output logic                                                        error_req_o,
    input  logic                                                        error_gnt_i,
    output logic                                                        sample_ardata_info_o,

//adbg_tap_top----------------------------------------
    // JTAG pins
    input logic    tms_pad_i,      // JTAG test mode select pad
    input logic    tck_pad_i,      // JTAG test clock pad
    input logic    trstn_pad_i,     // JTAG test reset pad
    input logic    tdi_pad_i,      // JTAG test data input pad
    output logic   tdo_pad_o,      // JTAG test data output logic  pad
    output logic   tdo_padoe_o,    // output logic  enable for JTAG test data output logic  pad 

    input logic    test_mode_i,     // test mode input

    // TAP states
    output logic   test_logic_reset_o,
    output logic   run_test_idle_o,
    output logic   shift_dr_o,
    output logic   pause_dr_o,
    output logic   update_dr_o,
    output logic   capture_dr_o,

    // Select signals for boundary scan or mbist
    output logic   extest_select_o,
    output logic   sample_preload_select_o,
    output logic   mbist_select_o,
    output logic   debug_select_o,

    // TDO signal that is connected to TDI of sub-modules.
    output logic   tdi_o,

    // TDI signals from sub-modules
    input logic    debug_tdo_i,    // from debug module
    input logic    bs_chain_tdo_i, // from Boundary Scan Chain
    input logic    mbist_tdo_i,    // from Mbist Chain

//rtc_clock-------------------------------------------
    //input  logic        clk_i,
	//input  logic        rstn_i,

	input  logic        clock_update_i,
	output logic [21:0] clock_o,
	input  logic [21:0] clock_i,

	input  logic  [9:0] init_sec_cnt_i,

	input  logic        timer_update_i,
	input  logic        timer_enable_i,
	input  logic        timer_retrig_i,
	input  logic [16:0] timer_target_i,
	output logic [16:0] timer_value_o,

	input  logic        alarm_enable_i,
	input  logic        alarm_update_i,
	input  logic [21:0] alarm_clock_i,
	output logic [21:0] alarm_clock_o,

	output logic        event_o,

	output logic        update_day_o,

//mux_func--------------------------------------------
  // global signals
  input  logic [127:0] a,
  input  logic [127:0] b,
  output logic [127:0] c,
  input  logic [127:0] d,
  //input  logic clk,
  //input  logic rst

//jtag_tap_top--------------------------------------------
    input  logic              tck_i,
    input  logic              trst_ni,
    input  logic              tms_i,
    input  logic              td_i,
    output logic              td_o,

    output logic              soc_tck_o,
    output logic              soc_trstn_o,
    output logic              soc_tms_o,
    output logic              soc_tdi_o,
    input  logic              soc_tdo_i,

    input  logic              test_clk_i,
    input  logic              test_rstn_i,

    input  logic        [7:0] soc_jtag_reg_i,
    output logic        [7:0] soc_jtag_reg_o,
    output logic              sel_fll_clk_o,

    // tap
    output logic               jtag_shift_dr_o,
    output logic               jtag_update_dr_o,
    output logic               jtag_capture_dr_o,
    output logic               axireg_sel_o,

    output logic               dbg_axi_scan_in_o,
    input  logic               dbg_axi_scan_out_i
);





//riscv_core instantiation------------------------------
riscv_core #(
 .N_EXT_PERF_COUNTERS(0),
 .INSTR_RDATA_WIDTH(32),
 .PULP_SECURE(0),
 .PULP_CLUSTER(1),
 .FPU(0),
 .SHARED_FP(0),
 .SHARED_DSP_MULT(0),
 .SHARED_INT_DIV(0),
 .SHARED_FP_DIVSQRT(0),
 .WAPUTYPE(0),
 .APU_NARGS_CPU(3),
 .APU_WOP_CPU(6),
 .APU_NDSFLAGS_CPU(15),
 .APU_NUSFLAGS_CPU(5)
 ) riscv_core(
  
  .clk_i (clk_top),
  .rst_ni (rstn_top),

  .clock_en_i (clock_en_i),
  .test_en_i (test_en_i),     // enable all clock gates for testing

  .fregfile_disable_i (fregfile_disable_i),  // disable the fp regfile, using int regfile instead

  // Core ID, Cluster ID and boot address are considered more or less static
  .boot_addr_i (boot_addr_i),
  .core_id_i (core_id_i),
  .cluster_id_i (cluster_id_i),

  // Instruction memory interface
  .instr_req_o (instr_req_o),
  .instr_gnt_i (instr_gnt_i),
  .instr_rvalid_i (instr_rvalid_i),
  .instr_addr_o (instr_addr_o),
  .instr_rdata_i (instr_rdata_i),

  // Data memory interface
  .data_req_o (data_req_o),
  .data_gnt_i (data_gnt_i),
  .data_rvalid_i (data_rvalid_i),
  .data_we_o (data_we_o),
  .data_be_o (data_be_o),
  .data_addr_o (data_addr_o),
  .data_wdata_o (data_wdata_o),
  .data_rdata_i (data_rdata_i),
  .data_err_i (data_err_i),

  // apu-interconnect
  // handshake signals
  .apu_master_req_o (apu_primary_req_o),
  .apu_master_ready_o (apu_primary_ready_o),
  .apu_master_gnt_i (apu_primary_gnt_i),
  // request channel
  .apu_master_operands_o (apu_primary_operands_o),
  .apu_master_op_o (apu_primary_op_o),
  .apu_master_type_o (apu_primary_type_o),
  .apu_master_flags_o (apu_primary_flags_o),
  // response channel
  .apu_master_valid_i (apu_primary_valid_i),
  .apu_master_result_i (apu_primary_result_i),
  .apu_master_flags_i (apu_primary_flags_i),

  // Interrupt inputs
  .irq_i (irq_i),                 // level sensitive IR lines
  .irq_id_i (irq_id_i),
  .irq_ack_o (irq_ack_o),
  .irq_id_o (irq_id_o),
  .irq_sec_i (irq_sec_i),

  .sec_lvl_o (sec_lvl_o),

  // Debug Interface
  .debug_req_i (debug_req_i),
  .debug_gnt_o (debug_gnt_o),
  .debug_rvalid_o (debug_rvalid_o),
  .debug_addr_i (debug_addr_i),
  .debug_we_i (debug_we_i),
  .debug_wdata_i (debug_wdata_i),
  .debug_rdata_o (debug_rdata_o),
  .debug_halted_o (debug_halted_o),
  .debug_halt_i (debug_halt_i),
  .debug_resume_i (debug_resume_i),

  // CPU Control Signals
  .fetch_enable_i (fetch_enable_i),
  .core_busy_o (core_busy_o),

  .ext_perf_counters_i (ext_perf_counters_i)
);

//apb_gpio instantiation------------------------------
apb_gpio #(
  .APB_ADDR_WIDTH(12)
  ) apb_gpio(
  .HCLK (clk_top),
  .HRESETn (rstn_top),

  .dft_cg_enable_i (dft_cg_enable_i),
  .PADDR (PADDR),
  .PWDATA (PWDATA),
  .PWRITE (PWRITE),
  .PSEL (PSEL),
  .PENABLE (PENABLE),
  .PRDATA (PRDATA),
  .PREADY (PREADY),
  .PSLVERR (PSLVERR),

  .gpio_in (gpio_in),
  .gpio_in_sync (gpio_in_sync),
  .gpio_out (gpio_out),
  .gpio_dir (gpio_dir),
  .gpio_padcfg (gpio_padcfg),
  .interrupt (interrupt)
);

//periph_bus_wrap instantiation----------------------
periph_bus_wrap #(
  .APB_ADDR_WIDTH(32),
  .APB_DATA_WIDTH(32)
  ) periph_bus_wrap (
  .clk_i(clk_top),
  .rst_ni(rstn_top),
  .apb_slave (apb_subordinate),
  .fll_master (fll_primary),
  .gpio_master (gpio_primary),
  .udma_master (udma_primary),
  .soc_ctrl_master (soc_ctrl_primary),
  .adv_timer_master (adv_timer_primary),
  .soc_evnt_gen_master (soc_evnt_gen_primary),
  .eu_master (eu_primary),
  .mmap_debug_master (mmap_debug_primary),
  .timer_master (timer_primary),
  .hwpe_master (hwpe_primary),
  .stdout_master (stdout_primary)
);

//soc_interconnect instantiation------------------------------
soc_interconnect #(
  .USE_AXI(USE_AXI),
  .ADDR_WIDTH(32), //ADDR_WIDTH=32  
  .N_HWPE_PORTS(N_HWPE_PORTS),
  .N_MASTER_32(N_PRIMARY_32),
  .N_MASTER_AXI_64(N_PRIMARY_AXI_64),
  .DATA_WIDTH(DATA_WIDTH),
  .BE_WIDTH(BE_WIDTH),
  .ID_WIDTH(ID_WIDTH),
  .AUX_WIDTH(AUX_WIDTH),
  .N_L2_BANKS(N_L2_BANKS),
  .N_L2_BANKS_PRI(N_L2_BANKS_PRI),
  .ADDR_L2_WIDTH(ADDR_L2_WIDTH),
  .ADDR_L2_PRI_WIDTH(ADDR_L2_PRI_WIDTH),
  .ROM_ADDR_WIDTH(ROM_ADDR_WIDTH),
  // AXI PARAMS
  // 32 bit axi Interface
  .AXI_32_ID_WIDTH(AXI_32_ID_WIDTH),
  .AXI_32_USER_WIDTH(AXI_32_USER_WIDTH),
  // 64 bit axi Interface
  .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
  .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
  .AXI_STRB_WIDTH(AXI_STRB_WIDTH),
  .AXI_USER_WIDTH(AXI_USER_WIDTH),
  .AXI_ID_WIDTH(AXI_ID_WIDTH)
  ) soc_interconnect (
  .clk(clk_top),
  .rst_n(rstn_top),
  .test_en_i(test_en_i),
  .L2_D_o(L2_D_o),
  .L2_A_o(L2_A_o),
  .L2_CEN_o(L2_CEN_o),
  .L2_WEN_o(L2_WEN_o),
  .L2_BE_o(L2_BE_o),
  .L2_ID_o(L2_ID_o),
  .L2_Q_i(L2_Q_i),
      //RISC DATA PORT
  .FC_DATA_req_i(FC_DATA_req_i),
  .FC_DATA_add_i(FC_DATA_add_i),
  .FC_DATA_wen_i(FC_DATA_wen_i),
  .FC_DATA_wdata_i(FC_DATA_wdata_i),
  .FC_DATA_be_i(FC_DATA_be_i),
  .FC_DATA_aux_i(FC_DATA_aux_i),
  .FC_DATA_gnt_o(FC_DATA_gnt_o),
  .FC_DATA_r_aux_o(FC_DATA_r_aux_o),
  .FC_DATA_r_valid_o(FC_DATA_r_valid_o),
  .FC_DATA_r_rdata_o(FC_DATA_r_rdata_o),
  .FC_DATA_r_opc_o(FC_DATA_r_opc_o),
      // RISC INSTR PORT
  .FC_INSTR_req_i(FC_INSTR_req_i),
  .FC_INSTR_add_i(FC_INSTR_add_i),
  .FC_INSTR_wen_i(FC_INSTR_wen_i),
  .FC_INSTR_wdata_i(FC_INSTR_wdata_i),
  .FC_INSTR_be_i(FC_INSTR_be_i),
  .FC_INSTR_aux_i(FC_INSTR_aux_i),
  .FC_INSTR_gnt_o(FC_INSTR_gnt_o),
  .FC_INSTR_r_aux_o(FC_INSTR_r_aux_o),
  .FC_INSTR_r_valid_o(FC_INSTR_r_valid_o),
  .FC_INSTR_r_rdata_o(FC_INSTR_r_rdata_o),
  .FC_INSTR_r_opc_o(FC_INSTR_r_opc_o),
      // UDMA TX
  .UDMA_TX_req_i(UDMA_TX_req_i),
  .UDMA_TX_add_i(UDMA_TX_add_i),
  .UDMA_TX_wen_i(UDMA_TX_wen_i),
  .UDMA_TX_wdata_i(UDMA_TX_wdata_i),
  .UDMA_TX_be_i(UDMA_TX_be_i),
  .UDMA_TX_aux_i(UDMA_TX_aux_i),
  .UDMA_TX_gnt_o(UDMA_TX_gnt_o),
  .UDMA_TX_r_aux_o(UDMA_TX_r_aux_o),
  .UDMA_TX_r_valid_o(UDMA_TX_r_valid_o),
  .UDMA_TX_r_rdata_o(UDMA_TX_r_rdata_o),
  .UDMA_TX_r_opc_o(UDMA_TX_r_opc_o),
      // UDMA RX
  .UDMA_RX_req_i(UDMA_RX_req_i),
  .UDMA_RX_add_i(UDMA_RX_add_i),
  .UDMA_RX_wen_i(UDMA_RX_wen_i),
  .UDMA_RX_wdata_i(UDMA_RX_wdata_i),
  .UDMA_RX_be_i(UDMA_RX_be_i),
  .UDMA_RX_aux_i(UDMA_RX_aux_i),
  .UDMA_RX_gnt_o(UDMA_RX_gnt_o),
  .UDMA_RX_r_aux_o(UDMA_RX_r_aux_o),
  .UDMA_RX_r_valid_o(UDMA_RX_r_valid_o),
  .UDMA_RX_r_rdata_o(UDMA_RX_r_rdata_o),
  .UDMA_RX_r_opc_o(UDMA_RX_r_opc_o),
      // DBG
  .DBG_RX_req_i(DBG_RX_req_i),
  .DBG_RX_add_i(DBG_RX_add_i),
  .DBG_RX_wen_i(DBG_RX_wen_i),
  .DBG_RX_wdata_i(DBG_RX_wdata_i),
  .DBG_RX_be_i(DBG_RX_be_i),
  .DBG_RX_aux_i(DBG_RX_aux_i),
  .DBG_RX_gnt_o(DBG_RX_gnt_o),
  .DBG_RX_r_aux_o(DBG_RX_r_aux_o),
  .DBG_RX_r_valid_o(DBG_RX_r_valid_o),
  .DBG_RX_r_rdata_o(DBG_RX_r_rdata_o),
  .DBG_RX_r_opc_o(DBG_RX_r_opc_o),
      // HWPE
  .HWPE_req_i(HWPE_req_i),
  .HWPE_add_i(HWPE_add_i),
  .HWPE_wen_i(HWPE_wen_i),
  .HWPE_wdata_i(HWPE_wdata_i),
  .HWPE_be_i(HWPE_be_i),
  .HWPE_aux_i(HWPE_aux_i),
  .HWPE_gnt_o(HWPE_gnt_o),
  .HWPE_r_aux_o(HWPE_r_aux_o),
  .HWPE_r_valid_o(HWPE_r_valid_o),
  .HWPE_r_rdata_o(HWPE_r_rdata_o),
  .HWPE_r_opc_o(HWPE_r_opc_o),
      // AXI INTERFACE (FROM CLUSTER)
  .AXI_Slave_aw_addr_i(AXI_Subordinate_aw_addr_i),
  .AXI_Slave_aw_prot_i(AXI_Subordinate_aw_prot_i),
  .AXI_Slave_aw_region_i(AXI_Subordinate_aw_region_i),
  .AXI_Slave_aw_len_i(AXI_Subordinate_aw_len_i),
  .AXI_Slave_aw_size_i(AXI_Subordinate_aw_size_i),
  .AXI_Slave_aw_burst_i(AXI_Subordinate_aw_burst_i),
  .AXI_Slave_aw_lock_i(AXI_Subordinate_aw_lock_i),
  .AXI_Slave_aw_cache_i(AXI_Subordinate_aw_cache_i),
  .AXI_Slave_aw_qos_i(AXI_Subordinate_aw_qos_i),
  .AXI_Slave_aw_id_i(AXI_Subordinate_aw_id_i),
  .AXI_Slave_aw_user_i(AXI_Subordinate_aw_user_i),
  .AXI_Slave_aw_valid_i(AXI_Subordinate_aw_valid_i),
  .AXI_Slave_aw_ready_o(AXI_Subordinate_aw_ready_o),
      // ADDRESS READ CHANNEL
  .AXI_Slave_ar_addr_i(AXI_Subordinate_ar_addr_i),
  .AXI_Slave_ar_prot_i(AXI_Subordinate_ar_prot_i),
  .AXI_Slave_ar_region_i(AXI_Subordinate_ar_region_i),
  .AXI_Slave_ar_len_i(AXI_Subordinate_ar_len_i),
  .AXI_Slave_ar_size_i(AXI_Subordinate_ar_size_i),
  .AXI_Slave_ar_burst_i(AXI_Subordinate_ar_burst_i),
  .AXI_Slave_ar_lock_i(AXI_Subordinate_ar_lock_i),
  .AXI_Slave_ar_cache_i(AXI_Subordinate_ar_cache_i),
  .AXI_Slave_ar_qos_i(AXI_Subordinate_ar_qos_i),
  .AXI_Slave_ar_id_i(AXI_Subordinate_ar_id_i),
  .AXI_Slave_ar_user_i(AXI_Subordinate_ar_user_i),
  .AXI_Slave_ar_valid_i(AXI_Subordinate_ar_valid_i),
  .AXI_Slave_ar_ready_o(AXI_Subordinate_ar_ready_o),
      // WRITE CHANNEL
  .AXI_Slave_w_user_i(AXI_Subordinate_w_user_i),
  .AXI_Slave_w_data_i(AXI_Subordinate_w_data_i),
  .AXI_Slave_w_strb_i(AXI_Subordinate_w_strb_i),
  .AXI_Slave_w_last_i(AXI_Subordinate_w_last_i),
  .AXI_Slave_w_valid_i(AXI_Subordinate_w_valid_i),
  .AXI_Slave_w_ready_o(AXI_Subordinate_w_ready_o),
      // WRITE RESPONSE CHANNEL
  .AXI_Slave_b_id_o(AXI_Subordinate_b_id_o),
  .AXI_Slave_b_resp_o(AXI_Subordinate_b_resp_o),
  .AXI_Slave_b_user_o(AXI_Subordinate_b_user_o),
  .AXI_Slave_b_valid_o(AXI_Subordinate_b_valid_o),
  .AXI_Slave_b_ready_i(AXI_Subordinate_b_ready_i),
      // READ CHANNEL
  .AXI_Slave_r_id_o(AXI_Subordinate_r_id_o),
  .AXI_Slave_r_user_o(AXI_Subordinate_r_user_o),
  .AXI_Slave_r_data_o(AXI_Subordinate_r_data_o),
  .AXI_Slave_r_resp_o(AXI_Subordinate_r_resp_o),
  .AXI_Slave_r_last_o(AXI_Subordinate_r_last_o),
  .AXI_Slave_r_valid_o(AXI_Subordinate_r_valid_o),
  .AXI_Slave_r_ready_i(AXI_Subordinate_r_ready_i),
      // BRIDGES
      // CH_0 --> APB
  .APB_PADDR_o(APB_PADDR_o),
  .APB_PWDATA_o(APB_PWDATA_o),
  .APB_PWRITE_o(APB_PWRITE_o),
  .APB_PSEL_o(APB_PSEL_o),
  .APB_PENABLE_o(APB_PENABLE_o),
  .APB_PRDATA_i(APB_PRDATA_i),
  .APB_PREADY_i(APB_PREADY_i),
  .APB_PSLVERR_i(APB_PSLVERR_i),
      // CH_1 --> AXI
      // ---------------------------------------------------------
      // AXI TARG Port Declarations ------------------------------
      // ---------------------------------------------------------
      //AXI write address bus -------------- // USED// -----------
  .AXI_Master_aw_id_o(AXI_Primary_aw_id_o),
  .AXI_Master_aw_addr_o(AXI_Primary_aw_addr_o),
  .AXI_Master_aw_len_o(AXI_Primary_aw_len_o),
  .AXI_Master_aw_size_o(AXI_Primary_aw_size_o),
  .AXI_Master_aw_burst_o(AXI_Primary_aw_burst_o),
  .AXI_Master_aw_lock_o(AXI_Primary_aw_lock_o),
  .AXI_Master_aw_cache_o(AXI_Primary_aw_cache_o),
  .AXI_Master_aw_prot_o(AXI_Primary_aw_prot_o),
  .AXI_Master_aw_region_o(AXI_Primary_aw_region_o),
  .AXI_Master_aw_user_o(AXI_Primary_aw_user_o),
  .AXI_Master_aw_qos_o(AXI_Primary_aw_qos_o),
  .AXI_Master_aw_valid_o(AXI_Primary_aw_valid_o),
  .AXI_Master_aw_ready_i(AXI_Primary_aw_ready_i),
      // ---------------------------------------------------------
      //AXI write data bus -------------- // USED// --------------
  .AXI_Master_w_data_o(AXI_Primary_w_data_o),
  .AXI_Master_w_strb_o(AXI_Primary_w_strb_o),
  .AXI_Master_w_last_o(AXI_Primary_w_last_o),
  .AXI_Master_w_user_o(AXI_Primary_w_user_o),
  .AXI_Master_w_valid_o(AXI_Primary_w_valid_o),
  .AXI_Master_w_ready_i(AXI_Primary_w_ready_i),
      // ---------------------------------------------------------
      //AXI write response bus -------------- // USED// ----------
  .AXI_Master_b_id_i(AXI_Primary_b_id_i),
  .AXI_Master_b_resp_i(AXI_Primary_b_resp_i),
  .AXI_Master_b_valid_i(AXI_Primary_b_valid_i),
  .AXI_Master_b_user_i(AXI_Primary_b_user_i),
  .AXI_Master_b_ready_o(AXI_Primary_b_ready_o),
      // ---------------------------------------------------------
      //AXI read address bus -------------------------------------
  .AXI_Master_ar_id_o(AXI_Primary_ar_id_o),
  .AXI_Master_ar_addr_o(AXI_Primary_ar_addr_o),
  .AXI_Master_ar_len_o(AXI_Primary_ar_len_o),
  .AXI_Master_ar_size_o(AXI_Primary_ar_size_o),
  .AXI_Master_ar_burst_o(AXI_Primary_ar_burst_o),
  .AXI_Master_ar_lock_o(AXI_Primary_ar_lock_o),
  .AXI_Master_ar_cache_o(AXI_Primary_ar_cache_o),
  .AXI_Master_ar_prot_o(AXI_Primary_ar_prot_o),
  .AXI_Master_ar_region_o(AXIAXI_Primary_ar_ready_i),
      // ---------------------------------------------------------
      //AXI read data bus ----------------------------------------
  .AXI_Master_r_id_i(AXI_Primary_r_id_i),
  .AXI_Master_r_data_i(AXI_Primary_r_data_i),
  .AXI_Master_r_resp_i(AXI_Primary_r_resp_i),
  .AXI_Master_r_last_i(AXI_Primary_r_last_i),
  .AXI_Master_r_user_i(AXI_Primary_r_user_i),
  .AXI_Master_r_valid_i(AXI_Primary_r_valid_i),
  .AXI_Master_r_ready_o(AXI_Primary_r_ready_o),
      // CH_2 --> ROM
  .rom_csn_o(rom_csn_o),
  .rom_add_o(rom_add_o),
  .rom_rdata_i(rom_rdata_i),
      // CH_3, CH_4 Private Mem Banks (L2)
  .L2_pri_D_o(L2_pri_D_o),
  .L2_pri_A_o(L2_pri_A_o),
  .L2_pri_CEN_o(L2_pri_CEN_o),
  .L2_pri_WEN_o(L2_pri_WEN_o),
  .L2_pri_BE_o(L2_pri_BE_o),
  .L2_pri_Q_i(L2_pri_Q_i)
);

//apb_node instantiation------------------------------
apb_node #(
  .NB_MASTER(NB_PRIMARY),
  .APB_DATA_WIDTH(32),
  .APB_ADDR_WIDTH(32)
  ) abpnode(
   // SUBORDINATE PORT
  .penable_i(penable_i),
  .pwrite_i(pwrite_i),
  .paddr_i(paddr_i),
  .pwdata_i(pwdata_i),
  .prdata_o(prdata_o),
  .pready_o(pready_o),
  .pslverr_o(pslverr_o),

      // MASTER PORTS
  .penable_o(penable_o),
  .pwrite_o(pwrite_o),
  .paddr_o(paddr_o),
  .psel_o(psel_o),
  .pwdata_o(pwdata_o),
  .prdata_i(prdata_i),
  .pready_i(pready_i),
  .pslverr_i(pslverr_i),

      // CONFIGURATION PORT
  .START_ADDR_i(START_ADDR_i),
  .END_ADDR_i(END_ADDR_i)
);

//axi_address_decoder_AR instantiation------------------------------
axi_address_decoder_AR #(
    .ADDR_WIDTH(32),
    .N_INIT_PORT(N_INIT_PORT),
    .N_REGION(N_REGION)
    ) axi_address_decoder_AR (
    .clk(clk_top),
    .rst_n(rstn_top),
    .arvalid_i(arvalid_i),
    .araddr_i(araddr_i),
    .arready_o(arready_o),
    .arvalid_o(arvalid_o),
    .arready_i(arready_i),

    .START_ADDR_i(START_ADDR_i_ar),
    .END_ADDR_i(END_ADDR_i_ar),
    .enable_region_i(enable_region_i),
    .connectivity_map_i(connectivity_map_i),
    .incr_req_o(incr_req_o),
    .full_counter_i(full_counter_i),
    .outstanding_trans_i(outstanding_trans_i),
    .error_req_o(error_req_o),
    .error_gnt_i(error_gnt_i),
    .sample_ardata_info_o(sample_ardata_info_o)
);

//adbg_tap_top instantiation------------------------------
adbg_tap_top adbg_tap_top (
    .tms_pad_i(tms_pad_i),      // JTAG test mode select pad
    .tck_pad_i(tck_pad_i),      // JTAG test clock pad
    .trstn_pad_i(trstn_pad_i),     // JTAG test reset pad
    .tdi_pad_i(tdi_pad_i),      // JTAG test data input pad
    .tdo_pad_o(tdo_pad_o),      // JTAG test data output logic  pad
    .tdo_padoe_o(tdo_padoe_o),    // output logic  enable for JTAG test data output logic  pad 

    .test_mode_i(test_mode_i),     // test mode input

    // TAP states
    .test_logic_reset_o(test_logic_reset_o),
    .run_test_idle_o(run_test_idle_o),
    .shift_dr_o(shift_dr_o),
    .pause_dr_o(pause_dr_o),
    .update_dr_o(update_dr_o),
    .capture_dr_o(capture_dr_o),

    // Select signals for boundary scan or mbist
    .extest_select_o(extest_select_o),
    .sample_preload_select_o(sample_preload_select_o),
    .mbist_select_o(mbist_select_o),
    .debug_select_o(debug_select_o),

    // TDO signal that is connected to TDI of sub-modules.
    .tdi_o(tdi_o),

    // TDI signals from sub-modules
    .debug_tdo_i(debug_tdo_i),    // from debug module
    .bs_chain_tdo_i(bs_chain_tdo_i), // from Boundary Scan Chain
    .mbist_tdo_i(mbist_tdo_i)    // from Mbist Chain
);

//rtc_clock instantiation------------------------------
rtc_clock rtc_clock(
    .clk_i(clk_top),
	.rstn_i(rstn_top),

	.clock_update_i(clock_update_i),
	.clock_o(clock_o),
	.clock_i(clock_i),

	.init_sec_cnt_i(init_sec_cnt_i),

	.timer_update_i(timer_update_i),
	.timer_enable_i(timer_enable_i),
	.timer_retrig_i(timer_retrig_i),
	.timer_target_i(timer_target_i),
	.timer_value_o(timer_value_o),

	.alarm_enable_i(alarm_enable_i),
	.alarm_update_i(alarm_update_i),
	.alarm_clock_i(alarm_clock_i),
	.alarm_clock_o(alarm_clock_o),

	.event_o(event_o),

	.update_day_o(update_day_o)
);

//mux_func instantiation------------------------------
mux_func mux_func(
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .clk(clk_top),
    .rst(rstn_top)
);

//jtag_tap_top instantiation------------------------------
jtag_tap_top jtag_tap_top(
    .tck_i(tck_i),
    .trst_ni(trst_ni),
    .tms_i(tms_i),
    .td_i(td_i),
    .td_o(td_o),

    .soc_tck_o(soc_tck_o),
    .soc_trstn_o(soc_trstn_o),
    .soc_tms_o(soc_tms_o),
    .soc_tdi_o(soc_tdi_o),
    .soc_tdo_i(soc_tdo_i),

    .test_clk_i(test_clk_i),
    .test_rstn_i(test_rstn_i),

    .soc_jtag_reg_i(soc_jtag_reg_i),
    .soc_jtag_reg_o(soc_jtag_reg_o),
    .sel_fll_clk_o(sel_fll_clk_o),
    .jtag_shift_dr_o(jtag_shift_dr_o),
    .jtag_update_dr_o(jtag_update_dr_o),
    .jtag_capture_dr_o(jtag_capture_dr_o),
    .axireg_sel_o(axireg_sel_o),

    .dbg_axi_scan_in_o(dbg_axi_scan_in_o),
    .dbg_axi_scan_out_i(dbg_axi_scan_out_i)
);

endmodule

//APB_ADDR_WIDTH repeat
//APB_DATA_WIDTH repeat
//ADDR_WIDTH repeat

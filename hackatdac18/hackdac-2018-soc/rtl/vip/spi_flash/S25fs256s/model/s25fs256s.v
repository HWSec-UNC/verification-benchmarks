///////////////////////////////////////////////////////////////////////////////
//  File name : s25fs256.v
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//  Copyright (C) 2014 Spansion, LLC.
//
//  MODIFICATION HISTORY :
//
//  version: |   author:     |  mod date:  |  changes made:
//    V1.0      S.Petrovic     28 Jan 13      Initial version
//                                            (FS-S_DRS_V3.1; Aug 10,2012)
//    V1.1      S.Petrovic     28 Nov 13      Corrected Quad DDR read
//                                            with DLP
//    V1.2      S.Petrovic     23 Dec 13      DLP read enabled with 4 latency
//                                            cycles
//    V1.3      S.Petrovic     10 Apr 14      Corrected assignment of PageSize
//    V1.4      S.Petrovic     15 Aug 14      Corrected SFDP read
//    V1.5      S.Petrovic     17 Aug 14      Simulation bug-fix
//    V1.6      S.Petrovic     26 Aug 14      Added SFDP JEDEC parameter
//    V1.7      S.Petrovic     16 Oct 14      Assignment of read_out is changed to
//                                            non-blocking. oe is gated with CS#
//
///////////////////////////////////////////////////////////////////////////////
//  PART DESCRIPTION:
//
//  Library:    FLASH
//  Technology: FLASH MEMORY
//  Part:       S25FS256S
//
//  Description: 512 Megabit Serial Flash Memory
//
//////////////////////////////////////////////////////////////////////////////
//  Comments :
//      For correct simulation, simulator resolution should be set to 1 ps
//      A device ordering (trim) option determines whether a feature is enabled
//      or not, or provide relevant parameters:
//        -15th character in TimingModel determines if enhanced high
//         performance option is available
//            (0,2,3) General Market
//            (Y,Z)   Secure
//
//////////////////////////////////////////////////////////////////////////////
//  Known Bugs:
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// MODULE DECLARATION                                                       //
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ps/1 ps

module s25fs256s
    (
        // Data Inputs/Outputs
        SI     ,
        SO     ,
        // Controls
        SCK    ,
        CSNeg  ,
        WPNeg  ,
        RESETNeg
    );

///////////////////////////////////////////////////////////////////////////////
// Port / Part Pin Declarations
///////////////////////////////////////////////////////////////////////////////

    inout   SI            ;
    inout   SO            ;

    input   SCK           ;
    input   CSNeg         ;
    inout   WPNeg         ;
    inout   RESETNeg      ;

    // interconnect path delay signals
    wire   SCK_ipd        ;
    wire   SI_ipd         ;
    wire   SO_ipd         ;
    wire   CSNeg_ipd      ;
    wire   WPNeg_ipd      ;
    wire   RESETNeg_ipd   ;

    wire SI_in            ;
    assign SI_in = SI_ipd ;

    wire SI_out           ;
    assign SI_out = SI    ;

    wire SO_in            ;
    assign SO_in = SO_ipd ;

    wire SO_out           ;
    assign SO_out = SO    ;

    wire   WPNeg_in                 ;
    //Internal pull-up
    assign WPNeg_in = (WPNeg_ipd === 1'bx) ? 1'b1 : WPNeg_ipd;

    wire   WPNeg_out                ;
    assign WPNeg_out = WPNeg        ;

    wire   RESETNeg_in              ;
    //Internal pull-up
    assign RESETNeg_in = (RESETNeg_ipd === 1'bx) ? 1'b1 : RESETNeg_ipd;

    wire   RESETNeg_out             ;
    assign RESETNeg_out = RESETNeg  ;

    // internal delays
    reg RST_in      ;
    reg RST_out     ;
    reg SWRST_in    ;
    reg SWRST_out   ;
    reg ERSSUSP_in  ;
    reg ERSSUSP_out ;
    reg PRGSUSP_in  ;
    reg PRGSUSP_out ;
    reg PPBERASE_in ;
    reg PPBERASE_out;
    reg PASSULCK_in ;
    reg PASSULCK_out;
    reg PASSACC_in ;
    reg PASSACC_out;

    // event control registers
    reg PRGSUSP_out_event;
    reg ERSSUSP_out_event;

    reg rising_edge_CSNeg_ipd  = 1'b0;
    reg falling_edge_CSNeg_ipd = 1'b0;
    reg rising_edge_SCK_ipd    = 1'b0;
    reg falling_edge_SCK_ipd   = 1'b0;
    reg rising_edge_RESETNeg   = 1'b0;
    reg falling_edge_RESETNeg  = 1'b0;
    reg falling_edge_RST       = 1'b0;
    reg rising_edge_RST_out    = 1'b0;
    reg rising_edge_SWRST_out  = 1'b0;
    reg rising_edge_reseted    = 1'b0;

    reg falling_edge_write     = 1'b0;

    reg rising_edge_PoweredUp  = 1'b0;
    reg rising_edge_PSTART     = 1'b0;
    reg rising_edge_PDONE      = 1'b0;
    reg rising_edge_ESTART     = 1'b0;
    reg rising_edge_EDONE      = 1'b0;
    reg rising_edge_WSTART     = 1'b0;
    reg rising_edge_WDONE      = 1'b0;
    reg rising_edge_CSDONE     = 1'b0;
    reg rising_edge_BCDONE     = 1'b0;
    reg rising_edge_EESSTART   = 1'b0;
    reg rising_edge_EESDONE    = 1'b0;

    reg falling_edge_PASSULCK_in = 1'b0;
    reg falling_edge_PPBERASE_in = 1'b0;

    reg RST                ;

    reg SOut_zd        = 1'bZ;
    reg SIOut_zd       = 1'bZ;
    reg WPNegOut_zd    = 1'bZ;
    reg RESETNegOut_zd = 1'bZ;

    parameter UserPreload       = 1;
    parameter mem_file_name     = "none";//"s25fs256s.mem";
    parameter otp_file_name     = "s25fs256sOTP.mem";//"none";

    parameter TimingModel       = "DefaultTimingModel";

    parameter  PartID           = "s25fs256s";
    parameter  MaxData          = 255;
    parameter  MemSize          = 28'h1FFFFFF;
    parameter  SecSize256       = 20'h3FFFF;
    parameter  SecSize64        = 18'hFFFF;
    parameter  SecSize4         = 12'hFFF;
    parameter  SecNumUni        = 511;
    parameter  SecNumHyb        = 519;
    parameter  BlockNumUni      = 127;
    parameter  BlockNumHyb      = 135;
    parameter  PageNum512       = 20'hFFFF;
    parameter  PageNum256       = 20'h1FFFF;
    parameter  AddrRANGE        = 28'h1FFFFFF;
    parameter  HiAddrBit        = 31;
    parameter  OTPSize          = 1023;
    parameter  OTPLoAddr        = 12'h000;
    parameter  OTPHiAddr        = 12'h3FF;
    parameter  SFDPLoAddr       = 16'h0000;
    parameter  SFDPHiAddr       = 16'h1151;
    parameter  SFDPLength       = 16'h1151;
    parameter  CFILength        = 8'hBF;
    parameter  BYTE             = 8;

    integer    SECURE_OPN; //  Trim Options active

    //varaibles to resolve architecture used
    reg [24*8-1:0] tmp_timing;//stores copy of TimingModel
    reg [7:0] tmp_char1; //Define General Market or Secure Device
    integer found = 1'b0;

    // If speedsimulation is needed uncomment following line

//        `define SPEEDSIM;

    // powerup
    reg PoweredUp;

    // Memory Array Configuration
    reg BottomBoot          = 1'b0;
    reg TopBoot             = 1'b0;
    reg UniformSec          = 1'b0;

    // FSM control signals
    reg PDONE     ;
    reg PSTART    ;
    reg PGSUSP    ;
    reg PGRES     ;

    reg RES_TO_SUSP_TIME;

    reg CSDONE    ;
    reg CSSTART   ;

    reg WDONE     ;
    reg WSTART    ;

    reg EESDONE   ;
    reg EESSTART  ;

    reg EDONE     ;
    reg ESTART    ;
    reg ESUSP     ;
    reg ERES      ;

    reg reseted   ;

    //Flag for Password unlock command
    reg PASS_UNLOCKED     = 1'b0;
    reg [63:0] PASS_TEMP  = 64'hFFFFFFFFFFFFFFFF;

    reg INITIAL_CONFIG    = 1'b0;
    reg CHECK_FREQ        = 1'b0;

    reg ZERO_DETECTED    = 1'b0;

    // Flag for Blank Check
    reg NOT_BLANK        = 1'b0;

    // Wrap Length
    integer WrapLength;

    // Programming buffer
    integer WByte[0:511];
    // SFDP array
    integer SFDP_array[SFDPLoAddr:SFDPHiAddr];
    // OTP Memory Array
    integer OTPMem[OTPLoAddr:OTPHiAddr];
    // Flash Memory Array
    integer Mem[0:AddrRANGE];

    //-----------------------------------------
    //  Registers
    //-----------------------------------------
    reg [7:0] SR1_in    = 8'h00;

    //Nonvolatile Status Register 1
    reg [7:0] SR1_NV    = 8'h00;

    wire       SRWD_NV;
    wire [2:0] BP_NV;

    assign SRWD_NV   = SR1_NV[7];
    assign BP_NV     = SR1_NV[4:2];

    //Volatile Status Register 1
    reg [7:0] SR1_V     = 8'h00;

    wire       SRWD;
    wire       P_ERR;
    wire       E_ERR;
    wire [2:0] BP;
    wire       WEL;
    wire       WIP;

    assign SRWD   = SR1_V[7]  ;
    assign P_ERR  = SR1_V[6]  ;
    assign E_ERR  = SR1_V[5]  ;
    assign BP     = SR1_V[4:2];
    assign WEL    = SR1_V[1]  ;
    assign WIP    = SR1_V[0]  ;

    //Volatile Status Register 2
    reg [7:0] SR2_V     = 8'h00;

    wire ESTAT;
    wire ES;
    wire PS;

    assign ESTAT = SR2_V[2];
    assign ES    = SR2_V[1];
    assign PS    = SR2_V[0];

    //Nonvolatile Configuration Register 1
    reg [7:0] CR1_in    = 8'h00;

    reg [7:0] CR1_NV    = 8'h00;

    wire   TBPROT_O;
    wire   LOCK_O;
    wire   BPNV_O;
    wire   TBPARM_O;
    wire   QUAD_O;

    assign TBPROT_O  = CR1_NV[5];
    assign LOCK_O    = CR1_NV[4];
    assign BPNV_O    = CR1_NV[3];
    assign TBPARM_O  = CR1_NV[2];
    assign QUAD_O    = CR1_NV[1];

    //Volatile Configuration Register 1
    reg [7:0] CR1_V     = 8'h00;

    wire   TBPROT;
    wire   LOCK;
    wire   BPNV;
    wire   TBPARM;
    wire   QUAD;
    wire   FREEZE;

    assign TBPROT  = CR1_V[5];
    assign LOCK    = CR1_V[4];
    assign BPNV    = CR1_V[3];
    assign TBPARM  = CR1_V[2];
    assign QUAD    = CR1_V[1];
    assign FREEZE  = CR1_V[0];

    //Nonvolatile Configuration Register 2
    reg [7:0] CR2_NV    = 8'h08;

    //Volatile Configuration Register 2
    reg [7:0] CR2_V     = 8'h08;

    wire   QUAD_ALL;

    assign QUAD_ALL  = CR2_V[6];

    //Nonvolatile Configuration Register 3
    reg [7:0] CR3_NV    = 8'h00;

    //Volatile Configuration Register 3
    reg [7:0] CR3_V     = 8'h00;

    //Nonvolatile Configuration Register 4
    reg [7:0] CR4_NV    = 8'h00;

    //Volatile Configuration Register 4
    reg [7:0] CR4_V     = 8'h00;

    // ASP Register
    reg[15:0] ASP_reg    = 16'hFFFF;
    reg[15:0] ASP_reg_in = 16'hFFFF;

    wire    DYBLBB       ;
    wire    PPBOTP       ;
    wire    PWDMLB       ;
    wire    PSTMLB       ;
    wire    PERMLB       ;
    assign  DYBLBB   = ASP_reg[4];
    assign  PPBOTP   = ASP_reg[3];
    assign  PWDMLB   = ASP_reg[2];
    assign  PSTMLB   = ASP_reg[1];
    assign  PERMLB   = ASP_reg[0];

    // Password register
    reg[63:0] Password_reg     = 64'hFFFFFFFFFFFFFFFF;
    reg[63:0] Password_reg_in  = 64'hFFFFFFFFFFFFFFFF;

    // PPB Lock Register
    reg[7:0] PPBL              = 8'h01;
    reg[7:0] PPBL_in           = 8'h01;

    wire   PPB_LOCK                  ;
    assign PPB_LOCK     = PPBL[0];

    // PPB Access Register
    reg[7:0] PPBAR             = 8'hFF;
    reg[7:0] PPBAR_in          = 8'hFF;

    reg[SecNumHyb:0] PPB_bits  = {(SecNumHyb+1){1'b1}};
    reg[BlockNumHyb:0] PPB_bits_b  = {(BlockNumHyb+1){1'b1}};

    // DYB Access Register
    reg[7:0] DYBAR             = 8'hFF;
    reg[7:0] DYBAR_in          = 8'hFF;

    reg[SecNumHyb:0] DYB_bits  = {(SecNumHyb+1){1'b1}};
    reg[BlockNumHyb:0] DYB_bits_b  = {(BlockNumHyb+1){1'b1}};

    // VDLR Register
    reg[7:0] VDLR_reg          = 8'h00;
    reg[7:0] VDLR_reg_in       = 8'h00;
    // NVDLR Register
    reg[7:0] NVDLR_reg         = 8'h00;
    reg[7:0] NVDLR_reg_in      = 8'h00;
    reg dlp_act                = 1'b0;

    reg [7:0] WRAR_reg_in = 8'h00;
    reg [7:0] RDAR_reg    = 8'h00;

    reg [7:0] SBL_data_in = 8'h00;

    // ECC Register
    reg[7:0] ECC_reg    = 8'h00;

    reg[SecNumHyb:0] ERS_nosucc  = {(SecNumHyb+1){1'b0}};
    reg[BlockNumHyb:0] ERS_nosucc_b  = {(BlockNumHyb+1){1'b0}};

    //The Lock Protection Registers for OTP Memory space
    reg[7:0] LOCK_BYTE1;
    reg[7:0] LOCK_BYTE2;
    reg[7:0] LOCK_BYTE3;
    reg[7:0] LOCK_BYTE4;

    reg write;
    reg cfg_write;
    reg read_out;
    reg dual          = 1'b0;
    reg rd_fast       = 1'b1;
    reg rd_slow       = 1'b0;
    reg ddr           = 1'b0;
    reg any_read      = 1'b0;

    reg DOUBLE          = 1'b0; //Double Data Rate (DDR) flag

    reg  change_TBPARM = 0;

    reg  change_BP = 0;
    reg [2:0] BP_bits   = 3'b0;

    reg     change_PageSize = 0;
    integer PageSize = 255;
    integer PageNum  = PageNum256;

    integer    ASP_ProtSE = 0;
    integer    Sec_ProtSE = 0;

    integer    RESET_EN = 0;     //Reset Enable Flag

    reg     change_addr ;
    integer Address = 0;
    integer SectorErased = 0;
    integer BlockErased = 0;

    reg     bc_done ;

    reg oe   = 1'b0;
    reg oe_z = 1'b0;

    integer Byte_number = 0;

    // Sector is protect if Sec_Prot(sect) = '1'
    reg [SecNumHyb:0] Sec_Prot  = 520'b0;
    // 256kB erase block is protect if Block_Prot(block_e) = '1'
    reg [BlockNumHyb:0] Block_Prot  = 136'b0;

    reg [8*(CFILength+1)-1:0]  CFI_array_tmp ;
    reg [7:0]                  CFI_tmp;

    reg [8*(SFDPLength+1)-1:0] SFDP_array_tmp ;
    reg [7:0]                  SFDP_tmp;

    // timing check violation
    reg Viol = 1'b0;

    integer WOTPByte;
    integer AddrLo;
    integer AddrHi;

    reg[7:0]  old_bit, new_bit;
    integer old_int, new_int;
    reg[63:0] old_pass;
    reg[63:0] new_pass;
    reg[7:0]  old_pass_byte;
    reg[7:0]  new_pass_byte;
    integer wr_cnt;
    integer cnt;

    integer read_cnt  = 0;
    integer read_addr = 0;
    integer byte_cnt  = 1;
    integer pgm_page = 0;

    reg[7:0] data_out;

    time SCK_cycle = 0;
    time prev_SCK;
    reg  glitch = 1'b0;
    reg  DataDriveOut_SO = 1'bZ ;
    reg  DataDriveOut_SI = 1'bZ ;
    reg  DataDriveOut_RESET = 1'bZ ;
    reg  DataDriveOut_WP = 1'bZ ;

	reg  Instruct_P4E;

///////////////////////////////////////////////////////////////////////////////
//Interconnect Path Delay Section
///////////////////////////////////////////////////////////////////////////////
 buf   (SCK_ipd, SCK);
 buf   (SI_ipd, SI);
 buf   (SO_ipd, SO);
 buf   (CSNeg_ipd, CSNeg);
 buf   (WPNeg_ipd, WPNeg);
 buf   (RESETNeg_ipd, RESETNeg);

///////////////////////////////////////////////////////////////////////////////
// Propagation  delay Section
///////////////////////////////////////////////////////////////////////////////
    nmos   (SI,       SIOut_zd       , 1);
    nmos   (SO,       SOut_zd        , 1);
    nmos   (RESETNeg, RESETNegOut_zd , 1);
    nmos   (WPNeg,    WPNegOut_zd    , 1);

    // Needed for TimingChecks
    // VHDL CheckEnable Equivalent

    //Single Data Rate Operations
    wire sdro;
    assign sdro = PoweredUp && ~DOUBLE;
    wire sdro_quad_io0;
    assign sdro_quad_io0 = PoweredUp && ~DOUBLE && ~dual && ~rd_fast && QUAD;
    wire sdro_io1;
    assign sdro_io1 = PoweredUp && ~DOUBLE && ~dual;
    wire sdro_quad_io2;
    assign sdro_quad_io2 = PoweredUp && ~DOUBLE && ~dual && QUAD;
    wire sdro_quad_io3;
    assign sdro_quad_io3 = PoweredUp && ~DOUBLE && ~dual && QUAD && ~CSNeg;

    //Dual Data Rate Operations
    wire ddro;
    assign ddro = PoweredUp && ddr;

    wire ddro_quad_io0;
    assign ddro_quad_io0 = PoweredUp && DOUBLE && ~dual && ~rd_fast && QUAD;
    wire ddro_io1;
    assign ddro_io1 = PoweredUp && DOUBLE && ~dual;
    wire ddro_quad_io2;
    assign ddro_quad_io2 = PoweredUp && DOUBLE && ~dual && QUAD;
    wire ddro_quad_io3;
    assign ddro_quad_io3 = PoweredUp && DOUBLE && ~dual && QUAD && ~CSNeg;

    wire rd ;
    wire fast_rd ;
    wire ddrd ;
    assign fast_rd = rd_fast;
    assign rd      = rd_slow;
    assign ddrd    = ddr;

    wire wr_prot;
    assign wr_prot = SRWD && ~QUAD;

    wire reset_act;
    assign reset_act = CR2_V[5] && (~QUAD || (QUAD && CSNeg_ipd));

    wire rst_not_quad;
    assign rst_not_quad = CR2_V[5] && ~QUAD;

    wire rst_quad;
    assign rst_quad = CR2_V[5] && QUAD;

    wire RD_EQ_1;
    assign RD_EQU_1 = any_read && ~rst_quad;

    wire QRD_EQ_1;
    assign QRD_EQU_1 = any_read && rst_quad;

    wire RD_EQ_0;
    assign RD_EQU_0 = ~any_read;

specify
        // tipd delays: interconnect path delays , mapped to input port delays.
        // In Verilog is not necessary to declare any tipd_ delay variables,
        // they can be taken from SDF file
        // With all the other delays real delays would be taken from SDF file

    // tpd delays
    specparam        tpd_SCK_SO_sdr          = 1; // (tV,tV,tHO,tV,tHO,tV)
    specparam        tpd_SCK_SO_ddr          = 1; // (tV,tV,tHO,tV,tHO,tV)
    specparam        tpd_CSNeg_SO_rd         = 1; // tDIS
    specparam        tpd_CSNeg_SO_rst_quad   = 1; // tDIS

    //tsetup values: setup times
    specparam        tsetup_CSNeg_SCK        = 1;   // tCSS edge /
    specparam        tsetup_SI_SCK_sdr       = 1;   // tSU  edge /
    specparam        tsetup_SI_SCK_ddr       = 1;   // tSU
    specparam        tsetup_WPNeg_CSNeg      = 1;   // tWPS edge \
    specparam        tsetup_RESETNeg_CSNeg   = 1;   // tRS  edge \

    //thold values: hold times
    specparam        thold_CSNeg_SCK         = 1;   // tCSH edge /
    specparam        thold_SI_SCK_sdr        = 1;   // tHD  edge /
    specparam        thold_SI_SCK_ddr        = 1;   // tHD
    specparam        thold_WPNeg_CSNeg       = 1;   // tWPH edge /
    specparam        thold_CSNeg_RESETNeg    = 1;   // tRH  edge /

    // tpw values: pulse width
    specparam        tpw_SCK_serial_posedge  = 1;
    specparam        tpw_SCK_fast_posedge    = 1;
    specparam        tpw_SCK_qddr_posedge    = 1;
    specparam        tpw_SCK_serial_negedge  = 1;
    specparam        tpw_SCK_fast_negedge    = 1;
    specparam        tpw_SCK_qddr_negedge    = 1;
    specparam        tpw_CSNeg_read_posedge  = 1;   // tCS
    specparam        tpw_CSNeg_qread_posedge = 1;   // tCS
    specparam        tpw_CSNeg_pgers_posedge = 1;   // tCS
    specparam        tpw_RESETNeg_negedge    = 1;   // tRP
    specparam        tpw_RESETNeg_posedge    = 1;   // tRS

    // tperiod min (calculated as 1/max freq)
    specparam        tperiod_SCK_serial_rd   = 1;   // 50 MHz
    specparam        tperiod_SCK_fast_rd     = 1;   //133 MHz
    specparam        tperiod_SCK_qddr        = 1;   // 80 MHz

    `ifdef SPEEDSIM
        // WRR Cycle Time
        specparam        tdevice_WRR               = 750e6;//tW = 750us
        // Page Program Operation
        specparam        tdevice_PP_256            = 90e6; //tPP = 90us
        // Page Program Operation
        specparam        tdevice_PP_512            = 95e6; //tPP = 95us
        // Sector Erase Operation
        specparam        tdevice_SE4               = 7250e6;//tSE = 7250us
        // Sector Erase Operation
        specparam        tdevice_SE256             = 29e9; //tSE = 29ms
        // Bulk Erase Operation
        specparam        tdevice_BE                = 360e9;//tBE = 360ms
        // Evaluate Erase Status Time
        specparam        tdevice_EES               = 10e6; //tEES = 10us
        // Suspend Latency
        specparam        tdevice_SUSP              = 4e6;  //tSL = 4us
        // Resume to next Suspend Time
        specparam        tdevice_RS                = 10e6; //tRS = 10 us
        // RESET# Low to CS# Low
        specparam        tdevice_RPH               = 35e6; //tRPH = 35 us
        // CS# High before HW Reset (Quad mode and Reset Feature are enabled)
        specparam        tdevice_CS                = 20e3; //tCS = 20 ns
        // VDD (min) to CS# Low
        specparam        tdevice_PU                = 300e6;//tPU = 300us
        // Password Unlock to Password Unlock Time
        specparam        tdevice_PASSACC           = 100e6;// 100us
    `else
        // WRR Cycle Time
        specparam        tdevice_WRR               = 750e9; //tW = 750ms
        // Page Program Operation
        specparam        tdevice_PP_256            = 900e6; //tPP = 900us
        // Page Program Operation
        specparam        tdevice_PP_512            = 950e6; //tPP = 950us
        // Sector Erase Operation
        specparam        tdevice_SE4               = 725e9; //tSE = 725ms
        // Sector Erase Operation
        specparam        tdevice_SE256             = 2900e9;//tSE = 2900ms
        // Bulk Erase Operation
        specparam        tdevice_BE                = 360e12;//tBE = 360s
        // Evaluate Erase Status Time
        specparam        tdevice_EES               = 100e6;//tEES = 100us
        // Suspend Latency
        specparam        tdevice_SUSP              = 40e6; //tSL = 40us
        // Resume to next Suspend Time
        specparam        tdevice_RS                = 100e6;//tRS = 100 us
        // RESET# Low to CS# Low
        specparam        tdevice_RPH               = 35e6; //tRPH = 35 us
        // CS# High before HW Reset (Quad mode and Reset Feature are enabled)
        specparam        tdevice_CS                = 20e3; //tCS = 20 ns
        // VDD (min) to CS# Low
        specparam        tdevice_PU                = 300e6;//tPU = 300us
        // Password Unlock to Password Unlock Time
        specparam        tdevice_PASSACC           = 100e6;// 100us
    `endif // SPEEDSIM

///////////////////////////////////////////////////////////////////////////////
// Input Port  Delays  don't require Verilog description
///////////////////////////////////////////////////////////////////////////////
// Path delays                                                               //
///////////////////////////////////////////////////////////////////////////////
   if (rd_slow && ~glitch)           (SCK => SO) = tpd_SCK_SO_sdr;
   if ((ddr || rd_fast) && ~glitch)  (SCK => SO) = tpd_SCK_SO_ddr;

   if (dual && ~glitch) (SCK => SI) = tpd_SCK_SO_ddr;

   if (QUAD && ~CSNeg && ~glitch) (SCK => RESETNeg) = tpd_SCK_SO_ddr;
   if (QUAD && ~glitch)           (SCK => WPNeg)    = tpd_SCK_SO_ddr;

   if (CSNeg && ~rst_quad)    (CSNeg => SO)     = tpd_CSNeg_SO_rd;
   if (CSNeg &&  rst_quad)    (CSNeg => SO)     = tpd_CSNeg_SO_rst_quad;

   if (CSNeg && dual && ~rst_quad) (CSNeg => SI) = tpd_CSNeg_SO_rd;
   if (CSNeg && dual &&  rst_quad) (CSNeg => SI) = tpd_CSNeg_SO_rst_quad;

   if (CSNeg && ~rst_quad) (CSNeg => RESETNeg) = tpd_CSNeg_SO_rd;
   if (CSNeg &&  rst_quad) (CSNeg => RESETNeg) = tpd_CSNeg_SO_rst_quad;

   if (CSNeg && ~rst_quad) (CSNeg => WPNeg)    = tpd_CSNeg_SO_rd;
   if (CSNeg &&  rst_quad) (CSNeg => WPNeg)    = tpd_CSNeg_SO_rst_quad;

///////////////////////////////////////////////////////////////////////////////
// Timing Violation                                                          //
///////////////////////////////////////////////////////////////////////////////
    $setup ( CSNeg          , posedge SCK,      tsetup_CSNeg_SCK        , Viol);

    $setup ( SI             , posedge SCK &&& sdro_io1,
                                                tsetup_SI_SCK_sdr       , Viol);
    $setup ( SI             , posedge SCK &&& ddro_io1,
                                                tsetup_SI_SCK_ddr       , Viol);
    $setup ( SI             , negedge SCK &&& ddro_io1,
                                                tsetup_SI_SCK_ddr       , Viol);

    $setup ( SO             , posedge SCK &&& sdro_quad_io0,
                                                tsetup_SI_SCK_sdr       , Viol);
    $setup ( SO             , posedge SCK &&& ddro_quad_io0,
                                                tsetup_SI_SCK_ddr       , Viol);
    $setup ( SO             , negedge SCK &&& ddro_quad_io0,
                                                tsetup_SI_SCK_ddr       , Viol);

    $setup ( WPNeg          , posedge SCK &&& sdro_quad_io2,
                                                tsetup_SI_SCK_sdr       , Viol);
    $setup ( WPNeg          , posedge SCK &&& ddro_quad_io2,
                                                tsetup_SI_SCK_ddr       , Viol);
    $setup ( WPNeg          , negedge SCK &&& ddro_quad_io2,
                                                tsetup_SI_SCK_ddr       , Viol);

    $setup ( RESETNeg       , posedge SCK &&& sdro_quad_io3,
                                                tsetup_SI_SCK_sdr       , Viol);
    $setup ( RESETNeg       , posedge SCK &&& ddro_quad_io3,
                                                tsetup_SI_SCK_ddr       , Viol);
    $setup ( RESETNeg       , negedge SCK &&& ddro_quad_io3,
                                                tsetup_SI_SCK_ddr       , Viol);

    $setup ( WPNeg          , negedge CSNeg &&& wr_prot,
                                                tsetup_WPNeg_CSNeg      , Viol);
    $setup ( RESETNeg       , negedge CSNeg &&& rst_not_quad,
                                                tsetup_RESETNeg_CSNeg   , Viol);

    $hold  ( posedge SCK    ,               CSNeg,   thold_CSNeg_SCK    , Viol);

    $hold  ( posedge SCK &&& sdro_io1,      SI ,     thold_SI_SCK_sdr    ,Viol);
    $hold  ( posedge SCK &&& ddro_io1,      SI ,     thold_SI_SCK_sdr    ,Viol);
    $hold  ( negedge SCK &&& ddro_io1,      SI ,     thold_SI_SCK_sdr    ,Viol);

    $hold  ( posedge SCK &&& sdro_quad_io0, SO ,     thold_SI_SCK_sdr    ,Viol);
    $hold  ( posedge SCK &&& ddro_quad_io0, SO ,     thold_SI_SCK_sdr    ,Viol);
    $hold  ( negedge SCK &&& ddro_quad_io0, SO ,     thold_SI_SCK_sdr    ,Viol);

    $hold  ( posedge SCK &&& sdro_quad_io2, WPNeg,   thold_SI_SCK_sdr    ,Viol);
    $hold  ( posedge SCK &&& ddro_quad_io2, WPNeg,   thold_SI_SCK_sdr    ,Viol);
    $hold  ( negedge SCK &&& ddro_quad_io2, WPNeg,   thold_SI_SCK_sdr    ,Viol);

    $hold  ( posedge SCK &&& sdro_quad_io3, RESETNeg,thold_SI_SCK_sdr    ,Viol);
    $hold  ( posedge SCK &&& ddro_quad_io3, RESETNeg,thold_SI_SCK_sdr    ,Viol);
    $hold  ( negedge SCK &&& ddro_quad_io3, RESETNeg,thold_SI_SCK_sdr    ,Viol);

    $hold  ( posedge CSNeg &&& wr_prot,     WPNeg ,  thold_WPNeg_CSNeg   ,Viol);
    $hold  ( negedge RESETNeg &&& reset_act,CSNeg ,  thold_CSNeg_RESETNeg,Viol);

    $width ( posedge SCK &&& rd           , tpw_SCK_serial_posedge);
    $width ( negedge SCK &&& rd           , tpw_SCK_serial_negedge);
    $width ( posedge SCK &&& fast_rd      , tpw_SCK_fast_posedge);
    $width ( negedge SCK &&& fast_rd      , tpw_SCK_fast_negedge);
    $width ( posedge SCK &&& ddrd         , tpw_SCK_qddr_posedge);
    $width ( negedge SCK &&& ddrd         , tpw_SCK_qddr_negedge);

    $width ( posedge CSNeg &&& RD_EQU_1   , tpw_CSNeg_read_posedge);
    $width ( posedge CSNeg &&& QRD_EQU_1  , tpw_CSNeg_qread_posedge);
    $width ( posedge CSNeg &&& RD_EQU_0   , tpw_CSNeg_pgers_posedge);
    $width ( negedge RESETNeg &&& reset_act , tpw_RESETNeg_negedge);
    $width ( posedge RESETNeg &&& reset_act , tpw_RESETNeg_posedge);

    $period ( posedge SCK &&& rd       , tperiod_SCK_serial_rd);
    $period ( posedge SCK &&& fast_rd  , tperiod_SCK_fast_rd);
    $period ( posedge SCK &&& ddrd     , tperiod_SCK_qddr);

endspecify

///////////////////////////////////////////////////////////////////////////////
// Main Behavior Block                                                       //
///////////////////////////////////////////////////////////////////////////////
// FSM states
 parameter IDLE             = 5'd0;
 parameter RESET_STATE      = 5'd1;
 parameter PGERS_ERROR      = 5'd2;
 parameter WRITE_SR         = 5'd3;
 parameter WRITE_ALL_REG    = 5'd4;
 parameter PAGE_PG          = 5'd5;
 parameter OTP_PG           = 5'd6;
 parameter PG_SUSP          = 5'd7;
 parameter SECTOR_ERS       = 5'd8;
 parameter BULK_ERS         = 5'd9;
 parameter ERS_SUSP         = 5'd10;
 parameter ERS_SUSP_PG      = 5'd11;
 parameter ERS_SUSP_PG_SUSP = 5'd12;
 parameter PASS_PG          = 5'd13;
 parameter PASS_UNLOCK      = 5'd14;
 parameter PPB_PG           = 5'd15;
 parameter PPB_ERS          = 5'd16;
 parameter ASP_PG           = 5'd17;
 parameter PLB_PG           = 5'd18;
 parameter DYB_PG           = 5'd19;
 parameter NVDLR_PG         = 5'd20;
 parameter BLANK_CHECK      = 5'd21;
 parameter EVAL_ERS_STAT    = 5'd22;

 reg [4:0] current_state;
 reg [4:0] next_state;

// Instruction type
 parameter NONE            = 7'd0;
 parameter WRR             = 7'd1;
 parameter PP              = 7'd2;
 parameter READ            = 7'd3;
 parameter WRDI            = 7'd4;
 parameter RDSR1           = 7'd5;
 parameter WREN            = 7'd6;
 parameter RDSR2           = 7'd7;
 parameter PP4             = 7'd8;
 parameter READ4           = 7'd9;
 parameter ECCRD4          = 7'd10;
 parameter ECCRD           = 7'd11;
 parameter P4E             = 7'd12;
 parameter P4E4            = 7'd13;
 parameter CLSR            = 7'd14;
 parameter EPR             = 7'd15;
 parameter RDCR            = 7'd16;
 parameter DLPRD           = 7'd17;
 parameter OTPP            = 7'd18;
 parameter PNVDLR          = 7'd19;
 parameter BE              = 7'd20;
 parameter RDAR            = 7'd21;
 parameter RSTEN           = 7'd22;
 parameter WRAR            = 7'd23;
 parameter EPS             = 7'd24;
 parameter RSTCMD          = 7'd25;
 parameter FAST_READ       = 7'd26;
 parameter FAST_READ4      = 7'd27;
 parameter ASPRD           = 7'd28;
 parameter ASPP            = 7'd29;
 parameter WVDLR           = 7'd30;
 parameter OTPR            = 7'd31;
 parameter RSFDP           = 7'd32;
 parameter RDID            = 7'd33;
 parameter PLBWR           = 7'd34;
 parameter PLBRD           = 7'd35;
 parameter RDQID           = 7'd36;
 parameter BAM4            = 7'd37;
 parameter DIOR            = 7'd38;
 parameter DIOR4           = 7'd39;
 parameter SBL             = 7'd40;
 parameter EES             = 7'd41;
 parameter SE              = 7'd42;
 parameter SE4             = 7'd43;
 parameter DYBRD4          = 7'd44;
 parameter DYBWR4          = 7'd45;
 parameter PPBRD4          = 7'd46;
 parameter PPBP4           = 7'd47;
 parameter PPBE            = 7'd48;
 parameter PASSRD          = 7'd49;
 parameter PASSP           = 7'd50;
 parameter PASSU           = 7'd51;
 parameter QIOR            = 7'd52;
 parameter QIOR4           = 7'd53;
 parameter DDRQIOR         = 7'd54;
 parameter DDRQIOR4        = 7'd55;
 parameter RESET           = 7'd56;
 parameter DYBRD           = 7'd57;
 parameter DYBWR           = 7'd58;
 parameter PPBRD           = 7'd59;
 parameter PPBP            = 7'd60;
 parameter MBR             = 7'd61;

// Command Register
 reg [6:0] Instruct;

//Bus cycle state
 parameter STAND_BY        = 3'd0;
 parameter OPCODE_BYTE     = 3'd1;
 parameter ADDRESS_BYTES   = 3'd2;
 parameter DUMMY_BYTES     = 3'd3;
 parameter MODE_BYTE       = 3'd4;
 parameter DATA_BYTES      = 3'd5;

 reg [2:0] bus_cycle_state;

    //Power Up time;
    initial
    begin
        PoweredUp = 1'b0;
        #tdevice_PU PoweredUp = 1'b1;
    end

    initial
    begin : Init
        write       = 1'b0;
        cfg_write   = 1'b0;
        read_out    = 1'b0;
        Address     = 0;
        change_addr = 1'b0;
        RST         = 1'b0;
        RST_in      = 1'b0;
        RST_out     = 1'b1;
        SWRST_in    = 1'b0;
        SWRST_out   = 1'b1;
        PDONE       = 1'b1;
        PSTART      = 1'b0;
        PGSUSP      = 1'b0;
        PGRES       = 1'b0;
        PRGSUSP_in  = 1'b0;
        ERSSUSP_in  = 1'b0;
        RES_TO_SUSP_TIME  = 1'b0;

        EDONE       = 1'b1;
        ESTART      = 1'b0;
        ESUSP       = 1'b0;
        ERES        = 1'b0;

        WDONE       = 1'b1;
        WSTART      = 1'b0;

        EESDONE     = 1'b1;
        EESSTART    = 1'b0;

        CSDONE      = 1'b1;
        CSSTART     = 1'b0;

        reseted     = 1'b0;

        Instruct        = NONE;
        bus_cycle_state = STAND_BY;
        current_state   = IDLE;
        next_state      = IDLE;
    end

    // initialize memory and load preload files if any
    initial
    begin: InitMemory
        integer i;

        for (i=0;i<=AddrRANGE;i=i+1)
        begin
            Mem[i] = MaxData;
        end

        if ((UserPreload) && !(mem_file_name == "none"))
        begin
           // Memory Preload
           //s25fs256s.mem, memory preload file
           //  @aaaaaaa - <aaaaaaa> stands for address
           //  dd       - <dd> is byte to be written at Mem(aaaaaaa++)
           // (aaaaaaa is incremented at every load)
           $readmemh(mem_file_name,Mem);
        end

        for (i=OTPLoAddr;i<=OTPHiAddr;i=i+1)
        begin
            OTPMem[i] = MaxData;
        end

        if (UserPreload && !(otp_file_name == "none"))
        begin
        //s25fs256s_otp memory file
        //   /        - comment
        //   @aaa - <aaa> stands for address
        //   dd  - <dd> is byte to be written at OTPMem(aaa++)
        //   (aaa is incremented at every load)
        //   only first 1-4 columns are loaded. NO empty lines !!!!!!!!!!!!!!!!
           $readmemh(otp_file_name,OTPMem);
        end

        LOCK_BYTE1[7:0] = OTPMem[16];
        LOCK_BYTE2[7:0] = OTPMem[17];
        LOCK_BYTE3[7:0] = OTPMem[18];
        LOCK_BYTE4[7:0] = OTPMem[19];
    end

    // initialize memory and load preload files if any
    initial
    begin: InitTimingModel
    integer i;
    integer j;
        //UNIFORM OR HYBRID arch model is used
        //assumptions:
        //1. TimingModel has format as S25FS256SXXXXXXXX_X_XXpF
        //2. TimingModel does not have more then 24 characters
        tmp_timing = TimingModel;//copy of TimingModel

        i = 23;
        while ((i >= 0) && (found != 1'b1))//search for first non null character
        begin        //i keeps position of first non null character
            j = 7;
            while ((j >= 0) && (found != 1'b1))
            begin
                if (tmp_timing[i*8+j] != 1'd0)
                    found = 1'b1;
                else
                    j = j-1;
            end
            i = i - 1;
        end
        i = i +1;
        if (found)//if non null character is found
        begin
            for (j=0;j<=7;j=j+1)
            begin
            //Security character is 15
                tmp_char1[j] = TimingModel[(i-14)*8+j];
            end
        end

        if (tmp_char1 == "0" || tmp_char1 == "2" || tmp_char1 == "3")
        begin
            SECURE_OPN = 0;
        end
        else if (tmp_char1 == "Y" || tmp_char1 == "Z")
        begin
            SECURE_OPN = 1;
        end

    end

    //SFDP
    initial
    begin: InitSFDP
    integer i;
    integer j;
    integer k,l,m;
        ///////////////////////////////////////////////////////////////////////
        // SFDP Header
        ///////////////////////////////////////////////////////////////////////
        SFDP_array[16'h0000] = 8'h53;
        SFDP_array[16'h0001] = 8'h46;
        SFDP_array[16'h0002] = 8'h44;
        SFDP_array[16'h0003] = 8'h50;
        SFDP_array[16'h0004] = 8'h00;
        SFDP_array[16'h0005] = 8'h01;
        SFDP_array[16'h0006] = 8'h01;
        SFDP_array[16'h0007] = 8'hFF;
        SFDP_array[16'h0008] = 8'h00;
        SFDP_array[16'h0009] = 8'h00;
        SFDP_array[16'h000A] = 8'h01;
        SFDP_array[16'h000B] = 8'h09;
        SFDP_array[16'h000C] = 8'h48;
        SFDP_array[16'h000D] = 8'h04;
        SFDP_array[16'h000E] = 8'h00;
        SFDP_array[16'h000F] = 8'hFF;
        SFDP_array[16'h0010] = 8'h01;
        SFDP_array[16'h0011] = 8'h00;
        SFDP_array[16'h0012] = 8'h01;
        SFDP_array[16'h0013] = 8'h51;
        SFDP_array[16'h0014] = 8'h00;
        SFDP_array[16'h0015] = 8'h04;
        SFDP_array[16'h0016] = 8'h00;
        // Unused
        for (i=16'h0017;i< 16'h1000;i=i+1)
        begin
           SFDP_array[i]=MaxData;
        end

        ///////////////////////////////////////////////////////////////////////
        // ID-CFI array data
        ///////////////////////////////////////////////////////////////////////
        // Manufacturer and Device ID
        SFDP_array[16'h1000] = 8'h01;
        SFDP_array[16'h1001] = 8'h02;
        SFDP_array[16'h1002] = 8'h19;
        SFDP_array[16'h1003] = 8'h4D;
        // Uniform 256kB sectors
        SFDP_array[16'h1004] = 8'h00;
        SFDP_array[16'h1005] = 8'h81;
        if (tmp_char1 == "0")
            SFDP_array[16'h1006] = 8'h30;
        else if (tmp_char1 == "2")
            SFDP_array[16'h1006] = 8'h32;
        else if (tmp_char1 == "3")
            SFDP_array[16'h1006] = 8'h33;
        else if (tmp_char1 == "Y")
            SFDP_array[16'h1006] = 8'h59;
        else if (tmp_char1 == "Z")
            SFDP_array[16'h1006] = 8'h5A;
        else
            SFDP_array[16'h1006] = 8'hxx;
        SFDP_array[16'h1007] = 8'h31;
        SFDP_array[16'h1008] = 8'h84;
        SFDP_array[16'h1009] = 8'h00;
        SFDP_array[16'h100A] = 8'h00;
        SFDP_array[16'h100B] = 8'h00;
        SFDP_array[16'h100C] = 8'h00;
        SFDP_array[16'h100D] = 8'h00;
        SFDP_array[16'h100E] = 8'h00;
        SFDP_array[16'h100F] = 8'h00;
        // CFI Query Identification String
        SFDP_array[16'h1010] = 8'h51;
        SFDP_array[16'h1011] = 8'h52;
        SFDP_array[16'h1012] = 8'h59;
        SFDP_array[16'h1013] = 8'h02;
        SFDP_array[16'h1014] = 8'h00;
        SFDP_array[16'h1015] = 8'h40;
        SFDP_array[16'h1016] = 8'h00;
        SFDP_array[16'h1017] = 8'h53;
        SFDP_array[16'h1018] = 8'h46;
        SFDP_array[16'h1019] = 8'h51;
        SFDP_array[16'h101A] = 8'h00;
        //CFI system interface string
        SFDP_array[16'h101B] = 8'h17;
        SFDP_array[16'h101C] = 8'h19;
        SFDP_array[16'h101D] = 8'h00;
        SFDP_array[16'h101E] = 8'h00;
        SFDP_array[16'h101F] = 8'h09;
        SFDP_array[16'h1020] = 8'h09;
        // 256kB sector
        SFDP_array[16'h1021] = 8'h0A;
        SFDP_array[16'h1022] = 8'h01;
        SFDP_array[16'h1023] = 8'h02;
        SFDP_array[16'h1024] = 8'h02;
        SFDP_array[16'h1025] = 8'h03;
        SFDP_array[16'h1026] = 8'h03;
        // Device Geometry Definition(Uniform Sector Devices)
        SFDP_array[16'h1027] = 8'h19;
        SFDP_array[16'h1028] = 8'h02;
        SFDP_array[16'h1029] = 8'h01;
        SFDP_array[16'h102A] = 8'h08;
        SFDP_array[16'h102B] = 8'h00;
        SFDP_array[16'h102C] = 8'h03;
        SFDP_array[16'h102D] = 8'h07;
        SFDP_array[16'h102E] = 8'h00;
        SFDP_array[16'h102F] = 8'h10;
        SFDP_array[16'h1030] = 8'h00;
        SFDP_array[16'h1031] = 8'h00;
        SFDP_array[16'h1032] = 8'h00;
        SFDP_array[16'h1033] = 8'h80;
        SFDP_array[16'h1034] = 8'h00;
        SFDP_array[16'h1035] = 8'hFE;
        SFDP_array[16'h1036] = 8'h01;
        SFDP_array[16'h1037] = 8'h00;
        SFDP_array[16'h1038] = 8'h01;
        SFDP_array[16'h1039] = 8'hFF;
        SFDP_array[16'h103A] = 8'hFF;
        SFDP_array[16'h103B] = 8'hFF;
        SFDP_array[16'h103C] = 8'hFF;
        SFDP_array[16'h103D] = 8'hFF;
        SFDP_array[16'h103E] = 8'hFF;
        SFDP_array[16'h103F] = 8'hFF;
        // CFI Primary Vendor-Specific Extended Query
        SFDP_array[16'h1040] = 8'h50;
        SFDP_array[16'h1041] = 8'h52;
        SFDP_array[16'h1042] = 8'h49;
        SFDP_array[16'h1043] = 8'h31;
        SFDP_array[16'h1044] = 8'h33;
        SFDP_array[16'h1045] = 8'h21;
        SFDP_array[16'h1046] = 8'h02;
        SFDP_array[16'h1047] = 8'h01;
        SFDP_array[16'h1048] = 8'h00;
        SFDP_array[16'h1049] = 8'h08;
        SFDP_array[16'h104A] = 8'h00;
        SFDP_array[16'h104B] = 8'h01;
        SFDP_array[16'h104C] = 8'h03;
        SFDP_array[16'h104D] = 8'h00;
        SFDP_array[16'h104E] = 8'h00;
        SFDP_array[16'h104F] = 8'h07;
        SFDP_array[16'h1050] = 8'h01;

        ///////////////////////////////////////////////////////////////////////
        // CFI Alternate Vendor Specific Extended Query Parameters
        ///////////////////////////////////////////////////////////////////////
        // CFI Alternate Vendor Specific Extended Query Header
        SFDP_array[16'h1051] = 8'h41;
        SFDP_array[16'h1052] = 8'h4C;
        SFDP_array[16'h1053] = 8'h54;
        SFDP_array[16'h1054] = 8'h32;
        SFDP_array[16'h1055] = 8'h30;

        // CFI Alternate Vendor Specific Extended Query Parameter 0
        SFDP_array[16'h1056] = 8'h00;
        SFDP_array[16'h1057] = 8'h10;
        SFDP_array[16'h1058] = 8'h53;
        SFDP_array[16'h1059] = 8'h32;
        SFDP_array[16'h105A] = 8'h35;
        SFDP_array[16'h105B] = 8'h46;
        SFDP_array[16'h105C] = 8'h53;
        SFDP_array[16'h105D] = 8'h32;
        SFDP_array[16'h105E] = 8'h35;
        SFDP_array[16'h105F] = 8'h36;
        SFDP_array[16'h1060] = 8'h53;
        SFDP_array[16'h1061] = 8'hFF;
        SFDP_array[16'h1062] = 8'hFF;
        SFDP_array[16'h1063] = 8'hFF;
        SFDP_array[16'h1064] = 8'hFF;
        SFDP_array[16'h1065] = 8'hFF;
        if (tmp_char1 == "0")
            SFDP_array[16'h1066] = 8'h30;
        else if (tmp_char1 == "2")
            SFDP_array[16'h1066] = 8'h32;
        else if (tmp_char1 == "3")
            SFDP_array[16'h1066] = 8'h33;
        else if (tmp_char1 == "Y")
            SFDP_array[16'h1066] = 8'h59;
        else if (tmp_char1 == "Z")
            SFDP_array[16'h1066] = 8'h5A;
        else
            SFDP_array[16'h1066] = 8'hxx;
        SFDP_array[16'h1067] = 8'h31;

        // CFI Alternate Vendor-Specific Extended Query Parameter 80h
        SFDP_array[16'h1068] = 8'h80;
        SFDP_array[16'h1069] = 8'h01;
        SFDP_array[16'h106A] = 8'hEB;

        // CFI Alternate Vendor-Specific Extended Query Parameter 84h
        SFDP_array[16'h106B] = 8'h84;
        SFDP_array[16'h106C] = 8'h08;
        SFDP_array[16'h106D] = 8'h75;
        SFDP_array[16'h106E] = 8'h28;
        SFDP_array[16'h106F] = 8'h7A;
        SFDP_array[16'h1070] = 8'h64;
        SFDP_array[16'h1071] = 8'h75;
        SFDP_array[16'h1072] = 8'h28;
        SFDP_array[16'h1073] = 8'h7A;
        SFDP_array[16'h1074] = 8'h64;
        SFDP_array[16'h1075] = 8'h88;
        SFDP_array[16'h1076] = 8'h04;
        SFDP_array[16'h1077] = 8'h0A;
        SFDP_array[16'h1078] = 8'h01;
        if (tmp_char1 == "0" || tmp_char1 == "2" || tmp_char1 == "3")
        begin
            SFDP_array[16'h1079] = 8'h00;
            SFDP_array[16'h107A] = 8'h01;
        end
        else if (tmp_char1 == "Z" || tmp_char1 == "Y")
        begin
            SFDP_array[16'h1079] = 8'h02;
            SFDP_array[16'h107A] = 8'h02;
        end
        else
        begin
            SFDP_array[16'h1079] = 8'hxx;
            SFDP_array[16'h107A] = 8'hxx;
        end

        // CFI Alternate Vendor-Specific Extended Query Parameter 8Ch
        SFDP_array[16'h107B] = 8'h8C;
        SFDP_array[16'h107C] = 8'h06;
        SFDP_array[16'h107D] = 8'h96;
        SFDP_array[16'h107E] = 8'h01;
        SFDP_array[16'h107F] = 8'h23;
        SFDP_array[16'h1080] = 8'h00;
        SFDP_array[16'h1081] = 8'h23;
        SFDP_array[16'h1082] = 8'h00;

        // CFI Alternate Vendor-Specific Extended Query Parameter 94h
        SFDP_array[16'h1083] = 8'h94;
        SFDP_array[16'h1084] = 8'h01;
        SFDP_array[16'h1085] = 8'h10;

        // CFI Alternate Vendor-Specific Extended Query Parameter F0h
        SFDP_array[16'h1086] = 8'hF0;
        SFDP_array[16'h1087] = 8'h06;
        SFDP_array[16'h1088] = 8'hFF;
        SFDP_array[16'h1089] = 8'hFF;
        SFDP_array[16'h108A] = 8'hFF;
        SFDP_array[16'h108B] = 8'hFF;
        SFDP_array[16'h108C] = 8'hFF;
        SFDP_array[16'h108D] = 8'hFF;

        // CFI Alternate Vendor-Specific Extended Query Parameter A5h
        SFDP_array[16'h108E] = 8'hA5;
        SFDP_array[16'h108F] = 8'h3C;
        SFDP_array[16'h1090] = 8'hFF;
        SFDP_array[16'h1091] = 8'hFF;
        SFDP_array[16'h1092] = 8'hBA;
        SFDP_array[16'h1093] = 8'hFF;
        SFDP_array[16'h1094] = 8'hFF;
        SFDP_array[16'h1095] = 8'hFF;
        SFDP_array[16'h1096] = 8'hFF;
        SFDP_array[16'h1097] = 8'h0F;
        SFDP_array[16'h1098] = 8'h48;
        SFDP_array[16'h1099] = 8'hEB;
        SFDP_array[16'h109A] = 8'hFF;
        SFDP_array[16'h109B] = 8'hFF;
        SFDP_array[16'h109C] = 8'hFF;
        SFDP_array[16'h109D] = 8'hFF;
        SFDP_array[16'h109E] = 8'h88;
        SFDP_array[16'h109F] = 8'hBB;
        SFDP_array[16'h10A0] = 8'hF6;
        SFDP_array[16'h10A1] = 8'hFF;
        SFDP_array[16'h10A2] = 8'hFF;
        SFDP_array[16'h10A3] = 8'hFF;
        SFDP_array[16'h10A4] = 8'hFF;
        SFDP_array[16'h10A5] = 8'hFF;
        SFDP_array[16'h10A6] = 8'hFF;
        SFDP_array[16'h10A7] = 8'hFF;
        SFDP_array[16'h10A8] = 8'hFF;
        SFDP_array[16'h10A9] = 8'hFF;
        SFDP_array[16'h10AA] = 8'h48;
        SFDP_array[16'h10AB] = 8'hEB;
        SFDP_array[16'h10AC] = 8'h0C;
        SFDP_array[16'h10AD] = 8'h20;
        SFDP_array[16'h10AE] = 8'h10;
        SFDP_array[16'h10AF] = 8'hD8;
        SFDP_array[16'h10B0] = 8'h00;
        SFDP_array[16'h10B1] = 8'hFF;
        SFDP_array[16'h10B2] = 8'h00;
        SFDP_array[16'h10B3] = 8'hFF;
        SFDP_array[16'h10B4] = 8'hFF;
        SFDP_array[16'h10B5] = 8'hFF;
        SFDP_array[16'h10B6] = 8'hFF;
        SFDP_array[16'h10B7] = 8'hFF;
        SFDP_array[16'h10B8] = 8'hFF;
        SFDP_array[16'h10B9] = 8'hFF;
        SFDP_array[16'h10BA] = 8'hFF;
        SFDP_array[16'h10BB] = 8'hFF;
        SFDP_array[16'h10BC] = 8'hFF;
        SFDP_array[16'h10BD] = 8'hFF;
        SFDP_array[16'h10BE] = 8'hFF;
        SFDP_array[16'h10BF] = 8'hFF;

        for (i=16'h10C0;i< 16'h111F;i=i+1)
        begin
           SFDP_array[i]=MaxData;
        end
        // CFI Alternate Vendor-Specific Extended Query Parameter A5h
        // SFDP JEDEC parameter
        SFDP_array[16'h1120] = 8'hA5;
        SFDP_array[16'h1121] = 8'h3C;
        SFDP_array[16'h1122] = 8'hFF;
        SFDP_array[16'h1123] = 8'hFF;
        SFDP_array[16'h1124] = 8'hBA;
        SFDP_array[16'h1125] = 8'hFF;
        SFDP_array[16'h1126] = 8'hFF;
        SFDP_array[16'h1127] = 8'hFF;
        SFDP_array[16'h1128] = 8'hFF;
        SFDP_array[16'h1129] = 8'h0F;
        SFDP_array[16'h112A] = 8'h48;
        SFDP_array[16'h112B] = 8'hEB;
        SFDP_array[16'h112C] = 8'hFF;
        SFDP_array[16'h112D] = 8'hFF;
        SFDP_array[16'h112E] = 8'hFF;
        SFDP_array[16'h112F] = 8'hFF;
        SFDP_array[16'h1130] = 8'h88;
        SFDP_array[16'h1131] = 8'hBB;
        SFDP_array[16'h1132] = 8'hF6;
        SFDP_array[16'h1133] = 8'hFF;
        SFDP_array[16'h1134] = 8'hFF;
        SFDP_array[16'h1135] = 8'hFF;
        SFDP_array[16'h1136] = 8'hFF;
        SFDP_array[16'h1137] = 8'hFF;
        SFDP_array[16'h1138] = 8'hFF;
        SFDP_array[16'h1139] = 8'hFF;
        SFDP_array[16'h113A] = 8'hFF;
        SFDP_array[16'h113B] = 8'hFF;
        SFDP_array[16'h113C] = 8'h48;
        SFDP_array[16'h113D] = 8'hEB;
        SFDP_array[16'h113E] = 8'h0C;
        SFDP_array[16'h113F] = 8'h20;
        SFDP_array[16'h1140] = 8'h10;
        SFDP_array[16'h1141] = 8'hD8;
        SFDP_array[16'h1142] = 8'h00;
        SFDP_array[16'h1143] = 8'hFF;
        SFDP_array[16'h1144] = 8'h00;
        SFDP_array[16'h1145] = 8'hFF;
        SFDP_array[16'h1146] = 8'hFF;
        SFDP_array[16'h1147] = 8'hFF;
        SFDP_array[16'h1148] = 8'hFF;
        SFDP_array[16'h1149] = 8'hFF;
        SFDP_array[16'h114A] = 8'hFF;
        SFDP_array[16'h114B] = 8'hFF;
        SFDP_array[16'h114C] = 8'hFF;
        SFDP_array[16'h114D] = 8'hFF;
        SFDP_array[16'h114E] = 8'hFF;
        SFDP_array[16'h114F] = 8'hFF;
        SFDP_array[16'h1150] = 8'hFF;
        SFDP_array[16'h1151] = 8'hFF;

        for(l=SFDPHiAddr;l>=0;l=l-1)
        begin
            SFDP_tmp = SFDP_array[SFDPLength-l];
            for(m=7;m>=0;m=m-1)
            begin
                SFDP_array_tmp[8*l+m] = SFDP_tmp[m];
            end
        end

        ///////////////////////////////////////////////////////////////////////
        // CFI-ID
        ///////////////////////////////////////////////////////////////////////
        for(i=CFILength;i>=0;i=i-1)
        begin
            CFI_tmp = SFDP_array[16'h1000-i+CFILength];
            for(j=7;j>=0;j=j-1)
            begin
                CFI_array_tmp[8*i+j] = CFI_tmp[j];
            end
        end
    end

    always @(next_state or PoweredUp or falling_edge_RST or RST_out)
    begin: StateTransition1
        if (PoweredUp)
        begin
            if ((~reset_act || (RESETNeg_in && reset_act)) && RST_out &&
                  SWRST_out)
            begin
                current_state = next_state;
                reseted = 1;
            end
            else if (((~RESETNeg_in && reset_act) ||
                     (rising_edge_RESETNeg && reset_act)) &&
                       falling_edge_RST)
            begin
            // no state transition while RESET# low
                current_state = RESET_STATE;
                RST_in = 1'b1;
                #1 RST_in = 1'b0;
                reseted   = 1'b0;
            end
        end
    end

    always @(falling_edge_write)
    begin: StateTransition2
        if ((Instruct == RESET && CR3_V[0]) || (Instruct == RSTCMD && RESET_EN))
        begin
            // no state transition while RESET is in progress
            current_state = RESET_STATE;
            SWRST_in = 1'b1;
            #1 SWRST_in = 1'b0;
            reseted   = 1'b0;
            RESET_EN = 0;
        end
    end

    ////////////////////////////////////////////////////////////////////////////
    // Timing control for the Hardware Reset
    ////////////////////////////////////////////////////////////////////////////
    always @(posedge RST_in)
    begin:Threset
        RST_out = 1'b0;
        #(tdevice_RPH -200000) RST_out = 1'b1;
    end

    always @(RESETNeg)
        begin
        RST <= #199000 RESETNeg;
    end

    ////////////////////////////////////////////////////////////////////////////
    // Timing control for the Software Reset
    ////////////////////////////////////////////////////////////////////////////
    always @(posedge SWRST_in)
    begin:Tswreset
        SWRST_out = 1'b0;
        #tdevice_RPH SWRST_out = 1'b1;
    end

    always @(negedge CSNeg_ipd)
    begin:CheckCSOnPowerUP
        if (~PoweredUp)
            $display ("Device is selected during Power Up");
    end

    ///////////////////////////////////////////////////////////////////////////
    //// Internal Delays
    ///////////////////////////////////////////////////////////////////////////

    always @(posedge PRGSUSP_in)
    begin:PRGSuspend
        PRGSUSP_out = 1'b0;
        #tdevice_SUSP PRGSUSP_out = 1'b1;
    end

    always @(posedge ERSSUSP_in)
    begin:ERSSuspend
        ERSSUSP_out = 1'b0;
        #tdevice_SUSP ERSSUSP_out = 1'b1;
    end

    always @(posedge PPBERASE_in)
    begin:PPBErs
        PPBERASE_out = 1'b0;
        #tdevice_SE256 PPBERASE_out = 1'b1;
    end

    always @(posedge PASSULCK_in)
    begin:PASSULock
        PASSULCK_out = 1'b0;
        #tdevice_PP_256 PASSULCK_out = 1'b1;
    end

    always @(posedge PASSACC_in)
    begin:PASSAcc
        PASSACC_out = 1'b0;
        #tdevice_PASSACC PASSACC_out = 1'b1;
    end

///////////////////////////////////////////////////////////////////////////////
// write cycle decode
///////////////////////////////////////////////////////////////////////////////
    integer opcode_cnt = 0;
    integer addr_cnt   = 0;
    integer mode_cnt   = 0;
    integer dummy_cnt  = 0;
    integer data_cnt   = 0;
    integer bit_cnt    = 0;

    reg [4095:0] Data_in = {4096{1'b1}};
    reg    [7:0] opcode;
    reg    [7:0] opcode_in;
    reg    [7:0] opcode_tmp;
    reg   [31:0] addr_bytes;
    reg   [31:0] hiaddr_bytes;
    reg   [31:0] Address_in;
    reg    [7:0] mode_bytes;
    reg    [7:0] mode_in;
    integer Latency_code;
    integer quad_data_in [0:1023];
    reg [3:0] quad_nybble = 4'b0;
    reg [3:0] Quad_slv;
    reg [7:0] Byte_slv;

   always @(rising_edge_CSNeg_ipd or falling_edge_CSNeg_ipd or
            rising_edge_SCK_ipd or falling_edge_SCK_ipd)
   begin: Buscycle
        integer i;
        integer j;
        integer k;
        time CLK_PER;
        time LAST_CLK;

        if (falling_edge_CSNeg_ipd)
        begin
            if (bus_cycle_state==STAND_BY)
            begin
                Instruct = NONE;
                write = 1'b1;
                cfg_write  = 0;
                opcode_cnt = 0;
                addr_cnt   = 0;
                mode_cnt   = 0;
                dummy_cnt  = 0;
                data_cnt   = 0;

                Data_in = {4096{1'b1}};

                CLK_PER    = 1'b0;
                LAST_CLK   = 1'b0;

                ZERO_DETECTED = 1'b0;
                DOUBLE = 1'b0;

                bus_cycle_state = OPCODE_BYTE;

            end
        end

        if (rising_edge_SCK_ipd) // Instructions, addresses or data present at
        begin                    // input are latched on the rising edge of SCK

            CLK_PER = $time - LAST_CLK;
            LAST_CLK = $time;
            if (CHECK_FREQ)
            begin
                if ((Instruct == FAST_READ) || (Instruct == FAST_READ) ||
                    (Instruct == OTPR) || (Instruct == RDAR) ||
                   (((Instruct == ECCRD) || (Instruct == ECCRD4)) && ~QUAD_ALL))
                begin
                    if ((CLK_PER < 20000 && Latency_code == 0) || // <= 50MHz
                        (CLK_PER < 14920 && Latency_code == 1) || // <= 67MHz
                        (CLK_PER < 12500 && Latency_code == 2) || // <= 80MHz
                        (CLK_PER < 10870 && Latency_code == 3) || // <= 92MHz
                        (CLK_PER <  9600 && Latency_code == 4) || // <=104MHz
                        (CLK_PER <  8620 && Latency_code == 5) || // <=116MHz
                        (CLK_PER <  7750 && Latency_code == 6) || // <=129MHz
                        (CLK_PER <  7520 && Latency_code >= 7))   // <=133MHz
                    begin
                        $display ("More wait states are required for");
                        $display ("this clock frequency value");
                    end
                    CHECK_FREQ = 0;
                end

                if ((Instruct == DIOR) || (Instruct == DIOR4))
                begin
                    if ((CLK_PER < 12500 && Latency_code == 0) || // <= 80MHz
                        (CLK_PER < 10870 && Latency_code == 1) || // <= 92MHz
                        (CLK_PER <  9600 && Latency_code == 2) || // <=104MHz
                        (CLK_PER <  8620 && Latency_code == 3) || // <=116MHz
                        (CLK_PER <  7750 && Latency_code == 4) || // <=129MHz
                        (CLK_PER <  7520 && Latency_code >= 5))   // <=133MHz
                    begin
                        $display ("More wait states are required for");
                        $display ("this clock frequency value");
                    end
                    CHECK_FREQ = 0;
                end

                if ((Instruct == QIOR) || (Instruct == QIOR4))
                begin
                    if ((CLK_PER < 23225 && Latency_code == 0) || // <= 43MHz
                        (CLK_PER < 18181 && Latency_code == 1) || // <= 55MHz
                        (CLK_PER < 14920 && Latency_code == 2) || // <= 67MHz
                        (CLK_PER < 12500 && Latency_code == 3) || // <= 80MHz
                        (CLK_PER < 10870 && Latency_code == 4) || // <= 92MHz
                        (CLK_PER <  9600 && Latency_code == 5) || // <=104MHz
                        (CLK_PER <  8620 && Latency_code == 6) || // <=116MHz
                        (CLK_PER <  7750 && Latency_code == 7) || // <=129MHz
                        (CLK_PER <  7520 && Latency_code >= 8))  // <=133MHz
                    begin
                        $display ("More wait states are required for");
                        $display ("this clock frequency value");
                    end
                    CHECK_FREQ = 0;
                end

                if (((Instruct == ECCRD) || (Instruct == ECCRD4)) && QUAD_ALL)
                begin
                    if ((CLK_PER < 55555 && Latency_code == 0) || // <= 18MHz
                        (CLK_PER < 33333 && Latency_code == 1) || // <= 30MHz
                        (CLK_PER < 23225 && Latency_code == 2) || // <= 43MHz
                        (CLK_PER < 18181 && Latency_code == 3) || // <= 55MHz
                        (CLK_PER < 14920 && Latency_code == 4) || // <= 67MHz
                        (CLK_PER < 12500 && Latency_code == 5) || // <= 80MHz
                        (CLK_PER < 10870 && Latency_code == 6) || // <= 92MHz
                        (CLK_PER <  9600 && Latency_code == 7) || // <=104MHz
                        (CLK_PER <  8620 && Latency_code == 8) || // <=116MHz
                        (CLK_PER <  7750 && Latency_code == 9) || // <=129MHz
                        (CLK_PER <  7520 && Latency_code >= 10))  // <=133MHz
                    begin
                        $display ("More wait states are required for");
                        $display ("this clock frequency value");
                    end
                    CHECK_FREQ = 0;
                end

                if ((Instruct == DDRQIOR) || (Instruct == DDRQIOR4))
                begin
                    if ((CLK_PER < 33333 && Latency_code <= 1) || // <= 30MHz
                        (CLK_PER < 23225 && Latency_code == 2) || // <= 43MHz
                        (CLK_PER < 18181 && Latency_code == 3) || // <= 55MHz
                        (CLK_PER < 14920 && Latency_code == 4) || // <= 67MHz
                        (CLK_PER < 12500 && Latency_code >= 5))   // <= 80MHz
                    begin
                        $display ("More wait states are required for");
                        $display ("this clock frequency value");
                    end
                    CHECK_FREQ = 0;
                end
            end

            if (~CSNeg_ipd)
            begin
                case (bus_cycle_state)
                    OPCODE_BYTE:
                    begin
                        Latency_code = CR2_V[3:0];

                        //Wrap Length
                        if (CR4_V[1:0] == 1)
                        begin
                            WrapLength = 16;
                        end
                        else if (CR4_V[1:0] == 2)
                        begin
                            WrapLength = 32;
                        end
                        else if (CR4_V[1:0] == 3)
                        begin
                            WrapLength = 64;
                        end
                        else
                        begin
                            WrapLength = 8;
                        end

                        if (QUAD_ALL)
                        begin
                            opcode_in[4*opcode_cnt]   = RESETNeg_in;
                            opcode_in[4*opcode_cnt+1] = WPNeg_in;
                            opcode_in[4*opcode_cnt+2] = SO_in;
                            opcode_in[4*opcode_cnt+3] = SI_in;
                        end
                        else
                        begin
                            opcode_in[opcode_cnt] = SI_in;
                        end

                        opcode_cnt = opcode_cnt + 1;

                        if ((QUAD_ALL && (opcode_cnt == BYTE/4)) ||
                           (opcode_cnt == BYTE))
                        begin
                            for(i=7;i>=0;i=i-1)
                            begin
                                opcode[i] = opcode_in[7-i];
                            end
                            case (opcode)

                                8'b00000001 : // 01h
                                begin
                                    Instruct = WRR;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b00000010 : // 02h
                                begin
                                    Instruct = PP;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b00000011 : // 03h
                                begin
                                    Instruct = READ;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b00000100 : // 04h
                                begin
                                    Instruct = WRDI;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b00000101 : // 05h
                                begin
                                    Instruct = RDSR1;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b00000110 : // 06h
                                begin
                                    Instruct = WREN;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b00000111 : // 07h
                                begin
                                    Instruct = RDSR2;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b00010010 : // 12h
                                begin
                                    Instruct = PP4;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b00010011 : // 13h
                                begin
                                    Instruct = READ4;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b00011000 : // 18h
                                begin
                                    Instruct = ECCRD4;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b00011001 : // 19h
                                begin
                                    Instruct = ECCRD;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b00100000 : // 20h
                                begin
                                    Instruct = P4E;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b00100001 : // 21h
                                begin
                                    Instruct = P4E4;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b00110000 : // 30h
                                begin
                                    if (CR3_V[2])
                                        Instruct = EPR;
                                    else
                                        Instruct = CLSR;

                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b00110101 : // 35h
                                begin
                                    Instruct = RDCR;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b01000001 : // 41h
                                begin
                                    Instruct = DLPRD;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b01000010 : // 42h
                                begin
                                    Instruct = OTPP;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b01000011 : // 43h
                                begin
                                    Instruct = PNVDLR;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b01100000 : // 60h
                                begin
                                    Instruct = BE;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b01100101 : // 65h
                                begin
                                    Instruct = RDAR;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b01100110 : // 66h
                                begin
                                    Instruct = RSTEN;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b01110001 : // 71h
                                begin
                                    Instruct = WRAR;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b01110101 : // 75h
                                begin
                                    Instruct = EPS;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b10000010 : // 82h
                                begin
                                    Instruct = CLSR;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b10000101 : // 85h
                                begin
                                    Instruct = EPS;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b10011001 : // 99h
                                begin
                                    Instruct = RSTCMD;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b00001011 : // 0Bh
                                begin
                                    Instruct = FAST_READ;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                    begin
                                        bus_cycle_state = ADDRESS_BYTES;
                                        CHECK_FREQ = 1'b1;
                                    end
                                end

                                8'b00001100 : // 0Ch
                                begin
                                    Instruct = FAST_READ4;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                    begin
                                        bus_cycle_state = ADDRESS_BYTES;
                                        CHECK_FREQ = 1'b1;
                                    end
                                end

                                8'b00101011 : // 2Bh
                                begin
                                    Instruct = ASPRD;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b00101111 : // 2Fh
                                begin
                                    Instruct = ASPP;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b01001010 : // 4Ah
                                begin
                                    Instruct = WVDLR;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b01001011 : // 4Bh
                                begin
                                    Instruct = OTPR;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b01011010 : // 5Ah
                                begin
                                    Instruct = RSFDP;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b01111010 : // 7Ah
                                begin
                                    Instruct = EPR;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b10001010 : // 8Ah
                                begin
                                    Instruct = EPR;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b10011111 : // 9Fh
                                begin
                                    Instruct = RDID;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b10100110 : // A6h
                                begin
                                    Instruct = PLBWR;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b10100111 : // A7h
                                begin
                                    Instruct = PLBRD;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b10101111 : // AFh
                                begin
                                    Instruct = RDQID;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b10110000 : // B0h
                                begin
                                    Instruct = EPS;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b10110111 : // B7h
                                begin
                                    Instruct = BAM4;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b10111011 : // BBh
                                begin
                                    Instruct = DIOR;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                    begin
                                        bus_cycle_state = ADDRESS_BYTES;
                                        CHECK_FREQ = 1'b1;
                                    end
                                end

                                8'b10111100 : // BCh
                                begin
                                    Instruct = DIOR4;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                    begin
                                        bus_cycle_state = ADDRESS_BYTES;
                                        CHECK_FREQ = 1'b1;
                                    end
                                end

                                8'b11000000 : // C0h
                                begin
                                    Instruct = SBL;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b11000111 : // C7h
                                begin
                                    Instruct = BE;
                                    bus_cycle_state = DATA_BYTES;
                                end

                                8'b11010000 : // D0h
                                begin
                                    Instruct = EES;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11011000 : // D8h
                                begin
                                    Instruct = SE;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11011100 : // DCh
                                begin
                                    Instruct = SE4;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11100000 : // E0h
                                begin
                                    Instruct = DYBRD4;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11100001 : // E1h
                                begin
                                    Instruct = DYBWR4;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11100010 : // E2h
                                begin
                                    Instruct = PPBRD4;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11100011 : // E3h
                                begin
                                    Instruct = PPBP4;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11100100 : // E4h
                                begin
                                    Instruct = PPBE;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b11100111 : // E7h
                                begin
                                    Instruct = PASSRD;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b11101000 : // E8h
                                begin
                                    Instruct = PASSP;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b11101001 : // E9h
                                begin
                                    Instruct = PASSU;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b11101011 : // EBh
                                begin
                                    Instruct = QIOR;
                                    bus_cycle_state = ADDRESS_BYTES;
                                    CHECK_FREQ = 1'b1;
                                end

                                8'b11101100 : // ECh
                                begin
                                    Instruct = QIOR4;
                                    bus_cycle_state = ADDRESS_BYTES;
                                    CHECK_FREQ = 1'b1;
                                end

                                8'b11101101 : // EDh
                                begin
                                    Instruct = DDRQIOR;
                                    bus_cycle_state = ADDRESS_BYTES;
                                    CHECK_FREQ = 1'b1;
                                end

                                8'b11101110 : // EEh
                                begin
                                    Instruct = DDRQIOR4;
                                    bus_cycle_state = ADDRESS_BYTES;
                                    CHECK_FREQ = 1'b1;
                                end

                                8'b11110000 : // F0h
                                begin
                                    Instruct = RESET;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = DATA_BYTES;
                                end

                                8'b11111010 : // FAh
                                begin
                                    Instruct = DYBRD;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11111011 : // FBh
                                begin
                                    Instruct = DYBWR;
                                    bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11111100: // FCh
                                begin
                                    Instruct = PPBRD;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11111101 : // FDh
                                begin
                                    Instruct = PPBP;
                                    if (QUAD_ALL)
                                    begin
                                    //Command not supported in Quad All mode
                                        bus_cycle_state = STAND_BY;
                                    end
                                    else
                                        bus_cycle_state = ADDRESS_BYTES;
                                end

                                8'b11111111 : // FFh
                                begin
                                    Instruct = MBR;
                                    bus_cycle_state = DATA_BYTES;
                                end

                            endcase
                        end
                    end //end of OPCODE BYTE

                    ADDRESS_BYTES :
                    begin
                        if ((Instruct == DDRQIOR) || (Instruct == DDRQIOR4))
                            DOUBLE = 1'b1;
                        else
                            DOUBLE = 1'b0;

                        if ((((Instruct == FAST_READ) || (Instruct == OTPR) ||
                             (Instruct == RDAR) || (Instruct == ECCRD)) &&
                             (~CR2_V[7])) || (Instruct == RSFDP))
                        begin
                        //Instruction + 3 Bytes Address + Dummy Byte
                            if (QUAD_ALL)
                            begin
                                Address_in[4*addr_cnt]   = RESETNeg_in;
                                Address_in[4*addr_cnt+1] = WPNeg_in;
                                Address_in[4*addr_cnt+2] = SO_in;
                                Address_in[4*addr_cnt+3] = SI_in;
                                read_cnt = 0;
                                addr_cnt = addr_cnt + 1;
                                if (addr_cnt == 3*BYTE/4)
                                begin
                                    for(i=23;i>=0;i=i-1)
                                    begin
                                        addr_bytes[23-i] = Address_in[i];
                                    end
                                    addr_bytes[31:24] = 8'b00000000;
                                    Address = addr_bytes;
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;

                                    if (Latency_code == 0)
                                        bus_cycle_state = DATA_BYTES;
                                    else
                                        bus_cycle_state = DUMMY_BYTES;
                                end
                            end
                            else
                            begin
                                Address_in[addr_cnt] = SI_in;
                                addr_cnt = addr_cnt + 1;
                                if (addr_cnt == 3*BYTE)
                                begin
                                    for(i=23;i>=0;i=i-1)
                                    begin
                                        addr_bytes[23-i] = Address_in[i];
                                    end
                                    addr_bytes[31:24] = 8'b00000000;
                                    Address = addr_bytes ;
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;

                                    if (Latency_code == 0)
                                        bus_cycle_state = DATA_BYTES;
                                    else
                                        bus_cycle_state = DUMMY_BYTES;
                                end
                            end
                        end
                        else if ((Instruct==FAST_READ4) || (Instruct==ECCRD4) ||
                            (((Instruct == FAST_READ) || (Instruct == OTPR) ||
                            (Instruct==RDAR) || (Instruct==ECCRD)) && CR2_V[7]))
                        begin
                        //Instruction + 4 Bytes Address + Dummy Byte
                            if (QUAD_ALL)
                            begin
                                Address_in[4*addr_cnt]   = RESETNeg_in;
                                Address_in[4*addr_cnt+1] = WPNeg_in;
                                Address_in[4*addr_cnt+2] = SO_in;
                                Address_in[4*addr_cnt+3] = SI_in;
                                read_cnt = 0;
                                addr_cnt = addr_cnt + 1;
                                if (addr_cnt == 4*BYTE/4)
                                begin
                                    for(i=31;i>=0;i=i-1)
                                    begin
                                        hiaddr_bytes[31-i] = Address_in[i];
                                    end
                                    Address = hiaddr_bytes[31:0];
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;

                                    if (Latency_code == 0)
                                        bus_cycle_state = DATA_BYTES;
                                    else
                                        bus_cycle_state = DUMMY_BYTES;
                                end
                            end
                            else
                            begin
                                Address_in[addr_cnt] = SI_in;
                                addr_cnt = addr_cnt + 1;
                                if (addr_cnt == 4*BYTE)
                                begin
                                    for(i=31;i>=0;i=i-1)
                                    begin
                                        hiaddr_bytes[31-i] = Address_in[i];
                                    end
                                    Address = hiaddr_bytes[31:0];
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;

                                    if (Latency_code == 0)
                                        bus_cycle_state = DATA_BYTES;
                                    else
                                        bus_cycle_state = DUMMY_BYTES;
                                end
                            end
                        end
                        else if ((Instruct == DIOR) && (~CR2_V[7]))
                        begin
                        //DUAL I/O High Performance Read(3 Bytes Addr)
                            Address_in[2*addr_cnt]     = SO_in;
                            Address_in[2*addr_cnt + 1] = SI_in;
                            read_cnt = 0;
                            addr_cnt = addr_cnt + 1;
                            if (addr_cnt == 3*BYTE/2)
                            begin
                                addr_cnt   = 0;
                                for(i=23;i>=0;i=i-1)
                                begin
                                    addr_bytes[23-i]=Address_in[i];
                                end
                                addr_bytes[31:24] = 8'b00000000;
                                Address = addr_bytes;
                                change_addr = 1'b1;
                                #1 change_addr = 1'b0;

                                bus_cycle_state = MODE_BYTE;
                            end
                        end
                        else if ((Instruct == DIOR4) ||
                                ((Instruct == DIOR) && CR2_V[7]))
                        begin //DUAL I/O High Performance Read(4 Bytes Addr)
                            Address_in[2*addr_cnt]     = SO_in;
                            Address_in[2*addr_cnt + 1] = SI_in;
                            read_cnt = 0;
                            addr_cnt = addr_cnt + 1;
                            if (addr_cnt == 4*BYTE/2)
                            begin
                                addr_cnt   = 0;
                                for(i=31;i>=0;i=i-1)
                                begin
                                    addr_bytes[31-i] = Address_in[i];
                                end
                                Address = addr_bytes[31:0];
                                change_addr = 1'b1;
                                #1 change_addr = 1'b0;

                                bus_cycle_state = MODE_BYTE;
                            end
                        end

                        else if ((Instruct == QIOR) && (~CR2_V[7]))
                        begin
                        //QUAD I/O High Performance Read (3Bytes Address)
                            if (QUAD)
                            begin
                                Address_in[4*addr_cnt]   = RESETNeg_in;
                                Address_in[4*addr_cnt+1] = WPNeg_in;
                                Address_in[4*addr_cnt+2] = SO_in;
                                Address_in[4*addr_cnt+3] = SI_in;
                                read_cnt = 0;
                                addr_cnt = addr_cnt + 1;
                                if (addr_cnt == 3*BYTE/4)
                                begin
                                    addr_cnt   = 0;
                                    for(i=23;i>=0;i=i-1)
                                    begin
                                        addr_bytes[23-i] = Address_in[i];
                                    end
                                    addr_bytes[31:24] = 8'b00000000;

                                    Address = addr_bytes;
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;
                                    bus_cycle_state = MODE_BYTE;
                                end
                            end
                            else
                                bus_cycle_state = STAND_BY;
                        end
                        else if ((Instruct==QIOR4) || ((Instruct==QIOR)
                                && CR2_V[7]))
                        begin
                            //QUAD I/O High Performance Read (4Bytes Addr)
                            if (QUAD)
                            begin
                                Address_in[4*addr_cnt]   = RESETNeg_in;
                                Address_in[4*addr_cnt+1] = WPNeg_in;
                                Address_in[4*addr_cnt+2] = SO_in;
                                Address_in[4*addr_cnt+3] = SI_in;
                                read_cnt = 0;
                                addr_cnt = addr_cnt +1;
                                if (addr_cnt == 4*BYTE/4)
                                begin
                                    addr_cnt   = 0;
                                    for(i=31;i>=0;i=i-1)
                                    begin
                                        hiaddr_bytes[31-i] = Address_in[i];
                                    end
                                    Address = hiaddr_bytes[31:0];
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;

                                    bus_cycle_state = MODE_BYTE;
                                end
                            end
                            else
                                bus_cycle_state = STAND_BY;
                        end
                        else if ((Instruct == READ4)  || (Instruct == PP4) ||
                                 (Instruct == SE4)    || (Instruct == PPBRD4) ||
                                 (Instruct == DYBRD4) || (Instruct == DYBWR4) ||
                                 (Instruct == PPBP4)  || (Instruct == P4E4) ||
                                 ((Instruct == READ)  && CR2_V[7]) ||
                                 ((Instruct == RDAR)  && CR2_V[7]) ||
                                 ((Instruct == WRAR)  && CR2_V[7]) ||
                                 ((Instruct == EES)   && CR2_V[7]) ||
                                 ((Instruct == PP)    && CR2_V[7]) ||
                                 ((Instruct == P4E)   && CR2_V[7]) ||
                                 ((Instruct == SE)    && CR2_V[7]) ||
                                 ((Instruct == OTPP)  && CR2_V[7]) ||
                                 ((Instruct == OTPR)  && CR2_V[7]) ||
                                 ((Instruct == DYBRD) && CR2_V[7]) ||
                                 ((Instruct == DYBWR) && CR2_V[7]) ||
                                 ((Instruct == PPBRD) && CR2_V[7]) ||
                                 ((Instruct == PPBP)  && CR2_V[7]))
                        begin
                        //Instruction + 4 Bytes Address
                            if (QUAD_ALL)
                            begin
                                Address_in[4*addr_cnt]   = RESETNeg_in;
                                Address_in[4*addr_cnt+1] = WPNeg_in;
                                Address_in[4*addr_cnt+2] = SO_in;
                                Address_in[4*addr_cnt+3] = SI_in;
                                read_cnt = 0;
                                addr_cnt = addr_cnt +1;
                                if (addr_cnt == 4*BYTE/4)
                                begin
                                    for(i=31;i>=0;i=i-1)
                                    begin
                                        hiaddr_bytes[31-i] = Address_in[i];
                                    end
                                    Address = hiaddr_bytes[31:0];
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;

                                    bus_cycle_state = DATA_BYTES;
                                end
                            end
                            else
                            begin
                                Address_in[addr_cnt] = SI_in;
                                addr_cnt = addr_cnt + 1;
                                if (addr_cnt == 4*BYTE)
                                begin
                                    for(i=31;i>=0;i=i-1)
                                    begin
                                        hiaddr_bytes[31-i] = Address_in[i];
                                    end
                                    Address = hiaddr_bytes[31:0];
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;

                                    bus_cycle_state = DATA_BYTES;
                                end
                            end
                        end

                        else if ((Instruct==DDRQIOR) && (~CR2_V[7]) && QUAD)
                        begin
                       //Quad I/O DDR Read Mode (3 Bytes Address)
                            Address_in[4*addr_cnt]   = RESETNeg_in;
                            Address_in[4*addr_cnt+1] = WPNeg_in;
                            Address_in[4*addr_cnt+2] = SO_in;
                            Address_in[4*addr_cnt+3] = SI_in;
                            opcode_tmp[addr_cnt/2]   = SI_in;
                            addr_cnt = addr_cnt +1;
                            read_cnt = 0;
                        end
                        else if (QUAD && ((Instruct==DDRQIOR4) ||
                                ((Instruct==DDRQIOR) && CR2_V[7])))
                        begin
                       //Quad I/O DDR Read Mode (4 Bytes Address)
                            Address_in[4*addr_cnt]   = RESETNeg_in;
                            Address_in[4*addr_cnt+1] = WPNeg_in;
                            Address_in[4*addr_cnt+2] = SO_in;
                            Address_in[4*addr_cnt+3] = SI_in;
                            opcode_tmp[addr_cnt/2]   = SI_in;
                            addr_cnt = addr_cnt +1;
                            read_cnt = 0;
                        end
                        else if (~CR2_V[7])
                        begin
                        //Instruction + 3 Bytes Address
                            if (QUAD_ALL)
                            begin
                                Address_in[4*addr_cnt]   = RESETNeg_in;
                                Address_in[4*addr_cnt+1] = WPNeg_in;
                                Address_in[4*addr_cnt+2] = SO_in;
                                Address_in[4*addr_cnt+3] = SI_in;
                                read_cnt = 0;
                                addr_cnt = addr_cnt +1;
                                if (addr_cnt == 3*BYTE/4)
                                begin
                                    for(i=23;i>=0;i=i-1)
                                    begin
                                        addr_bytes[23-i] = Address_in[i];
                                    end
                                    addr_bytes[31:24] = 8'b00000000;
                                    Address = addr_bytes;
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;

                                    bus_cycle_state = DATA_BYTES;
                                end
                            end
                            else
                            begin
                                Address_in[addr_cnt] = SI_in;
                                addr_cnt = addr_cnt + 1;
                                if (addr_cnt == 3*BYTE)
                                begin
                                    for(i=23;i>=0;i=i-1)
                                    begin
                                        addr_bytes[23-i] = Address_in[i];
                                    end
                                    addr_bytes[31:24] = 8'b00000000;
                                    Address = addr_bytes;
                                    change_addr = 1'b1;
                                    #1 change_addr = 1'b0;

                                    bus_cycle_state = DATA_BYTES;
                                end
                            end
                        end
                    end //end of ADDRESS_BYTES

                    MODE_BYTE :
                    begin
                        if ((Instruct==DIOR) || (Instruct == DIOR4))
                        begin
                            mode_in[2*mode_cnt]   = SO_in;
                            mode_in[2*mode_cnt+1] = SI_in;
                            mode_cnt = mode_cnt + 1;
                            if (mode_cnt == BYTE/2)
                            begin
                                mode_cnt = 0;
                                for(i=7;i>=0;i=i-1)
                                begin
                                    mode_bytes[i] = mode_in[7-i];
                                end
                                if (Latency_code == 0)
                                    bus_cycle_state = DATA_BYTES;
                                else
                                    bus_cycle_state = DUMMY_BYTES;
                            end
                        end
                        else if (((Instruct==QIOR) || (Instruct == QIOR4))
                                && QUAD)
                        begin
                            mode_in[4*mode_cnt]   = RESETNeg_in;
                            mode_in[4*mode_cnt+1] = WPNeg_in;
                            mode_in[4*mode_cnt+2] = SO_in;
                            mode_in[4*mode_cnt+3] = SI_in;
                            mode_cnt = mode_cnt + 1;
                            if (mode_cnt == BYTE/4)
                            begin
                                mode_cnt = 0;
                                for(i=7;i>=0;i=i-1)
                                begin
                                    mode_bytes[i] = mode_in[7-i];
                                end
                                if (Latency_code == 0)
                                    bus_cycle_state = DATA_BYTES;
                                else
                                    bus_cycle_state = DUMMY_BYTES;
                            end
                        end
                        else if (((Instruct==DDRQIOR) || (Instruct == DDRQIOR4))
                                 && QUAD)
                        begin
                            mode_in[0] = RESETNeg_in;
                            mode_in[1] = WPNeg_in;
                            mode_in[2] = SO_in;
                            mode_in[3] = SI_in;
                        end
                        dummy_cnt = 0;
                    end //end of MODE_BYTE

                    DUMMY_BYTES :
                    begin
                        dummy_cnt = dummy_cnt + 1;
                        if (((Instruct==DDRQIOR) || (Instruct == DDRQIOR4)) &&
                              VDLR_reg != 8'b00000000)
                        begin
                            read_out = 1'b1;
                            read_out <= #1 1'b0;
                        end
                    end //end of DUMMY_BYTES

                    DATA_BYTES :
                    begin
                        if ((Instruct == DDRQIOR) || (Instruct == DDRQIOR4))
                        begin
                            read_out = 1'b1;
                            read_out <= #1 1'b0;
                        end

                        if (QUAD_ALL)
                        begin
                            quad_nybble = {RESETNeg_in, WPNeg_in, SO_in, SI_in};
                            if (data_cnt > ((PageSize+1)*2-1))
                            begin
                            //In case of quad mode,if more than PageSize+1 bytes
                            //are sent to the device previously latched data
                            //are discarded and last 256/512 data bytes are
                            //guaranteed to be programmed correctly within
                            //the same page.
                                for(i=0;i<=(PageSize*2-1);i=i+1)
                                begin
                                    quad_data_in[i] = quad_data_in[i+1];
                                end
                                quad_data_in[(PageSize+1)*2-1] = quad_nybble;
                                data_cnt = data_cnt +1;
                            end
                            else
                            begin
                                if (quad_nybble !== 4'bZZZZ)
                                begin
                                    quad_data_in[data_cnt] = quad_nybble;
                                end
                                data_cnt = data_cnt +1;
                            end
                        end
                        else
                        begin
                            if (data_cnt > ((PageSize+1)*8-1))
                            begin
                            //In case of serial mode and PP,
                            //if more than PageSize are sent to the device
                            //previously latched data are discarded and last
                            //256/512 data bytes are guaranteed to be programmed
                            //correctly within the same page.
                                if (bit_cnt == 0)
                                begin
                                    for(i=0;i<=(PageSize*BYTE-1);i=i+1)
                                    begin
                                        Data_in[i] = Data_in[i+8];
                                    end
                                end
                                Data_in[PageSize*BYTE + bit_cnt] = SI_in;
                                bit_cnt = bit_cnt + 1;
                                if (bit_cnt == 8)
                                begin
                                    bit_cnt = 0;
                                end
                                data_cnt = data_cnt + 1;
                            end
                            else
                            begin
                                Data_in[data_cnt] = SI_in;
                                data_cnt = data_cnt + 1;
                                bit_cnt = 0;
                            end
                        end
                    end //end of DATA_BYTES

                endcase
            end
        end

        if (falling_edge_SCK_ipd)
        begin

            if (~CSNeg_ipd)
            begin
                case (bus_cycle_state)
                    ADDRESS_BYTES :
                    begin
                        if ((Instruct==DDRQIOR) && (~CR2_V[7]) && QUAD)
                        begin
                       //Quad I/O DDR Read Mode (3 Bytes Address)
                            Address_in[4*addr_cnt]   = RESETNeg_in;
                            Address_in[4*addr_cnt+1] = WPNeg_in;
                            Address_in[4*addr_cnt+2] = SO_in;
                            Address_in[4*addr_cnt+3] = SI_in;
                            if (addr_cnt != 0)
                            begin
                                addr_cnt = addr_cnt + 1;
                            end
                            read_cnt = 0;
                            if (addr_cnt == 3*BYTE/4)
                            begin
                                addr_cnt   = 0;
                                for(i=23;i>=0;i=i-1)
                                begin
                                    addr_bytes[23-i] = Address_in[i];
                                end
                                addr_bytes[31:24] = 8'b00000000;
                                Address = addr_bytes;
                                change_addr = 1'b1;
                               #1 change_addr = 1'b0;

                                bus_cycle_state = MODE_BYTE;
                            end
                        end
                        else if (QUAD && ((Instruct==DDRQIOR4) ||
                                ((Instruct==DDRQIOR) && CR2_V[7])))
                        begin
                            Address_in[4*addr_cnt]   = RESETNeg_in;
                            Address_in[4*addr_cnt+1] = WPNeg_in;
                            Address_in[4*addr_cnt+2] = SO_in;
                            Address_in[4*addr_cnt+3] = SI_in;
                            if (addr_cnt != 0)
                            begin
                                addr_cnt = addr_cnt + 1;
                            end
                            read_cnt = 0;
                            if (addr_cnt == 4*BYTE/4)
                            begin
                                addr_cnt   = 0;
                                for(i=31;i>=0;i=i-1)
                                begin
                                    addr_bytes[31-i] = Address_in[i];
                                end
                                Address = addr_bytes[31:0];
                                change_addr = 1'b1;
                                #1 change_addr = 1'b0;

                                bus_cycle_state = MODE_BYTE;
                            end
                        end
                    end //end of ADDRESS_BYTES

                    MODE_BYTE :
                    begin
                        if ((Instruct==DDRQIOR) || (Instruct==DDRQIOR4))
                        begin
                            mode_in[4] = RESETNeg_in;
                            mode_in[5] = WPNeg_in;
                            mode_in[6] = SO_in;
                            mode_in[7] = SI_in;
                            for(i=7;i>=0;i=i-1)
                            begin
                                mode_bytes[i] = mode_in[7-i];
                            end

                            if (VDLR_reg != 8'b00000000)
                            begin
                                read_out = 1'b1;
                                read_out <= #1 1'b0;
                            end

                            if (Latency_code == 0)
                                bus_cycle_state = DATA_BYTES;
                            else
                                bus_cycle_state = DUMMY_BYTES;
                        end
                    end //end of MODE_BYTE

                    DUMMY_BYTES :
                    begin
                        dummy_cnt = dummy_cnt + 1;
                        if (((Instruct==DDRQIOR) || (Instruct==DDRQIOR4)) &&
                             VDLR_reg != 8'b00000000)
                        begin
                            read_out = 1'b1;
                            read_out <= #1 1'b0;
                        end
                        if (Instruct == RSFDP)
                        begin
                            if (dummy_cnt == 15)
                            begin
                                bus_cycle_state = DATA_BYTES;
                            end
                        end
                        else
                        begin
                            if (Latency_code == dummy_cnt/2)
                            begin
                                bus_cycle_state = DATA_BYTES;
                                read_out = 1'b1;
                                read_out <= #1 1'b0;
                            end
                        end
                    end //end of DUMMY_BYTES

                    DATA_BYTES :
                    begin
                        if ((((Instruct == DDRQIOR) || (Instruct == DDRQIOR4) ||
                            (Instruct==QIOR) || (Instruct==QIOR4)) && QUAD) ||
                            (Instruct == READ)     || (Instruct == READ4) ||
                            (Instruct == FAST_READ)|| (Instruct == FAST_READ4)||
                            (Instruct == RDSR1)    || (Instruct == RDSR2) ||
                            (Instruct == RDCR)     || (Instruct == OTPR)  ||
                            (Instruct == DIOR)     || (Instruct == DIOR4) ||
                            (Instruct == RDID)     || (Instruct == RDQID) ||
                            (Instruct == PPBRD)    || (Instruct == PPBRD4) ||
                            (Instruct == DYBRD)    || (Instruct == DYBRD4) ||
                            (Instruct == ECCRD)    || (Instruct == ECCRD4) ||
                            (Instruct == ASPRD)    || (Instruct == DLPRD) ||
                            (Instruct == PASSRD)   || (Instruct == PLBRD) ||
                            (Instruct == RSFDP) || (Instruct == RDAR))
                        begin
                            read_out = 1'b1;
                            read_out <= #1 1'b0;
                        end
                    end //end of DATA_BYTES

                endcase
            end
        end

        if (rising_edge_CSNeg_ipd)
        begin
            if (bus_cycle_state != DATA_BYTES)
            begin
                if (opcode_tmp == 8'hFF)
                begin
                    Instruct = MBR;
                end
                bus_cycle_state = STAND_BY;
            end
            else
            begin
                if (((mode_bytes[7:4] == 4'b1010) &&
                     (Instruct==DIOR || Instruct==DIOR4 ||
                      Instruct==QIOR || Instruct==QIOR4)) ||
                    ((mode_bytes[7:4] == ~mode_bytes[3:0]) &&
                     (Instruct == DDRQIOR || Instruct == DDRQIOR4)))
                    bus_cycle_state = ADDRESS_BYTES;
                else
                    bus_cycle_state = STAND_BY;

                case (Instruct)
                    WREN,
                    WRDI,
                    BE,
                    SE,
                    SE4,
                    P4E,
                    P4E4,
                    CLSR,
                    RSTEN,
                    RSTCMD,
                    RESET,
                    BAM4,
                    MBR,
                    PPBE,
                    PPBP,
                    PPBP4,
                    PLBWR,
                    EES,
                    EPS,
                    EPR:
                    begin
                        if (data_cnt == 0)
                            write = 1'b0;
                    end

                    WRR:
                    begin
                        if (~QUAD_ALL)
                        begin
                            if (data_cnt == 8)
                            //If CS# is driven high after eight
                            //cycle,only the Status Register is
                            //written.
                            begin
                                write = 1'b0;
                                for(i=0;i<=7;i=i+1)
                                begin
                                    SR1_in[i] = Data_in[7-i];
                                end
                            end
                            else if (data_cnt == 16)
                            //After the 16th cycle both the
                            //Status and Configuration Registers
                            //are written to.
                            begin
                                write = 1'b0;
                                cfg_write = 1'b1;

                                for(i=0;i<=7;i=i+1)
                                begin
                                    SR1_in[i] = Data_in[7-i];
                                    CR1_in[i] = Data_in[15-i];
                                end
                            end
                        end
                        else
                        begin

                        end
                    end

                    WRAR:
                    begin
                        if (~QUAD_ALL)
                        begin
                            if (data_cnt == 8)
                            begin
                                write = 1'b0;
                                for(i=0;i<=7;i=i+1)
                                begin
                                    WRAR_reg_in[i] = Data_in[7-i];
                                end
                            end
                        end
                        else
                        begin
                            if (data_cnt == 2)
                            begin
                                write = 1'b0;
                                for(i=1;i>=0;i=i-1)
                                begin
                                   Quad_slv = quad_data_in[1-i];
                                   if (i==1)
                                        WRAR_reg_in[7:4] = Quad_slv;
                                    else if (i==0)
                                        WRAR_reg_in[3:0] = Quad_slv;
                                end
                            end
                        end
                    end

                    PP,
                    PP4,
                    OTPP:
                    begin
                        if (~QUAD_ALL)
                        begin
                            if (data_cnt > 0)
                            begin
                                if ((data_cnt % 8) == 0)
                                begin
                                    write = 1'b0;
                                    for(i=0;i<=PageSize;i=i+1)
                                    begin
                                        for(j=7;j>=0;j=j-1)
                                        begin
                                            if ((Data_in[(i*8)+(7-j)]) !== 1'bX)
                                            begin
                                                Byte_slv[j] =
                                                           Data_in[(i*8)+(7-j)];
                                                if (Data_in[(i*8)+(7-j)]==1'b0)
                                                begin
                                                    ZERO_DETECTED = 1'b1;
                                                end
                                            end
                                        end
                                        WByte[i] = Byte_slv;
                                    end

                                    if (data_cnt > (PageSize+1)*BYTE)
                                        Byte_number = PageSize;
                                    else
                                        Byte_number = ((data_cnt/8) - 1);
                                end
                            end
                        end
                        else
                        begin
                            if (data_cnt >0)
                            begin
                                if ((data_cnt % 2) == 0)
                                begin
                                    write = 1'b0;
                                    for(i=0;i<=PageSize;i=i+1)
                                    begin
                                        for(j=1;j>=0;j=j-1)
                                        begin
                                            Quad_slv =
                                            quad_data_in[(i*2)+(1-j)];
                                            if (j==1)
                                                Byte_slv[7:4] = Quad_slv;
                                            else if (j==0)
                                                Byte_slv[3:0] = Quad_slv;
                                        end
                                        WByte[i] = Byte_slv;
                                    end
                                    if (data_cnt > (PageSize+1)*2)
                                        Byte_number = PageSize;
                                    else
                                        Byte_number = ((data_cnt/2)-1);
                                end
                            end
                        end
                    end

                    ASPP:
                    begin
                        if (data_cnt == 16)
                        begin
                            write = 1'b0;
                            for(j=0;j<=15;j=j+1)
                            begin
                                ASP_reg_in[j] = Data_in[15-j];
                            end
                        end
                    end

                    PNVDLR:
                    begin
                        if (data_cnt == 8)
                        begin
                            write = 1'b0;
                            for(j=0;j<=7;j=j+1)
                            begin
                                NVDLR_reg_in[j] = Data_in[7-j];
                            end
                        end
                    end

                    WVDLR:
                    begin
                        if (data_cnt == 8)
                        begin
                            write = 1'b0;
                            for(j=0;j<=7;j=j+1)
                            begin
                                VDLR_reg_in[j] = Data_in[7-j];
                            end
                        end
                    end

                    DYBWR,
                    DYBWR4:
                    begin
                        if (~QUAD_ALL)
                        begin
                            if (data_cnt == 8)
                            begin
                                write = 1'b0;
                                for(j=0;j<=7;j=j+1)
                                begin
                                    DYBAR_in[j] = Data_in[7-j];
                                end
                            end
                        end
                        else
                        begin
                            if (data_cnt == 2)
                            begin
                                write = 1'b0;
                                for(i=1;i>=0;i=i-1)
                                begin
                                   Quad_slv = quad_data_in[1-i];
                                   if (i==1)
                                        DYBAR_in[7:4] = Quad_slv;
                                    else if (i==0)
                                        DYBAR_in[3:0] = Quad_slv;
                                end
                            end
                        end
                    end

                    PASSP:
                    begin
                        if (data_cnt == 64)
                        begin
                            write = 1'b0;
                            for(j=1;j<=8;j=j+1)
                            begin
                                for(k=1;k<=8;k=k+1)
                                begin
                                    Password_reg_in[j*8-k] =
                                                           Data_in[8*(j-1)+k-1];
                                end
                            end
                        end
                    end

                    PASSU:
                    begin
                        if (data_cnt == 64)
                        begin
                            write = 1'b0;
                            for(j=1;j<=8;j=j+1)
                            begin
                                for(k=1;k<=8;k=k+1)
                                begin
                                    PASS_TEMP[j*8-k] = Data_in[8*(j-1)+k-1];
                                end
                            end
                        end
                    end

                    SBL:
                    begin
                        if (data_cnt == 8)
                        begin
                            write = 1'b0;
                            for(i=0;i<=7;i=i+1)
                            begin
                                SBL_data_in[i] = Data_in[7-i];
                            end
                        end
                    end

                endcase
            end
        end
    end

///////////////////////////////////////////////////////////////////////////////
// Timing control for the Page Program
///////////////////////////////////////////////////////////////////////////////
    time  pob;
    time  elapsed_pgm;
    time  start_pgm;
    time  duration_pgm;
    event pdone_event;

    always @(rising_edge_PSTART or rising_edge_reseted)
    begin : ProgTime

        if (CR3_V[4] == 1'b0)
        begin
            pob = tdevice_PP_256;
        end
        else
        begin
            pob = tdevice_PP_512;
        end

        if (rising_edge_reseted)
        begin
            PDONE = 1; // reset done, programing terminated
            disable pdone_process;
        end
        else if (reseted)
        begin
            if (rising_edge_PSTART && PDONE)
            begin
                elapsed_pgm = 0;
                duration_pgm = pob;
                PDONE = 1'b0;
                start_pgm = $time;
                ->pdone_event;
            end
        end
    end

    always @(posedge PGSUSP)
    begin
        if (PGSUSP && (~PDONE))
        begin
            disable pdone_process;
            elapsed_pgm = $time - start_pgm;
            duration_pgm = pob - elapsed_pgm;
            PDONE = 1'b0;
        end
    end

    always @(posedge PGRES)
    begin
        start_pgm = $time;
        ->pdone_event;
    end

    always @(pdone_event)
    begin : pdone_process
        #(duration_pgm) PDONE = 1;
    end

///////////////////////////////////////////////////////////////////////////////
// Timing control for the Write Status Register
///////////////////////////////////////////////////////////////////////////////
    time  wob;
    event wdone_event;
    event csdone_event;

    always @(rising_edge_WSTART or rising_edge_reseted)
    begin:WriteTime

        wob = tdevice_WRR;

        if (rising_edge_reseted)
        begin
            WDONE = 1; // reset done, Write terminated
            disable wdone_process;
        end
        else if (reseted)
        begin
            if (rising_edge_WSTART && WDONE)
            begin
                WDONE = 1'b0;
                -> wdone_event;
            end
        end
    end

    always @(wdone_event)
    begin : wdone_process
        #wob WDONE = 1;
    end

   always @(posedge CSSTART or rising_edge_reseted)
   begin:WriteVolatileBitsTime

        if (rising_edge_reseted)
        begin
            CSDONE = 1; // reset done, Write terminated
            disable csdone_process;
        end
        else if (reseted)
        begin
            if (CSSTART && CSDONE)
            begin
                CSDONE = 1'b0;
                -> csdone_event;
            end
        end
    end

    always @(csdone_event)
    begin : csdone_process
        #50000 CSDONE = 1;
    end

///////////////////////////////////////////////////////////////////////////////
// Timing control for Evaluate Erase Status
///////////////////////////////////////////////////////////////////////////////
    event eesdone_event;

    always @(rising_edge_EESSTART or rising_edge_reseted)
    begin:EESTime

        if (rising_edge_reseted)
        begin
            EESDONE = 1; // reset done, Write terminated
            disable eesdone_process;
        end
        else if (reseted)
        begin
            if (rising_edge_EESSTART && EESDONE)
            begin
                EESDONE = 1'b0;
                -> eesdone_event;
            end
        end
    end

    always @(eesdone_event)
    begin : eesdone_process
		if (!CR3_V[1])
        	#(tdevice_EES/4) EESDONE = 1;
		else
        	#tdevice_EES EESDONE = 1;
    end

///////////////////////////////////////////////////////////////////////////////
// Timing control for Erase
///////////////////////////////////////////////////////////////////////////////
    event edone_event;
    time elapsed_ers;
    time start_ers;
    time duration_ers;

    always @(rising_edge_ESTART or rising_edge_reseted)
    begin : ErsTime

        if (Instruct == BE)
        begin
            duration_ers = tdevice_BE;
        end
        else if ((Instruct == P4E) || (Instruct == P4E4)
			|| (((Instruct == SE) || (Instruct == SE4)) && !CR3_V[1]))
        begin
            duration_ers = tdevice_SE4;
        end
        else
        begin
            duration_ers = tdevice_SE256;
        end

        if (rising_edge_reseted && !EDONE)
        begin
            EDONE = 1; // reset done, ERASE terminated
            ERS_nosucc[SectorErased] = 1'b1;
            ERS_nosucc_b[BlockErased] = 1'b1;
            disable edone_process;
        end
        else if (reseted)
        begin
            elapsed_ers = 0;
            EDONE = 1'b0;
            start_ers = $time;
            ->edone_event;
        end
    end

    always @(posedge ESUSP)
    begin
        if (ESUSP && (~EDONE))
        begin
            disable edone_process;
            elapsed_ers = $time - start_ers;
			if (duration_ers == tdevice_SE4)
            	duration_ers = tdevice_SE4 - elapsed_ers;
			else if (duration_ers == tdevice_SE256)
            	duration_ers = tdevice_SE256 - elapsed_ers;
            EDONE = 1'b0;
        end
    end

    always @(posedge ERES)
    begin
        if  (ERES && (~EDONE))
        begin
            start_ers = $time;
            ->edone_event;
        end
    end

    always @(edone_event)
    begin : edone_process
        EDONE = 1'b0;
        #duration_ers EDONE = 1'b1;
    end

    ///////////////////////////////////////////////////////////////////
    // Process for clock frequency determination
    ///////////////////////////////////////////////////////////////////
    always @(posedge SCK_ipd)
    begin : clock_period
        if (SCK_ipd)
        begin
            SCK_cycle = $time - prev_SCK;
            prev_SCK = $time;
        end
    end

//    /////////////////////////////////////////////////////////////////////////
//    // Main Behavior Process
//    // combinational process for next state generation
//    /////////////////////////////////////////////////////////////////////////

    integer i;
    integer j;

    always @(rising_edge_PoweredUp or falling_edge_write or rising_edge_WDONE or
           rising_edge_PDONE or rising_edge_EDONE or rising_edge_RST_out or
           rising_edge_SWRST_out or rising_edge_CSDONE or rising_edge_BCDONE or
           PRGSUSP_out_event or ERSSUSP_out_event or falling_edge_PASSULCK_in or
           rising_edge_EESDONE or falling_edge_PPBERASE_in or
           rising_edge_RESETNeg)
    begin: StateGen1

        integer sect;
        integer block_e;
		reg sect8_no_prot;
		reg sect511_no_prot;
		reg sect_no_prot;
		reg block8_no_prot;
		reg block127_no_prot;
		reg block_no_prot;

        if (RST_out == 1'b0 || SWRST_out == 1'b0)
            next_state = current_state;
        else
        begin
            case (current_state)
                RESET_STATE :
                begin
                    if (rising_edge_RST_out || rising_edge_SWRST_out)
                    begin
                        next_state = IDLE;
                    end
                end

                IDLE :
                begin
                    if (falling_edge_write)
                    begin
                        if (Instruct == WRR && WEL == 1 &&
                           ~(SRWD && ~WPNeg_in && ~QUAD))
                        begin
                        // can not execute if HPM is entered or
                        // if WEL bit is zero
                            if (((TBPROT_O == 1 && CR1_in[5] == 1'b0) ||
                                 (TBPARM_O == 1 && CR1_in[2] == 1'b0 &&
                                  CR3_V[3] == 1'b0) ||
                                 (BPNV_O   == 1 && CR1_in[3] == 1'b0)) &&
                                 cfg_write)
                            begin
                                $display ("WARNING: Writing of OTP bits back ");
                                $display ("to their default state is ignored ");
                                $display ("and no error is set!");

                            end
                            else if (~(PWDMLB && PSTMLB) &&
                                (CR1_in[5] == 1'b1 || CR1_in[3] == 1'b1 ||
                                (CR1_in[4] == 1'b1 && SECURE_OPN == 1'b1) ||
                                (CR1_in[2] == 1'b1 && CR3_NV[3] == 1'b0)))
                            begin
                            // Once the protection mode is selected, the OTP
                            // bits are permanently protected from programming
                                next_state = PGERS_ERROR;
                            end
                            else
                            begin
                                next_state = WRITE_SR;
                            end
                        end
                        else if (Instruct == WRAR && WEL == 1 &&
                               ~(SRWD && ~WPNeg_in && ~QUAD &&
                                (Address==32'h00000000 ||
                                 Address==32'h00000002 ||
                                 Address==32'h00800000 ||
                                 Address==32'h00800002)))
                        begin
                        // can not execute if WEL bit is zero or Hardware
                        // Protection Mode is entered and SR1NV,SR1V,CR1NV or
                        // CR1V is selected (no error is set)
                            if ((Address == 32'h00000001)  ||
                               ((Address >  32'h00000005)  &&
                                (Address <  32'h00000010)) ||
                               ((Address >  32'h00000010)  &&
                                (Address <  32'h00000020)) ||
                               ((Address >  32'h00000027)  &&
                                (Address <  32'h00000030)) ||
                               ((Address >  32'h00000031)  &&
                                (Address <  32'h00800000)) ||
                               ((Address >  32'h00800005) &&
                                (Address <  32'h00800010)) ||
                               ((Address >  32'h00800010) &&
                                (Address <  32'h00800040)) ||
                                (Address >  32'h00800040))
                            begin
                                $display ("WARNING: Undefined location ");
                                $display (" selected. Command is ignored!");
                            end
                            else if (Address == 32'h00800040) // PPBL
                            begin
                                $display ("WARNING: PPBL register cannot be ");
                                $display ("written by the WRAR command. ");
                                $display ("Command is ignored!");
                            end
                            else if ((Address == 32'h00000002) &&
                                ((TBPROT_O == 1 && WRAR_reg_in[5] == 1'b0) ||
                                 (TBPARM_O == 1 && WRAR_reg_in[2] == 1'b0 &&
                                  CR3_V[3] == 1'b0) ||
                                (BPNV_O   == 1 && WRAR_reg_in[3] == 1'b0)))
                            begin
                                $display ("WARNING: Writing of OTP bits back ");
                                $display ("to their default state is ignored ");
                                $display ("and no error is set!");

                            end
                            else if (~(PWDMLB && PSTMLB))
                            begin
                            // Once the protection mode is selected,the OTP
                            // bits are permanently protected from programming
                                if (((WRAR_reg_in[5] == 1'b1 ||
                                   (WRAR_reg_in[4]==1'b1 && SECURE_OPN==1'b1) ||
                                    WRAR_reg_in[3] == 1'b1 ||
                                   (WRAR_reg_in[2]==1'b1 && CR3_NV[3]==1'b0)) &&
                                    Address == 32'h00000002) || // CR1NV[5:2]
                                    Address == 32'h00000003  || // CR2NV
                                    Address == 32'h00000004  || // CR3NV
                                    Address == 32'h00000005  || // CR4NV
                                    Address == 32'h00000010  || // NVDLR
                                    Address == 32'h00000020  || // PASS[7:0]
                                    Address == 32'h00000021  || // PASS[15:8]
                                    Address == 32'h00000022  || // PASS[23:16]
                                    Address == 32'h00000023  || // PASS[31:24]
                                    Address == 32'h00000024  || // PASS[39:32]
                                    Address == 32'h00000025  || // PASS[47:40]
                                    Address == 32'h00000026  || // PASS[55:48]
                                    Address == 32'h00000027  || // PASS[63:56]
                                    Address == 32'h00000030  || // ASPR[7:0]
                                    Address == 32'h00000031)    // ASPR[15:8]
                                begin
                                    next_state = PGERS_ERROR;
                                end
                                else
                                    next_state = WRITE_ALL_REG;
                            end
                            else // Protection Mode not selected
                            begin
                                if ((Address == 32'h00000030) ||
                                    (Address == 32'h00000031))//ASPR
                                begin
                                    if (WRAR_reg_in[2] == 1'b0 &&
                                        WRAR_reg_in[1] == 1'b0 &&
                                        Address == 32'h00000030)
                                        next_state = PGERS_ERROR;
                                    else
                                        next_state = WRITE_ALL_REG;
                                end
                                else
                                    next_state = WRITE_ALL_REG;
                            end
                        end
                        else if ((Instruct==PP || Instruct==PP4) && WEL == 1)
                        begin
                            ReturnSectorID(sect,Address);

                            if (Sec_Prot[sect]== 0 && PPB_bits[sect]== 1 &&
                                DYB_bits[sect]== 1)
                            begin
                                next_state = PAGE_PG;
                            end
                            else
                                next_state = PGERS_ERROR;
                        end
                        else if (Instruct == OTPP && WEL == 1)
                        begin
                            if (Address + Byte_number <= OTPHiAddr)
                            begin //Program within valid OTP Range
                                if (((((Address>=16'h0010 && Address<=16'h00FF))
                                    && LOCK_BYTE1[Address/32] == 1) ||
                                    ((Address>=16'h0100 && Address<=16'h01FF)
                                    && LOCK_BYTE2[(Address-16'h0100)/32]==1) ||
                                    ((Address>=16'h0200 && Address<=16'h02FF)
                                    && LOCK_BYTE3[(Address-16'h0200)/32]==1) ||
                                    ((Address>=16'h0300 && Address<=16'h03FF)
                                    && LOCK_BYTE4[(Address-16'h0300)/32] == 1)))
                                begin
                                    if (FREEZE == 0)
                                        next_state =  OTP_PG;
                                    else
                                    //Attempting to program within valid OTP
                                    //range while FREEZE = 1
                                        next_state =  PGERS_ERROR;
                                end
                                else if (ZERO_DETECTED)
                                begin
                                //Attempting to program any zero in the 16
                                //lowest bytes or attempting to program any zero
                                //in locked region
                                    next_state = PGERS_ERROR;
                                end
                            end
                        end																																		
                        else if ((Instruct==SE || Instruct==SE4) && WEL == 1)
                        begin
                            ReturnSectorID(sect,Address);
                            ReturnBlockID(block_e,Address);

							sect8_no_prot = ~Sec_Prot[8] && PPB_bits[8]
									&& DYB_bits[8];
							sect511_no_prot = ~Sec_Prot[511] && PPB_bits[511]
									&& DYB_bits[511];
							sect_no_prot = ~Sec_Prot[sect] && PPB_bits[sect]
									&& DYB_bits[sect];
							block8_no_prot = ~Block_Prot[8] && PPB_bits_b[8]
									&& DYB_bits_b[8];
							block127_no_prot = ~Block_Prot[127] && PPB_bits_b[127]
									&& DYB_bits_b[127];							
							block_no_prot = ~Block_Prot[block_e] && 
									PPB_bits_b[block_e] && DYB_bits_b[block_e];
                            if (~CR3_V[1])
							begin																			
                            	if ((UniformSec && sect_no_prot) ||
                                 (BottomBoot && (sect >= 8) &&  sect_no_prot) ||
                                 (BottomBoot && (sect < 8) &&  sect8_no_prot) ||
								 (TopBoot && (sect <= 511) && sect_no_prot) ||
								 (TopBoot && (sect > 511) && sect511_no_prot))
                                 begin
                                    if (~CR3_V[5])
                                        next_state =  SECTOR_ERS;
                                    else
                                        next_state =  BLANK_CHECK;
                                end
                                else
                                    next_state = PGERS_ERROR;
							end
                            else
							begin
								if ((UniformSec && block_no_prot) ||
                                 (BottomBoot && (block_e >= 8) && block_no_prot) ||
                                 (BottomBoot && (block_e < 8) && block8_no_prot) ||
								 (TopBoot && (block_e <= 127) && block_no_prot) ||
								 (TopBoot && (block_e > 127) && block127_no_prot))
								begin
									if (~CR3_V[5])
											next_state =  SECTOR_ERS;
										else
											next_state =  BLANK_CHECK;
								end
                                else
                                    next_state = PGERS_ERROR;
							end
                        end
                        else if ((Instruct == P4E || Instruct == P4E4) &&
                                  WEL == 1)
                        begin
                            ReturnSectorID(sect,Address);
                            if (UniformSec || (TopBoot && sect < 512) ||
                               (BottomBoot && sect > 7))
                            begin
                                $display("The instruction is applied to");
                                $display("a sector that is larger than");
                                $display("4 KB.");
                                $display("Instruction is ignored!!!");
                            end
                            else
                            begin
                                if (Sec_Prot[sect]== 0 &&
                                  PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
                                begin
                                    if (~CR3_V[5])
                                        next_state =  SECTOR_ERS;
                                    else
                                        next_state =  BLANK_CHECK;
                                end
                                else
                                    next_state = PGERS_ERROR;
                            end
                        end
                        else if (Instruct == BE && WEL == 1 &&
                                (SR1_V[4]==0 && SR1_V[3]==0 && SR1_V[2]==0))
                        begin
                            if (~CR3_V[5])
                                next_state = BULK_ERS;
                            else
                                next_state = BLANK_CHECK;
                        end
                        else if ((Instruct==PPBP || Instruct==PPBP4) && WEL)
                            if ((((SECURE_OPN == 1) && PERMLB) ||
                                  (SECURE_OPN == 0)) && PPB_LOCK)
                                next_state = PPB_PG;
                            else
                                next_state = PGERS_ERROR;
                        else if (Instruct == PPBE && WEL && (SECURE_OPN == 1))
                            if (PPBOTP && PPB_LOCK && PERMLB)
                                next_state = PPB_ERS;
                            else
                                next_state = PGERS_ERROR;
                        else if (Instruct == ASPP && WEL == 1)
                        begin
                            //ASP Register Program Command
                            if (PWDMLB && PSTMLB)// Protection Mode not selected
                            begin
                                if (ASP_reg_in[2]==1'b0 && ASP_reg_in[1]==1'b0)
                                    next_state = PGERS_ERROR;
                                else
                                    next_state = ASP_PG;
                            end
                            else
                                next_state = PGERS_ERROR;
                        end
                        else if (Instruct == PLBWR && WEL == 1)
                            next_state = PLB_PG;
                        else if ((Instruct==DYBWR || Instruct==DYBWR4) && WEL)
                        begin
                            if (DYBAR_in == 8'hFF || DYBAR_in == 8'h00)
                                next_state = DYB_PG;
                            else
                                next_state = PGERS_ERROR;
                        end
                        else if (Instruct == PNVDLR && WEL == 1)
                        begin
                            if (PWDMLB && PSTMLB)// Protection Mode not selected
                                next_state = NVDLR_PG;
                            else
                                next_state = PGERS_ERROR;
                        end
                        else if (Instruct == PASSP && WEL == 1)
                        begin
                            if (PWDMLB && PSTMLB)// Protection Mode not selected
                                next_state = PASS_PG;
                            else
                                next_state = PGERS_ERROR;
                        end
                        else if (Instruct == PASSU && WEL == 1 && ~WIP)
                            next_state = PASS_UNLOCK;
                        else if (Instruct == EES)
                            next_state = EVAL_ERS_STAT;
                        else
                            next_state = IDLE;
                    end
                end

                WRITE_SR :
                begin
                    if (rising_edge_WDONE)
                        next_state = IDLE;
                end

                WRITE_ALL_REG :
                begin
                    if (rising_edge_WDONE || rising_edge_CSDONE)
                        next_state = IDLE;
                end

                PAGE_PG :
                begin
                    if (PRGSUSP_out_event && PRGSUSP_out == 1)
                        next_state = PG_SUSP;
                    else if (rising_edge_PDONE)
                        next_state = IDLE;
                end

                OTP_PG :
                begin
                    if (rising_edge_PDONE)
                        next_state = IDLE;
                end

                PG_SUSP :
                begin
                    if (falling_edge_write)
                    begin
                       if (Instruct == EPR)
                            next_state = PAGE_PG;
                    end
                end

                SECTOR_ERS :
                begin
                    if (ERSSUSP_out_event && ERSSUSP_out == 1)
                        next_state = ERS_SUSP;
                    else if (rising_edge_EDONE)
                        next_state = IDLE;
                end

                BULK_ERS :
                begin
                    if (rising_edge_EDONE)
                        next_state = IDLE;
                end

                ERS_SUSP :
                begin
                    if (falling_edge_write)
                    begin
                        if ((Instruct==PP || Instruct==PP4) && WEL && ~P_ERR)
                        begin
                            ReturnSectorID(sect,Address);
                            ReturnBlockID(block_e,Address);

							if (CR3_V[1]== 0)
								if (SectorErased != sect)
								begin
									if (Sec_Prot[sect]== 0 && 
									PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
										next_state = ERS_SUSP_PG;
								end
							else
								if (BlockErased != block_e)
								begin
									if (Sec_Prot[sect]== 0 &&
									PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
										next_state = ERS_SUSP_PG;
								end
                        end
                        else if ((Instruct==DYBWR || Instruct==DYBWR4) && WEL &&
                            ~P_ERR)
                        begin
                            if (DYBAR_in == 8'hFF || DYBAR_in == 8'h00)
                                next_state = DYB_PG;
                            else
                                next_state = PGERS_ERROR;
                        end
                        else if (Instruct == EPR && ~P_ERR)
                            next_state = SECTOR_ERS;
                    end
                end

                ERS_SUSP_PG :
                begin
                    if (rising_edge_PDONE)
                        next_state = ERS_SUSP;
                    else if (PRGSUSP_out_event && PRGSUSP_out == 1)
                        next_state = ERS_SUSP_PG_SUSP;
                end

                ERS_SUSP_PG_SUSP :
                begin

                    if (falling_edge_write)
                    begin
                        if (Instruct == EPR)
                        begin
                            next_state =  ERS_SUSP_PG;
                        end
                    end
                end

                PASS_PG :
                begin
                    if (rising_edge_PDONE)
                        next_state = IDLE;
                end

                PASS_UNLOCK :
                begin
                    if (falling_edge_PASSULCK_in)
                    begin
                        if (~P_ERR)
                            next_state = IDLE;
                        else
                            next_state = PGERS_ERROR;
                    end
                end

                PPB_PG :
                begin
                    if (rising_edge_PDONE)
                        next_state = IDLE;
                end

                PPB_ERS :
                begin
                if (falling_edge_PPBERASE_in)
                    next_state = IDLE;
                end

                PLB_PG :
                begin
                if (rising_edge_PDONE)
                    next_state = IDLE;
                end

                DYB_PG :
                begin
                if (rising_edge_PDONE)
                    if (ES)
                        next_state = ERS_SUSP;
                    else
                        next_state = IDLE;
                end

                ASP_PG :
                begin
                if (rising_edge_PDONE)
                    next_state = IDLE;
                end

                NVDLR_PG :
                begin
                if (rising_edge_PDONE)
                    next_state = IDLE;
                end

                PGERS_ERROR :
                begin
                    if (falling_edge_write)
                    begin
                        if (Instruct == WRDI && ~P_ERR && ~E_ERR)
                        begin
                        // A Clear Status Register (CLSR) followed by a Write
                        // Disable (WRDI) command must be sent to return the
                        // device to standby state
                            next_state = IDLE;
                        end
                    end
                end

                BLANK_CHECK :
                begin
                    if (rising_edge_BCDONE)
                    begin
                        if (NOT_BLANK)
                            if (Instruct == BE)
                                next_state = BULK_ERS;
                            else
                                next_state = SECTOR_ERS;
                        else
                            next_state = IDLE;
                    end
                end

                EVAL_ERS_STAT :
                begin
                    if (rising_edge_EESDONE)
                        next_state = IDLE;
                end

            endcase
        end
    end

//    /////////////////////////////////////////////////////////////////////////
//    //FSM Output generation and general functionality
//    /////////////////////////////////////////////////////////////////////////
    reg change_addr_event    = 1'b0;
    reg Instruct_event       = 1'b0;
    reg current_state_event  = 1'b0;

    integer WData [0:511];
    integer WOTPData;
    integer Addr;
    integer Addr_tmp;
    integer Addr_idcfi;

    always @(Instruct_event)
    begin
        read_cnt  = 0;
        byte_cnt  = 1;
        rd_fast   = 1'b0;
        rd_slow   = 1'b0;
        dual      = 1'b0;
        ddr       = 1'b0;
        any_read  = 1'b0;
        Addr_idcfi = 0;
    end

    always @(posedge read_out)
    begin
        if (PoweredUp == 1'b1)
        begin
            oe_z = 1'b1;
            #1000 oe_z = 1'b0;

            if (CSNeg_ipd==1'b0)
            begin
                oe = 1'b1;
                #1000 oe = 1'b0;
            end
        end
    end

    always @(change_addr_event)
    begin
        if (change_addr_event)
        begin
            read_addr = Address;
        end
    end

    always @(posedge PASSACC_out)
    begin
        SR1_V[0] = 1'b0; //WIP
        PASSACC_in = 1'b0;
    end

    always @(rising_edge_PoweredUp or posedge oe or posedge oe_z or
           posedge WDONE or posedge CSDONE or posedge PDONE or posedge EDONE or
           current_state_event or posedge PRGSUSP_out or posedge ERSSUSP_out or
           posedge PASSULCK_out or posedge PPBERASE_out or rising_edge_BCDONE or
           rising_edge_EESDONE or falling_edge_write)
    begin: Functionality
    integer i,j;
    integer sect;
    integer Addr_ers;
    integer block_e;
	reg sect8_no_prot;
	reg sect511_no_prot;
	reg sect_no_prot;
	reg block8_no_prot;
	reg block127_no_prot;
	reg block_no_prot;

        if (rising_edge_PoweredUp)
        begin
            // the default condition after power-up
            // During POR,the non-volatile version of the registers is copied to
            // volatile version to provide the default state of the volatile
            // register
            SR1_V = SR1_NV;

            CR1_V = CR1_NV;
            CR2_V = CR2_NV;
            CR3_V = CR3_NV;
            CR4_V = CR4_NV;

            VDLR_reg = NVDLR_reg;

            //As shipped from the factory, all devices default ASP to the
            //Persistent Protection mode, with all sectors unprotected,
            //when power is applied. The device programmer or host system must
            //then choose which sector protection method to use.
            //For Persistent Protection mode, PPBLOCK defaults to "1"
            PPBL[0] = 1'b1;

            if (~DYBLBB && (SECURE_OPN == 1))
			begin
                //All the DYB power-up in the protected state
                DYB_bits = {520{1'b0}};
                DYB_bits_b = {136{1'b0}};
			end
            else
			begin
                //All the DYB power-up in the unprotected state
                DYB_bits = {520{1'b1}};
                DYB_bits_b = {136{1'b1}};
			end

            BP_bits = {SR1_V[4],SR1_V[3],SR1_V[2]};
            change_BP = 1'b1;
            #1 change_BP = 1'b0;
        end

        case (current_state)
            IDLE :
            begin
				Instruct_P4E = 1'b0;
                if (falling_edge_write)
                begin
                    if (Instruct == WREN)
                        SR1_V[1] = 1'b1;
                    else if (Instruct == WRDI)
                        SR1_V[1] = 0;
                    else if (Instruct == BAM4)
                        CR2_V[7] = 1;
                    else if (Instruct == SBL)
                    begin
                    //----------------------------------------------------------
                    // SBL command doesn't require WEL bit set to "1"
                    // If the user set WEL bit, it will remain high after the
                    // command.
                    //----------------------------------------------------------
                        // Enable/Disable the wrapped read feature
                        CR4_V[4]   = SBL_data_in[4];
                        // Set the wrap boundary
                        CR4_V[1:0] = SBL_data_in[1:0];

                    end
                    else if (Instruct == EES)
                    begin
                        ReturnSectorID(sect,Address);
                        ReturnBlockID(block_e,Address);

                        EESSTART = 1'b1;
                        EESSTART <= #5 1'b0;
                        SR1_V[0] = 1'b1;  // WIP
                        SR1_V[1] = 1'b1;  // WEL
                    end
                    else if (Instruct == WRR && WEL == 1)
                    begin
                        if (~(SRWD && ~WPNeg_in && ~QUAD))
                        begin
                            if (((TBPROT_O ==1 && CR1_in[5] == 1'b0) ||
                                 (TBPARM_O == 1 && CR1_in[2] == 1'b0 &&
                                  CR3_V[3] == 1'b0) ||
                                 (BPNV_O   ==1 && CR1_in[3] == 1'b0)) &&
                                 cfg_write)
                            begin
                                SR1_V[1] = 1'b0; // WEL
                            end
                            else if (~(PWDMLB && PSTMLB) &&
                                (CR1_in[5] == 1'b1 || CR1_in[3] == 1'b1 ||
                                (CR1_in[4] == 1'b1 && SECURE_OPN == 1'b1) ||
                                (CR1_in[2] == 1'b1 && CR3_NV[3] == 1'b0)))
                            begin
                            // Once the protection mode is selected, the OTP
                            // bits are permanently protected from programming
                                SR1_V[6] = 1'b1; // P_ERR
                                SR1_V[0] = 1'b1; // WIP
                            end
                            else
                            begin
                                WSTART = 1'b1;
                                WSTART <= #5 1'b0;
                                SR1_V[0] = 1'b1;  // WIP
                            end
                         end
                         else
                         // can not execute if Hardware Protection Mode
                         // is entered or if WEL bit is zero
                             SR1_V[1] = 1'b0; // WEL
                    end
                    else if (Instruct == WRAR && WEL == 1)
                    begin
                        if (~(SRWD && ~WPNeg_in && ~QUAD &&
                           (Address==32'h00000000 || Address==32'h00000002 ||
                            Address==32'h00800000 || Address==32'h00800002)))
                        begin
                        // can not execute if WEL bit is zero or Hardware
                        // Protection Mode is entered and SR1NV,SR1V,CR1NV or
                        // CR1V is selected (no error is set)
                            Addr = Address;

                            if ((Address == 32'h00000001)  ||
                               ((Address >  32'h00000005)  &&
                                (Address <  32'h00000010)) ||
                               ((Address >  32'h00000010)  &&
                                (Address <  32'h00000020)) ||
                               ((Address >  32'h00000027)  &&
                                (Address <  32'h00000030)) ||
                               ((Address >  32'h00000031)  &&
                                (Address <  32'h00800000)) ||
                               ((Address >  32'h00800005) &&
                                (Address <  32'h00800010)) ||
                                (Address >  32'h00800010))
                            begin
                                SR1_V[1] = 1'b0; // WEL
                            end
                            else if ((Address == 32'h00000002) &&
                                ((TBPROT_O == 1 && WRAR_reg_in[5] == 1'b0) ||
                                 (TBPARM_O == 1 && WRAR_reg_in[2] == 1'b0 &&
                                  CR3_V[3] == 1'b0) ||
                                (BPNV_O   == 1 && WRAR_reg_in[3] == 1'b0)))
                            begin
                                SR1_V[1] = 1'b0; // WEL
                            end
                            else if (~(PWDMLB && PSTMLB))
                            begin
                            // Once the protection mode is selected,the OTP
                            // bits are permanently protected from programming
                                if (((WRAR_reg_in[5] == 1'b1 ||
                                   (WRAR_reg_in[4]==1'b1 && SECURE_OPN==1'b1) ||
                                    WRAR_reg_in[3] == 1'b1 ||
                                   (WRAR_reg_in[2]==1'b1 && CR3_NV[3]==1'b0)) &&
                                    Address == 32'h00000002) || // CR1NV[5:2]
                                    Address == 32'h00000003  || // CR2NV
                                    Address == 32'h00000004  || // CR3NV
                                    Address == 32'h00000005  || // CR4NV
                                    Address == 32'h00000010  || // NVDLR
                                    Address == 32'h00000020  || // PASS[7:0]
                                    Address == 32'h00000021  || // PASS[15:8]
                                    Address == 32'h00000022  || // PASS[23:16]
                                    Address == 32'h00000023  || // PASS[31:24]
                                    Address == 32'h00000024  || // PASS[39:32]
                                    Address == 32'h00000025  || // PASS[47:40]
                                    Address == 32'h00000026  || // PASS[55:48]
                                    Address == 32'h00000027  || // PASS[63:56]
                                    Address == 32'h00000030  || // ASPR[7:0]
                                    Address == 32'h00000031)    // ASPR[15:8]
                                begin
                                    SR1_V[6] = 1'b1; // P_ERR
                                    SR1_V[0] = 1'b1; // WIP
                                end
                                else
                                begin
                                    CSSTART = 1'b1;
                                    CSSTART <= #5 1'b0;
                                    SR1_V[0] = 1'b1;  // WIP
                                end
                            end
                            else // Protection Mode not selected
                            begin
                                if ((Address == 32'h00000030) ||
                                    (Address == 32'h00000031))//ASPR
                                begin
                                    if (WRAR_reg_in[2] == 1'b0 &&
                                        WRAR_reg_in[1] == 1'b0 &&
                                        Address == 32'h00000030)
                                    begin
                                        SR1_V[6] = 1'b1; // P_ERR
                                        SR1_V[0] = 1'b1; // WIP
                                    end
                                    else
                                    begin
                                        WSTART = 1'b1;
                                        WSTART <= #5 1'b0;
                                        SR1_V[0] = 1'b1;  // WIP
                                    end
                                end
                                else if ((Address == 32'h00000000) ||
                                         (Address == 32'h00000010) ||
                                         (Address >= 32'h00000002) &&
                                         (Address <= 32'h00000005) ||
                                         (Address >= 32'h00000020) &&
                                         (Address <= 32'h00000027))
                                begin
                                    WSTART = 1'b1;
                                    WSTART <= #5 1'b0;
                                    SR1_V[0] = 1'b1;  // WIP
                                end
                                else
                                begin
                                    CSSTART = 1'b1;
                                    CSSTART <= #5 1'b0;
                                    SR1_V[0] = 1'b1;  // WIP
                                end
                            end
                        end
                        else
                        // can not execute if Hardware Protection Mode
                        // is entered or if WEL bit is zero
                        SR1_V[1] = 1'b0; // WEL
                    end
                    else if ((Instruct == PP || Instruct == PP4) && WEL ==1)
                    begin
                        ReturnSectorID(sect,Address);
                        pgm_page = Address / (PageSize+1);

                        if (Sec_Prot[sect] == 0 &&
                            PPB_bits[sect]== 1 && DYB_bits[sect]== 1)
                        begin
                            PSTART  = 1'b1;
                            PSTART <= #5 1'b0;
                            PGSUSP  = 0;
                            PGRES   = 0;
                            INITIAL_CONFIG = 1;
                            SR1_V[0] = 1'b1;  // WIP
                            Addr    = Address;
                            Addr_tmp= Address;
                            wr_cnt  = Byte_number;
                            for (i=wr_cnt;i>=0;i=i-1)
                            begin
                                if (Viol != 0)
                                    WData[i] = -1;
                                else
                                    WData[i] = WByte[i];
                            end
                        end
                        else
                        begin
                        //P_ERR bit will be set when the user attempts to
                        //to program within a protected main memory sector
                            SR1_V[6] = 1'b1; //P_ERR
                            SR1_V[0] = 1'b1; //WIP
                        end
                    end
                    else if (Instruct == OTPP && WEL == 1)
                    begin
                        if (Address + Byte_number <= OTPHiAddr)
                        begin //Program within valid OTP Range
                            if (((((Address>=16'h0010 && Address<=16'h00FF))
                                && LOCK_BYTE1[Address/32] == 1) ||
                                ((Address>=16'h0100 && Address<=16'h01FF)
                                && LOCK_BYTE2[(Address-16'h0100)/32]==1) ||
                                ((Address>=16'h0200 && Address<=16'h02FF)
                                && LOCK_BYTE3[(Address-16'h0200)/32]==1) ||
                                ((Address>=16'h0300 && Address<=16'h03FF)
                                && LOCK_BYTE4[(Address-16'h0300)/32] == 1)))
                            begin
                            // As long as the FREEZE bit remains cleared to a
                            // logic '0' the OTP address space is programmable.
                                if (FREEZE == 0)
                                begin
                                    PSTART  = 1'b1;
                                    PSTART <= #5 1'b0;
                                    SR1_V[0] = 1'b1; //WIP
                                    Addr    = Address;
                                    Addr_tmp= Address;
                                    wr_cnt  = Byte_number;
                                    for (i=wr_cnt;i>=0;i=i-1)
                                    begin
                                        if (Viol != 0)
                                            WData[i] = -1;
                                        else
                                            WData[i] = WByte[i];
                                    end
                                end
                                else
                                //Attempting to program within valid OTP
                                //range while FREEZE = 1
                                begin
                                    SR1_V[6] = 1'b1; // P_ERR
                                    SR1_V[0] = 1'b1; // WIP
                                end
                            end
                            else if (ZERO_DETECTED)
                            begin
                                if (Address > 12'h3FF)
                                begin
                                    $display ("Given address is ");
                                    $display ("out of OTP address range");
                                end
                                else
                                begin
                                //Attempting to program any zero in the 16
                                //lowest bytes or attempting to program any zero
                                //in locked region
                                    SR1_V[6] = 1'b1; // P_ERR
                                    SR1_V[0] = 1'b1; // WIP
                                end
                            end
                        end
                    end
                    else if ((Instruct==SE || Instruct==SE4) && WEL == 1)
                    begin
                        ReturnSectorID(sect,Address);
                        ReturnBlockID(block_e,Address);
                        SectorErased = sect;
                        BlockErased  = block_e;
																				
						sect8_no_prot = ~Sec_Prot[8] && PPB_bits[8]
									&& DYB_bits[8];
						sect511_no_prot = ~Sec_Prot[511] && PPB_bits[511]
									&& DYB_bits[511];
						sect_no_prot = ~Sec_Prot[sect] && PPB_bits[sect]
									&& DYB_bits[sect];
						block8_no_prot = ~Block_Prot[8] && PPB_bits_b[8]
									&& DYB_bits_b[8];
						block127_no_prot = ~Block_Prot[127] && PPB_bits_b[127]
									&& DYB_bits_b[127];
						block_no_prot = ~Block_Prot[block_e] &&
									PPB_bits_b[block_e] && DYB_bits_b[block_e];
                        if (~CR3_V[1])
						begin
                            if ((UniformSec && sect_no_prot) ||
                            (BottomBoot && (sect >= 8) &&  sect_no_prot) ||
                            (BottomBoot && (sect < 8) &&  sect8_no_prot) ||
						    (TopBoot && (sect > 511) && sect511_no_prot) ||
							(TopBoot && (sect <= 511) && sect_no_prot))
                            begin
                                Addr_ers = Address;
                                if (~CR3_V[5])
 								begin
                                    bc_done = 1'b0;
                                    ESTART  = 1'b1;
                                    ESTART <= #5 1'b0;
                                    ESUSP     = 0;
                                    ERES      = 0;
                                    INITIAL_CONFIG = 1;
                                    SR1_V[0] = 1'b1; //WIP
                                end
                            end
                            else
                            begin
                            //E_ERR bit will be set when the user attempts to
                            //erase an individual protected main memory sector
                                SR1_V[5] = 1'b1; //E_ERR
                                SR1_V[0] = 1'b1; //WIP
                            end
						end
                        else
						begin
							if ((UniformSec && block_no_prot) ||
                            (BottomBoot && (block_e >= 8) && block_no_prot) ||
                            (BottomBoot && (block_e < 8) && block8_no_prot) ||
							(TopBoot && (block_e <= 127) && block_no_prot) ||
							(TopBoot && (block_e > 127) && block127_no_prot))
							begin
                                Addr_ers = Address;
                                if (~CR3_V[5])
 								begin
                                    bc_done = 1'b0;
                                    ESTART  = 1'b1;
                                    ESTART <= #5 1'b0;
                                    ESUSP     = 0;
                                    ERES      = 0;
                                    INITIAL_CONFIG = 1;
                                    SR1_V[0] = 1'b1; //WIP
                                end
                            end
                            else
                            begin
                                SR1_V[5] = 1'b1; //E_ERR
                                SR1_V[0] = 1'b1; //WIP
                            end
						end
					end
                    else if ((Instruct == P4E || Instruct == P4E4) && WEL == 1)
                    begin
                        ReturnSectorID(SectorErased,Address);

                        if (UniformSec || (TopBoot && SectorErased <= 511) ||
                           (BottomBoot && SectorErased >= 8))
                        begin
                            SR1_V[1] = 1'b0;//WEL
                        end
                        else
                        begin
                            if (Sec_Prot[SectorErased] == 0 &&
                                PPB_bits[SectorErased]== 1 && DYB_bits[SectorErased]== 1)
                            //A P4E instruction applied to a sector
                            //that has been Write Protected through the
                            //Block Protect Bits or ASP will not be
                            //executed and will set the E_ERR status
                            begin
                                Addr_ers = Address;
							    Instruct_P4E = 1'b1;
                                if (~CR3_V[5])
                                begin
                                    bc_done = 1'b0;
                                    ESTART = 1'b1;
                                    ESTART <= #5 1'b0;
                                    ESUSP     = 0;
                                    ERES      = 0;
                                    INITIAL_CONFIG = 1;
                                    SR1_V[0] = 1'b1; //WIP
                                end
                            end
                            else
                            begin
                            //E_ERR bit will be set when the user attempts to
                            //erase an individual protected main memory sector
                                SR2_V[5] = 1'b1; //E_ERR
                                SR1_V[0] = 1'b1; //WIP
                            end
                        end
                    end
                    else if (Instruct == BE && WEL == 1)
                    begin
                        if (SR1_V[4]==0 && SR1_V[3]==0 && SR1_V[2]==0)
                        begin
                            if (~CR3_V[5])
                            begin
                                bc_done = 1'b0;
                                ESTART = 1'b1;
                                ESTART <= #5 1'b0;
                                ESUSP  = 0;
                                ERES   = 0;
                                INITIAL_CONFIG = 1;
                                SR1_V[0] = 1'b1; //WIP
                            end
                        end
                        else
                        begin
                        //The Bulk Erase command will not set E_ERR if a
                        //protected sector is found during the command
                        //execution.
                            SR1_V[1] = 1'b0;//WEL
                        end
                    end
                    else if ((Instruct==PPBP || Instruct==PPBP4) && WEL)
                    begin
                        if ((((SECURE_OPN==1) && PERMLB) || (SECURE_OPN==0)) &&
                           PPB_LOCK)
                        begin
                            ReturnSectorID(sect,Address);
                            ReturnBlockID(block_e,Address);
                            PSTART = 1'b1;
                            PSTART <= #5 1'b0;
                            SR1_V[0] = 1'b1;//WIP
                        end
                        else
                        begin
                            SR1_V[6] = 1'b1; // P_ERR
                            SR1_V[0] = 1'b1; // WIP
                        end
                    end
                    else if (Instruct == PPBE && WEL)
                    begin
                        if (SECURE_OPN == 1)
                        begin
                            if (PPBOTP && PPB_LOCK && PERMLB)
                            begin
                                PPBERASE_in = 1'b1;
                                SR1_V[0] = 1'b1; // WIP
                            end
                            else
                            begin
                                SR1_V[5] = 1'b1; // E_ERR
                                SR1_V[0] = 1'b1; // WIP
                            end
                        end
                        else
                            SR1_V[1] = 1'b0; // WEL
                    end
                    else if (Instruct == ASPP  && WEL == 1)
                    begin
                        if (PWDMLB && PSTMLB)// Protection Mode not selected
                        begin
                            if (ASP_reg_in[2]==1'b0 && ASP_reg_in[1]==1'b0)
                            begin
                                $display("ASPR[2:1] = 00  Illegal condition");
                                SR1_V[6] = 1'b1; // P_ERR
                                SR1_V[0] = 1'b1; // WIP
                            end
                            else
                            begin
                                PSTART = 1'b1;
                                PSTART <= #5 1'b0;
                                SR1_V[0] = 1'b1; // WIP
                            end
                        end
                        else
                        begin
                            SR1_V[0] = 1'b1; // WIP
                            SR1_V[6] = 1'b1; // P_ERR
                            $display ("Once the Protection Mode is selected,");
                            $display ("no further changes to the ASP ");
                            $display ("register is allowed.");
                        end
                    end
                    else if (Instruct == PLBWR  && WEL == 1)
                    begin
                        PSTART = 1'b1;
                        PSTART <= #5 1'b0;
                        SR1_V[0] = 1'b1; // WIP
                    end
                    else if ((Instruct==DYBWR || Instruct==DYBWR4) && WEL)
                    begin
                        if (DYBAR_in == 8'hFF || DYBAR_in == 8'h00)
                        begin
                            ReturnSectorID(sect,Address);
                            ReturnBlockID(block_e,Address);
                            PSTART   = 1'b1;
                            PSTART  <= #5 1'b0;
                            SR1_V[0] = 1'b1;// WIP
                        end
                        else
                        begin
                            SR1_V[6] = 1'b1;// P_ERR
                            SR1_V[0] = 1'b1;// WIP
                        end
                    end
                    else if (Instruct == PNVDLR  && WEL == 1)
                    begin
                        if (PWDMLB && PSTMLB)// Protection Mode not selected
                        begin
                            PSTART   = 1'b1;
                            PSTART  <= #5 1'b0;
                            SR1_V[0] = 1;// WIP
                        end
                        else
                        begin
                            SR2_V[6] = 1'b1; //P_ERR
                            SR1_V[0] = 1'b1; //WIP
                        end
                    end
                    else if (Instruct == WVDLR  && WEL == 1)
                    begin
                        VDLR_reg = VDLR_reg_in;
                        SR1_V[1] = 1'b0; //WEL
                    end
                    else if (Instruct == PASSP && WEL == 1)
                    begin
                        if (PWDMLB && PSTMLB)// Protection Mode not selected
                        begin
                            PSTART = 1'b1;
                            PSTART <= #5 1'b0;
                            SR1_V[0] = 1'b1;
                        end
                        else
                        begin
                            SR2_V[6] = 1'b1; //P_ERR
                            SR1_V[0] = 1'b1; //WIP
                            $display ("Password programming is not allowed");
                            $display (" when Protection Mode is selected.");
                        end
                    end
                    else if (Instruct == PASSU  && WEL)
                    begin
                        if (~WIP)
                        begin
                            PASSULCK_in = 1;
                            SR1_V[0] = 1'b1; //WIP
                        end
                        else
                        begin
                            $display ("The PASSU command cannot be accepted");
                            $display (" any faster than once every 100us");
                        end
                    end
                    else if (Instruct == CLSR)
                    begin
                        SR1_V[6] = 0;// P_ERR
                        SR1_V[5] = 0;// E_ERR
                        SR1_V[0] = 0;// WIP
                    end

                    if (Instruct == RSTEN)
                    begin
                        RESET_EN = 1;
                    end
                    else
                    begin
                        RESET_EN <= 0;
                    end
                end
                else if (oe_z)
                begin
                    if (Instruct == READ || Instruct == READ4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    else if ((Instruct == DDRQIOR || Instruct == DDRQIOR4)
                             && QUAD)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else if (Instruct == DIOR || Instruct == DIOR4 ||
                           ((Instruct == QIOR || Instruct == QIOR4)
                             && QUAD))
                    begin
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;
                    end
                    else
                    begin
                        if (QUAD_ALL)
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                    end
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end
                else if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin
                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_SO = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == READ || Instruct == READ4)
                    begin
                        //Read Memory array
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;

                        if (Mem[read_addr] !== -1)
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO  = data_out[7-read_cnt];
                        end
                        else
                        begin
                            DataDriveOut_SO  = 8'bx;
                        end

                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                        begin
                            read_cnt = 0;
                            if (read_addr == AddrRANGE)
                                read_addr = 0;
                            else
                                read_addr = read_addr + 1;
                        end
                    end
                    else if (Instruct == FAST_READ || Instruct == FAST_READ4)
                    begin

                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;

                        if (Mem[read_addr] !== -1)
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO  = data_out[7-read_cnt];
                        end
                        else
                        begin
                            DataDriveOut_SO  = 8'bx;
                        end

                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                        begin
                            read_cnt = 0;

                            if (~CR4_V[4])  //Wrap Disabled
                            begin
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                            else           //Wrap Enabled
                            begin
                                read_addr = read_addr + 1;

                                if (read_addr % WrapLength == 0)
                                    read_addr = read_addr - WrapLength;

                            end
                        end
                    end
                    else if (Instruct == DIOR || Instruct == DIOR4)
                    begin
                        //Read Memory array
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;

                        if (Mem[read_addr] !== -1)
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO = data_out[7-2*read_cnt];
                            DataDriveOut_SI = data_out[6-2*read_cnt];
                        end
                        else
                        begin
                            DataDriveOut_SO = 8'bx;
                            DataDriveOut_SI = 8'bx;
                        end

                        data_out[7:0] = Mem[read_addr];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 4)
                        begin
                            read_cnt = 0;

                            if (~CR4_V[4])  //Wrap Disabled
                            begin
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                            else           //Wrap Enabled
                            begin
                                read_addr = read_addr + 1;

                                if (read_addr % WrapLength == 0)
                                    read_addr = read_addr - WrapLength;
                            end
                        end
                    end
                    else if ((Instruct == QIOR    || Instruct == QIOR4 ||
                              Instruct == DDRQIOR || Instruct == DDRQIOR4) &&
                              QUAD)
                    begin
                        //Read Memory array
                        if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end

                        if (bus_cycle_state == DUMMY_BYTES)
                        begin
                            if ((Instruct == DDRQIOR || Instruct == DDRQIOR4)
                            && QUAD)
                            begin
                                Return_DLP(Latency_code,dummy_cnt, dlp_act);
                                // Data Learning Pattern (DLP) is enabled
                                // Optional DLP
                                if (VDLR_reg != 8'b00000000 && dlp_act == 1'b1)
                                begin
                                    DataDriveOut_RESET = VDLR_reg[7-read_cnt];
                                    DataDriveOut_WP    = VDLR_reg[7-read_cnt];
                                    DataDriveOut_SO    = VDLR_reg[7-read_cnt];
                                    DataDriveOut_SI    = VDLR_reg[7-read_cnt];
                                    dlp_act = 1'b0;
                                    read_cnt = read_cnt + 1;
                                    if (read_cnt == 8)
                                    begin
                                        read_cnt = 0;
                                    end
                                end
                            end
                        end
                        else
                        begin
                            data_out[7:0]  = Mem[read_addr];
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                    end
                    else if (Instruct == OTPR)
                    begin
                        if(read_addr>=OTPLoAddr && read_addr<=OTPHiAddr)
                        begin
                        //Read OTP Memory array
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                            data_out[7:0] = OTPMem[read_addr];
                            DataDriveOut_SO  = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                read_addr = read_addr + 1;
                            end
                        end
                        else if (read_addr > OTPHiAddr)
                        begin
                        //OTP Read operation will not wrap to the
                        //starting address after the OTP address is at
                        //its maximum; instead, the data beyond the
                        //maximum OTP address will be undefined.
                            DataDriveOut_SO = 1'bX;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDID)
                    begin
                        if (QUAD_ALL)
                        begin
                            if (Addr_idcfi <= CFILength)
                            begin
                                data_out[7:0]  = SFDP_array[16'h1000 + Addr_idcfi];
                                DataDriveOut_RESET = data_out[7-4*read_cnt];
                                DataDriveOut_WP    = data_out[6-4*read_cnt];
                                DataDriveOut_SO    = data_out[5-4*read_cnt];
                                DataDriveOut_SI    = data_out[4-4*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 2)
                                begin
                                    read_cnt = 0;
                                    Addr_idcfi = Addr_idcfi+1;
                                end
                            end
                        end
                        else
                        begin
                            if (Addr_idcfi <= CFILength)
                            begin
                                data_out[7:0] = SFDP_array[16'h1000 + Addr_idcfi];
                                DataDriveOut_SO  = data_out[7-read_cnt];
                                read_cnt  = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt = 0;
                                    Addr_idcfi = Addr_idcfi+1;
                                end
                            end
                        end
                    end

                    else if ((Instruct == RDQID) && QUAD)
                    begin
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;

                        if (Addr_idcfi <= CFILength)
                        begin
                            data_out[7:0]  = SFDP_array[16'h1000 + Addr_idcfi];
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                                Addr_idcfi = Addr_idcfi+1;
                            end
                        end
                    end
                    else if (Instruct == RSFDP)
                    begin
                        if (QUAD_ALL)
                        begin
                            if (addr_bytes <= SFDPHiAddr)
                            begin
                                data_out[7:0]  = SFDP_array[addr_bytes];
                                DataDriveOut_RESET = data_out[7-4*read_cnt];
                                DataDriveOut_WP    = data_out[6-4*read_cnt];
                                DataDriveOut_SO    = data_out[5-4*read_cnt];
                                DataDriveOut_SI    = data_out[4-4*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 2)
                                begin
                                    read_cnt = 0;
                                   addr_bytes = addr_bytes+1;
                                end
                            end
                            else
                            begin
                            //Continued shifting of output beyond the end of
                            //the defined ID-CFI address space will
                            //provide undefined data.
                                DataDriveOut_RESET = 1'bX;
                                DataDriveOut_WP    = 1'bX;
                                DataDriveOut_SO    = 1'bX;
                                DataDriveOut_SI    = 1'bX;
                            end
                        end
                        else
                        begin
                            if (addr_bytes <= SFDPHiAddr)
                            begin
                                data_out[7:0]  = SFDP_array[addr_bytes];
                                DataDriveOut_SO = data_out[7-read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 8)
                                begin
                                    read_cnt = 0;
                                    addr_bytes = addr_bytes+1;
                                end
                            end
                            else
                            begin
                            //Continued shifting of output beyond the end of
                            //the defined ID-CFI address space will
                            //provide undefined data.
                                DataDriveOut_SO = 1'bX;
                            end
                        end
                    end
                    else if (Instruct == DLPRD)
                    begin
                    //Read DLP
                        DataDriveOut_SO = VDLR_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == ECCRD || Instruct == ECCRD4)
                    begin
                    //Read DLP
                        if (QUAD_ALL)
                        begin
                            DataDriveOut_RESET = ECC_reg[7-4*read_cnt];
                            DataDriveOut_WP    = ECC_reg[6-4*read_cnt];
                            DataDriveOut_SO    = ECC_reg[5-4*read_cnt];
                            DataDriveOut_SI    = ECC_reg[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                                read_cnt = 0;
                        end
                        else
                        begin
                            DataDriveOut_SO = ECC_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == DYBRD || Instruct == DYBRD4)
                    begin
                    //Read DYB Access Register
                        ReturnSectorID(sect,Address);

                        if (DYB_bits[sect] == 1)
                            DYBAR[7:0] = 8'hFF;
                        else
                        begin
                            DYBAR[7:0] = 8'h0;
                        end

                        if (QUAD_ALL)
                        begin
                            DataDriveOut_RESET = DYBAR[7-4*read_cnt];
                            DataDriveOut_WP    = DYBAR[6-4*read_cnt];
                            DataDriveOut_SO    = DYBAR[5-4*read_cnt];
                            DataDriveOut_SI    = DYBAR[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                                read_cnt = 0;
                        end
                        else
                        begin
                            DataDriveOut_SO = DYBAR[7-read_cnt];
                            read_cnt  = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == PPBRD || Instruct == PPBRD4)
                    begin
                    //Read PPB Access Register
                        ReturnSectorID(sect,Address);

                        if (PPB_bits[sect] == 1)
                            PPBAR[7:0] = 8'hFF;
                        else
                        begin
                            PPBAR[7:0] = 8'h0;
                        end

                        DataDriveOut_SO = PPBAR[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == ASPRD)
                    begin
                    //Read ASP Register
                        DataDriveOut_SO = ASP_reg[15-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 16)
                            read_cnt = 0;
                    end
                    else if (Instruct == PLBRD)
                    begin
                    //Read PPB Lock Register
                        DataDriveOut_SO = PPBL[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == PASSRD)
                    begin
                    //Read Password Register
                        if (~(PWDMLB == 0 && PSTMLB == 1))
                        begin
                            DataDriveOut_SO =
                                          Password_reg[(8*byte_cnt-1)-read_cnt];
                            read_cnt  = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                byte_cnt = byte_cnt + 1;
                                if (byte_cnt == 9)
                                    byte_cnt = 1;
                            end
                        end
                    end
                end
            end

            WRITE_SR:
            begin

                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin
                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin

                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if (WDONE == 1)
                begin
                    SR1_V[0] = 1'b0; //WIP
                    SR1_V[1] = 1'b0; //WEL

                    //SRWD bit
                    SR1_NV[7] = SR1_in[7];
                    SR1_V [7] = SR1_in[7];

                    if ((~LOCK_O && SECURE_OPN == 1) || (SECURE_OPN == 0))
                    begin
                        if (FREEZE == 0)
                        //The Freeze Bit, when set to 1, locks the current
                        //state of the BP2-0 bits in Status Register,
                        //the TBPROT and TBPARM bits in the Config Register
                        //As long as the FREEZE bit remains cleared to logic
                        //'0', the other bits of the Configuration register
                        //including FREEZE are writeable.
                        begin
                            if (BPNV_O == 0)
                            begin
                                SR1_NV[4] = SR1_in[4];//BP2_NV
                                SR1_NV[3] = SR1_in[3];//BP1_NV
                                SR1_NV[2] = SR1_in[2];//BP0_NV

                                SR1_V[4]  = SR1_in[4];//BP2
                                SR1_V[3]  = SR1_in[3];//BP1
                                SR1_V[2]  = SR1_in[2];//BP0
                            end
                            else
                            begin
                                SR1_V[4]  = SR1_in[4];//BP2
                                SR1_V[3]  = SR1_in[3];//BP1
                                SR1_V[2]  = SR1_in[2];//BP0
                            end

                            BP_bits = {SR1_V[4],SR1_V[3],SR1_V[2]};

                            if (TBPROT_O == 1'b0 && INITIAL_CONFIG == 1'b0)
                            begin
                                CR1_NV[5] = CR1_in[5];//TBPROT_O
                                CR1_V[5]  = CR1_in[5];//TBPROT
                            end
                            if (BPNV_O == 1'b0)
                            begin
                                CR1_NV[3] = CR1_in[3];//BPNV_O
                                CR1_V[3]  = CR1_in[3];//BPNV

                            end
                            if (TBPARM_O == 1'b0 && INITIAL_CONFIG == 1'b0 &&
                                CR3_V[3] == 1'b0)
                            begin
                                CR1_NV[2] = CR1_in[2];//TBPARM_O
                                CR1_V[2]  = CR1_in[2];//TBPARM
                                change_TBPARM = 1'b1;
                                #1 change_TBPARM = 1'b0;
                            end

                            change_BP = 1'b1;
                            #1 change_BP = 1'b0;
                        end
                    end

                    if (~QUAD_ALL)
                    begin
                    // While Quad All mode is selected (CR2NV[1]=1 or CR2V[1]=1)
                    // the QUAD bit cannot be cleared to 0.
                        CR1_NV[1] = CR1_in[1]; //QUAD_NV
                        CR1_V[1]  = CR1_in[1]; //QUAD
                    end

                    if (FREEZE == 1'b0)
                    begin
                        CR1_V[0] = CR1_in[0];//FREEZE
                    end

                    if (SECURE_OPN == 1'b1 && LOCK_O == 1'b0)
                    begin
                        CR1_NV[4] = CR1_in[4];//LOCK_O
                        CR1_V[4]  = CR1_in[4];//LOCK
                    end
                end
            end

            WRITE_ALL_REG :
            begin

                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin

                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                new_pass_byte = WRAR_reg_in;
                if (Addr == 32'h00000020)
                    old_pass_byte = Password_reg[7:0];
                else if (Addr == 32'h00000021)
                    old_pass_byte = Password_reg[15:8];
                else if (Addr == 32'h00000022)
                    old_pass_byte = Password_reg[23:16];
                else if (Addr == 32'h00000023)
                    old_pass_byte = Password_reg[31:24];
                else if (Addr == 32'h00000024)
                    old_pass_byte = Password_reg[39:32];
                else if (Addr == 32'h00000025)
                    old_pass_byte = Password_reg[47:40];
                else if (Addr == 32'h00000026)
                    old_pass_byte = Password_reg[55:48];
                else if (Addr == 32'h00000027)
                    old_pass_byte = Password_reg[63:56];

                for (i=0;i<=7;i=i+1)
                begin
                    if (old_pass_byte[j] == 0)
                        new_pass_byte[j] = 0;
                end

                if (WDONE && CSDONE)
                begin
                    SR1_V[0] = 1'b0; // WIP
                    SR1_V[1] = 1'b0; // WEL

                    if (Addr == 32'h00000000) // SR1_NV;
                    begin
                        //SRWD bit
                        SR1_NV[7] = WRAR_reg_in[7];
                        SR1_V [7] = WRAR_reg_in[7];

                        if ((~LOCK_O && (SECURE_OPN == 1)) || (SECURE_OPN == 0))
                        begin
                            if (FREEZE == 0)
                            //The Freeze Bit, when set to 1, locks the current
                            //state of the BP2-0 bits in Status Register.
                            begin
                                if (BPNV_O == 0)
                                begin
                                    SR1_NV[4] = WRAR_reg_in[4];//BP2_NV
                                    SR1_NV[3] = WRAR_reg_in[3];//BP1_NV
                                    SR1_NV[2] = WRAR_reg_in[2];//BP0_NV

                                    SR1_V[4]  = WRAR_reg_in[4];//BP2
                                    SR1_V[3]  = WRAR_reg_in[3];//BP1
                                    SR1_V[2]  = WRAR_reg_in[2];//BP0

                                    BP_bits = {SR1_V[4],SR1_V[3],SR1_V[2]};

                                    change_BP    = 1'b1;
                                    #1 change_BP = 1'b0;
                                end
                            end
                        end
                    end
                    else if (Addr == 32'h00000002) // CR1_NV;
                    begin
                        if ((~LOCK_O && (SECURE_OPN == 1)) || (SECURE_OPN == 0))
                        begin
                            if (FREEZE == 0)
                            //The Freeze Bit, when set to 1, locks the current
                            //state of the BP2-0 bits in Status Register,
                            //the TBPROT and TBPARM bits in the Config Register
                            //As long as the FREEZE bit remains cleared to logic
                            //'0', the other bits of the Configuration register
                            //including FREEZE are writeable.
                            begin
                                if (TBPROT_O == 1'b0 && INITIAL_CONFIG == 1'b0)
                                begin
                                    CR1_NV[5] = WRAR_reg_in[5];//TBPROT_O
                                    CR1_V[5]  = WRAR_reg_in[5];//TBPROT
                                end
                                if (BPNV_O == 1'b0)
                                begin
                                    CR1_NV[3] = WRAR_reg_in[3];//BPNV_O
                                    CR1_V[3]  = WRAR_reg_in[3];//BPNV

                                end
                                if (TBPARM_O==1'b0 && INITIAL_CONFIG==1'b0 &&
                                    CR3_V[3] == 1'b0)
                                begin
                                    CR1_NV[2] = WRAR_reg_in[2];//TBPARM_O
                                    CR1_V[2]  = WRAR_reg_in[2];//TBPARM
                                    change_TBPARM = 1'b1;
                                    #1 change_TBPARM = 1'b0;
                                end
                            end
                        end

                        if (~QUAD_ALL)
                        begin
                        // While Quad All mode is selected (CR2NV[1]=1 or
                        // CR2V[1]=1) the QUAD bit cannot be cleared to 0.
                            CR1_NV[1] = WRAR_reg_in[1]; //QUAD_NV
                            CR1_V[1]  = WRAR_reg_in[1]; //QUAD
                        end

                        if (SECURE_OPN == 1'b1 && LOCK_O == 1'b0)
                        begin
                            CR1_NV[4] = WRAR_reg_in[4];//LOCK_O
                            CR1_V[4]  = WRAR_reg_in[4];//LOCK
                        end
                    end
                    else if (Addr == 32'h00000003) // CR2_NV
                    begin
                        if (CR2_NV[7] == 1'b0)
                        begin
                            CR2_NV[7] = WRAR_reg_in[7];// AL_NV
                            CR2_V[7]  = WRAR_reg_in[7];// AL
                        end

                        if (CR2_NV[6] == 1'b0 && WRAR_reg_in[6] == 1'b1)
                        begin
                            CR2_NV[6] = WRAR_reg_in[6];// QA_NV
                            CR2_V[6]  = WRAR_reg_in[6];// QA

                            CR1_NV[1] = 1'b1; //QUAD_NV
                            CR1_V[1]  = 1'b1; //QUAD
                        end

                        if (CR2_NV[5] == 1'b0)
                        begin
                            CR2_NV[5] = WRAR_reg_in[5];// IO3R_NV
                            CR2_V[5]  = WRAR_reg_in[5];// IO3R_S
                        end

                        if (CR2_NV[3:0] == 4'b1000)
                        begin
                            CR2_NV[3:0] = WRAR_reg_in[3:0];// RL_NV[3:0]
                            CR2_V[3:0]  = WRAR_reg_in[3:0];// RL[3:0]
                        end
                    end
                    else if (Addr == 32'h00000004) // CR3_NV
                    begin
                        if (CR3_NV[5] == 1'b0)
                        begin
                            CR3_NV[5] = WRAR_reg_in[5];// BC_NV
                            CR3_V[5]  = WRAR_reg_in[5];// BC_V
                        end

                        if (CR3_NV[4] == 1'b0)
                        begin
                            CR3_NV[4] = WRAR_reg_in[4];// 02h_NV
                            CR3_V[4]  = WRAR_reg_in[4];// 02h_V
                            change_PageSize = 1'b1;
                            #1 change_PageSize = 1'b0;
                        end

                        if (CR3_NV[3] == 1'b0)
                        begin
                            CR3_NV[3] = WRAR_reg_in[3];// 20_NV
                            CR3_V[3]  = WRAR_reg_in[3];// 20_V
                        end

                        if (CR3_NV[2] == 1'b0)
                        begin
                            CR3_NV[2] = WRAR_reg_in[2];// 30_NV
                            CR3_V[2]  = WRAR_reg_in[2];// 30_V
                        end

                        if (CR3_NV[1] == 1'b0)
                        begin
                            CR3_NV[1] = WRAR_reg_in[1];// D8h_NV
                            CR3_V[1]  = WRAR_reg_in[1];// D8h_V
                        end

                        if (CR3_NV[0] == 1'b0)
                        begin
                            CR3_NV[0] = WRAR_reg_in[0];// F0_NV
                            CR3_V[0]  = WRAR_reg_in[0];// F0_V
                        end
                    end
                    else if (Addr == 32'h00000005) // CR4_NV
                    begin
                        if (CR4_NV[7:5] == 3'b000)
                        begin
                            CR4_NV[7:5] = WRAR_reg_in[7:5];// OI_O[2:0]
                            CR4_V[7:5]  = WRAR_reg_in[7:5];// OI[2:0]
                        end

                        if (CR4_NV[4] == 1'b0)
                        begin
                            CR4_NV[4] = WRAR_reg_in[4];// WE_O
                            CR4_V[4]  = WRAR_reg_in[4];// WE
                        end

                        if (CR4_NV[1:0] == 2'b00)
                        begin
                            CR4_NV[1:0] = WRAR_reg_in[1:0];// WL_O[1:0]
                            CR4_V[1:0]  = WRAR_reg_in[1:0];// WL[1:0]
                        end
                    end
                    else if (Addr == 32'h00000010)
                    // NVDLR_reg;
                    begin
                        if (NVDLR_reg == 0)
                        begin
                            NVDLR_reg = WRAR_reg_in;
                            VDLR_reg  = WRAR_reg_in;
                        end
                        else
                            $display("NVDLR bits allready programmed");
                    end
                    else if (Addr == 32'h00000020)
                    // Password_reg[7:0];
                    begin
                        Password_reg[7:0] = new_pass_byte;
                    end
                    else if (Addr == 32'h00000021)
                    // Password_reg[15:8];
                    begin
                        Password_reg[15:8] = new_pass_byte;
                    end
                    else if (Addr == 32'h00000022)
                    // Password_reg[23:16];
                    begin
                        Password_reg[23:16] = new_pass_byte;
                    end
                    else if (Addr == 32'h00000023)
                    // Password_reg[31:24];
                    begin
                        Password_reg[31:24] = new_pass_byte;
                    end
                    else if (Addr == 32'h00000024)
                    // Password_reg[39:32];
                    begin
                        Password_reg[39:32] = new_pass_byte;
                    end
                    else if (Addr == 32'h00000025)
                    // Password_reg[47:40];
                    begin
                        Password_reg[47:40] = new_pass_byte;
                    end
                    else if (Addr == 32'h00000026)
                    // Password_reg[55:48];
                    begin
                        Password_reg[55:48] = new_pass_byte;
                    end
                    else if (Addr == 32'h00000027)
                    // Password_reg[63:56];
                    begin
                        Password_reg[63:56] = new_pass_byte;
                    end
                    else if (Addr == 32'h00000030) // ASP_reg[7:0]
                    begin
                        if (SECURE_OPN == 1)
                        begin
                            if (DYBLBB == 1'b0 && WRAR_reg_in[4] == 1'b1)
                                $display("DYBLBB bit is allready programmed");
                            else
                                ASP_reg[4] = WRAR_reg_in[4];//DYBLBB

                            if (PPBOTP == 1'b0 && WRAR_reg_in[3] == 1'b1)
                                $display("PPBOTP bit is allready programmed");
                            else
                                ASP_reg[3] = WRAR_reg_in[3];//PPBOTP

                            if (PERMLB == 1'b0 && WRAR_reg_in[0] == 1'b1)
                                $display("PERMLB bit is allready programmed");
                            else
                                ASP_reg[0] = WRAR_reg_in[0];//PERMLB
                        end

                        ASP_reg[2] = WRAR_reg_in[2];//PWDMLB
                        ASP_reg[1] = WRAR_reg_in[1];//PSTMLB
                    end
                    else if (Addr == 32'h00000031)
                    // ASP_reg[15:8];
                    begin
                        $display("RFU bits");
                    end
                    else if (Addr == 32'h00800000) // SR1_V
                    begin
                        //SRWD bit
                        SR1_V [7] = WRAR_reg_in[7];

                        if ((~LOCK_O && (SECURE_OPN == 1)) || (SECURE_OPN == 0))
                        begin
                            if (FREEZE == 0)
                            //The Freeze Bit, when set to 1, locks the current
                            //state of the BP2-0 bits in Status Register.
                            begin
                                if (BPNV_O == 1)
                                begin
                                    SR1_V[4]  = WRAR_reg_in[4];//BP2
                                    SR1_V[3]  = WRAR_reg_in[3];//BP1
                                    SR1_V[2]  = WRAR_reg_in[2];//BP0

                                    BP_bits = {SR1_V[4],SR1_V[3],SR1_V[2]};

                                    change_BP    = 1'b1;
                                    #1 change_BP = 1'b0;
                                end
                            end
                        end
                    end
                    else if (Addr == 32'h00800001) // SR2_V
                    begin
                        $display("Status Register 2 does not have user ");
                        $display("programmable bits, all defined bits are  ");
                        $display("volatile read only status.");
                    end
                    else if (Addr == 32'h00800002) // CR1_V
                    begin
                        if (~QUAD_ALL)
                        begin
                        // While Quad All mode is selected (CR2NV[1]=1 or
                        // CR2V[1]=1) the QUAD bit cannot be cleared to 0.
                            CR1_V[1]  = WRAR_reg_in[1]; //QUAD
                        end

                        if (FREEZE == 1'b0)
                        begin
                            CR1_V[0] = WRAR_reg_in[0];// FREEZE
                        end
                    end
                    else if (Addr == 32'h00800003) // CR2_V
                    begin
                        CR2_V[7]   = WRAR_reg_in[7];  // AL
                        CR2_V[6]   = WRAR_reg_in[6];  // QA
                        if (WRAR_reg_in[6] == 1'b1)
                            CR1_V[1]  = 1'b1;         // QUAD
                        CR2_V[5]   = WRAR_reg_in[5];  // IO3R_S
                        CR2_V[3:0] = WRAR_reg_in[3:0];// RL[3:0]
                    end
                    else if (Addr == 32'h00800004) // CR3_V
                    begin
                        CR3_V[5]  = WRAR_reg_in[5];// BC_V
                        CR3_V[4]  = WRAR_reg_in[4];// 02h_V
                        CR3_V[3]  = WRAR_reg_in[3];// 20_V
                        CR3_V[2]  = WRAR_reg_in[2];// 30_V
                        CR3_V[1]  = WRAR_reg_in[1];// D8h_V
                        CR3_V[0]  = WRAR_reg_in[0];// F0_V

                        change_PageSize = 1'b1;
                        #1 change_PageSize = 1'b0;

                    end
                    else if (Addr == 32'h00800005) // CR4_V
                    begin
                        CR4_V[7:5]  = WRAR_reg_in[7:5];// OI[2:0]
                        CR4_V[4]    = WRAR_reg_in[4];  // WE
                        CR4_V[1:0]  = WRAR_reg_in[1:0];// WL[1:0]
                    end
                    else if (Addr == 32'h00800010) // VDLR_reg
                    begin
                        VDLR_reg  = WRAR_reg_in;
                    end
                end
            end

            PAGE_PG :
            begin
                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if(current_state_event && current_state == PAGE_PG)
                begin
                    if (~PDONE)
                    begin
                        ADDRHILO_PG(AddrLo, AddrHi, Addr);
                        cnt = 0;

                        for (i=0;i<=wr_cnt;i=i+1)
                        begin
                            new_int = WData[i];
                            old_int = Mem[Addr + i - cnt];
                            if (new_int > -1)
                            begin
                                new_bit = new_int;
                                if (old_int > -1)
                                begin
                                    old_bit = old_int;
                                    for(j=0;j<=7;j=j+1)
                                    begin
                                        if (~old_bit[j])
                                            new_bit[j]=1'b0;
                                    end
                                    new_int=new_bit;
                                end
                                WData[i]= new_int;
                            end
                            else
                            begin
                                WData[i] = -1;
                            end

                            Mem[Addr + i - cnt] = - 1;
                            if ((Addr + i) == AddrHi)
                            begin
                                Addr = AddrLo;
                                cnt = i + 1;
                            end
                        end
                    end
                    cnt = 0;
                end

                if (PDONE)
                begin
                    SR1_V[0] = 1'b0; //WIP
                    SR1_V[1] = 1'b0; //WEL

                    for (i=0;i<=wr_cnt;i=i+1)
                    begin
                        Mem[Addr_tmp + i - cnt] = WData[i];
                        if ((Addr_tmp + i) == AddrHi)
                        begin
                            Addr_tmp = AddrLo;
                            cnt = i + 1;
                        end
                    end
                end

                if (falling_edge_write)
                begin
                    if (Instruct == EPS && ~PRGSUSP_in)
                    begin
                        if (~RES_TO_SUSP_TIME)
                        begin
                            PGSUSP = 1'b1;
                            PGSUSP <= #5 1'b0;
                            PRGSUSP_in = 1'b1;
                        end
                        else
                        begin
                            $display("Minimum for tRS is not satisfied! ",
                                     "PGSP command is ignored");
                        end
                    end
                end
            end

            PG_SUSP:
            begin
                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (PRGSUSP_out && PRGSUSP_in)
                begin
                    PRGSUSP_in = 1'b0;
                    //The WIP bit in the Status Register will indicate that
                    //the device is ready for another operation.
                    SR1_V[0] = 1'b0;
                    //The Program Suspend (PS) bit in the Status Register will
                    //be set to the logical “1” state to indicate that the
                    //program operation has been suspended.
                    SR2_V[0] = 1'b1;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == READ || Instruct == READ4)
                    begin
                        //Read Memory array
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;

                        if (pgm_page != read_addr / (PageSize+1))
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO  = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO  = 8'bxxxxxxxx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == FAST_READ || Instruct == FAST_READ4)
                    begin

                        if (pgm_page != read_addr / (PageSize+1))
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO  = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO  = 8'bxxxxxxxx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                    end
                    else if (Instruct == DIOR || Instruct == DIOR4)
                    begin
                        //Read Memory array
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;

                        if (pgm_page != read_addr / (PageSize+1))
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO = data_out[7-2*read_cnt];
                            DataDriveOut_SI = data_out[6-2*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO  = 1'bx;
                            DataDriveOut_SI  = 1'bx;

                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                    end
                    else if ((Instruct == QIOR    || Instruct == QIOR4 ||
                              Instruct == DDRQIOR || Instruct == DDRQIOR4) &&
                              QUAD)
                    begin
                        //Read Memory array
                        if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end

                        if (pgm_page != read_addr / (PageSize+1))
                        begin
                            if (bus_cycle_state == DUMMY_BYTES)
                            begin
                                if ((Instruct==DDRQIOR || Instruct==DDRQIOR4) &&
                                     QUAD)
                                begin
                                    Return_DLP(Latency_code,dummy_cnt, dlp_act);
                                    // Data Learning Pattern (DLP) is enabled
                                    // Optional DLP
                                    if (VDLR_reg!=8'b00000000 && dlp_act==1'b1)
                                    begin
                                        DataDriveOut_RESET =
                                                           VDLR_reg[7-read_cnt];
                                        DataDriveOut_WP    =
                                                           VDLR_reg[7-read_cnt];
                                        DataDriveOut_SO    =
                                                           VDLR_reg[7-read_cnt];
                                        DataDriveOut_SI    =
                                                           VDLR_reg[7-read_cnt];
                                        dlp_act = 1'b0;
                                        read_cnt = read_cnt + 1;
                                        if (read_cnt == 8)
                                        begin
                                            read_cnt = 0;
                                        end
                                    end
                                end
                            end
                            else
                            begin
                                data_out[7:0]  = Mem[read_addr];
                                DataDriveOut_RESET = data_out[7-4*read_cnt];
                                DataDriveOut_WP    = data_out[6-4*read_cnt];
                                DataDriveOut_SO    = data_out[5-4*read_cnt];
                                DataDriveOut_SI    = data_out[4-4*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 2)
                                begin
                                    read_cnt = 0;

                                    if (~CR4_V[4])  //Wrap Disabled
                                    begin
                                        if (read_addr == AddrRANGE)
                                            read_addr = 0;
                                        else
                                            read_addr = read_addr + 1;
                                    end
                                    else           //Wrap Enabled
                                    begin
                                        read_addr = read_addr + 1;

                                        if (read_addr % WrapLength == 0)
                                            read_addr = read_addr - WrapLength;
                                    end
                                end
                            end
                        end
                        else
                        begin
                            DataDriveOut_RESET = 1'bx;
                            DataDriveOut_WP    = 1'bx;
                            DataDriveOut_SO    = 1'bx;
                            DataDriveOut_SI    = 1'bx;

                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                    end
                end
                else if (oe_z)
                begin
                    if (Instruct == READ || Instruct == READ4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DIOR || Instruct == DIOR4 ||
                             Instruct == QIOR || Instruct == QIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else
                    begin
                        if (QUAD_ALL)
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                    end
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if (falling_edge_write)
                begin
                    if (Instruct == EPR)
                    begin
                        SR2_V[0] = 1'b0; // PS
                        SR1_V[0] = 1'b1; // WIP
                        PGRES  = 1'b1;
                        PGRES <= #5 1'b0;
                        RES_TO_SUSP_TIME = 1'b1;
                        RES_TO_SUSP_TIME <= #tdevice_RS 1'b0;//100us
                    end
                    else if (Instruct == CLSR)
                    begin
                        SR1_V[6] = 0;// P_ERR
                        SR1_V[5] = 0;// E_ERR
                        SR1_V[0] = 0;// WIP
                    end

                    if (Instruct == RSTEN)
                    begin
                        RESET_EN = 1;
                    end
                    else
                    begin
                        RESET_EN <= 0;
                    end
                end
            end

            OTP_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        DataDriveOut_SO = SR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        DataDriveOut_SO = RDAR_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if(current_state_event && current_state == OTP_PG)
                begin
                    if (~PDONE)
                    begin

                        for (i=0;i<=wr_cnt;i=i+1)
                        begin
                            new_int = WData[i];
                            old_int = OTPMem[Addr + i];
                            if (new_int > -1)
                            begin
                                new_bit = new_int;
                                if (old_int > -1)
                                begin
                                    old_bit = old_int;
                                    for(j=0;j<=7;j=j+1)
                                    begin
                                        if (~old_bit[j])
                                            new_bit[j] = 1'b0;
                                    end
                                    new_int = new_bit;
                                end
                                WData[i] = new_int;
                            end
                            else
                            begin
                                WData[i] = -1;
                            end
                            OTPMem[Addr + i] =  -1;
                        end
                    end
                end

                if (PDONE)
                begin
                    SR1_V[0] = 1'b0; // WIP
                    SR1_V[1] = 1'b0; // WEL

                    for (i=0;i<=wr_cnt;i=i+1)
                    begin
                        OTPMem[Addr + i] = WData[i];
                    end
                    LOCK_BYTE1 = OTPMem[16];
                    LOCK_BYTE2 = OTPMem[17];
                    LOCK_BYTE3 = OTPMem[18];
                    LOCK_BYTE4 = OTPMem[19];
                end
            end

            SECTOR_ERS:
            begin
                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if(current_state_event && current_state == SECTOR_ERS)
                begin
                    if (~EDONE)
                    begin
						if (!CR3_V[1])
						begin
							ADDRHILO_SEC(AddrLo, AddrHi, Addr_ers);
							for (i=AddrLo;i<=AddrHi;i=i+1)
							begin
								Mem[i] = -1;
							end
						end
						else
						begin
							ADDRHILO_BLK(AddrLo, AddrHi, Addr_ers);
							for (i=AddrLo;i<=AddrHi;i=i+1)
							begin
								Mem[i] = -1;
							end
						end
                    end
                end

                if (EDONE == 1)
                begin
                    SR1_V[0] = 1'b0; //WIP
                    SR1_V[1] = 1'b0; //WEL

					if (!CR3_V[1])
					begin
						ADDRHILO_SEC(AddrLo, AddrHi, Addr_ers);
                    	ERS_nosucc[SectorErased] = 1'b0;
						for (i=AddrLo;i<=AddrHi;i=i+1)
							Mem[i] = MaxData;
					end
					else
					begin
						ADDRHILO_BLK(AddrLo, AddrHi, Addr_ers);
                    	ERS_nosucc_b[BlockErased] = 1'b0;
						for (i=AddrLo;i<=AddrHi;i=i+1)
							Mem[i] = MaxData;
					end
                end

                if (falling_edge_write)
                begin
                    if (Instruct == EPS && ~ERSSUSP_in)
                    begin
                        if (~RES_TO_SUSP_TIME)
                        begin
                            ESUSP      = 1'b1;
                            ESUSP     <= #5 1'b0;
                            ERSSUSP_in = 1'b1;
                        end
                        else
                        begin
                            $display("Minimum for tRS is not satisfied! ",
                                     "PGSP command is ignored");
                        end
                    end
                end
            end

            BULK_ERS:
            begin
                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if(current_state_event && current_state == BULK_ERS)
                begin
                    if (~EDONE)
                    begin
                        for (i=0;i<=AddrRANGE;i=i+1)
                        begin
                            ReturnSectorID(sect,i);
                            if (PPB_bits[sect] == 1 && DYB_bits[sect] == 1)
                            begin
                                Mem[i] = -1;
                            end
                        end
                    end
                end

                if (EDONE == 1)
                begin
                    SR1_V[0] = 1'b0; // WIP
                    SR1_V[1] = 1'b0; // WEL
                    for (i=0;i<=AddrRANGE;i=i+1)
                    begin
                        ReturnSectorID(sect,i);
                        if (PPB_bits[sect] == 1 && DYB_bits[sect] == 1)
                        begin
                            Mem[i] = MaxData;
                        end
                    end
                end
            end

            ERS_SUSP:
            begin
                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (ERSSUSP_out)
                begin
                    ERSSUSP_in = 0;
                    //The Erase Suspend (ES) bit in the Status Register will
                    //be set to the logical “1” state to indicate that the
                    //erase operation has been suspended.
                    SR2_V[1] = 1'b1;
                    //The WIP bit in the Status Register will indicate that
                    //the device is ready for another operation.
                    SR1_V[0] = 1'b0;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == READ || Instruct == READ4)
                    begin
                        //Read Memory array
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        ReturnSectorID(sect,read_addr);
                        ReturnBlockID(block_e,read_addr);
                        if ((sect != SectorErased && !CR3_V[1]) ||
							(block_e != BlockErased && CR3_V[1]))
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO  = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO  = 8'bxxxxxxxx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == FAST_READ || Instruct == FAST_READ4)
                    begin

                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b0;
                        ddr     = 1'b0;

                        ReturnSectorID(sect,read_addr);
                        ReturnBlockID(block_e,read_addr);
                        if ((sect != SectorErased && !CR3_V[1]) ||
							(block_e != BlockErased && CR3_V[1]))
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO  = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO  = 8'bxxxxxxxx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                    end
                    else if (Instruct == DIOR || Instruct == DIOR4)
                    begin
                        //Read Memory array
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;

                        ReturnSectorID(sect,read_addr);
                        ReturnBlockID(block_e,read_addr);
                        if ((sect != SectorErased && !CR3_V[1]) ||
							(block_e != BlockErased && CR3_V[1]))
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO = data_out[7-2*read_cnt];
                            DataDriveOut_SI = data_out[6-2*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = 1'bx;
                            DataDriveOut_SI = 1'bx;

                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                    end
                    else if ((Instruct == QIOR    || Instruct == QIOR4 ||
                              Instruct == DDRQIOR || Instruct == DDRQIOR4) &&
                              QUAD)
                    begin
                        //Read Memory array
                        if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end

                        ReturnSectorID(sect,read_addr);
                        ReturnBlockID(block_e,read_addr);
                        if ((sect != SectorErased && !CR3_V[1]) ||
							(block_e != BlockErased && CR3_V[1]))
                        begin
                            if (bus_cycle_state == DUMMY_BYTES)
                            begin
                                if ((Instruct==DDRQIOR || Instruct==DDRQIOR4) &&
                                     QUAD)
                                begin
                                    Return_DLP(Latency_code,dummy_cnt, dlp_act);
                                    // Data Learning Pattern (DLP) is enabled
                                    // Optional DLP
                                    if (VDLR_reg!=8'b00000000 && dlp_act==1'b1)
                                    begin
                                        DataDriveOut_RESET =
                                                           VDLR_reg[7-read_cnt];
                                        DataDriveOut_WP    =
                                                           VDLR_reg[7-read_cnt];
                                        DataDriveOut_SO    =
                                                           VDLR_reg[7-read_cnt];
                                        DataDriveOut_SI    =
                                                           VDLR_reg[7-read_cnt];
                                        dlp_act = 1'b0;
                                        read_cnt = read_cnt + 1;
                                        if (read_cnt == 8)
                                        begin
                                            read_cnt = 0;
                                        end
                                    end
                                end
                            end
                            else
                            begin
                                data_out[7:0]  = Mem[read_addr];
                                DataDriveOut_RESET = data_out[7-4*read_cnt];
                                DataDriveOut_WP    = data_out[6-4*read_cnt];
                                DataDriveOut_SO    = data_out[5-4*read_cnt];
                                DataDriveOut_SI    = data_out[4-4*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 2)
                                begin
                                    read_cnt = 0;

                                    if (~CR4_V[4])  //Wrap Disabled
                                    begin
                                        if (read_addr == AddrRANGE)
                                            read_addr = 0;
                                        else
                                            read_addr = read_addr + 1;
                                    end
                                    else           //Wrap Enabled
                                    begin
                                        read_addr = read_addr + 1;

                                        if (read_addr % WrapLength == 0)
                                            read_addr = read_addr - WrapLength;
                                    end
                                end
                            end
                        end
                        else
                        begin
                            DataDriveOut_RESET = 1'bx;
                            DataDriveOut_WP    = 1'bx;
                            DataDriveOut_SO    = 1'bx;
                            DataDriveOut_SI    = 1'bx;

                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                    end
                    else if (Instruct == DYBRD || Instruct == DYBRD4)
                    begin
                    //Read DYB Access Register
                        ReturnSectorID(sect,Address);

                        if (DYB_bits[sect] == 1)
                            DYBAR[7:0] = 8'hFF;
                        else
                        begin
                            DYBAR[7:0] = 8'h0;
                        end

                        if (QUAD_ALL)
                        begin

                            DataDriveOut_RESET = DYBAR[7-4*read_cnt];
                            DataDriveOut_WP    = DYBAR[6-4*read_cnt];
                            DataDriveOut_SO    = DYBAR[5-4*read_cnt];
                            DataDriveOut_SI    = DYBAR[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                                read_cnt = 0;
                        end
                        else
                        begin
                            DataDriveOut_SO = DYBAR[7-read_cnt];
                            read_cnt  = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == PPBRD || Instruct == PPBRD4)
                    begin
                    //Read PPB Access Register
                        ReturnSectorID(sect,Address);

                        if (PPB_bits[sect] == 1)
                            PPBAR[7:0] = 8'hFF;
                        else
                        begin
                            PPBAR[7:0] = 8'h0;
                        end

                        DataDriveOut_SO = PPBAR[7-read_cnt];
                        read_cnt  = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    if (Instruct == READ || Instruct == READ4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DIOR || Instruct == DIOR4 ||
                             Instruct == QIOR || Instruct == QIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else
                    begin
                        if (QUAD_ALL)
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                    end
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if (falling_edge_write)
                begin
                    if (Instruct == EPR)
                    begin
                        SR2_V[1] = 1'b0; // ES
                        SR1_V[0] = 1'b1; // WIP

                        ERES = 1'b1;
                        ERES <= #5 1'b0;
                        RES_TO_SUSP_TIME = 1'b1;
                        RES_TO_SUSP_TIME <= #tdevice_RS 1'b0;//100us
                    end
                    else if ((Instruct==PP || Instruct==PP4) && WEL && ~P_ERR)
                    begin
                        ReturnSectorID(sect,Address);
                        ReturnBlockID(block_e,Address);

                        if (((SectorErased != sect) && !CR3_V[1]) ||
							((BlockErased != block_e) && CR3_V[1]))
                        begin
                            if (Sec_Prot[sect]== 0 && PPB_bits[sect]== 1 &&
                                DYB_bits[sect]== 1)
                            begin
                                PSTART = 1'b1;
                                PSTART <= #5 1'b0;
                                PGSUSP  = 0;
                                PGRES   = 0;
                                SR1_V[0] = 1'b1;//WIP
                                Addr     = Address;
                                Addr_tmp = Address;
                                wr_cnt   = Byte_number;
                                for (i=wr_cnt;i>=0;i=i-1)
                                begin
                                    if (Viol != 0)
                                        WData[i] = -1;
                                    else
                                        WData[i] = WByte[i];
                                end
                            end
                            else
                            begin
                                SR1_V[1] = 1'b1;// WIP
                                SR1_V[6] = 1'b1;// P_ERR
                            end
                        end
                        else
                        begin
                            SR1_V[1] = 1'b1;// WIP
                            SR1_V[6] = 1'b1;// P_ERR
                        end
                    end
                    else if ((Instruct==DYBWR || Instruct==DYBWR4) && WEL)
                    begin
                        if (DYBAR_in == 8'hFF || DYBAR_in == 8'h00)
                        begin
                            ReturnSectorID(sect,Address);
                            ReturnBlockID(block_e,Address);
                            PSTART   = 1'b1;
                            PSTART  <= #5 1'b0;
                            SR1_V[0] = 1'b1;// WIP
                        end
                        else
                        begin
                            SR1_V[6] = 1'b1;// P_ERR
                            SR1_V[0] = 1'b1;// WIP
                        end
                    end
                    else if (Instruct == WREN)
                        SR1_V[1] = 1'b1; //WEL
                    else if (Instruct == CLSR)
                    begin
                        SR1_V[6] = 0;// P_ERR
                        SR1_V[5] = 0;// E_ERR
                        SR1_V[0] = 0;// WIP
                    end

                    if (Instruct == RSTEN)
                    begin
                        RESET_EN = 1;
                    end
                    else
                    begin
                        RESET_EN <= 0;
                    end
                end
            end

            ERS_SUSP_PG:
            begin
                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if(current_state_event && current_state == ERS_SUSP_PG)
                begin
                    if (~PDONE)
                    begin
                        ADDRHILO_PG(AddrLo, AddrHi, Addr);
                        cnt = 0;
                        for (i=0;i<=wr_cnt;i=i+1)
                        begin
                            new_int = WData[i];
                            old_int = Mem[Addr + i - cnt];
                            if (new_int > -1)
                            begin
                                new_bit = new_int;
                                if (old_int > -1)
                                begin
                                    old_bit = old_int;
                                    for(j=0;j<=7;j=j+1)
                                    begin
                                        if (~old_bit[j])
                                            new_bit[j] = 1'b0;
                                    end
                                    new_int = new_bit;
                                end
                                WData[i] = new_int;
                            end
                            else
                            begin
                                WData[i] = -1;
                            end

                            if ((Addr + i) == AddrHi)
                            begin
                                Addr = AddrLo;
                                cnt = i + 1;
                            end
                        end
                    end
                    cnt =0;
                end

                if (PDONE)
                begin
                    SR1_V[0] = 1'b0; //WIP
                    SR1_V[1] = 1'b0; //WEL

                    for (i=0;i<=wr_cnt;i=i+1)
                    begin
                        Mem[Addr_tmp + i - cnt] = WData[i];
                        if ((Addr_tmp + i) == AddrHi)
                        begin
                            Addr_tmp = AddrLo;
                            cnt = i + 1;
                        end
                    end
                end

                if (falling_edge_write)
                begin
                    if (Instruct == EPS && ~PRGSUSP_in)
                    begin
                        if (~RES_TO_SUSP_TIME)
                        begin
                            PGSUSP = 1'b1;
                            PGSUSP <= #5 1'b0;
                            PRGSUSP_in = 1'b1;
                        end
                        else
                        begin
                            $display("Minimum for tRS is not satisfied! ",
                                     "PGSP command is ignored");
                        end
                    end
                end
            end

            ERS_SUSP_PG_SUSP:
            begin
                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (PRGSUSP_out && PRGSUSP_in)
                begin
                    PRGSUSP_in = 1'b0;
                    //The WIP bit in the Status Register will indicate that
                    //the device is ready for another operation.
                    SR1_V[0] = 1'b0;
                    //The Program Suspend (PS) bit in the Status Register will
                    //be set to the logical “1” state to indicate that the
                    //program operation has been suspended.
                    SR2_V[0] = 1'b1;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == READ || Instruct == READ4)
                    begin
                        //Read Memory array
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                        ReturnSectorID(sect,read_addr);
                        ReturnBlockID(block_e,read_addr);
                        if (((sect != SectorErased && !CR3_V[1]) ||
							(block_e != BlockErased && CR3_V[1])) &&
                            pgm_page != read_addr / (PageSize+1))
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO  = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO  = 8'bxxxxxxxx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;
                                if (read_addr == AddrRANGE)
                                    read_addr = 0;
                                else
                                    read_addr = read_addr + 1;
                            end
                        end
                    end
                    else if (Instruct == FAST_READ || Instruct == FAST_READ4)
                    begin

                        ReturnSectorID(sect,read_addr);
                        ReturnBlockID(block_e,read_addr);
                        if (((sect != SectorErased && !CR3_V[1]) ||
							(block_e != BlockErased && CR3_V[1])) &&
                            pgm_page != read_addr / (PageSize+1))
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO  = data_out[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO  = 8'bxxxxxxxx;
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                    end
                    else if (Instruct == DIOR || Instruct == DIOR4)
                    begin
                        //Read Memory array
                        rd_fast = 1'b1;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;

                        ReturnSectorID(sect,read_addr);
                        ReturnBlockID(block_e,read_addr);
                        if (((sect != SectorErased && !CR3_V[1]) ||
							(block_e != BlockErased && CR3_V[1])) &&
                            pgm_page != read_addr / (PageSize+1))
                        begin
                            data_out[7:0] = Mem[read_addr];
                            DataDriveOut_SO = data_out[7-2*read_cnt];
                            DataDriveOut_SI = data_out[6-2*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = 1'bx;
                            DataDriveOut_SI = 1'bx;

                            read_cnt = read_cnt + 1;
                            if (read_cnt == 4)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                    end
                    else if ((Instruct == QIOR    || Instruct == QIOR4 ||
                              Instruct == DDRQIOR || Instruct == DDRQIOR4) &&
                              QUAD)
                    begin
                        //Read Memory array
                        if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b1;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end

                        ReturnSectorID(sect,read_addr);
                        ReturnBlockID(block_e,read_addr);
                        if (((sect != SectorErased && !CR3_V[1]) ||
							(block_e != BlockErased && CR3_V[1])) &&
                            pgm_page != read_addr / (PageSize+1))
                        begin
                            if (bus_cycle_state == DUMMY_BYTES)
                            begin
                                if ((Instruct==DDRQIOR || Instruct==DDRQIOR4) &&
                                     QUAD)
                                begin
                                    Return_DLP(Latency_code,dummy_cnt, dlp_act);
                                    // Data Learning Pattern (DLP) is enabled
                                    // Optional DLP
                                    if (VDLR_reg!=8'b00000000 && dlp_act==1'b1)
                                    begin
                                        DataDriveOut_RESET =
                                                           VDLR_reg[7-read_cnt];
                                        DataDriveOut_WP    =
                                                           VDLR_reg[7-read_cnt];
                                        DataDriveOut_SO    =
                                                           VDLR_reg[7-read_cnt];
                                        DataDriveOut_SI    =
                                                           VDLR_reg[7-read_cnt];
                                        dlp_act = 1'b0;
                                        read_cnt = read_cnt + 1;
                                        if (read_cnt == 8)
                                        begin
                                            read_cnt = 0;
                                        end
                                    end
                                end
                            end
                            else
                            begin
                                data_out[7:0]  = Mem[read_addr];
                                DataDriveOut_RESET = data_out[7-4*read_cnt];
                                DataDriveOut_WP    = data_out[6-4*read_cnt];
                                DataDriveOut_SO    = data_out[5-4*read_cnt];
                                DataDriveOut_SI    = data_out[4-4*read_cnt];
                                read_cnt = read_cnt + 1;
                                if (read_cnt == 2)
                                begin
                                    read_cnt = 0;

                                    if (~CR4_V[4])  //Wrap Disabled
                                    begin
                                        if (read_addr == AddrRANGE)
                                            read_addr = 0;
                                        else
                                            read_addr = read_addr + 1;
                                    end
                                    else           //Wrap Enabled
                                    begin
                                        read_addr = read_addr + 1;

                                        if (read_addr % WrapLength == 0)
                                            read_addr = read_addr - WrapLength;
                                    end
                                end
                            end
                        end
                        else
                        begin
                            DataDriveOut_RESET = 1'bx;
                            DataDriveOut_WP    = 1'bx;
                            DataDriveOut_SO    = 1'bx;
                            DataDriveOut_SI    = 1'bx;

                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;

                                if (~CR4_V[4])  //Wrap Disabled
                                begin
                                    if (read_addr == AddrRANGE)
                                        read_addr = 0;
                                    else
                                        read_addr = read_addr + 1;
                                end
                                else           //Wrap Enabled
                                begin
                                    read_addr = read_addr + 1;

                                    if (read_addr % WrapLength == 0)
                                        read_addr = read_addr - WrapLength;
                                end
                            end
                        end
                    end
                end
                else if (oe_z)
                begin
                    if (Instruct == READ || Instruct == READ4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b1;
                        dual    = 1'b0;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DIOR || Instruct == DIOR4 ||
                             Instruct == QIOR || Instruct == QIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b0;
                    end
                    else if (Instruct == DDRQIOR || Instruct == DDRQIOR4)
                    begin
                        rd_fast = 1'b0;
                        rd_slow = 1'b0;
                        dual    = 1'b1;
                        ddr     = 1'b1;
                    end
                    else
                    begin
                        if (QUAD_ALL)
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b1;
                            ddr     = 1'b0;
                        end
                        else
                        begin
                            rd_fast = 1'b1;
                            rd_slow = 1'b0;
                            dual    = 1'b0;
                            ddr     = 1'b0;
                        end
                    end
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if (falling_edge_write)
                begin
                    if (Instruct == EPR)
                    begin
                        SR2_V[0] = 1'b0; // PS
                        SR1_V[0] = 1'b1; // WIP
                        PGRES  = 1'b1;
                        PGRES <= #5 1'b0;
                        RES_TO_SUSP_TIME = 1'b1;
                        RES_TO_SUSP_TIME <= #tdevice_RS 1'b0;//100us
                    end
                    else if (Instruct == CLSR)
                    begin
                        SR1_V[6] = 0;// P_ERR
                        SR1_V[5] = 0;// E_ERR
                        SR1_V[0] = 0;// WIP
                    end

                    if (Instruct == RSTEN)
                    begin
                        RESET_EN = 1;
                    end
                    else
                    begin
                        RESET_EN <= 0;
                    end
                end
            end

            PASS_PG:
            begin

                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        DataDriveOut_SO = SR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        DataDriveOut_SO = RDAR_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_SO    = 1'bZ;
                end

                new_pass = Password_reg_in;
                old_pass = Password_reg;
                for (i=0;i<=63;i=i+1)
                begin
                    if (old_pass[j] == 0)
                        new_pass[j] = 0;
                end

                if (PDONE)
                begin
                    Password_reg = new_pass;
                    SR1_V[0] = 1'b0; //WIP
                    SR1_V[1] = 1'b0; //WEL
                end
            end

            PASS_UNLOCK:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        DataDriveOut_SO = SR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        DataDriveOut_SO = RDAR_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_SO    = 1'bZ;
                end

                if (PASS_TEMP == Password_reg)
                begin
                    PASS_UNLOCKED = 1'b1;
                end
                else
                begin
                    PASS_UNLOCKED = 1'b0;
                end
                if (PASSULCK_out)
                begin
                    if ((PASS_UNLOCKED == 1'b1) && (~PWDMLB))
                    begin
                        PPBL [0] = 1'b1;
                        SR1_V[0] = 1'b0; //WIP
                    end
                    else
                    begin
                        SR1_V[6] = 1'b1; //P_ERR
                        SR1_V[0] = 1'b1; //WIP
                        $display ("Incorrect Password");
                        PASSACC_in = 1'b1;
                    end
                    PASSULCK_in = 1'b0;
                end
            end

            PPB_PG:
            begin

                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        DataDriveOut_SO = SR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        DataDriveOut_SO = RDAR_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;

                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_SO    = 1'bZ;
                end

                if (PDONE)
                begin
                    PPB_bits[sect]= 1'b0;
                    PPB_bits_b[block_e]= 1'b0;
                    SR1_V[0] = 1'b0;
                    SR1_V[1] = 1'b0;
                end
            end

            PPB_ERS:
            begin

                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        DataDriveOut_SO = SR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        DataDriveOut_SO = RDAR_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;

                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_SO    = 1'bZ;
                end

                if (PPBERASE_out)
                begin

                    PPB_bits = {520{1'b1}};
                    PPB_bits_b[block_e]= {136{1'b1}};

                    SR1_V[0] = 1'b0;
                    SR1_V[1] = 1'b0;
                    PPBERASE_in = 1'b0;
                end
            end

            PLB_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        DataDriveOut_SO = SR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        DataDriveOut_SO = RDAR_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_SO    = 1'bZ;
                end

                if (PDONE)
                begin
                    PPBL[0] = 1'b0;
                    SR1_V[0] = 1'b0; //WIP
                    SR1_V[1] = 1'b0; //WEL
                end
            end

            DYB_PG:
            begin
                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDSR2)
                    begin

                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if (PDONE)
                begin
                    DYBAR = DYBAR_in;
                    if (DYBAR == 8'hFF)
                    begin
                        DYB_bits[sect]= 1'b1;
                        DYB_bits_b[block_e]= 1'b1;
                    end
                    else if (DYBAR == 8'h00)
                    begin
                        DYB_bits[sect]= 1'b0;
                        DYB_bits_b[block_e]= 1'b0;
                    end

                    SR1_V[0] = 1'b0;
                    SR1_V[1] = 1'b0;
                end
            end

            ASP_PG:
            begin
                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        DataDriveOut_SO = SR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        DataDriveOut_SO = RDAR_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_SO    = 1'bZ;
                end

                if (PDONE)
                begin
                    if(SECURE_OPN == 1)
                    begin
                        if (DYBLBB == 1'b0 && ASP_reg_in[4] == 1'b1)
                            $display("DYBLBB bit is allready programmed");
                        else
                            ASP_reg[4] = ASP_reg_in[4];//DYBLBB

                        if (PPBOTP == 1'b0 && ASP_reg_in[3] == 1'b1)
                            $display("PPBOTP bit is allready programmed");
                        else
                            ASP_reg[3] = ASP_reg_in[3];//PPBOTP

                        if (PERMLB == 1'b0 && ASP_reg_in[0] == 1'b1)
                            $display("PERMLB bit is allready programmed");
                        else
                            ASP_reg[0] = ASP_reg_in[0];//PERMLB
                    end

                    ASP_reg[2] = ASP_reg_in[2];//PWDMLB
                    ASP_reg[1] = ASP_reg_in[1];//PSTMLB

                    SR1_V[0] = 1'b0;
                    SR1_V[1] = 1'b0;
                end
            end

            NVDLR_PG:
            begin

                rd_fast = 1'b1;
                rd_slow = 1'b0;
                dual    = 1'b0;
                ddr     = 1'b0;

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        DataDriveOut_SO = SR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDSR2)
                    begin
                        //Read Status Register 2
                        DataDriveOut_SO = SR2_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDCR)
                    begin
                        //Read Configuration Register 1
                        DataDriveOut_SO = CR1_V[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        DataDriveOut_SO = RDAR_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_SO    = 1'bZ;
                end

                if (PDONE)
                begin
                    SR1_V[0] = 1'b0;
                    SR1_V[1] = 1'b0;

                    if (NVDLR_reg == 0)
                    begin
                        NVDLR_reg = NVDLR_reg_in;
                        VDLR_reg  = NVDLR_reg_in;
                    end
                    else
                        $display("NVDLR bits allready programmed");
                end
            end

            RESET_STATE:
            begin
            // During Reset,the non-volatile version of the registers is
            // copied to volatile version to provide the default state of
            // the volatile register
                SR1_V[7:5] = SR1_NV[7:5];
                SR1_V[1:0] = SR1_NV[1:0];

                if (Instruct == RESET || Instruct == RSTCMD)
                begin
                // The volatile FREEZE bit (CR1_V[0]) and the volatile PPB Lock
                // bit are not changed by the SW RESET
                    CR1_V[7:1] = CR1_NV[7:1];
                end
                else
                begin
                    CR1_V = CR1_NV;

                    if (~PWDMLB)
                        PPBL[0] = 1'b0;
                    else
                        PPBL[0] = 1'b1;
                end

                CR2_V = CR2_NV;
                CR3_V = CR3_NV;
                CR4_V = CR4_NV;

                VDLR_reg = NVDLR_reg;
                dlp_act = 1'b0;
                //Loads the Program Buffer with all ones
                for(i=0;i<=511;i=i+1)
                begin
                    WData[i] = MaxData;
                end

                if (FREEZE == 1'b0)
                begin
                //When BPNV is set to '1'. the BP2-0 bits in Status
                //Register are volatile and will be reseted after
                //reset command
                SR1_V[4:2] = SR1_NV[4:2];
                BP_bits = {SR1_V[4],SR1_V[3],SR1_V[2]};
                change_BP = 1'b1;
                #1 change_BP = 1'b0;
                end
            end

            PGERS_ERROR :
            begin
                if (QUAD_ALL)
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b1;
                    ddr     = 1'b0;
                end
                else
                begin
                    rd_fast = 1'b1;
                    rd_slow = 1'b0;
                    dual    = 1'b0;
                    ddr     = 1'b0;
                end

                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                    else if (Instruct == RDAR)
                    begin
                        READ_ALL_REG(read_addr, RDAR_reg);

                        if (QUAD_ALL)
                        begin
                            data_out[7:0]  = RDAR_reg;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = RDAR_reg[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                end
                else if (oe_z)
                begin
                    DataDriveOut_RESET = 1'bZ;
                    DataDriveOut_WP    = 1'bZ;
                    DataDriveOut_SO    = 1'bZ;
                    DataDriveOut_SI    = 1'bZ;
                end

                if (falling_edge_write)
                begin
                    if (Instruct == WRDI && ~P_ERR && ~E_ERR)
                    begin
                    // A Clear Status Register (CLSR) followed by a Write
                    // Disable (WRDI) command must be sent to return the
                    // device to standby state
                        SR1_V[1] = 1'b0; //WEL
                    end
                    else if (Instruct == CLSR)
                    begin
                        SR1_V[6] = 0;// P_ERR
                        SR1_V[5] = 0;// E_ERR
                        SR1_V[0] = 0;// WIP
                    end

                    if (Instruct == RSTEN)
                    begin
                        RESET_EN = 1;
                    end
                    else
                    begin
                        RESET_EN <= 0;
                    end
                end
            end

            BLANK_CHECK :
            begin
                if (rising_edge_BCDONE)
                begin
                    if (NOT_BLANK)
                    begin
                        //Start Sector Erase
                        ESTART = 1'b1;
                        ESTART <= #5 1'b0;
                        ESUSP     = 0;
                        ERES      = 0;
                        INITIAL_CONFIG = 1;
                        SR1_V[0] = 1'b1; //WIP
                        Addr = Address;
                        Addr_ers = Address;
                    end
                    else
                        SR1_V[1] = 1'b1; //WEL
                end
                else
                begin
					if (CR3_V[1]== 0)
					begin
                    	ADDRHILO_SEC(AddrLo, AddrHi, Address);
                    	for (i=AddrLo;i<=AddrHi;i=i+1)
                    	begin
                        	if (Mem[i] != MaxData)
                            	NOT_BLANK = 1'b1;
                    	end
                    	bc_done = 1'b1;
					end
					else
					begin
                    	ADDRHILO_BLK(AddrLo, AddrHi, Address);
                    	for (i=AddrLo;i<=AddrHi;i=i+1)
                    	begin
                        	if (Mem[i] != MaxData)
                            	NOT_BLANK = 1'b1;
                    	end
                    	bc_done = 1'b1;
					end
                end
            end

            EVAL_ERS_STAT :
            begin
                if (oe)
                begin
                    any_read = 1'b1;
                    if (Instruct == RDSR1)
                    begin
                    //Read Status Register 1
                        if (QUAD_ALL)
                        begin
                            data_out[7:0] = SR1_V;
                            DataDriveOut_RESET = data_out[7-4*read_cnt];
                            DataDriveOut_WP    = data_out[6-4*read_cnt];
                            DataDriveOut_SO    = data_out[5-4*read_cnt];
                            DataDriveOut_SI    = data_out[4-4*read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 2)
                            begin
                                read_cnt = 0;
                            end
                        end
                        else
                        begin
                            DataDriveOut_SO = SR1_V[7-read_cnt];
                            read_cnt = read_cnt + 1;
                            if (read_cnt == 8)
                                read_cnt = 0;
                        end
                    end
                end

                if (rising_edge_EESDONE)
                begin
                    SR1_V[0] = 1'b0;
                    SR1_V[1] = 1'b0;

					if (CR3_V[1]== 0)
					begin
                    	if (ERS_nosucc[sect] == 1'b1)
                       		SR2_V[2] = 1'b0;
						else
							SR2_V[2] = 1'b1;
					end
					else
					begin
                    	if (ERS_nosucc_b[block_e] == 1'b1)
                       		SR2_V[2] = 1'b0;
						else
							SR2_V[2] = 1'b1;
                    end
                end
            end

        endcase
    end

    always @(posedge CSNeg_ipd)
    begin
        //Output Disable Control
        SOut_zd        = 1'bZ;
        SIOut_zd       = 1'bZ;
        RESETNegOut_zd = 1'bZ;
        WPNegOut_zd    = 1'bZ;
        DataDriveOut_SO    = 1'bZ;
        DataDriveOut_SI    = 1'bZ;
        DataDriveOut_RESET = 1'bZ;
        DataDriveOut_WP    = 1'bZ;
    end

    always @(change_TBPARM, posedge PoweredUp)
    begin
        if (CR3_V[3] == 1'b0)
        begin
            if (TBPARM_O == 0)
            begin
                TopBoot     = 0;
                BottomBoot = 1;
            end
            else
            begin
                TopBoot     = 1;
                BottomBoot  = 0;
            end
        end
        else
        begin
            UniformSec = 1;
        end
    end

    always @(posedge change_BP)
    begin
        case (SR1_V[4:2])

            3'b000:
            begin
                Sec_Prot[SecNumHyb:0] = {520{1'b0}};
                Block_Prot[BlockNumHyb:0] = {136{1'b0}};
            end

            3'b001:
            begin
                if (CR3_V[3]) // Uniform Sector Architecture
                begin
                    if (~TBPROT_O)  // BP starts at Top
                    begin
                        Sec_Prot[SecNumUni:(SecNumUni+1)*63/64] =   {8{1'b1}};
                        Sec_Prot[(SecNumUni+1)*63/64-1 : 0]     = {504{1'b0}};
                        Block_Prot[BlockNumUni:(BlockNumUni+1)*63/64] =   {2{1'b1}};
                        Block_Prot[(BlockNumUni+1)*63/64-1 : 0]     = {126{1'b0}};
                    end
                    else
                    begin
                        Sec_Prot[(SecNumUni+1)/64-1 : 0]       =   {8{1'b1}};
                        Sec_Prot[SecNumUni : (SecNumUni+1)/64] = {504{1'b0}};
                        Block_Prot[(BlockNumUni+1)/64-1 : 0] =   {2{1'b1}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)/64]     = {126{1'b0}};
                    end
                end
                else  // Hybrid Sector Architecture
                begin
                    if(TBPARM_O)  // 4 KB Physical Sectors at Top
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)*63/64]= {16{1'b1}};
                            Sec_Prot[(SecNumHyb-7)*63/64-1 : 0]   = {504{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)*63/64]= {10{1'b1}};
                            Block_Prot[(BlockNumHyb-7)*63/64-1 : 0]   = {126{1'b0}};
                        end
                        else
                        begin
                            Sec_Prot[(SecNumHyb-7)/64-1 : 0]      =   {8{1'b1}};
                            Sec_Prot[SecNumHyb :(SecNumHyb-7)/64] = {512{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/64-1 : 0]      =   {2{1'b1}};
                            Block_Prot[BlockNumHyb :(BlockNumHyb-7)/64] = {134{1'b0}};
                        end
                    end
                    else          // 4 KB Physical Sectors at Bottom
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)*63/64+8] =
                                                                      {8{1'b1}};
                            Sec_Prot[(SecNumHyb-7)*63/64+7 : 0]   = {512{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)*63/64+8] =
                                                                      {2{1'b1}};
                            Block_Prot[(BlockNumHyb-7)*63/64+7 : 0]   = {134{1'b0}};
                        end
                        else            // BP starts at Bottom
                        begin
                            Sec_Prot[(SecNumHyb-7)/64+7 : 0]      =  {16{1'b1}};
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)/64+8]= {504{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/64+7 : 0]      =  {10{1'b1}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)/64+8]= {126{1'b0}};
                        end
                    end
                end
            end

            3'b010:
            begin
                if (CR3_V[3]) // Uniform Sector Architecture
                begin
                    if (~TBPROT_O)  // BP starts at Top
                    begin
                        Sec_Prot[SecNumUni : (SecNumUni+1)*31/32] = {16{1'b1}};
                        Sec_Prot[(SecNumUni+1)*31/32-1 : 0]       = {496{1'b0}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)*31/32] = {4{1'b1}};
                        Sec_Prot[(BlockNumUni+1)*31/32-1 : 0]       = {124{1'b0}};
                    end
                    else            // BP starts at Bottom
                    begin
                        Sec_Prot[(SecNumUni+1)/32-1 : 0]       = {16{1'b1}};
                        Sec_Prot[SecNumUni : (SecNumUni+1)/32] = {496{1'b0}};
                        Block_Prot[(BlockNumUni+1)/32-1 : 0]       = {4{1'b1}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)/32] = {124{1'b0}};
                    end
                end
                else  // Hybrid Sector Architecture
                begin
                    if(TBPARM_O)  // 4 KB Physical Sectors at Top
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)*31/32]= {24{1'b1}};
                            Sec_Prot[(SecNumHyb-7)*31/32-1 : 0]   = {496{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)*31/32]= {12{1'b1}};
                            Block_Prot[(BlockNumHyb-7)*31/32-1 : 0]   = {124{1'b0}};
                        end
                        else
                        begin
                            Sec_Prot[(SecNumHyb-7)/32-1 : 0]      =   {16{1'b1}};
                            Sec_Prot[SecNumHyb :(SecNumHyb-7)/32] = {504{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/32-1 : 0]      =   {4{1'b1}};
                            Block_Prot[BlockNumHyb :(BlockNumHyb-7)/32] = {132{1'b0}};
                        end
                    end
                    else          // 4 KB Physical Sectors at Bottom
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)*31/32+8] =
                                                                      {16{1'b1}};
                            Sec_Prot[(SecNumHyb-7)*31/32+7 : 0]   = {504{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)*31/32+8] =
                                                                      {4{1'b1}};
                            Block_Prot[(BlockNumHyb-7)*31/32+7 : 0]   = {132{1'b0}};
                        end
                        else            // BP starts at Bottom
                        begin
                            Sec_Prot[(SecNumHyb-7)/32+7 : 0]      =  {24{1'b1}};
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)/32+8]= {496{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/32+7 : 0]      =  {12{1'b1}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)/32+8]= {124{1'b0}};
                        end
                    end
                end
            end

            3'b011:
            begin
                if (CR3_V[3]) // Uniform Sector Architecture
                begin
                    if (~TBPROT_O)  // BP starts at Top
                    begin
                        Sec_Prot[SecNumUni : (SecNumUni+1)*15/16] = {32{1'b1}};
                        Sec_Prot[(SecNumUni+1)*15/16-1 : 0]       = {480{1'b0}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)*15/16] = {8{1'b1}};
                        Block_Prot[(BlockNumUni+1)*15/16-1 : 0]       = {120{1'b0}};
                    end
                    else            // BP starts at Bottom
                    begin
                        Sec_Prot[(SecNumUni+1)/16-1 : 0]       = {32{1'b1}};
                        Sec_Prot[SecNumUni : (SecNumUni+1)/16] = {480{1'b0}};
                        Block_Prot[(BlockNumUni+1)/16-1 : 0]       = {8{1'b1}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)/16] = {120{1'b0}};
                    end
                end
                else  // Hybrid Sector Architecture
                begin
                    if(TBPARM_O)  // 4 KB Physical Sectors at Top
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)*15/16]= {40{1'b1}};
                            Sec_Prot[(SecNumHyb-7)*15/16-1 : 0]   = {480{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)*15/16]= {16{1'b1}};
                            Block_Prot[(BlockNumHyb-7)*15/16-1 : 0]   = {120{1'b0}};
                        end
                        else
                        begin
                            Sec_Prot[(SecNumHyb-7)/16-1 : 0]      =  {32{1'b1}};
                            Sec_Prot[SecNumHyb :(SecNumHyb-7)/16] = {488{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/16-1 : 0]      =  {8{1'b1}};
                            Block_Prot[BlockNumHyb :(BlockNumHyb-7)/16] = {128{1'b0}};
                        end
                    end
                    else          // 4 KB Physical Sectors at Bottom
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)*15/16+8] =
                                                                     {32{1'b1}};
                            Sec_Prot[(SecNumHyb-7)*15/16+7 : 0]   = {488{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)*15/16+8] =
                                                                     {8{1'b1}};
                            Block_Prot[(BlockNumHyb-7)*15/16+7 : 0]   = {128{1'b0}};
                        end
                        else            // BP starts at Bottom
                        begin
                            Sec_Prot[(SecNumHyb-7)/16+7 : 0]      =  {40{1'b1}};
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)/16+8]= {480{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/16+7 : 0]      =  {16{1'b1}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)/16+8]= {120{1'b0}};
                        end
                    end
                end
            end

            3'b100:
            begin
                if (CR3_V[3]) // Uniform Sector Architecture
                begin
                    if (~TBPROT_O)  // BP starts at Top
                    begin
                        Sec_Prot[SecNumUni : (SecNumUni+1)*7/8] = {64{1'b1}};
                        Sec_Prot[(SecNumUni+1)*7/8-1 : 0]       = {448{1'b0}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)*7/8] = {16{1'b1}};
                        Block_Prot[(BlockNumUni+1)*7/8-1 : 0]       = {112{1'b0}};
                    end
                    else            // BP starts at Bottom
                    begin
                        Sec_Prot[(SecNumUni+1)/8-1 : 0]       = {64{1'b1}};
                        Sec_Prot[SecNumUni : (SecNumUni+1)/8] = {448{1'b0}};
                        Block_Prot[(BlockNumUni+1)/8-1 : 0]       = {16{1'b1}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)/8] = {112{1'b0}};
                    end
                end
                else  // Hybrid Sector Architecture
                begin
                    if(TBPARM_O)  // 4 KB Physical Sectors at Top
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)*7/8]= {72{1'b1}};
                            Sec_Prot[(SecNumHyb-7)*7/8-1 : 0]   = {448{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)*7/8]= {24{1'b1}};
                            Block_Prot[(BlockNumHyb-7)*7/8-1 : 0]   = {112{1'b0}};
                        end
                        else
                        begin
                            Sec_Prot[(SecNumHyb-7)/8-1 : 0]      =  {64{1'b1}};
                            Sec_Prot[SecNumHyb :(SecNumHyb-7)/8] = {456{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/8-1 : 0]      =  {16{1'b1}};
                            Block_Prot[BlockNumHyb :(BlockNumHyb-7)/8] = {120{1'b0}};
                        end
                    end
                    else          // 4 KB Physical Sectors at Bottom
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)*7/8+8] =
                                                                     {64{1'b1}};
                            Sec_Prot[(SecNumHyb-7)*7/8+7 : 0]     = {456{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)*7/8+8] =
                                                                     {16{1'b1}};
                            Block_Prot[(BlockNumHyb-7)*7/8+7 : 0]     = {120{1'b0}};
                        end
                        else            // BP starts at Bottom
                        begin
                            Sec_Prot[(SecNumHyb-7)/8+7 : 0]       =  {72{1'b1}};
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)/8+8] = {448{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/8+7 : 0]       =  {24{1'b1}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)/8+8] = {112{1'b0}};
                        end
                    end
                end
            end

            3'b101:
            begin
                if (CR3_V[3]) // Uniform Sector Architecture
                begin
                    if (~TBPROT_O)  // BP starts at Top
                    begin
                        Sec_Prot[SecNumUni : (SecNumUni+1)*3/4] = {128{1'b1}};
                        Sec_Prot[(SecNumUni+1)*3/4-1 : 0]       = {384{1'b0}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)*3/4] = {32{1'b1}};
                        Block_Prot[(BlockNumUni+1)*3/4-1 : 0]       = {96{1'b0}};
                    end
                    else            // BP starts at Bottom
                    begin
                        Sec_Prot[(SecNumUni+1)/4-1 : 0]       = {128{1'b1}};
                        Sec_Prot[SecNumUni : (SecNumUni+1)/4] = {384{1'b0}};
                        Block_Prot[(BlockNumUni+1)/4-1 : 0]       = {32{1'b1}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)/4] = {96{1'b0}};
                    end
                end
                else  // Hybrid Sector Architecture
                begin
                    if(TBPARM_O)  // 4 KB Physical Sectors at Top
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)*3/4]= {136{1'b1}};
                            Sec_Prot[(SecNumHyb-7)*3/4-1 : 0]   = {384{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)*3/4]= {40{1'b1}};
                            Block_Prot[(BlockNumHyb-7)*3/4-1 : 0]   = {96{1'b0}};

                        end
                        else
                        begin
                            Sec_Prot[(SecNumHyb-7)/4-1 : 0]      =  {128{1'b1}};
                            Sec_Prot[SecNumHyb :(SecNumHyb-7)/4] = {392{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/4-1 : 0]      =  {32{1'b1}};
                            Block_Prot[BlockNumHyb :(BlockNumHyb-7)/4] = {104{1'b0}};
                        end
                    end
                    else          // 4 KB Physical Sectors at Bottom
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)*3/4+8] =
                                                                     {128{1'b1}};
                            Sec_Prot[(SecNumHyb-7)*3/4+7 : 0]     = {392{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)*3/4+8] =
                                                                     {32{1'b1}};
                            Block_Prot[(BlockNumHyb-7)*3/4+7 : 0]     = {104{1'b0}};
                        end
                        else            // BP starts at Bottom
                        begin
                            Sec_Prot[(SecNumHyb-7)/4+7 : 0]       =  {136{1'b1}};
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)/4+8] = {384{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/4+7 : 0]       =  {40{1'b1}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)/4+8] = {96{1'b0}};
                        end
                    end
                end
            end

            3'b110:
            begin
                if (CR3_V[3]) // Uniform Sector Architecture
                begin
                    if (~TBPROT_O)  // BP starts at Top
                    begin
                        Sec_Prot[SecNumUni : (SecNumUni+1)/2] = {256{1'b1}};
                        Sec_Prot[(SecNumUni+1)/2-1 : 0]       = {256{1'b0}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)/2] = {64{1'b1}};
                        Block_Prot[(BlockNumUni+1)/2-1 : 0]       = {64{1'b0}};
                    end
                    else            // BP starts at Bottom
                    begin
                        Sec_Prot[(SecNumUni+1)/2-1 : 0]       = {256{1'b1}};
                        Sec_Prot[SecNumUni : (SecNumUni+1)/2] = {256{1'b0}};
                        Block_Prot[(BlockNumUni+1)/2-1 : 0]       = {64{1'b1}};
                        Block_Prot[BlockNumUni : (BlockNumUni+1)/2] = {64{1'b0}};
                    end
                end
                else  // Hybrid Sector Architecture
                begin
                    if(TBPARM_O)  // 4 KB Physical Sectors at Top
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)/2] = {264{1'b1}};
                            Sec_Prot[(SecNumHyb-7)/2-1 : 0]     = {256{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)/2] = {72{1'b1}};
                            Block_Prot[(BlockNumHyb-7)/2-1 : 0]     = {64{1'b0}};
                        end
                        else
                        begin
                            Sec_Prot[(SecNumHyb-7)/2-1 : 0]      = {256{1'b1}};
                            Sec_Prot[SecNumHyb :(SecNumHyb-7)/2] = {264{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/2-1 : 0]      = {64{1'b1}};
                            Block_Prot[BlockNumHyb :(BlockNumHyb-7)/2] = {72{1'b0}};
                        end
                    end
                    else          // 4 KB Physical Sectors at Bottom
                    begin
                        if (~TBPROT_O)  // BP starts at Top
                        begin
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)/2+8] = {256{1'b1}};
                            Sec_Prot[(SecNumHyb-7)/2+7 : 0]       = {264{1'b0}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)/2+8] = {64{1'b1}};
                            Block_Prot[(BlockNumHyb-7)/2+7 : 0]       = {72{1'b0}};
                        end
                        else            // BP starts at Bottom
                        begin
                            Sec_Prot[(SecNumHyb-7)/2+7 : 0]       = {264{1'b1}};
                            Sec_Prot[SecNumHyb:(SecNumHyb-7)/2+8] = {256{1'b0}};
                            Block_Prot[(BlockNumHyb-7)/2+7 : 0]       = {72{1'b1}};
                            Block_Prot[BlockNumHyb:(BlockNumHyb-7)/2+8] = {64{1'b0}};
                        end
                    end
                end
            end

            3'b111:
            begin
                Sec_Prot[SecNumHyb:0] =  {520{1'b1}};
                Block_Prot[BlockNumHyb:0] =  {136{1'b1}};
            end
        endcase
    end

    always @(CR3_V[4])
    begin
        if (CR3_V[4] == 1'b0)
        begin
            PageSize = 255;
            PageNum  = PageNum256;
        end
        else
        begin
            PageSize = 511;
            PageNum  = PageNum512;
        end
    end
    ///////////////////////////////////////////////////////////////////////////
    // functions & tasks
    ///////////////////////////////////////////////////////////////////////////
    // Procedure DDR_DPL
    task Return_DLP;
    input integer Latency_code;
    input integer dummy_cnt;
    inout dlp_act;
    begin
        if (Latency_code >= 4 && dummy_cnt >= (2*Latency_code-8))
            dlp_act = 1'b1;
        else
        begin
            dlp_act = 1'b0;
        end
    end
    endtask

    // Procedure ADDRHILO_SEC
    task ADDRHILO_SEC;
    inout   AddrLOW;
    inout   AddrHIGH;
    input   Addr;
    integer AddrLOW;
    integer AddrHIGH;
    integer Addr;
    integer sector;
    begin
        if (CR3_V[3] == 1'b0) //Hybrid Sector Architecture
        begin
            if (TBPARM_O == 0) //4KB Sectors at Bottom
            begin
                if (Addr/(SecSize64+1) == 0)
                begin
                    if ((Addr/(SecSize4+1) < 8) && Instruct_P4E)  //4KB Sectors
                    begin
                        sector   = Addr/(SecSize4+1);
                        AddrLOW  = sector*(SecSize4+1);
                        AddrHIGH = sector*(SecSize4+1) + SecSize4;
                    end
                    else
                    begin
                        AddrLOW  = 8*(SecSize4+1);
                        AddrHIGH = SecSize64;
                    end
                end
                else
                begin
                    sector   = Addr/(SecSize64+1);
                    AddrLOW  = sector*(SecSize64+1);
                    AddrHIGH = sector*(SecSize64+1) + SecSize64;
                end
            end
            else  //4KB Sectors at Top
            begin
                if (Addr/(SecSize64+1) == 511)
                begin
                    if ((Addr > (AddrRANGE - 8*(SecSize4+1))) &&
												Instruct_P4E) //4KB Sectors
                    begin
                        sector   = 512 +
                           (Addr-(AddrRANGE + 1 - 8*(SecSize4+1)))/(SecSize4+1);
                        AddrLOW  = AddrRANGE + 1 - 8*(SecSize4+1) +
                           (sector-512)*(SecSize4+1);
                        AddrHIGH = AddrRANGE + 1 - 8*(SecSize4+1) +
                                   (sector-512)*(SecSize4+1) + SecSize4;
                    end
                    else
                    begin
                        AddrLOW  = 511*(SecSize64+1);
                        AddrHIGH = AddrRANGE - 8*(SecSize4+1);
                    end
                end
                else
                begin
                    sector   = Addr/(SecSize64+1);
                    AddrLOW  = sector*(SecSize64+1);
                    AddrHIGH = sector*(SecSize64+1) + SecSize64;
                end
            end
        end
        else   //Uniform Sector Architecture
        begin
                sector   = Addr/(SecSize64+1);
                AddrLOW  = sector*(SecSize64+1);
                AddrHIGH = sector*(SecSize64+1) + SecSize64;
        end
    end
    endtask

// Procedure ADDRHILO_BLK
    task ADDRHILO_BLK;
    inout   AddrLOW;
    inout   AddrHIGH;
    input   Addr; 
    integer AddrLOW;
    integer AddrHIGH;
    integer Addr;
    integer block_e;
	begin
        if (CR3_V[3] == 1'b0) //Hybrid Sector Architecture
        begin
            if (TBPARM_O == 0) //4KB Sectors at Bottom
            begin
                if (Addr/(SecSize256+1) == 0)
                begin
                    if (Addr/(SecSize4+1) < 8 && Instruct_P4E)  //4KB Sectors
                    begin
                        block_e  = Addr/(SecSize4+1);
                        AddrLOW  = block_e*(SecSize4+1);
                        AddrHIGH = block_e*(SecSize4+1) + SecSize4;
                    end
                    else
                    begin
                        AddrLOW  = 8*(SecSize4+1);
                        AddrHIGH = SecSize256;
                    end
                end
                else
                begin
                    block_e   = Addr/(SecSize256+1);
                    AddrLOW  = block_e*(SecSize256+1);
                    AddrHIGH = block_e*(SecSize256+1) + SecSize256;
                end
            end
            else  //4KB Sectors at Top
            begin
                if (Addr/(SecSize256+1) == 127)
                begin
                    if (Addr >  (AddrRANGE - 8*(SecSize4+1)) && Instruct_P4E)
													 //4KB Sectors
                    begin
                        block_e   = 128 +
                           (Addr-(AddrRANGE + 1 - 8*(SecSize4+1)))/(SecSize4+1);
                        AddrLOW  = AddrRANGE + 1 - 8*(SecSize4+1) +
                           (block_e-128)*(SecSize4+1);
                        AddrHIGH = AddrRANGE + 1 - 8*(SecSize4+1) +
                                   (block_e-128)*(SecSize4+1) + SecSize4;
                    end
                    else
                    begin
                        AddrLOW  = 127*(SecSize256+1);
                        AddrHIGH = AddrRANGE - 8*(SecSize4+1);
                    end
                end
                else
                begin
                    block_e   = Addr/(SecSize256+1);
                    AddrLOW  = block_e*(SecSize256+1);
                    AddrHIGH = block_e*(SecSize256+1) + SecSize256;
                end
            end
        end
        else   //Uniform Sector Architecture
        begin
            block_e   = Addr/(SecSize256+1);
            AddrLOW  = block_e*(SecSize256+1);
            AddrHIGH = block_e*(SecSize256+1) + SecSize256;
        end
    end
    endtask

    // Procedure ADDRHILO_PG
    task ADDRHILO_PG;
    inout  AddrLOW;
    inout  AddrHIGH;
    input   Addr;
    integer AddrLOW;
    integer AddrHIGH;
    integer Addr;
    integer page;
    begin
        page = Addr / (PageSize + 1);
        AddrLOW = page * (PageSize + 1);
        AddrHIGH = page * (PageSize + 1) + PageSize;
    end
    endtask

    // Procedure ReturnSectorID
    task ReturnSectorID;
    inout   sect;
    input   Address;
    integer sect;
    integer Address;
    integer conv;
    integer HybAddrHi;
    integer HybAddrLow;
    begin
        conv = Address / (SecSize64+1);

        if (CR3_V[3] == 1'b0) //Hybrid Sector Architecture
        begin
            if (BottomBoot)
            begin
                if (conv == 0)  //4KB Sectors
                begin
                    HybAddrHi = 8*(SecSize4+1) - 1;

                    if (Address <= HybAddrHi)
                        sect = Address/(SecSize4+1);
                    else
                        sect = 8;
                end
                else
                begin
                    sect = conv + 8;
                end
            end
            else if (TopBoot)
            begin
                if (conv == 511)       //4KB Sectors
                begin
                    HybAddrLow = AddrRANGE + 1 - 8*(SecSize4+1);

                    if (Address < HybAddrLow)
                        sect = 511;
                    else
                        sect = 512 + (Address - HybAddrLow) / (SecSize4+1);
                end
                else
                begin
                    sect = conv;
                end
            end
        end
        else  //Uniform Sector Architecture
        begin
            sect = conv;
        end
    end
    endtask

    task ReturnBlockID;
    inout   block_e;
    input   Address;
    integer block_e;
    integer Address;
    integer conv;
    integer HybAddrHi;
    integer HybAddrLow;
	begin
        conv = Address / (SecSize256+1);

        if (CR3_V[3] == 1'b0) //Hybrid Sector Architecture
        begin
            if (BottomBoot)
            begin
                if (conv == 0)  //4KB Sectors
                begin
                    HybAddrHi = 8*(SecSize4+1) - 1;

                    if (Address <= HybAddrHi)
                        block_e = Address/(SecSize4+1);
                    else
                        block_e = 8;
                end
                else
                begin
                    block_e = conv + 8;
                end
            end
            else if (TopBoot)
            begin
                if (conv == 127)       //4KB Sectors
                begin
                    HybAddrLow = AddrRANGE + 1 - 8*(SecSize4+1);

                    if (Address < HybAddrLow)
                        block_e = 127;
                    else
                        block_e = 128 + (Address - HybAddrLow) / (SecSize4+1);
                end
                else
                begin
                   block_e = conv;
                end
            end
        end
        else  //Uniform Sector Architecture
        begin
            block_e = conv;
        end
    end
    endtask

    task READ_ALL_REG;
        input integer Addr;
        inout integer RDAR_reg;
    begin

        if (Addr == 32'h00000000)
            RDAR_reg = SR1_NV;
        else if (Addr == 32'h00000002)
            RDAR_reg = CR1_NV;
        else if (Addr == 32'h00000003)
            RDAR_reg = CR2_NV;
        else if (Addr == 32'h00000004)
            RDAR_reg = CR3_NV;
        else if (Addr == 32'h00000005)
            RDAR_reg = CR4_NV;
        else if (Addr == 32'h00000010)
            RDAR_reg = NVDLR_reg;
        else if (Addr == 32'h00000020)
        begin
            if (PWDMLB)
                RDAR_reg = Password_reg[7:0];
            else
                RDAR_reg = 8'bXX;
        end
        else if (Addr == 32'h00000021)
        begin
            if (PWDMLB)
                RDAR_reg = Password_reg[15:8];
            else
                RDAR_reg = 8'bXX;
        end
        else if (Addr == 32'h00000022)
        begin
            if (PWDMLB)
                RDAR_reg = Password_reg[23:16];
            else
                RDAR_reg = 8'bXX;
        end
        else if (Addr == 32'h00000023)
        begin
            if (PWDMLB)
                RDAR_reg = Password_reg[31:24];
            else
                RDAR_reg = 8'bXX;
        end
        else if (Addr == 32'h00000024)
        begin
            if (PWDMLB)
                RDAR_reg = Password_reg[39:32];
            else
                RDAR_reg = 8'bXX;
        end
        else if (Addr == 32'h00000025)
        begin
            if (PWDMLB)
                RDAR_reg = Password_reg[47:40];
            else
                RDAR_reg = 8'bXX;
        end
        else if (Addr == 32'h00000026)
        begin
            if (PWDMLB)
                RDAR_reg = Password_reg[55:48];
            else
                RDAR_reg = 8'bXX;
        end
        else if (Addr == 32'h00000027)
        begin
            if (PWDMLB)
                RDAR_reg = Password_reg[63:56];
            else
                RDAR_reg = 8'bXX;
        end
        else if (Addr == 32'h00000030)
            RDAR_reg = ASP_reg[7:0];
        else if (Addr == 32'h00000031)
            RDAR_reg = ASP_reg[15:8];
        else if (Addr == 32'h00800000)
            RDAR_reg = SR1_V;
        else if (Addr == 32'h00800001)
            RDAR_reg = SR2_V;
        else if (Addr == 32'h00800002)
            RDAR_reg = CR1_V;
        else if (Addr == 32'h00800003)
            RDAR_reg = CR2_V;
        else if (Addr == 32'h00800004)
            RDAR_reg = CR3_V;
        else if (Addr == 32'h00800005)
            RDAR_reg = CR4_V;
        else if (Addr == 32'h00800010)
            RDAR_reg = VDLR_reg;
        else if (Addr == 32'h00800040)
            RDAR_reg = PPBL;
        else
            RDAR_reg = 8'bXX;//N/A

    end
    endtask

    ///////////////////////////////////////////////////////////////////////////
    // edge controll processes
    ///////////////////////////////////////////////////////////////////////////

    always @(posedge PoweredUp)
    begin
        rising_edge_PoweredUp = 1;
        #1 rising_edge_PoweredUp = 0;
    end

    always @(posedge SCK_ipd)
    begin
       rising_edge_SCK_ipd = 1'b1;
       #1 rising_edge_SCK_ipd = 1'b0;
    end

    always @(negedge SCK_ipd)
    begin
       falling_edge_SCK_ipd = 1'b1;
       #1 falling_edge_SCK_ipd = 1'b0;
    end

    always @(posedge CSNeg_ipd)
    begin
        rising_edge_CSNeg_ipd = 1'b1;
        #1 rising_edge_CSNeg_ipd = 1'b0;
    end

    always @(negedge CSNeg_ipd)
    begin
        falling_edge_CSNeg_ipd = 1'b1;
        #1 falling_edge_CSNeg_ipd = 1'b0;
    end

    always @(negedge write)
    begin
        falling_edge_write = 1;
        #1 falling_edge_write = 0;
    end

    always @(posedge reseted)
    begin
        rising_edge_reseted = 1;
        #1 rising_edge_reseted = 0;
    end

    always @(negedge RESETNeg)
    begin
        falling_edge_RESETNeg = 1;
        #1 falling_edge_RESETNeg = 0;
    end

    always @(posedge RESETNeg)
    begin
        rising_edge_RESETNeg = 1;
        #1 rising_edge_RESETNeg = 0;
    end

    always @(posedge PSTART)
    begin
        rising_edge_PSTART = 1'b1;
        #1 rising_edge_PSTART = 1'b0;
    end

    always @(posedge PDONE)
    begin
        rising_edge_PDONE = 1'b1;
        #1 rising_edge_PDONE = 1'b0;
    end

    always @(posedge WSTART)
    begin
        rising_edge_WSTART = 1;
        #1 rising_edge_WSTART = 0;
    end

    always @(posedge WDONE)
    begin
        rising_edge_WDONE = 1'b1;
        #1 rising_edge_WDONE = 1'b0;
    end

    always @(posedge CSDONE)
    begin
        rising_edge_CSDONE = 1'b1;
        #1 rising_edge_CSDONE = 1'b0;
    end

    always @(posedge EESSTART)
    begin
        rising_edge_EESSTART = 1;
        #1 rising_edge_EESSTART = 0;
    end

    always @(posedge EESDONE)
    begin
        rising_edge_EESDONE = 1'b1;
        #1 rising_edge_EESDONE = 1'b0;
    end

    always @(posedge bc_done)
    begin
        rising_edge_BCDONE = 1'b1;
        #1 rising_edge_BCDONE = 1'b0;
    end

    always @(posedge ESTART)
    begin
        rising_edge_ESTART = 1'b1;
        #1 rising_edge_ESTART = 1'b0;
    end

    always @(posedge EDONE)
    begin
        rising_edge_EDONE = 1'b1;
        #1 rising_edge_EDONE = 1'b0;
    end

    always @(posedge PRGSUSP_out)
    begin
        PRGSUSP_out_event = 1;
        #1 PRGSUSP_out_event = 0;
    end

    always @(posedge ERSSUSP_out)
    begin
        ERSSUSP_out_event = 1;
        #1 ERSSUSP_out_event = 0;
    end

    always @(change_addr)
    begin
        change_addr_event = 1'b1;
        #1 change_addr_event = 1'b0;
    end

    always @(current_state)
    begin
        current_state_event = 1'b1;
        #1 current_state_event = 1'b0;
    end

    always @(Instruct)
    begin
        Instruct_event = 1'b1;
        #1 Instruct_event = 1'b0;
    end

    always @(posedge RST_out)
    begin
        rising_edge_RST_out = 1'b1;
        #1 rising_edge_RST_out = 1'b0;
    end

    always @(negedge RST)
    begin
        falling_edge_RST = 1'b1;
        #1 falling_edge_RST = 1'b0;
    end

    always @(posedge SWRST_out)
    begin
        rising_edge_SWRST_out = 1'b1;
        #1 rising_edge_SWRST_out = 1'b0;
    end

    always @(negedge PASSULCK_in)
    begin
        falling_edge_PASSULCK_in = 1'b1;
        #1 falling_edge_PASSULCK_in = 1'b0;
    end

    always @(negedge PPBERASE_in)
    begin
        falling_edge_PPBERASE_in = 1'b1;
        #1 falling_edge_PPBERASE_in = 1'b0;
    end

    integer DQt_01;
    integer DQt_0Z;

    reg  BuffInDQ;
    wire BuffOutDQ;

    reg  BuffInDQZ;
    wire BuffOutDQZ;

    BUFFER    BUF_DOut   (BuffOutDQ, BuffInDQ);
    BUFFER    BUF_DOutZ  (BuffOutDQZ, BuffInDQZ);

    initial
    begin
        BuffInDQ   = 1'b1;
        BuffInDQZ  = 1'b1;
    end

    always @(posedge BuffOutDQ)
    begin
        DQt_01 = $time;
    end

    always @(posedge BuffOutDQZ)
    begin
        DQt_0Z = $time;
    end

    always @(DataDriveOut_SO,DataDriveOut_SI,DataDriveOut_RESET,DataDriveOut_WP)
    begin
        if ((DQt_01 > SCK_cycle/2) && DOUBLE)
        begin
            glitch = 1;
            SOut_zd        <= #(DQt_01-1000) DataDriveOut_SO;
            SIOut_zd       <= #(DQt_01-1000) DataDriveOut_SI;
            RESETNegOut_zd <= #(DQt_01-1000) DataDriveOut_RESET;
            WPNegOut_zd    <= #(DQt_01-1000) DataDriveOut_WP;
        end
        else
        begin
            glitch = 0;
            SOut_zd        <= DataDriveOut_SO;
            SIOut_zd       <= DataDriveOut_SI;
            RESETNegOut_zd <= DataDriveOut_RESET;
            WPNegOut_zd    <= DataDriveOut_WP;
        end
    end

endmodule

module BUFFER (OUT,IN);
    input IN;
    output OUT;
    buf   ( OUT, IN);
endmodule

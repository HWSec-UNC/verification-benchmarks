-------------------------------------------------------------------------------
--  File Name: s25fs256s.vhd
-------------------------------------------------------------------------------
--  Copyright (C) 2013 Spansion, LLC.
--
--  MODIFICATION HISTORY:
--
--  version: |  author:  | mod date: |  changes made:
--   V1.0      S.Petrovic  28 Jan 13   Initial version
--                                            (FS-S_DRS_V3.1; Aug 10,2012)
--   V1.1      S.Petrovic  28 Nov 13   Corrected Quad DDR read with DLP
--   V1.2      S.Petrovic  23 Dec 13   DLP read enabled with 4 latency cycles
--   V1.3      S.Petrovic  15 Aug 14   Corrected SFDP read
--   V1.4      S.Petrovic  26 Aug 14   Added SFDP JEDEC parameter
--
-------------------------------------------------------------------------------
--  PART DESCRIPTION:
--
--  Library:    FLASH
--  Technology: FLASH MEMORY
--  Part:       S25FS256S
--
--   Description: 256 Megabit Serial Flash Memory
--
-------------------------------------------------------------------------------
--  Comments :
--      For correct simulation, simulator resolution should be set to 1 ps
--      A device ordering (trim) option determines whether a feature is enabled
--      or not, or provide relevant parameters:
--        -15th character in TimingModel determines if enhanced high
--         performance option is available
--            (0,2,3) General Market
--            (Y,Z)   Secure
--
--------------------------------------------------------------------------------
--  Known Bugs:
--
--------------------------------------------------------------------------------
LIBRARY IEEE;   USE IEEE.std_logic_1164.ALL;
                USE STD.textio.ALL;
                USE IEEE.VITAL_timing.ALL;
                USE IEEE.VITAL_primitives.ALL;

LIBRARY FMF;    USE FMF.gen_utils.ALL;
                USE FMF.conversions.ALL;
-------------------------------------------------------------------------------
-- ENTITY DECLARATION
-------------------------------------------------------------------------------
ENTITY s25fs256s IS
    GENERIC (
    ---------------------------------------------------------------------------
	-- TIMING GENERICS:
    ---------------------------------------------------------------------------
        -- tipd delays: interconnect path delays (delay between components)
        --    There should be one for each IN or INOUT pin in the port list
        --    They are given default values of zero delay.
        tipd_SCK                : VitalDelayType01  := VitalZeroDelay01;
        tipd_SI                 : VitalDelayType01  := VitalZeroDelay01;
        tipd_SO                 : VitalDelayType01  := VitalZeroDelay01;
        tipd_CSNeg              : VitalDelayType01  := VitalZeroDelay01;
        tipd_RESETNeg           : VitalDelayType01  := VitalZeroDelay01;
        tipd_WPNeg              : VitalDelayType01  := VitalZeroDelay01;

        -- tpd delays: propagation delays (pin-to-pin delay within a component)
        tpd_SCK_SO_normal     : VitalDelayType01Z := UnitDelay01Z; -- tV, tHO
        tpd_SCK_SO_ddr        : VitalDelayType01Z := UnitDelay01Z; -- tV, tHO
        tpd_CSNeg_SO_normal   : VitalDelayType01Z := UnitDelay01Z; -- tDIS
        tpd_CSNeg_SO_rst_quad : VitalDelayType01Z := UnitDelay01Z; -- tDIS

        -- tsetup values: setup times
        --   setup time is minimum time before the referent signal edge the
        --   input should be stable
        tsetup_CSNeg_SCK       : VitalDelayType := UnitDelay; -- tCSS /
        tsetup_SI_SCK          : VitalDelayType := UnitDelay; -- tSU:DAT /
        tsetup_SI_SCK_double_noedge_posedge   : VitalDelayType
										:= UnitDelay; -- tSU:DAT /
        tsetup_WPNeg_CSNeg     : VitalDelayType := UnitDelay; -- tWPS \
        tsetup_RESETNeg_CSNeg  : VitalDelayType := UnitDelay; -- tRH

        -- thold values: hold times
        --   hold time is minimum time the input should be present stable
        --   after the referent signal edge
        thold_CSNeg_SCK        : VitalDelayType := UnitDelay; -- tCSH /
        thold_SI_SCK           : VitalDelayType := UnitDelay; -- tHD:DAT /
        thold_SI_SCK_double_noedge_posedge      : VitalDelayType
											    := UnitDelay; -- tHD:DAT /
        thold_WPNeg_CSNeg      : VitalDelayType    := UnitDelay; -- tWPH /
        thold_CSNeg_RESETNeg   : VitalDelayType    := UnitDelay; -- tRPH

        --tpw values: pulse width
        tpw_SCK_serial_posedge  : VitalDelayType := UnitDelay; -- tWH
        tpw_SCK_fast_posedge    : VitalDelayType := UnitDelay; -- tWH
        tpw_SCK_qddr_posedge    : VitalDelayType := UnitDelay; -- tWH
        tpw_SCK_serial_negedge  : VitalDelayType := UnitDelay; -- tWL
        tpw_SCK_fast_negedge    : VitalDelayType := UnitDelay; -- tWL
        tpw_SCK_qddr_negedge    : VitalDelayType := UnitDelay; -- tWL
        tpw_CSNeg_posedge       : VitalDelayType := UnitDelay; -- tCS
        tpw_CSNeg_rst_quad_posedge  : VitalDelayType := UnitDelay; -- tCS
        tpw_CSNeg_wip_posedge   : VitalDelayType := UnitDelay; -- tCS
        tpw_RESETNeg_negedge    : VitalDelayType := UnitDelay; -- tRP
        tpw_RESETNeg_posedge    : VitalDelayType := UnitDelay; -- tRS

        -- tperiod min (calculated as 1/max freq)
        tperiod_SCK_serial_rd   : VitalDelayType := UnitDelay; --fSCK=50MHz
        tperiod_SCK_fast_rd     : VitalDelayType := UnitDelay; --fSCK=133MHz
        tperiod_SCK_qddr        : VitalDelayType := UnitDelay; --fSCK=80MHz 

        -- tdevice values: values for internal delays
        --timing values that are internal to the model and not associated
        --with any port.
        -- WRR Cycle Time
        tdevice_WRR              : VitalDelayType := 750 ms;  --tW
        -- Page Program Operation
        tdevice_PP_256           : VitalDelayType := 900 us;  --tPP
        -- Page Program Operation
 		tdevice_PP_512           : VitalDelayType := 950 us;  --tPP

        -- Sector Erase Operation
        tdevice_SE4              : VitalDelayType := 725 ms; --tSE
        -- Sector Erase Operation
        tdevice_SE256            : VitalDelayType := 2900 ms; --tSE

        -- Bulk Erase Operation
        tdevice_BE               : VitalDelayType := 360 sec; --tBE
        -- Evaluate Erase Status Time
        tdevice_EES              : VitalDelayType := 100 us;  --tEES
        -- Suspend latency
        tdevice_SUSP            : VitalDelayType := 40 us;   --tESL
        -- Resume to next Suspend Time
        tdevice_RS              : VitalDelayType := 100 us;   --tPSL
        -- RESET# Low to CS# Low
        tdevice_RPH             : VitalDelayType := 35 us;   --tRPH
        -- CS# High before HW Reset (Quad mode and Reset Feature are enabled)
        tdevice_CS              : VitalDelayType := 20 ns;   --tRPH
        -- VDD (min) to CS# Low
        tdevice_PU              : VitalDelayType := 300 us;  --tPU

    ---------------------------------------------------------------------------
    -- CONTROL GENERICS:
    ---------------------------------------------------------------------------
        -- generic control parameters
        InstancePath      : STRING    := DefaultInstancePath;
        TimingChecksOn    : BOOLEAN   := DefaultTimingChecks;
        MsgOn             : BOOLEAN   := DefaultMsgOn;
        XOn               : BOOLEAN   := DefaultXon;
        -- memory file to be loaded
        mem_file_name     : STRING    := "s25fs256s.mem";
        otp_file_name     : STRING    := "s25fs256sOTP.mem";

        UserPreload       : BOOLEAN   := FALSE; --TRUE;
        LongTimming       : BOOLEAN   := TRUE;

		BootConfig        : BOOLEAN   := TRUE;

        -- For FMF SDF technology file usage
        TimingModel       : STRING
    );
    PORT (
        -- Data Inputs/Outputs
        SI                : INOUT std_ulogic := 'U'; -- serial data input/IO0
        SO                : INOUT std_ulogic := 'U'; -- serial data output/IO1
        -- Controls
        SCK               : IN    std_ulogic := 'U'; -- serial clock input
        CSNeg             : IN    std_ulogic := 'U'; -- chip select input
        WPNeg             : INOUT std_ulogic := 'U'; -- write protect input/IO2
        RESETNeg          : INOUT std_ulogic := 'U'  -- hold input/IO3
    );

    ATTRIBUTE VITAL_LEVEL0 of s25fs256s : ENTITY IS TRUE;
END s25fs256s;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------

ARCHITECTURE vhdl_behavioral_static_memory_allocation of s25fs256s IS
    ATTRIBUTE VITAL_LEVEL0 OF
    vhdl_behavioral_static_memory_allocation : ARCHITECTURE IS TRUE;

    ---------------------------------------------------------------------------
    -- CONSTANT AND SIGNAL DECLARATION
    ---------------------------------------------------------------------------
    --Declaration of constants - memory characteristics
        -- The constant declared here are used to enable the creation of models
        -- of memories within a family with a minimum amount of editing

    CONSTANT PartID        : STRING  := "s25fs256s";
    CONSTANT MaxData       : NATURAL := 16#FF#;        --255;
    CONSTANT MemSize       : NATURAL := 16#1FFFFFF#;
    CONSTANT SecNumUni     : NATURAL :=  511;
    CONSTANT SecNumHyb     : NATURAL :=  519;
    CONSTANT BlockNumUni   : NATURAL :=  127;
    CONSTANT BlockNumHyb   : NATURAL :=  135;
    CONSTANT SecSize256    : NATURAL := 16#3FFFF#;     --256KB
    CONSTANT SecSize64     : NATURAL := 16#FFFF#;     --64KB
    CONSTANT SecSize4      : NATURAL := 16#FFF#;     --4KB
    CONSTANT AddrRANGE     : NATURAL := 16#1FFFFFF#;
    CONSTANT HiAddrBit     : NATURAL := 31;
    CONSTANT OTPSize       : NATURAL := 1023;
    CONSTANT OTPLoAddr     : NATURAL := 16#000#;
    CONSTANT OTPHiAddr     : NATURAL := 16#3FF#;
    CONSTANT SFDPLoAddr    : NATURAL := 16#0000#;
    CONSTANT SFDPHiAddr    : NATURAL := 16#1151#;
    CONSTANT SFDPLength    : NATURAL := 16#1151#;
    CONSTANT CFILength     : NATURAL := 16#BF#;
    CONSTANT BYTE          : NATURAL := 8;

    -- Declaration of signals that will hold the delayed values of ports
    SIGNAL SI_ipd          : std_ulogic := 'U';
    SIGNAL SO_ipd          : std_ulogic := 'U';
    SIGNAL SCK_ipd         : std_ulogic := 'U';
    SIGNAL CSNeg_ipd       : std_ulogic := 'U';
    SIGNAL RESETNeg_ipd    : std_ulogic := 'U';
    SIGNAL WPNeg_ipd       : std_ulogic := 'U';

    SIGNAL RESETNeg_pullup : std_ulogic := 'U';
    SIGNAL WPNeg_pullup    : std_ulogic := 'U';

    -- internal delays
    SIGNAL WRR_in          : std_ulogic := '0';
    SIGNAL WRR_out         : std_ulogic := '0';
    SIGNAL PP_256_in       : std_ulogic := '0';
    SIGNAL PP_256_out      : std_ulogic := '0';
    SIGNAL PP_512_in       : std_ulogic := '0';
    SIGNAL PP_512_out      : std_ulogic := '0';
    SIGNAL SE4_in          : std_ulogic := '0';
    SIGNAL SE4_out         : std_ulogic := '0';
    SIGNAL SE256_in        : std_ulogic := '0';
    SIGNAL SE256_out       : std_ulogic := '0';
    SIGNAL BE_in           : std_ulogic := '0';
    SIGNAL BE_out          : std_ulogic := '0';
    SIGNAL EES_in          : std_ulogic := '0';
    SIGNAL EES_out         : std_ulogic := '0';
    SIGNAL ERSSUSP_in      : std_ulogic := '0';
    SIGNAL ERSSUSP_out     : std_ulogic := '0';
    SIGNAL PRGSUSP_in      : std_ulogic := '0';
    SIGNAL PRGSUSP_out     : std_ulogic := '0';
    SIGNAL ERSSUSP_tmp_in  : std_ulogic := '0';
    SIGNAL ERSSUSP_tmp_out : std_ulogic := '0';
    SIGNAL PRGSUSP_tmp_in  : std_ulogic := '0';
    SIGNAL PRGSUSP_tmp_out : std_ulogic := '0';
    SIGNAL RS_in           : std_ulogic := '0';
    SIGNAL RS_out          : std_ulogic := '0';
    SIGNAL RPH_in          : std_ulogic := '0';
    SIGNAL RPH_out         : std_ulogic := '0';
    SIGNAL CS_in           : std_ulogic := '0';
    SIGNAL CS_out          : std_ulogic := '1';
    SIGNAL PU_in           : std_ulogic := '0';
    SIGNAL PU_out          : std_ulogic := '0';
    SIGNAL PPBERASE_in     : std_ulogic := '0';
    SIGNAL PPBERASE_out    : std_ulogic := '0';
    SIGNAL PASSULCK_in     : std_ulogic := '0';
    SIGNAL PASSULCK_out    : std_ulogic := '0';

	SIGNAL SECURE_OPN      : std_logic := '0';

    ---------------------------------------------------------------------------
    -- Memory data initial value.
    ---------------------------------------------------------------------------
    SHARED VARIABLE max_data     : NATURAL := 16#FF#;

BEGIN
    ---------------------------------------------------------------------------
    -- Internal Delays
    ---------------------------------------------------------------------------
    -- Artificial VITAL primitives to incorporate internal delays
    -- Because a tdevice generics is used, there must be a VITAL_primitives
    -- assotiated with them
    WRR    : VitalBuf(WRR_out,     WRR_in,    (tdevice_WRR     ,UnitDelay));
    PP_256 : VitalBuf(PP_256_out,  PP_256_in, (tdevice_PP_256   ,UnitDelay));
    PP_512 : VitalBuf(PP_512_out,  PP_512_in, (tdevice_PP_512   ,UnitDelay));
    SE4    : VitalBuf(SE4_out,     SE4_in,    (tdevice_SE4     ,UnitDelay));
    SE256  : VitalBuf(SE256_out,   SE256_in,  (tdevice_SE256   ,UnitDelay));
    BE     : VitalBuf(BE_out,      BE_in,     (tdevice_BE      ,UnitDelay));
    EES    : VitalBuf(EES_out,     EES_in,    (tdevice_EES     ,UnitDelay));
    ESUSP  : VitalBuf(ERSSUSP_tmp_out, ERSSUSP_tmp_in, (tdevice_SUSP
															 ,UnitDelay));
    PSUSP  : VitalBuf(PRGSUSP_tmp_out, PRGSUSP_tmp_in, (tdevice_SUSP
															 ,UnitDelay));
    RS     : VitalBuf(RS_out,      RS_in,     (tdevice_RS      ,UnitDelay));
    RPH    : VitalBuf(RPH_out,     RPH_in,    (tdevice_RPH     ,UnitDelay));
    CS     : VitalBuf(CS_out,      CS_in,     (tdevice_CS      ,UnitDelay));
    PU     : VitalBuf(PU_out,      PU_in,     (tdevice_PU      ,UnitDelay));

    ---------------------------------------------------------------------------
    -- Wire Delays
    ---------------------------------------------------------------------------
    WireDelay : BLOCK
    BEGIN

        w_1 : VitalWireDelay (SI_ipd,      SI,      tipd_SI);
        w_2 : VitalWireDelay (SO_ipd,      SO,      tipd_SO);
        w_3 : VitalWireDelay (SCK_ipd,     SCK,     tipd_SCK);
        w_4 : VitalWireDelay (CSNeg_ipd,   CSNeg,   tipd_CSNeg);
        w_5 : VitalWireDelay (RESETNeg_ipd,RESETNeg,tipd_RESETNeg);
        w_6 : VitalWireDelay (WPNeg_ipd,   WPNeg,   tipd_WPNeg);

    END BLOCK;

    ---------------------------------------------------------------------------
    -- Main Behavior Block
    ---------------------------------------------------------------------------
    Behavior: BLOCK

        PORT (
            SIIn           : IN    std_ulogic := 'U';
            SIOut          : OUT   std_ulogic := 'U';
            SOIn           : IN    std_logic  := 'U';
            SOut           : OUT   std_logic  := 'U';
            SCK            : IN    std_ulogic := 'U';
            CSNeg          : IN    std_ulogic := 'U';
            RESETNegIn     : IN    std_ulogic := 'U';
            RESETNegOut    : OUT   std_ulogic := 'U';
            WPNegIn        : IN    std_ulogic := 'U';
            WPNegOut       : OUT   std_ulogic := 'U'
        );

        PORT MAP (
             SIIn       => SI_ipd,
             SIOut      => SI,
             SOIn       => SO_ipd,
             SOut       => SO,
             SCK        => SCK_ipd,
             CSNeg      => CSNeg_ipd,

             RESETNegIn  => RESETNeg_ipd,
             RESETNegOut => RESETNeg,
             WPNegIn    => WPNeg_ipd,
             WPNegOut   => WPNeg
        );

        -- State Machine : State_Type
        TYPE state_type IS (IDLE,
                            RESET_STATE,
                            PGERS_ERROR,
                            WRITE_SR,
							WRITE_ALL_REG,
                            PAGE_PG,
                            OTP_PG,
                            PG_SUSP,
                            SECTOR_ERS,
                            BULK_ERS,
                            ERS_SUSP,
                            ERS_SUSP_PG,
                            ERS_SUSP_PG_SUSP,
                            PASS_PG,
                            PASS_UNLOCK,
                            PPB_PG,
                            PPB_ERS,
                            ASP_PG,
                            PLB_PG,
                            DYB_PG,
                            NVDLR_PG,
							BLANK_CHECK,
							EVAL_ERS_STAT
                            );

        -- Instruction Type
        TYPE instruction_type IS ( NONE,
								   WRR,
								   PP,
								   READ,
								   WRDI,
								   RDSR1,
								   WREN,
								   RDSR2,
								   PP4,
								   READ4,
								   ECCRD4,
								   ECCRD,
								   P4E,
								   P4E4,
								   CLSR,
								   EPR,
								   RDCR,
								   DLPRD,
								   OTPP ,
								   PNVDLR,
								   BE,
								   RDAR,
								   RSTEN,
								   WRAR,
								   EPS,
								   RSTCMD,
								   FAST_READ,
								   FAST_READ4,
								   ASPRD,
								   ASPP,
								   WVDLR,
								   OTPR,
								   RSFDP,
								   RDID,
								   PLBWR,
								   PLBRD,
								   RDQID,
								   BAM4,
								   DIOR,
								   DIOR4,
								   SBL,
								   EES,
								   SE,
								   SE4,
								   DYBRD4,
								   DYBWR4,
								   PPBRD4,
								   PPBP4,
								   PPBE,
								   PASSRD,
								   PASSP,
								   PASSU,
								   QIOR,
								   QIOR4,
								   DDRQIOR,
								   DDRQIOR4,
								   RESET,
								   DYBRD,
								   DYBWR,
								   PPBRD,
								   PPBP,
								   MBR
                                );

        TYPE WByteType IS ARRAY (0 TO 511) OF INTEGER RANGE -1 TO MaxData;
        -- Flash Memory Array
        TYPE MemArray IS ARRAY (0 TO AddrRANGE) OF INTEGER RANGE -1 TO MaxData;
        -- OTP Memory Array
        TYPE OTPArray IS ARRAY (OTPLoAddr TO OTPHiAddr) OF INTEGER
                                                    RANGE -1 TO MaxData;
        --CFI Array (Common Flash Interface Query codes)
        TYPE SFDPtype  IS ARRAY (0 TO SFDPLength) OF
                                              INTEGER RANGE -1 TO 16#FF#;
        -----------------------------------------------------------------------
        --  memory declaration
        -----------------------------------------------------------------------
        -- Main Memory
        SHARED VARIABLE Mem          : MemArray  := (OTHERS => MaxData);
        -- OTP Sector
        SHARED VARIABLE OTPMem       : OTPArray  := (OTHERS => MaxData);
        --CFI Array
        --SFDP Array
        SHARED VARIABLE SFDP_array    : SFDPtype   := (OTHERS => 0);
        SHARED VARIABLE CFI_array_tmp :
								std_logic_vector(8*(CFILength+1)-1 downto 0);
        SHARED VARIABLE CFI_tmp1 : NATURAL RANGE 0 TO  MaxData;
        SHARED VARIABLE CFI_tmp : std_logic_vector(7 downto 0);

        SHARED VARIABLE SFDP_array_tmp :
								std_logic_vector(8*(SFDPLength+1)-1 downto 0);
        SHARED VARIABLE SFDP_tmp : std_logic_vector(7 downto 0);

        -- Programming Buffer
        SIGNAL WByte                 : WByteType := (OTHERS => MaxData);

        -- states
        SIGNAL current_state         : state_type;
        SIGNAL next_state            : state_type;

        SIGNAL Instruct              : instruction_type;
        --zero delay signal
        SIGNAL SOut_zd               : std_logic := 'Z';
        SIGNAL SIOut_zd              : std_logic := 'Z';
        SIGNAL RESETNegOut_zd        : std_logic := 'Z';
        SIGNAL WPNegOut_zd           : std_logic := 'Z';

        -- powerup
        SIGNAL PoweredUp             : std_logic := '0';

        -----------------------------------------------------------------------
        -- Registers
        -----------------------------------------------------------------------
        --     ***  Status Register 1  ***

        SIGNAL SR1_in   : std_logic_vector(7 downto 0)   := (others => '0');
    	-- Nonvolatile Status Register 1
        SIGNAL  SR1_NV   : std_logic_vector(7 downto 0)   := (others => '0');

        ALIAS SRWD_NV      :std_logic IS SR1_NV(6);
        ALIAS BP2_NV       :std_logic IS SR1_NV(4);
        ALIAS BP1_NV       :std_logic IS SR1_NV(3);
        ALIAS BP0_NV       :std_logic IS SR1_NV(2);

    	-- Volatile Status Register 1
        SIGNAL  SR1_V   : std_logic_vector(7 downto 0)   := (others => '0');

        -- Status Register Write Disable Bit
        ALIAS SRWD      :std_logic IS SR1_V(7);
        -- Status Register Programming Error Bit
        ALIAS P_ERR     :std_logic IS SR1_V(6);
        -- Status Register Erase Error Bit
        ALIAS E_ERR     :std_logic IS SR1_V(5);
        -- Status Register Block Protection Bits
        ALIAS BP2       :std_logic IS SR1_V(4);
        ALIAS BP1       :std_logic IS SR1_V(3);
        ALIAS BP0       :std_logic IS SR1_V(2);
        -- Status Register Write Enable Latch Bit
        ALIAS WEL       :std_logic IS SR1_V(1);
        -- Status Register Write In Progress Bit
        ALIAS WIP       :std_logic IS SR1_V(0);

    	-- Volatile Status Register 2
        SIGNAL SR2_V   : std_logic_vector(7 downto 0)
                                                := (others => '0');
        -- Erase status
        ALIAS ESTAT        :std_logic IS SR2_V(2);
        -- Erase suspend
        ALIAS ES        :std_logic IS SR2_V(1);
        -- Program suspend
        ALIAS PS        :std_logic IS SR2_V(0);

        -- Nonvolatile Configuration Register 1
        SIGNAL CR1_in   : std_logic_vector(7 downto 0)
                                                := (others => '0');
        SIGNAL CR1_NV   : std_logic_vector(7 downto 0)
                                                := (others => '0');
        -- Configuration Register TBPROT bit
        ALIAS TBPROT_O    :std_logic IS CR1_NV(5);
        -- Configuration Register LOCK bit
        ALIAS LOCK_O      :std_logic IS CR1_NV(4);
        -- Configuration Register BPNV bit
        ALIAS BPNV_O      :std_logic IS CR1_NV(3);
        -- Configuration Register TBPARM bit
        ALIAS TBPARM_O    :std_logic IS CR1_NV(2);
        -- Configuration Register QUAD bit
        ALIAS QUAD_O      :std_logic IS CR1_NV(1);

		--Volatile Configuration Register 1
        SIGNAL CR1_V   : std_logic_vector(7 downto 0)
                                                := (others => '0');
        -- Configuration Register TBPROT bit
        ALIAS TBPROT    :std_logic IS CR1_V(5);
        -- Configuration Register LOCK bit
        ALIAS LOCK      :std_logic IS CR1_V(4);
        -- Configuration Register BPNV bit
        ALIAS BPNV      :std_logic IS CR1_V(3);
        -- Configuration Register TBPARM bit
        ALIAS TBPARM    :std_logic IS CR1_V(2);
        -- Configuration Register QUAD bit
        ALIAS QUAD      :std_logic IS CR1_V(1);
        -- Configuration Register FREEZE bit
        ALIAS FREEZE      :std_logic IS CR1_V(0);

		-- Nonvolatile Configuration Register 2
        SIGNAL CR2_NV   : std_logic_vector(7 downto 0)
                                                := "00001000";
		-- Volatile Configuration Register 2
        SIGNAL CR2_V   : std_logic_vector(7 downto 0)
                                                := "00001000";
        -- Configuration Register 2 QUAD_ALL bit
        ALIAS  QUAD_ALL    :std_logic IS CR2_V(6);

		-- Nonvolatile Configuration Register 3
        SIGNAL CR3_NV   : std_logic_vector(7 downto 0)
                                                := (others => '0');
		-- Volatile Configuration Register 3
        SIGNAL CR3_V   : std_logic_vector(7 downto 0)
                                                := (others => '0');
		-- Nonvolatile Configuration Register 4
        SIGNAL CR4_NV   : std_logic_vector(7 downto 0)
                                                := (others => '0');
		-- Volatile Configuration Register 4
        SIGNAL CR4_V   : std_logic_vector(7 downto 0)
                                                := (others => '0');

        --  VDLR Register
        SHARED VARIABLE VDLR_reg      : std_logic_vector(7 downto 0)
                                                := "00000000";
        SIGNAL VDLR_reg_in            : std_logic_vector(7 downto 0)
                                                := (others => '0');

        -- NVDLR Register
        SHARED VARIABLE NVDLR_reg     : std_logic_vector(7 downto 0)
                                                := "00000000";
        SIGNAL NVDLR_reg_in           : std_logic_vector(7 downto 0)
                                                := (others => '0');
        -- ASP Register
        SHARED VARIABLE ASP_reg        : std_logic_vector(15 downto 0)
                                                     := (others => '1');
        SIGNAL ASP_reg_in              : std_logic_vector(15 downto 0)
                                                     := (others => '1');
        --DYB Lock Boot Bit
        ALIAS DYBLBB      :std_logic IS ASP_reg(4);
        --PPB OTP Bit
        ALIAS PPBOTP    :std_logic IS ASP_reg(3);
        -- Password Protection Mode Lock Bit
        ALIAS PWDMLB    :std_logic IS ASP_reg(2);
        --Persistent Protection Mode Lock Bit
        ALIAS PSTMLB    :std_logic IS ASP_reg(1);
        --Permanent Protection Lock bit
        ALIAS PERMLB    :std_logic IS ASP_reg(0);

        --      ***  Password Register  ***
        SHARED VARIABLE Password_reg   : std_logic_vector(63 downto 0)
                                                := (others => '1');
        SIGNAL Password_reg_in         : std_logic_vector(63 downto 0)
                                                := (others => '1');
        --      ***  PPB Lock Register  ***
        SHARED VARIABLE PPBL           : std_logic_vector(7 downto 0)
                                                := "00000001";
        SIGNAL PPBL_in                 : std_logic_vector(7 downto 0)
                                                := "00000001";
        --Persistent Protection Mode Lock Bit
        ALIAS PPB_LOCK                  : std_logic IS PPBL(0);
        SIGNAL PPB_LOCK_temp            : std_ulogic := '0';
        --      ***  PPB Access Register  ***
        SHARED VARIABLE PPBAR          : std_logic_vector(7 downto 0)
                                                := (others => '1');
        SIGNAL PPBAR_in                : std_logic_vector(7 downto 0)
                                                := (others => '1');
        -- PPB_bits(Sec)
        SHARED VARIABLE PPB_bits       : std_logic_vector(SecNumHyb downto 0)
                                                := (OTHERS => '1');
        -- PPB_bits_b(block_e)
        SHARED VARIABLE PPB_bits_b     : std_logic_vector(BlockNumHyb downto 0)
                                                := (OTHERS => '1');																				
        --      ***  DYB Access Register  ***
        SHARED VARIABLE DYBAR          : std_logic_vector(7 downto 0)
                                                := (others => '1');
        SIGNAL DYBAR_in                : std_logic_vector(7 downto 0)
                                                := (others => '1');
        -- DYB(Sec)
        SHARED VARIABLE DYB_bits       : std_logic_vector(SecNumHyb downto 0)
												:= (others => '1');
        -- DYB_bits_b(block_e)
        SHARED VARIABLE DYB_bits_b     : std_logic_vector(BlockNumHyb downto 0)
                                                := (OTHERS => '1');	

        SHARED VARIABLE WRAR_reg_in    : std_logic_vector(7 downto 0)
                                                := (others => '0');
        SHARED VARIABLE RDAR_reg                : std_logic_vector(7 downto 0)
                                                := (others => '0');
        SIGNAL SBL_data_in             : std_logic_vector(7 downto 0)
                                                := (others => '0');

        SHARED VARIABLE ECC_reg        : std_logic_vector(7 downto 0)
                                                := (others => '0');
        -- The Lock Protection Registers for OTP Memory space
        SHARED VARIABLE LOCK_BYTE1 :std_logic_vector(7 downto 0);
        SHARED VARIABLE LOCK_BYTE2 :std_logic_vector(7 downto 0);
        SHARED VARIABLE LOCK_BYTE3 :std_logic_vector(7 downto 0);
        SHARED VARIABLE LOCK_BYTE4 :std_logic_vector(7 downto 0);

        --Command Register
        SIGNAL write              : std_logic := '0';
        SIGNAL cfg_write          : std_logic := '0';
        SIGNAL read_out           : std_logic := '0';

        SIGNAL dual               : boolean   := false;
        SIGNAL rd_fast            : boolean   := true;
        SIGNAL rd_slow            : boolean   := false;
        SIGNAL ddr                : boolean   := false;
        SIGNAL any_read           : boolean   := false;

        SIGNAL oe                 : boolean   := false;
        SIGNAL oe_z               : boolean   := false;

        -- Memory Array Configuration
        SIGNAL BottomBoot          : boolean  := BootConfig;
        SIGNAL TopBoot             : boolean  := NOT BootConfig;
        SIGNAL UniformSec          : boolean  := false;

        --FSM control signals
        SIGNAL PDONE              : std_logic := '1'; --Page Prog. Done
        SIGNAL PSTART             : std_logic := '0'; --Start Page Programming
        SIGNAL PGSUSP             : std_logic := '0'; --Suspend Program
        SIGNAL PGRES              : std_logic := '0'; --Resume Program

        SIGNAL RES_TO_SUS_TIME    : std_logic := '0';--Resume to Suspend Flag

        SIGNAL WDONE              : std_logic := '1'; --Write operation Done
        SIGNAL WSTART             : std_logic := '0'; --Start Write operation

        SIGNAL CSDONE             : std_logic := '1'; --Write volatile bits
        SIGNAL CSSTART            : std_logic := '0'; --Start Write volatile bits

        SIGNAL EESDONE            : std_logic := '1'; --Evaluate Erase Status Done
        SIGNAL EESSTART           : std_logic := '0'; --Start Evaluate Erase Status operation

        SIGNAL ESTART             : std_logic := '0'; --Start Erase operation
        SIGNAL EDONE              : std_logic := '1'; --Erase operation Done
        SIGNAL ESUSP              : std_logic := '0'; --Suspend Erase
        SIGNAL ERES               : std_logic := '0'; --Resume Erase

        SIGNAL BCDONE             : std_logic := '1';

        --reset timing
        SIGNAL RST                 : std_logic := '0';
        SIGNAL reseted             : std_logic := '0'; --Reset Timing Control
        SIGNAL RST_in              : std_logic := '0';
        SIGNAL RST_out             : std_logic := '1';
        SIGNAL SWRST_in            : std_logic := '0';
        SIGNAL SWRST_out           : std_logic := '1';
        SIGNAL RESET_EN            : std_logic := '0';
        SIGNAL reset_act           : boolean;
        SIGNAL rst_quad            : boolean;
        SIGNAL double              : boolean;

        --Flag that mark if ASP Register is allready programmed
        SIGNAL ASPOTPFLAG         : BOOLEAN   := FALSE;
        SIGNAL INITIAL_CONFIG     : std_logic := '0';

        SHARED VARIABLE SectorErased  : NATURAL RANGE 0 TO SecNumHyb := 0;
        SHARED VARIABLE BlockErased   : NATURAL RANGE 0 TO BlockNumHyb := 0;
        SHARED VARIABLE SecAddr_pgm   : NATURAL RANGE 0 TO SecNumHyb := 0;

        SHARED VARIABLE pgm_page  : NATURAL;

        SHARED VARIABLE ASP_ProtSE  : NATURAL   := 0;
        SHARED VARIABLE Sec_ProtSE  : NATURAL   := 0;

        --Flag for Password unlock command
        SIGNAL PASS_UNLOCKED      : boolean   := FALSE;
        SIGNAL PASS_TEMP          : std_logic_vector(63 downto 0)
                                                := (others => '1');
        SHARED VARIABLE EHP       : BOOLEAN := FALSE;

        SHARED VARIABLE read_cnt  : NATURAL := 0;
        SHARED VARIABLE byte_cnt  : NATURAL := 1;
        SHARED VARIABLE read_addr : NATURAL;

        SHARED VARIABLE start_delay : NATURAL RANGE 0 TO 7;

        SIGNAL change_addr        : std_logic := '0';
        SIGNAL Address            : NATURAL;
        SIGNAL ERS_nosucc         : std_logic_vector(SecNumHyb downto 0)
                                                 := (OTHERS => '0');
        SIGNAL ERS_nosucc_b       : std_logic_vector(BlockNumHyb downto 0)
                                                 := (OTHERS => '0');
        -- Sector is protect if Sec_Prot(SecNum) = '1'
        SHARED VARIABLE Sec_Prot  : std_logic_vector(SecNumHyb downto 0) :=
                                                   (OTHERS => '0');
        SHARED VARIABLE Block_Prot: std_logic_vector(BlockNumHyb downto 0) :=
                                                   (OTHERS => '0');

        SIGNAL change_BP          : std_logic := '0';
        SHARED VARIABLE BP_bits   : std_logic_vector(2 downto 0) := "000";
        SIGNAL change_TBPARM      : std_logic := '0';

        SIGNAL PageSize    : NATURAL RANGE 0 TO 512;

        SIGNAL Byte_number        : NATURAL RANGE 0 TO 511    := 0;

        TYPE bus_cycle_type IS (STAND_BY,
                                OPCODE_BYTE,
                                ADDRESS_BYTES,
                                DUMMY_BYTES,
                                MODE_BYTE,
                                DATA_BYTES
                                );
        SHARED VARIABLE bus_cycle_state    : bus_cycle_type;
        -- switch between Data bytes and Dummy bytes
        SHARED VARIABLE DummyBytes_act     : X01 := '0';
        SIGNAL dummy_cnt_act_temp          : NATURAL := 0;
        SIGNAL dummy_cnt_act               : NATURAL := 0;

        SHARED VARIABLE Latency_code       : NATURAL;
        SHARED VARIABLE WrapLength         : NATURAL RANGE 0 TO 64;
        SHARED VARIABLE opcode_cnt         : NATURAL := 0;
        SHARED VARIABLE addr_cnt           : NATURAL := 0;
        SHARED VARIABLE mode_cnt           : NATURAL := 0;
        SHARED VARIABLE dummy_cnt          : NATURAL := 0;
        SHARED VARIABLE data_cnt           : NATURAL := 0;
        SHARED VARIABLE ZERO_DETECTED      : std_logic;

        -- Flag for Blank Check
        SIGNAL NOT_BLANK                   : std_ulogic := '0';
        SIGNAL bc_done                     : std_ulogic := '0';

        SIGNAL RES_TO_SUSP_TIME            : std_ulogic := '0';
		SIGNAL res_time                    : time;

        -- timing check violation
        SIGNAL Viol               : X01 := '0';

		FUNCTION ReturnSectorID(ADDR       : NATURAL;
								BottomBoot : BOOLEAN;
								TopBoot    : BOOLEAN) RETURN NATURAL IS
			VARIABLE result : NATURAL;
			VARIABLE conv   : NATURAL;
		BEGIN
			conv := ADDR / (SecSize64+1);
			IF BottomBoot THEN
				IF conv=0 AND ADDR<(8*(SecSize4+1)) THEN
					result := ADDR/(SecSize4+1);
				ELSIF conv=0 AND ADDR>=8*(SecSize4+1) THEN
					result := 8;
				ELSE
					result := conv + 8;
				END IF;
			ELSIF TopBoot THEN
				IF conv=511 AND ADDR<(AddrRANGE+1 - 8*(SecSize4+1)) THEN
					result := 511;
				ELSIF conv=511 AND ADDR>(AddrRANGE - 8*(SecSize4+1)) THEN
					result := 512 + (ADDR -
					(AddrRANGE+1 - 8*(SecSize4+1)))/(SecSize4+1);
				ELSE
					result := conv;
				END IF;
			ELSE
				result := conv;
			END IF;
			RETURN result;
		END ReturnSectorID;

		FUNCTION ReturnBlockID (ADDR       : NATURAL;
								BottomBoot : BOOLEAN;
								TopBoot    : BOOLEAN) RETURN NATURAL IS
			VARIABLE result : NATURAL;
			VARIABLE conv   : NATURAL;
		BEGIN
			conv := ADDR / (SecSize256+1);
			IF BottomBoot THEN
				IF conv=0 AND ADDR<(8*(SecSize4+1)) THEN
					result := ADDR/(SecSize4+1);
				ELSIF conv=0 AND ADDR>=8*(SecSize4+1) THEN
					result := 8;
				ELSE
					result := conv + 8;
				END IF;
			ELSIF TopBoot THEN
				IF conv=511 AND ADDR<(AddrRANGE+1 - 8*(SecSize4+1)) THEN
					result := 511;
				ELSIF conv=511 AND ADDR>(AddrRANGE - 8*(SecSize4+1)) THEN
					result := 512 + (ADDR -
					(AddrRANGE+1 - 8*(SecSize4+1)))/(SecSize4+1);
				ELSE
					result := conv;
				END IF;
			ELSE
				result := conv;
			END IF;
			RETURN result;
		END ReturnBlockID;

    BEGIN
    ---------------------------------------------------------------------------
    --Power Up time
    ---------------------------------------------------------------------------

    PoweredUp <= '1' AFTER tdevice_PU;
	reset_act <= CR2_V(5)='1' AND (QUAD='0' OR (QUAD='1' AND CSNeg='1'));
    rst_quad <= TRUE WHEN (CR2_V(5) = '1') AND (QUAD = '1')  ELSE  FALSE;

	res_time <= tdevice_RS WHEN LongTimming  ELSE tdevice_RS/10;

    PageSize <= 255 WHEN CR3_V(4)='0' ELSE 511;

    TimingModelSel: PROCESS
    BEGIN
        IF TimingModel(15)='0' OR TimingModel(15)='2' OR
		TimingModel(15)='3' THEN
            SECURE_OPN <= '0';
        ELSIF TimingModel(15)='Y' OR TimingModel(15)='y' OR
		TimingModel(15)='Z' OR TimingModel(15)='z' THEN
            SECURE_OPN <= '1';
		END IF;
        WAIT;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- VITAL Timing Checks Procedures
    ---------------------------------------------------------------------------
    VITALTimingCheck: PROCESS(SIIn, SOIn, SCK_ipd, CSNeg_ipd, RESETNeg_ipd,
                              WPNegIn)

        -- Timing Check Variables
        -- Setup/Hold Checks variables
        VARIABLE Tviol_CSNeg_SCK  : X01 := '0';
        VARIABLE TD_CSNeg_SCK     : VitalTimingDataType;

        VARIABLE Tviol_SI_SCK            : X01 := '0';
        VARIABLE TD_SI_SCK               : VitalTimingDataType;

        VARIABLE Tviol_SI_SCK_ddr_R      : X01 := '0';
        VARIABLE TD_SI_SCK_ddr_R         : VitalTimingDataType;

        VARIABLE Tviol_SI_SCK_ddr_F      : X01 := '0';
        VARIABLE TD_SI_SCK_ddr_F         : VitalTimingDataType;


        VARIABLE Tviol_SO_SCK            : X01 := '0';
        VARIABLE TD_SO_SCK               : VitalTimingDataType;

        VARIABLE Tviol_SO_SCK_ddr_R      : X01 := '0';
        VARIABLE TD_SO_SCK_ddr_R         : VitalTimingDataType;

        VARIABLE Tviol_SO_SCK_ddr_F      : X01 := '0';
        VARIABLE TD_SO_SCK_ddr_F         : VitalTimingDataType;


        VARIABLE Tviol_WPNeg_SCK         : X01 := '0';
        VARIABLE TD_WPNeg_SCK            : VitalTimingDataType;

        VARIABLE Tviol_WPNeg_SCK_ddr_R   : X01 := '0';
        VARIABLE TD_WPNeg_SCK_ddr_R      : VitalTimingDataType;

        VARIABLE Tviol_WPNeg_SCK_ddr_F   : X01 := '0';
        VARIABLE TD_WPNeg_SCK_ddr_F      : VitalTimingDataType;

        VARIABLE Tviol_RESETNeg_SCK      : X01 := '0';
        VARIABLE TD_RESETNeg_SCK         : VitalTimingDataType;

        VARIABLE Tviol_RESETNeg_SCK_ddr_R   : X01 := '0';
        VARIABLE TD_RESETNeg_SCK_ddr_R      : VitalTimingDataType;

        VARIABLE Tviol_RESETNeg_SCK_ddr_F   : X01 := '0';
        VARIABLE TD_RESETNeg_SCK_ddr_F      : VitalTimingDataType;

        VARIABLE Tviol_WPNeg_CSNeg_setup    : X01 := '0';
        VARIABLE TD_WPNeg_CSNeg_setup       : VitalTimingDataType;

        VARIABLE Tviol_WPNeg_CSNeg_hold     : X01 := '0';
        VARIABLE TD_WPNeg_CSNeg_hold        : VitalTimingDataType;

        VARIABLE Tviol_RESETNeg_CSNeg       : X01 := '0';
        VARIABLE TD_RESETNeg_CSNeg          : VitalTimingDataType;

        VARIABLE Tviol_CSNeg_RESETNeg       : X01 := '0';
        VARIABLE TD_CSNeg_RESETNeg          : VitalTimingDataType;

        --Pulse Width and Period Check Variables
        VARIABLE Pviol_SCK_rd       : X01 := '0';
        VARIABLE PD_SCK_rd          : VitalPeriodDataType
											:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_fast     : X01 := '0';
        VARIABLE PD_SCK_fast        : VitalPeriodDataType
											:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_ddr      : X01 := '0';
        VARIABLE PD_SCK_ddr         : VitalPeriodDataType
											:= VitalPeriodDataInit;

        VARIABLE Pviol_CSNeg      : X01 := '0';
        VARIABLE PD_CSNeg         : VitalPeriodDataType
											:= VitalPeriodDataInit;

        VARIABLE Pviol_CSNeg_rst_quad : X01 := '0';
        VARIABLE PD_CSNeg_rst_quad    : VitalPeriodDataType
											:= VitalPeriodDataInit;

        VARIABLE Pviol_CSNeg_wip    : X01 := '0';
        VARIABLE PD_CSNeg_wip       : VitalPeriodDataType
											:= VitalPeriodDataInit;

        VARIABLE Pviol_RESETNeg     : X01 := '0';
        VARIABLE PD_RESETNeg        : VitalPeriodDataType
											:= VitalPeriodDataInit;

        VARIABLE Violation          : X01 := '0';

    BEGIN
    ---------------------------------------------------------------------------
    -- Timing Check Section
    ---------------------------------------------------------------------------
        IF (TimingChecksOn) THEN

        -- Setup/Hold Check between CS# and SCK
        VitalSetupHoldCheck (
            TestSignal      => CSNeg_ipd,
            TestSignalName  => "CS#",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_CSNeg_SCK,
            SetupLow        => tsetup_CSNeg_SCK,
            HoldHigh        => thold_CSNeg_SCK,
            HoldLow         => thold_CSNeg_SCK,
            CheckEnabled    => true,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_CSNeg_SCK,
            Violation       => Tviol_CSNeg_SCK
        );

        -- Hold Check between CSNeg and RESETNeg
        VitalSetupHoldCheck (
            TestSignal      => CSNeg,
            TestSignalName  => "CSNeg",
            RefSignal       => RESETNeg,
            RefSignalName   => "RESETNeg",
            HoldHigh        => thold_CSNeg_RESETNeg,
            CheckEnabled    => CR2_V(5)='1' AND QUAD='0',
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_CSNeg_RESETNeg,
            Violation       => Tviol_CSNeg_RESETNeg
        );

        -- Setup/Hold Check between SI and SCK, SDR mode
        VitalSetupHoldCheck (
            TestSignal      => SIIn,
            TestSignalName  => "SI",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK,
            SetupLow        => tsetup_SI_SCK,
            HoldHigh        => thold_SI_SCK,
            HoldLow         => thold_SI_SCK,
            CheckEnabled    => PoweredUp='1' AND SIOut_zd /= SIIn,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SI_SCK,
            Violation       => Tviol_SI_SCK
        );

        -- Setup/Hold Check between SI and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => SIIn,
            TestSignalName  => "SI",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_double_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_double_noedge_posedge,
            HoldHigh        => thold_SI_SCK_double_noedge_posedge,
            HoldLow         => thold_SI_SCK_double_noedge_posedge,
            CheckEnabled    => PoweredUp='1' AND double AND
			SIOut_zd/=SIIn,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SI_SCK_ddr_R,
            Violation       => Tviol_SI_SCK_ddr_R
        );

        -- Setup/Hold Check between SI and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => SIIn,
            TestSignalName  => "SI",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_double_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_double_noedge_posedge,
            HoldHigh        => thold_SI_SCK_double_noedge_posedge,
            HoldLow         => thold_SI_SCK_double_noedge_posedge,
            CheckEnabled    => PoweredUp='1' AND double AND
			SIOut_zd/=SIIn,
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SI_SCK_ddr_F,
            Violation       => Tviol_SI_SCK_ddr_F
        );

        -- Setup/Hold Check between SO and SCK, SDR mode
        VitalSetupHoldCheck (
            TestSignal      => SOIn,
            TestSignalName  => "SO",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK,
            SetupLow        => tsetup_SI_SCK,
            HoldHigh        => thold_SI_SCK,
            HoldLow         => thold_SI_SCK,
            CheckEnabled    => PoweredUp='1' AND SOut_zd /= SOIn,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SO_SCK,
            Violation       => Tviol_SO_SCK
        );
        -- Setup/Hold Check between SO and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => SOIn,
            TestSignalName  => "SO",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_double_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_double_noedge_posedge,
            HoldHigh        => thold_SI_SCK_double_noedge_posedge,
            HoldLow         => thold_SI_SCK_double_noedge_posedge,
            CheckEnabled    => PoweredUp='1' AND double AND
			SOut_zd /= SOIn,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SO_SCK_ddr_R,
            Violation       => Tviol_SO_SCK_ddr_R
        );
        -- Setup/Hold Check between SO and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => SOIn,
            TestSignalName  => "SO",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_double_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_double_noedge_posedge,
            HoldHigh        => thold_SI_SCK_double_noedge_posedge,
            HoldLow         => thold_SI_SCK_double_noedge_posedge,
            CheckEnabled    => PoweredUp='1' AND double AND
			SOut_zd /= SOIn,
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SO_SCK_ddr_F,
            Violation       => Tviol_SO_SCK_ddr_F
        );

        -- Setup/Hold Check between WPNeg and SCK, SDR mode
        VitalSetupHoldCheck (
            TestSignal      => WPNegIn,
            TestSignalName  => "WPNeg",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK,
            SetupLow        => tsetup_SI_SCK,
            HoldHigh        => thold_SI_SCK,
            HoldLow         => thold_SI_SCK,
            CheckEnabled    => PoweredUp='1' AND
			WPNegOut_zd /= WPNegIn	AND QUAD='1',
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WPNeg_SCK,
            Violation       => Tviol_WPNeg_SCK
        );
        -- Setup/Hold Check between WPNeg and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => WPNegIn,
            TestSignalName  => "WPNeg",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_double_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_double_noedge_posedge,
            HoldHigh        => thold_SI_SCK_double_noedge_posedge,
            HoldLow         => thold_SI_SCK_double_noedge_posedge,
            CheckEnabled    => PoweredUp='1' AND double AND
			 WPNegOut_zd /= WPNegIn	AND QUAD='1',
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WPNeg_SCK_ddr_R,
            Violation       => Tviol_WPNeg_SCK_ddr_R
        );
        -- Setup/Hold Check between WPNeg and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => WPNegIn,
            TestSignalName  => "WPNeg",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_double_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_double_noedge_posedge,
            HoldHigh        => thold_SI_SCK_double_noedge_posedge,
            HoldLow         => thold_SI_SCK_double_noedge_posedge,
            CheckEnabled    => PoweredUp='1' AND double AND
			WPNegOut_zd /= WPNegIn AND QUAD='1',
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WPNeg_SCK_ddr_F,
            Violation       => Tviol_WPNeg_SCK_ddr_F
        );

        -- Setup/Hold Check between RESETNeg and SCK, SDR mode
        VitalSetupHoldCheck (
            TestSignal      => RESETNegIn,
            TestSignalName  => "RESETNeg",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK,
            SetupLow        => tsetup_SI_SCK,
            HoldHigh        => thold_SI_SCK,
            HoldLow         => thold_SI_SCK,
            CheckEnabled    => PoweredUp='1' AND
			RESETNegOut_zd /= RESETNegIn AND QUAD='1' AND CSNeg='0',
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WPNeg_SCK,
            Violation       => Tviol_RESETNeg_SCK
        );
        -- Setup/Hold Check between RESETNeg and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => RESETNegIn,
            TestSignalName  => "RESETNeg",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_double_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_double_noedge_posedge,
            HoldHigh        => thold_SI_SCK_double_noedge_posedge,
            HoldLow         => thold_SI_SCK_double_noedge_posedge,
            CheckEnabled    => PoweredUp='1' AND double AND
			RESETNegOut_zd /= RESETNegIn AND QUAD='1' AND CSNeg='0',
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_RESETNeg_SCK_ddr_R,
            Violation       => Tviol_RESETNeg_SCK_ddr_R
        );
        -- Setup/Hold Check between RESETNeg and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => RESETNegIn,
            TestSignalName  => "RESETNeg",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_double_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_double_noedge_posedge,
            HoldHigh        => thold_SI_SCK_double_noedge_posedge,
            HoldLow         => thold_SI_SCK_double_noedge_posedge,
            CheckEnabled    => PoweredUp='1' AND double AND
            RESETNegOut_zd /= RESETNegIn AND QUAD='1' AND CSNeg='0',
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_RESETNeg_SCK_ddr_F,
            Violation       => Tviol_RESETNeg_SCK_ddr_F
        );

        -- Setup Check between WP# and CS# \
        VitalSetupHoldCheck (
            TestSignal      => WPNegIn,
            TestSignalName  => "WP#",
            RefSignal       => CSNeg_ipd,
            RefSignalName   => "CS#",
            SetupHigh       => tsetup_WPNeg_CSNeg,
            CheckEnabled    => SRWD='1' AND QUAD='0',
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WPNeg_CSNeg_setup,
            Violation       => Tviol_WPNeg_CSNeg_setup
        );

        -- Hold Check between WP# and CS# /
        VitalSetupHoldCheck (
            TestSignal      => WPNegIn,
            TestSignalName  => "WP#",
            RefSignal       => CSNeg_ipd,
            RefSignalName   => "CS#",
            HoldHigh        => thold_WPNeg_CSNeg,
            CheckEnabled    => SRWD = '1' AND QUAD = '0',
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WPNeg_CSNeg_hold,
            Violation       => Tviol_WPNeg_CSNeg_hold
        );

        -- Setup Check between RESETNeg and CSNeg, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => RESETNeg,
            TestSignalName  => "RESETNeg",
            RefSignal       => CSNeg,
            RefSignalName   => "CSNeg",
            SetupHigh       => tsetup_RESETNeg_CSNeg,
            CheckEnabled    => CR2_V(5)='1' AND QUAD='0',
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_RESETNeg_CSNeg,
            Violation       => Tviol_RESETNeg_CSNeg
        );

        --Pulse Width and Period Check Variables
        -- Pulse Width Check SCK for READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            PulseWidthLow   =>  tpw_SCK_serial_negedge,
            PulseWidthHigh  =>  tpw_SCK_serial_posedge,
            PeriodData      =>  PD_SCK_rd,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_rd,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  rd_slow);

        -- Pulse Width Check SCK for FAST_READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            PulseWidthLow   =>  tpw_SCK_fast_negedge,
            PulseWidthHigh  =>  tpw_SCK_fast_posedge,
            PeriodData      =>  PD_SCK_fast,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_fast,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  rd_fast );

        -- Pulse Width Check SCK for DDR mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            PulseWidthLow   =>  tpw_SCK_qddr_negedge,
            PulseWidthHigh  =>  tpw_SCK_qddr_posedge,
            PeriodData      =>  PD_SCK_ddr,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_ddr,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  ddr);

        -- Pulse Width Check CS# for READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  CSNeg_ipd,
            TestSignalName  =>  "CS#",
            PulseWidthHigh  =>  tpw_CSNeg_posedge,
            PeriodData      =>  PD_CSNeg,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_CSNeg,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  any_read);

        -- Pulse Width Check CS# for QUAD mode
        VitalPeriodPulseCheck (
            TestSignal      =>  CSNeg_ipd,
            TestSignalName  =>  "CS#",
            PulseWidthHigh  =>  tpw_CSNeg_rst_quad_posedge,
            PeriodData      =>  PD_CSNeg_rst_quad,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_CSNeg_rst_quad,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  rst_quad);

        -- Pulse Width Check CS# for Program/Erase, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  CSNeg_ipd,
            TestSignalName  =>  "CS#",
            PulseWidthHigh  =>  tpw_CSNeg_wip_posedge,
            PeriodData      =>  PD_CSNeg_wip,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_CSNeg_wip,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  WIP = '1');

        -- Pulse Width Check RESETNeg
        VitalPeriodPulseCheck (
            TestSignal        => RESETNeg_ipd,
            TestSignalName    => "RESETNeg",
            PulseWidthLow     => tpw_RESETNeg_negedge,
            PulseWidthHigh    => tpw_RESETNeg_posedge,
            CheckEnabled      => reset_act,
            HeaderMsg         => InstancePath & PartID,
            PeriodData        => PD_RESETNeg,
            Violation         => Pviol_RESETNeg);

        -- Period Check SCK for READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            Period          =>  tperiod_SCK_serial_rd,
            PeriodData      =>  PD_SCK_rd,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_rd,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  rd_slow );

        -- Period Check SCK for FAST READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            Period          =>  tperiod_SCK_fast_rd,
            PeriodData      =>  PD_SCK_fast,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_fast,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  rd_fast );

        -- Period Check SCK for DUAL READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            Period          =>  tperiod_SCK_qddr,
            PeriodData      =>  PD_SCK_ddr,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_ddr,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  ddr );

        Violation :=   Tviol_CSNeg_SCK OR
					   Tviol_CSNeg_RESETNeg OR
					   Tviol_SI_SCK OR
					   Tviol_SI_SCK_ddr_R OR
					   Tviol_SI_SCK_ddr_F OR
					   Tviol_SO_SCK OR
					   Tviol_SO_SCK_ddr_R OR
					   Tviol_SO_SCK_ddr_F OR
					   Tviol_WPNeg_SCK OR
					   Tviol_WPNeg_SCK_ddr_R OR
					   Tviol_WPNeg_SCK_ddr_F OR
					   Tviol_RESETNeg_SCK OR
					   Tviol_RESETNeg_SCK_ddr_R OR
					   Tviol_RESETNeg_SCK_ddr_F OR
					   Tviol_WPNeg_CSNeg_setup OR
					   Tviol_WPNeg_CSNeg_hold OR
					   Tviol_RESETNeg_CSNeg OR
					   Tviol_CSNeg_RESETNeg OR
					   Pviol_SCK_rd OR
					   Pviol_SCK_fast OR
					   Pviol_SCK_ddr OR
					   Pviol_CSNeg OR
					   Pviol_CSNeg_rst_quad OR
					   Pviol_CSNeg_wip OR
					   Pviol_RESETNeg;

            Viol <= Violation;

            ASSERT Violation = '0'
                REPORT InstancePath & partID & ": simulation may be" &
                    " inaccurate due to timing violations"
                SEVERITY WARNING;

        END IF;
    END PROCESS VITALTimingCheck;

    ----------------------------------------------------------------------------
    -- sequential process for FSM state transition
    ----------------------------------------------------------------------------

   RST <= RESETNeg AFTER 199 ns;

    StateTransition1: PROCESS(next_state, PoweredUp, RST, RST_out, SWRST_out,
								RESETNeg, write)
    BEGIN
        IF PoweredUp = '1' THEN
        	IF (NOT reset_act OR (RESETNegIn='1' AND reset_act)) AND
			RST_out = '1' AND SWRST_out = '1' THEN
                current_state <= next_state;
				reseted <= '1';
			ELSIF ((RESETNegIn='0' AND reset_act) OR
			(rising_edge(RESETNeg) AND reset_act)) AND falling_edge(RST) THEN
            -- no state transition while RESET# low
                current_state <= RESET_STATE;
				RST_in <= '1', '0' AFTER 1 ns;
				reseted <= '0';
			END IF;

			IF falling_edge(write) THEN
				IF (Instruct = RESET AND CR3_V(0)='1') OR
				(Instruct = RSTCMD AND RESET_EN = '1') THEN
				-- no state transition while RESET is in progress
					current_state <= RESET_STATE;
					SWRST_in <= '1', '0' AFTER 1 ns;
					reseted <= '0';
				END IF;
			END IF;
		END IF;
    END PROCESS;

    -- Timing control for the Hardware Reset
    Threset1: PROCESS(RST_in)
    BEGIN
		IF rising_edge(RST_in) THEN
			RST_out <= '0', '1' AFTER (tdevice_RPH - 200 ns);
		END IF;
    END PROCESS;
    -- Timing control for the Software Reset
    Threset2: PROCESS(SWRST_in)
    BEGIN
		IF rising_edge(SWRST_in) THEN
			SWRST_out <= '0', '1' AFTER (tdevice_RPH);
		END IF;
    END PROCESS;

    -- 4kB Erase/Uniform sec architecture
   SecArch: PROCESS(TBPARM_O, PoweredUp, CR3_V(3))
    BEGIN
		IF CR3_V(3) = '0' THEN
			IF TBPARM_O = '0' THEN
                BottomBoot <= true;
                TopBoot    <= false;
            	UniformSec <= false;
			ELSE
                BottomBoot <= false;
                TopBoot    <= true;
            	UniformSec <= false;
			END IF;
		ELSE
            UniformSec <= true;
            BottomBoot <= false;
            TopBoot    <= false;
		END IF;
    END PROCESS;

   ---------------------------------------------------------------------------
    --  Write cycle decode
    ---------------------------------------------------------------------------

    BusCycleDecode : PROCESS(SCK_ipd, CSNeg_ipd)

        TYPE quad_data_type IS ARRAY (0 TO 1023) OF INTEGER RANGE 0 TO 15;

        VARIABLE bit_cnt            : NATURAL := 0;
        VARIABLE Data_in            : std_logic_vector(4095 downto 0)
                                                    := (others => '1');

        VARIABLE opcode             : std_logic_vector(7 downto 0);
        VARIABLE opcode_in          : std_logic_vector(7 downto 0);
        VARIABLE opcode_tmp         : std_logic_vector(7 downto 0);
        VARIABLE addr_bytes         : std_logic_vector(31 downto 0);
        VARIABLE hiaddr_bytes       : std_logic_vector(31 downto 0);
        VARIABLE Address_in         : std_logic_vector(31 downto 0);
        VARIABLE mode_bytes         : std_logic_vector(7 downto 0);
        VARIABLE mode_in            : std_logic_vector(7 downto 0);
        VARIABLE quad_data_in       : quad_data_type;
        VARIABLE quad_nybble        : std_logic_vector(3 downto 0)
											:= "0000";
        VARIABLE Quad_slv           : std_logic_vector(3 downto 0);
        VARIABLE Byte_slv           : std_logic_vector(7 downto 0)
											:= "00000000";
        VARIABLE Quad_int           : INTEGER;

        VARIABLE CLK_PER            : time;
        VARIABLE LAST_CLK           : time;
        VARIABLE Check_freq         : boolean := FALSE;

    BEGIN

        IF rising_edge(CSNeg_ipd) AND bus_cycle_state /= DATA_BYTES THEN
			IF opcode_tmp = "11111111" THEN
                    Instruct <= MBR;
			END IF;
            bus_cycle_state := STAND_BY;
        ELSE

            CASE bus_cycle_state IS
                WHEN STAND_BY =>

                    IF falling_edge(CSNeg_ipd) THEN
                        Instruct  <= NONE;
                        write     <= '1';
                        cfg_write <= '0';
                        opcode_cnt:= 0;
                        addr_cnt  := 0;
                        mode_cnt  := 0;
                        dummy_cnt := 0;
                        data_cnt  := 0;
                        CLK_PER   := 0 ns;
                        LAST_CLK  := 0 ns;
						Data_in   := (others => '1');
                        ZERO_DETECTED := '0';
                        bus_cycle_state := OPCODE_BYTE;
                    END IF;

                WHEN OPCODE_BYTE =>
                    IF rising_edge(SCK_ipd) THEN

                        CLK_PER  := NOW - LAST_CLK;
                        LAST_CLK := NOW;
                        IF Check_freq THEN
							IF Instruct=FAST_READ OR Instruct=OTPR OR
							Instruct=RDAR OR
							((Instruct=ECCRD OR Instruct=ECCRD4) AND
							 QUAD_ALL = '0') THEN
                            	IF (CLK_PER<20 ns AND Latency_code=0) OR --50MHz
                               (CLK_PER<14.92 ns AND Latency_code=1) OR--67MHz
                               (CLK_PER<12.50 ns AND Latency_code=2) OR--80MHz
                               (CLK_PER<10.87 ns AND Latency_code=3) OR--92MHz
                               (CLK_PER<9.60 ns AND Latency_code=4) OR--104MHz
                               (CLK_PER<8.62 ns AND Latency_code=5) OR--116MHz
                               (CLK_PER<7.75 ns AND Latency_code=6) OR--129MHz
                               (CLK_PER<7.52 ns AND Latency_code>=7) --133MHz
								THEN
                                  ASSERT FALSE
                                  REPORT "More wait states are required for " &
                                       "this clock frequency value"
                                  SEVERITY warning;
								END IF;
                        	   Check_freq := FALSE;
                            END IF;
							IF Instruct=DIOR OR Instruct=DIOR4 THEN
                            	IF (CLK_PER<12.50 ns AND Latency_code=0) OR--80MHz
                               (CLK_PER<10.87 ns AND Latency_code=1) OR--92MHz
                               (CLK_PER<9.60 ns AND Latency_code=2) OR--104MHz
                               (CLK_PER<8.62 ns AND Latency_code=3) OR--116MHz
                               (CLK_PER<7.75 ns AND Latency_code=4) OR--129MHz
                               (CLK_PER<7.52 ns AND Latency_code>=5) --133MHz
								THEN
                                  ASSERT FALSE
                                  REPORT "More wait states are required for " &
                                       "this clock frequency value"
                                  SEVERITY warning;
								END IF;
                        	   Check_freq := FALSE;
                            END IF;

							IF Instruct=QIOR OR Instruct=QIOR4 THEN
                            	IF (CLK_PER<23.22 ns AND Latency_code=0) OR--43MHz
                            	(CLK_PER<18.18 ns AND Latency_code=1) OR--55MHz
                            	(CLK_PER<14.92 ns AND Latency_code=2) OR--67MHz
                            	(CLK_PER<12.50 ns AND Latency_code=3) OR--80MHz
                                (CLK_PER<10.87 ns AND Latency_code=4) OR--92MHz
                                (CLK_PER<9.60 ns AND Latency_code=5) OR--104MHz
                                (CLK_PER<8.62 ns AND Latency_code=6) OR--116MHz
                                (CLK_PER<7.75 ns AND Latency_code=7) OR--129MHz
                                (CLK_PER<7.52 ns AND Latency_code>=8) --133MHz
								 THEN
                                  ASSERT FALSE
                                  REPORT "More wait states are required for " &
                                       "this clock frequency value"
                                  SEVERITY warning;
								END IF;
                        	    Check_freq := FALSE;
                            END IF;

							IF (Instruct=ECCRD OR Instruct=ECCRD4) AND
							QUAD_ALL='1' THEN
                            	IF (CLK_PER<55.55 ns AND Latency_code=0) OR--18MHz
                            	(CLK_PER<33.33 ns AND Latency_code=1) OR--30MHz
                            	(CLK_PER<23.22 ns AND Latency_code=2) OR--43MHz
                            	(CLK_PER<18.18 ns AND Latency_code=3) OR--55MHz
                            	(CLK_PER<14.92 ns AND Latency_code=4) OR--67MHz
                            	(CLK_PER<12.50 ns AND Latency_code=5) OR--80MHz
                                (CLK_PER<10.87 ns AND Latency_code=6) OR--92MHz
                                (CLK_PER<9.60 ns AND Latency_code=7) OR--104MHz
                                (CLK_PER<8.62 ns AND Latency_code=8) OR--116MHz
                                (CLK_PER<7.75 ns AND Latency_code=9) OR--129MHz
                                (CLK_PER<7.52 ns AND Latency_code>=10) --133MHz
								 THEN
                                  ASSERT FALSE
                                  REPORT "More wait states are required for " &
                                       "this clock frequency value"
                                  SEVERITY warning;
								END IF;
                        	    Check_freq := FALSE;
                            END IF;

							IF (Instruct=DDRQIOR OR Instruct=DDRQIOR4) THEN
                            	IF (CLK_PER<33.33 ns AND Latency_code<=1) OR--30MHz
                            	(CLK_PER<23.22 ns AND Latency_code=2) OR--43MHz
                            	(CLK_PER<18.18 ns AND Latency_code=3) OR--55MHz
                            	(CLK_PER<14.92 ns AND Latency_code=4) OR--67MHz
                            	(CLK_PER<12.50 ns AND Latency_code>=5)--80MHz
								 THEN
                                  ASSERT FALSE
                                  REPORT "More wait states are required for " &
                                       "this clock frequency value"
                                  SEVERITY warning;
								END IF;
                        	    Check_freq := FALSE;
                            END IF;
                        END IF;

                        IF CSNeg_ipd = '0' THEN

							Latency_code := to_nat(CR2_V(3 downto 0));

							-- Wrap Length
							IF to_nat(CR4_V(1 DOWNTO 0)) = 1 THEN
								WrapLength := 16;
							ELSIF to_nat(CR4_V(1 DOWNTO 0)) = 2 THEN
								WrapLength := 32;
							ELSIF to_nat(CR4_V(1 DOWNTO 0)) = 3 THEN
								WrapLength := 64;
							ELSE
								WrapLength := 8;
							END IF;

							IF QUAD_ALL = '1' THEN
                            	opcode_in(4*opcode_cnt) := RESETNegIn;
                            	opcode_in(4*opcode_cnt+1) := WPNegIn;
                            	opcode_in(4*opcode_cnt+2) := SOIn;
                            	opcode_in(4*opcode_cnt+3) := SIIn;
							ELSE
                            	opcode_in(opcode_cnt) := SIIn;
							END IF;
                            opcode_cnt := opcode_cnt + 1;

                        	IF (QUAD_ALL = '1' AND opcode_cnt = BYTE/4) OR
                            opcode_cnt = BYTE THEN
                                --MSB first
                                FOR I IN 7 DOWNTO 0 LOOP
                                    opcode(i) := opcode_in(7-i);
                                END LOOP;
                                CASE opcode IS
                                    WHEN "00000001"  => --01h
                                        Instruct <= WRR;
                                        bus_cycle_state := DATA_BYTES;

                                    WHEN "00000010"  => --02h
                                        Instruct <= PP;
                                        bus_cycle_state := ADDRESS_BYTES;

                                    WHEN "00000011"  => --03h
                                        Instruct <= READ;
										IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
										END IF;

                                    WHEN "00000100"  => --04h
                                        Instruct <= WRDI;
                                        bus_cycle_state := DATA_BYTES;

                                    WHEN "00000101"  => --05h
                                        Instruct <= RDSR1;
                                        bus_cycle_state := DATA_BYTES;

                                    WHEN "00000110"  => --06h
                                        Instruct <= WREN;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "00000111"  => --07h
                                        Instruct <= RDSR2;
										IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

                                    WHEN "00010010"  => --12h
                                        Instruct <= PP4;
                                        bus_cycle_state := ADDRESS_BYTES;

                                    WHEN "00010011"  => --13h
                                        Instruct <= READ4;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
										END IF;

									WHEN "00011000"  => --18h
                                        Instruct <= ECCRD4;
                                        bus_cycle_state := ADDRESS_BYTES;

                                    WHEN "00011001"  => --19h
                                        Instruct <= ECCRD;
                                        bus_cycle_state := ADDRESS_BYTES;

                                    WHEN "00100000"  => --20h
                                        Instruct <= P4E;
                                        bus_cycle_state := ADDRESS_BYTES;

									WHEN "00100001"  => --21h
                                        Instruct <= P4E4;
                                        bus_cycle_state := ADDRESS_BYTES;

                                    WHEN "00110000"  => --30h
                                        IF CR3_V(2) = '1' THEN
                                        	Instruct <= EPR;
										ELSE
                                        	Instruct <= CLSR;
										END IF;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "00110101"  => --35h
                                        Instruct <= RDCR;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "01000001"  => --41h
                                        Instruct <= DLPRD;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "01000010"  => --42h
                                        Instruct <= OTPP;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
										END IF;

									WHEN "01000011"  => --43h
                                        Instruct <= PNVDLR;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "01100000"  => --60h
                                        Instruct <= BE;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "01100101"  => --65h
                                        Instruct <= RDAR;
                                        bus_cycle_state := ADDRESS_BYTES;

									WHEN "01100110"  => --66h
                                        Instruct <= RSTEN;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "01110001"  => --71h
                                        Instruct <= WRAR;
                                        bus_cycle_state := ADDRESS_BYTES;

									WHEN "01110101"  => --75h
                                        Instruct <= EPS;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "10000010"  => --82h
                                        Instruct <= CLSR;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "10000101"  => --85h
                                        Instruct <= EPS;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "10011001"  => --99h
                                        Instruct <= RSTCMD;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "00001011"  => --0Bh
                                        Instruct <= FAST_READ;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
                                        	Check_freq := TRUE;
										END IF;

									WHEN "00001100"  => --0Ch
                                        Instruct <= FAST_READ4;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
                                        	Check_freq := TRUE;
										END IF;

									WHEN "00101011"  => --2Bh
                                        Instruct <= ASPRD;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "00101111"  => --2Fh
                                        Instruct <= ASPP;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "01001010"  => --4Ah
                                        Instruct <= WVDLR;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "01001011"  => --4Bh
                                        Instruct <= OTPR;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
										END IF;

									WHEN "01011010"  => --5Ah
                                        Instruct <= RSFDP;
                                        bus_cycle_state := ADDRESS_BYTES;

									WHEN "01111010"  => --7Ah
                                        Instruct <= EPR;

                                        bus_cycle_state := DATA_BYTES;
									WHEN "10001010"  => --8Ah
                                        Instruct <= EPR;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "10011111"  => --9Fh
                                        Instruct <= RDID;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "10100110"  => --A6h
                                        Instruct <= PLBWR;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "10100111"  => --A7h
                                        Instruct <= PLBRD;
										IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "10101111"  => --AFh
                                        Instruct <= RDQID;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "10110000"  => --B0h
                                        Instruct <= EPS;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "10110111"  => --B7h
                                        Instruct <= BAM4;
										IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "10111011"  => --BBh
                                        Instruct <= DIOR;
										IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
											Check_freq := true;
										END IF;

									WHEN "10111100"  => --BCh
                                        Instruct <= DIOR4;
										IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
											Check_freq := true;
										END IF;

									WHEN "11000000"  => --C0h
                                        Instruct <= SBL;
										IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "11000111"  => --C7h
                                        Instruct <= BE;
                                        bus_cycle_state := DATA_BYTES;

									WHEN "11010000"  => --D0h
                                        Instruct <= EES;
                                        bus_cycle_state := ADDRESS_BYTES;

								    WHEN "11011000"  => --D8h
                                        Instruct <= SE;
                                        bus_cycle_state := ADDRESS_BYTES;

									WHEN "11011100"  => --DCh
                                        Instruct <= SE4;
                                        bus_cycle_state := ADDRESS_BYTES;

									WHEN "11100000"  => --E0h
                                        Instruct <= DYBRD4;
                                        bus_cycle_state := ADDRESS_BYTES;

								    WHEN "11100001"  => --E1h
                                        Instruct <= DYBWR4;
                                        bus_cycle_state := ADDRESS_BYTES;

									WHEN "11100010"  => --E2h
                                        Instruct <= PPBRD4;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
										END IF;

									WHEN "11100011"  => --E3h
                                        Instruct <= PPBP4;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
										END IF;

								    WHEN "11100100"  => --E4h
                                        Instruct <= PPBE;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "11100111"  => --E7h
                                        Instruct <= PASSRD;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "11101000"  => --E8h
                                        Instruct <= PASSP;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

								    WHEN "11101001"  => --E9h
                                        Instruct <= PASSU;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "11101011"  => --EBh
                                        Instruct <= QIOR;
                                        bus_cycle_state := ADDRESS_BYTES;
										Check_freq := true;

									WHEN "11101100"  => --ECh
                                        Instruct <= QIOR4;
                                        bus_cycle_state := ADDRESS_BYTES;
										Check_freq := true;

									WHEN "11101101"  => --EDh
                                        Instruct <= DDRQIOR;
                                        bus_cycle_state := ADDRESS_BYTES;
										Check_freq := true;

									WHEN "11101110"  => --EEh
                                        Instruct <= DDRQIOR4;
                                        bus_cycle_state := ADDRESS_BYTES;
										Check_freq := true;

									WHEN "11110000"  => --F0h
                                        Instruct <= RESET;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := DATA_BYTES;
										END IF;

									WHEN "11111010"  => --FAh
                                        Instruct <= DYBRD;
                                        bus_cycle_state := ADDRESS_BYTES;

									WHEN "11111011"  => --FBh
                                        Instruct <= DYBWR;
                                        bus_cycle_state := ADDRESS_BYTES;

									WHEN "11111100"  => --FCh
                                        Instruct <= PPBRD;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
										END IF;

									WHEN "11111101"  => --FDh
                                        Instruct <= PPBP;
                                        IF QUAD_ALL = '1' THEN
                                    --Command not supported in Quad All mode
                                        	bus_cycle_state := STAND_BY;
										ELSE
                                        	bus_cycle_state := ADDRESS_BYTES;
										END IF;

									WHEN "11111111"  => --FFh
                                        Instruct <= MBR;
                                        bus_cycle_state := DATA_BYTES;

                                    WHEN others =>
                                        null;

                                END CASE;
                            END IF;
                        END IF;
                    END IF;

                WHEN ADDRESS_BYTES =>
                    IF rising_edge(SCK_ipd) AND  CSNeg_ipd= '0' THEN
                        IF (Instruct=DDRQIOR) OR (Instruct=DDRQIOR4)
					   THEN
                            double <= TRUE;
                        ELSE
                            double <= FALSE;
						END IF;

                    	IF ((Instruct= FAST_READ OR Instruct= OTPR
                        OR Instruct = RDAR OR Instruct = ECCRD) 
						AND CR2_V(7)='0') OR Instruct= RSFDP THEN
						-- Instruction + 3 Bytes Address + Dummy Byte
							IF QUAD_ALL = '1' THEN
                            	Address_in(4*addr_cnt) := RESETNegIn;
                            	Address_in(4*addr_cnt+1) := WPNegIn;
                            	Address_in(4*addr_cnt+2) := SOIn;
                            	Address_in(4*addr_cnt+3) := SIIn;
                            	read_cnt := 0;
                            	addr_cnt := addr_cnt + 1;
                            	IF addr_cnt = (3*BYTE)/4 THEN
                            		addr_cnt := 0;
                            		FOR I IN 23 DOWNTO 0 LOOP
                                		addr_bytes(23-i) := Address_in(i);
                            		END LOOP;
                                	addr_bytes(31 downto 24):="00000000";
                                	Address <= to_nat(addr_bytes);
                                	change_addr <= '1','0' AFTER 1 ns;
                                	IF (Latency_code = 0) THEN
                                    	bus_cycle_state := DATA_BYTES;
                                	ELSE
                                    	bus_cycle_state := DUMMY_BYTES;
                                	END IF;
								END IF;
							ELSE
                            	Address_in(addr_cnt) := SIIn;
                            	addr_cnt := addr_cnt + 1;
                            	IF addr_cnt = 3*BYTE THEN
                            		addr_cnt := 0;
									FOR I IN 23 DOWNTO 0 LOOP
                                		addr_bytes(23-i) := Address_in(i);
                            		END LOOP;
                                	addr_bytes(31 downto 24):="00000000";
                                	Address <= to_nat(addr_bytes);
                                	change_addr <= '1','0' AFTER 1 ns;
                                	IF (Latency_code = 0) THEN
                                    	bus_cycle_state := DATA_BYTES;
                                	ELSE
                                    	bus_cycle_state := DUMMY_BYTES;
                                	END IF;
								END IF;
							END IF;
                    	ELSIF Instruct= FAST_READ4 OR Instruct= ECCRD4 OR
						((Instruct= FAST_READ OR Instruct= OTPR OR
						Instruct= RDAR OR
						Instruct= ECCRD) AND CR2_V(7)='1') THEN
						-- Instruction + 4 Bytes Address + Dummy Byte
							IF QUAD_ALL = '1' THEN
                            	Address_in(4*addr_cnt) := RESETNegIn;
                            	Address_in(4*addr_cnt+1) := WPNegIn;
                            	Address_in(4*addr_cnt+2) := SOIn;
                           		Address_in(4*addr_cnt+3) := SIIn;
                            	read_cnt := 0;
                            	addr_cnt := addr_cnt + 1;
                            	IF addr_cnt = (4*BYTE)/4 THEN
                            		addr_cnt := 0;
                                	FOR I IN 31 DOWNTO 0 LOOP
                                    	hiaddr_bytes(31-i) := Address_in(i);
                                	END LOOP;
                                	Address <= to_nat(hiaddr_bytes);
                                	change_addr <= '1','0' AFTER 1 ns;
                                	IF (Latency_code = 0) THEN
                                    	bus_cycle_state := DATA_BYTES;
                                	ELSE
                                    	bus_cycle_state := DUMMY_BYTES;
                                	END IF;
								END IF;
							ELSE
								Address_in(addr_cnt) := SIIn;
                            	addr_cnt := addr_cnt + 1;
                            	IF addr_cnt = 4*BYTE THEN
									FOR I IN 31 DOWNTO 0 LOOP
                                    	hiaddr_bytes(31-i) := Address_in(i);
                            		END LOOP;
                                	Address <= to_nat(hiaddr_bytes);
                                	change_addr <= '1','0' AFTER 1 ns;
                                	IF (Latency_code = 0) THEN
                                    	bus_cycle_state := DATA_BYTES;
                                	ELSE
                                   	    bus_cycle_state := DUMMY_BYTES;
                                	END IF;
								END IF;
							END IF;
						ELSIF Instruct= DIOR AND CR2_V(7)='0' THEN
						-- DUAL I/O High Performance Read(3 Bytes Addr)
                        	Address_in(2*addr_cnt) := SOIn;
                        	Address_in(2*addr_cnt+1) := SIIn;
                        	read_cnt := 0;
                        	addr_cnt := addr_cnt + 1;
							IF addr_cnt = (3*BYTE)/2 THEN
                            	addr_cnt := 0;
                            	FOR I IN 23 DOWNTO 0 LOOP
                                addr_bytes(23-i) := Address_in(i);
                            	END LOOP;
                            	addr_bytes(31 downto 24):="00000000";
                            	Address <= to_nat(addr_bytes);
                            	change_addr <= '1','0' AFTER 1 ns;
                            	bus_cycle_state := MODE_BYTE;
							END IF;
						ELSIF Instruct= DIOR4 OR (Instruct= DIOR
                    	AND CR2_V(7)='1') THEN
						-- DUAL I/O High Performance Read(4 Bytes Addr)
                        	Address_in(2*addr_cnt) := SOIn;
                        	Address_in(2*addr_cnt+1) := SIIn;
                        	read_cnt := 0;
                        	addr_cnt := addr_cnt + 1;
							IF addr_cnt = (4*BYTE)/2 THEN
                            	addr_cnt := 0;
                            	FOR I IN 31 DOWNTO 0 LOOP
                                	hiaddr_bytes(31-i) := Address_in(i);
                            	END LOOP;
                            	Address <= to_nat(hiaddr_bytes);
                            	change_addr <= '1','0' AFTER 1 ns;
                            	bus_cycle_state := MODE_BYTE;
							END IF;
						ELSIF Instruct= QIOR AND CR2_V(7)='0' THEN
						-- QUAD I/O High Performance Read(3 Bytes Addr)
							IF QUAD = '1' THEN
                            	Address_in(4*addr_cnt) := RESETNegIn;
                            	Address_in(4*addr_cnt+1) := WPNegIn;
                            	Address_in(4*addr_cnt+2) := SOIn;
                            	Address_in(4*addr_cnt+3) := SIIn;
                            	read_cnt := 0;
                            	addr_cnt := addr_cnt + 1;
                            	IF addr_cnt = (3*BYTE)/4 THEN
                            		addr_cnt := 0;
                                	FOR I IN 23 DOWNTO 0 LOOP
                                    	addr_bytes(23-i) := Address_in(i);
                                	END LOOP;
                            		addr_bytes(31 downto 24):="00000000";
                                	Address <= to_nat(addr_bytes);
                                	change_addr <= '1','0' AFTER 1 ns;
                                	bus_cycle_state := MODE_BYTE;
								END IF;
							ELSE
                           		bus_cycle_state := STAND_BY;
							END IF;
						ELSIF Instruct= QIOR4 OR
						(Instruct= QIOR AND CR2_V(7)='1') THEN
						-- QUAD I/O High Performance Read(4 Bytes Addr)
							IF QUAD = '1' THEN
                            	Address_in(4*addr_cnt) := RESETNegIn;
                            	Address_in(4*addr_cnt+1) := WPNegIn;
                            	Address_in(4*addr_cnt+2) := SOIn;
                            	Address_in(4*addr_cnt+3) := SIIn;
                            	read_cnt := 0;
                            	addr_cnt := addr_cnt + 1;
                            	IF addr_cnt = (4*BYTE)/4 THEN
                            		addr_cnt := 0;
                                	FOR I IN 31 DOWNTO 0 LOOP
                                    	hiaddr_bytes(31-i) := Address_in(i);
                                	END LOOP;
                                	Address <= to_nat(hiaddr_bytes);
                                	change_addr <= '1','0' AFTER 1 ns;
                                	bus_cycle_state := MODE_BYTE;
								END IF;
							ELSE
                            	bus_cycle_state := STAND_BY;
							END IF;
						ELSIF (Instruct= READ4 OR Instruct= SE4 OR
						Instruct= PPBRD4 OR Instruct= DYBRD4 OR
						Instruct= DYBWR4 OR Instruct= PPBP4 OR
						Instruct= P4E4 OR Instruct= PP4) OR (
						(Instruct= READ AND CR2_V(7)='1') OR
						(Instruct= RDAR AND CR2_V(7)='1') OR
						(Instruct= WRAR AND CR2_V(7)='1') OR
						(Instruct= EES  AND CR2_V(7)='1') OR
						(Instruct= PP   AND CR2_V(7)='1') OR
						(Instruct= P4E  AND CR2_V(7)='1') OR
						(Instruct= SE   AND CR2_V(7)='1') OR
						(Instruct= OTPP AND CR2_V(7)='1') OR
						(Instruct= OTPR AND CR2_V(7)='1') OR
						(Instruct= DYBRD AND CR2_V(7)='1') OR
						(Instruct= DYBWR AND CR2_V(7)='1') OR
						(Instruct= PPBRD AND CR2_V(7)='1') OR
						(Instruct= PPBP  AND CR2_V(7)='1') )
						THEN
						-- Instruction + 4 Bytes Address
							IF QUAD_ALL = '1' THEN
								Address_in(4*addr_cnt) := RESETNegIn;
								Address_in(4*addr_cnt+1) := WPNegIn;
								Address_in(4*addr_cnt+2) := SOIn;
								Address_in(4*addr_cnt+3) := SIIn;
								read_cnt := 0;
								addr_cnt := addr_cnt + 1;
								IF addr_cnt = (4*BYTE)/4 THEN
									addr_cnt := 0;
									FOR I IN 31 DOWNTO 0 LOOP
										hiaddr_bytes(31-i) := Address_in(i);
									END LOOP;
									Address <= to_nat(hiaddr_bytes);
									change_addr <= '1','0' AFTER 1 ns;
									bus_cycle_state := DATA_BYTES;
								END IF;
							ELSE
								Address_in(addr_cnt) := SIIn;
								addr_cnt := addr_cnt + 1;
								IF addr_cnt = 4*BYTE THEN
									FOR I IN 31 DOWNTO 0 LOOP
										hiaddr_bytes(31-i) := Address_in(i);
									END LOOP;
									Address <= to_nat(hiaddr_bytes);
									change_addr <= '1','0' AFTER 1 ns;
									bus_cycle_state := DATA_BYTES;
								END IF;
							END IF;
						ELSIF Instruct= DDRQIOR AND CR2_V(7)='0'
						AND  QUAD = '1' THEN
					--Quad I/O DDR Read Mode (3 Bytes Address)
							Address_in(4*addr_cnt) := RESETNegIn;
							Address_in(4*addr_cnt+1) := WPNegIn;
							Address_in(4*addr_cnt+2) := SOIn;
							Address_in(4*addr_cnt+3) := SIIn;
							opcode_tmp(addr_cnt/2) := SIIn;
							read_cnt := 0;
							addr_cnt := addr_cnt + 1;
						ELSIF (Instruct= DDRQIOR4 OR
						(Instruct= DDRQIOR AND CR2_V(7)='1'))
						AND  QUAD = '1' THEN
					--Quad I/O DDR Read Mode (4 Bytes Address)
							Address_in(4*addr_cnt) := RESETNegIn;
							Address_in(4*addr_cnt+1) := WPNegIn;
							Address_in(4*addr_cnt+2) := SOIn;
							Address_in(4*addr_cnt+3) := SIIn;
							opcode_tmp(addr_cnt/2) := SIIn;
							read_cnt := 0;
							addr_cnt := addr_cnt + 1;
						ELSIF CR2_V(7)='0' THEN
						-- Instruction + 3 Bytes Address
							IF QUAD_ALL = '1' THEN
								Address_in(4*addr_cnt) := RESETNegIn;
								Address_in(4*addr_cnt+1) := WPNegIn;
								Address_in(4*addr_cnt+2) := SOIn;
								Address_in(4*addr_cnt+3) := SIIn;
								read_cnt := 0;
								addr_cnt := addr_cnt + 1;
								IF addr_cnt = (3*BYTE)/4 THEN
									addr_cnt := 0;
									FOR I IN 23 DOWNTO 0 LOOP
										addr_bytes(23-i) := Address_in(i);
									END LOOP;
									addr_bytes(31 downto 24):="00000000";
									Address <= to_nat(addr_bytes);
									change_addr <= '1','0' AFTER 1 ns;
									bus_cycle_state := DATA_BYTES;
								END IF;
							ELSE
								Address_in(addr_cnt) := SIIn;
								addr_cnt := addr_cnt + 1;
								IF addr_cnt = 3*BYTE THEN
									FOR I IN 23 DOWNTO 0 LOOP
										addr_bytes(23-i) := Address_in(i);
									END LOOP;
									addr_bytes(31 downto 24):="00000000";
									Address <= to_nat(addr_bytes);
									change_addr <= '1','0' AFTER 1 ns;
									bus_cycle_state := DATA_BYTES;
								END IF;
							END IF;
						END IF;

                    ELSIF falling_edge(SCK_ipd) AND  CSNeg_ipd= '0' THEN
						IF Instruct= DDRQIOR AND CR2_V(7)='0'
						AND  QUAD = '1' THEN
					--Quad I/O DDR Read Mode (3 Bytes Address)
							Address_in(4*addr_cnt) := RESETNegIn;
							Address_in(4*addr_cnt+1) := WPNegIn;
							Address_in(4*addr_cnt+2) := SOIn;
							Address_in(4*addr_cnt+3) := SIIn;
							IF addr_cnt /= 0 THEN
								addr_cnt := addr_cnt + 1;
							END IF;
							read_cnt := 0;
							IF addr_cnt = (3*BYTE)/4 THEN
                            	addr_cnt := 0;
                                FOR I IN 23 DOWNTO 0 LOOP
                                    addr_bytes(23-i) := Address_in(i);
                                END LOOP;
                            	addr_bytes(31 downto 24):="00000000";
                                Address <= to_nat(addr_bytes);
                                change_addr <= '1','0' AFTER 1 ns;
                                bus_cycle_state := MODE_BYTE;
							END IF;

						ELSIF (Instruct= DDRQIOR4 OR
						(Instruct= DDRQIOR AND CR2_V(7)='1'))
						AND  QUAD = '1' THEN
					--Quad I/O DDR Read Mode (4 Bytes Address)
							Address_in(4*addr_cnt) := RESETNegIn;
							Address_in(4*addr_cnt+1) := WPNegIn;
							Address_in(4*addr_cnt+2) := SOIn;
							Address_in(4*addr_cnt+3) := SIIn;
							IF addr_cnt /= 0 THEN
								addr_cnt := addr_cnt + 1;
							END IF;
							read_cnt := 0;
							IF addr_cnt = (4*BYTE)/4 THEN
                            	addr_cnt := 0;
                                FOR I IN 31 DOWNTO 0 LOOP
                                    hiaddr_bytes(31-i) := Address_in(i);
                                END LOOP;
                                Address <= to_nat(hiaddr_bytes);
                                change_addr <= '1','0' AFTER 1 ns;
                                bus_cycle_state := MODE_BYTE;
							END IF;
						END IF;
					END IF;
					IF rising_edge(CSNeg_ipd) THEN
						IF opcode_tmp = "11111111" THEN
							Instruct <= MBR;
						END IF;
					END IF;

                WHEN MODE_BYTE =>
                    IF rising_edge(SCK_ipd) AND CSNeg = '0' THEN
                        IF Instruct=DIOR OR Instruct = DIOR4 THEN
                            mode_in(2*mode_cnt)   := SOIn;
                            mode_in(2*mode_cnt+1) := SIIn;
                            mode_cnt := mode_cnt + 1;
                            IF mode_cnt = BYTE/2 THEN
                                mode_cnt := 0;
								FOR I IN 7 DOWNTO 0 LOOP
                                    mode_bytes(i) := mode_in(7-i);
                                END LOOP;
                                IF Latency_code = 0 THEN
                                    bus_cycle_state := DATA_BYTES;
                                ELSE
                                    bus_cycle_state := DUMMY_BYTES;
                                END IF;
                            END IF;
 						ELSIF (Instruct=QIOR OR Instruct = QIOR4)
                               AND QUAD = '1' THEN
                            mode_in(4*mode_cnt)   := RESETNegIn;
                            mode_in(4*mode_cnt+1) := WPNegIn;
                            mode_in(4*mode_cnt+2) := SOIn;
                            mode_in(4*mode_cnt+3) := SIIn;
                            mode_cnt := mode_cnt + 1;
                            IF mode_cnt = BYTE/4 THEN
                                mode_cnt := 0;
                                FOR I IN 7 DOWNTO 0 LOOP
                                    mode_bytes(i) := mode_in(7-i);
                                END LOOP;
								IF Latency_code = 0 THEN
                                    bus_cycle_state := DATA_BYTES;
                                ELSE
                                    bus_cycle_state := DUMMY_BYTES;
                                END IF;
                            END IF;
                        ELSIF (Instruct=DDRQIOR OR Instruct = DDRQIOR4)
                             AND QUAD = '1' THEN
                            mode_in(0) := RESETNegIn;
                            mode_in(1) := WPNegIn;
                            mode_in(2) := SOIn;
                            mode_in(3) := SIIn;
                        END IF;
                        dummy_cnt := 0;

					ELSIF falling_edge(SCK_ipd) AND CSNeg = '0' THEN
                        IF Instruct=DDRQIOR OR Instruct = DDRQIOR4 THEN
                            mode_in(4) := RESETNegIn;
       						mode_in(5) := WPNegIn;
                            mode_in(6) := SOIn;
                            mode_in(7) := SIIn;
                            FOR I IN 7 DOWNTO 0 LOOP
                                mode_bytes(i) := mode_in(7-i);
                            END LOOP;
							IF Latency_code = 0 THEN
                                bus_cycle_state := DATA_BYTES;
                            ELSE
                                bus_cycle_state := DUMMY_BYTES;
                            END IF;
                            IF VDLR_reg /= "00000000" THEN
                                read_out <= '1', '0' AFTER 1 ns;
                            END IF;
                        END IF;
                    END IF;

 				WHEN DUMMY_BYTES =>
                    IF rising_edge(SCK_ipd) AND CSNeg = '0' THEN
                        IF (Instruct=DDRQIOR OR Instruct=DDRQIOR4) AND
                             (VDLR_reg /= "00000000") THEN
                            read_out <= '1', '0' AFTER 1 ns;
                        END IF;
                        dummy_cnt := dummy_cnt + 1;

                    ELSIF falling_edge(SCK_ipd) AND CSNeg = '0' THEN
                        dummy_cnt := dummy_cnt + 1;
                        IF (Instruct=DDRQIOR OR Instruct=DDRQIOR4) AND
                             (VDLR_reg /= "00000000") THEN
                            read_out <= '1', '0' AFTER 1 ns;
                        END IF;
                        IF Instruct=RSFDP THEN
                            IF dummy_cnt = 15 THEN
                                bus_cycle_state := DATA_BYTES;
                            END IF;
                        ELSE
                            IF Latency_code = dummy_cnt/2 THEN
                                bus_cycle_state := DATA_BYTES;
                                read_out <= '1', '0' AFTER 1 ns;
                            END IF;
                        END IF;

                    END IF;

                WHEN DATA_BYTES =>
                    IF rising_edge(SCK_ipd) AND CSNeg = '0' THEN
                        IF Instruct=DDRQIOR OR Instruct=DDRQIOR4 THEN
                            read_out <= '1', '0' AFTER 1 ns;
                    	END IF;
						IF QUAD_ALL='1' THEN
							IF RESETNegIn/='Z' AND RESETNegIn/='X' AND
							  WPNegIn/='Z' AND WPNegIn/='X' AND
							  SOIn/='Z' AND SOIn/='X' AND
							  SIIn/='Z' AND SIIn/='X' THEN
                            	quad_nybble := RESETNegIn & WPNegIn & SOIn & SIIn;
							END IF;
                            IF data_cnt > ((PageSize+1)*2-1) THEN
                            --In case of quad mode,if more than PageSize+1 bytes
                            --are sent to the device previously latched data
                            --are discarded and last 256/512 data bytes are
                            --guaranteed to be programmed correctly within
                            --the same page.
                                FOR I IN 0 TO (PageSize*2-1) LOOP
                                    quad_data_in(i) := quad_data_in(i+1);
                                END LOOP;
                                quad_data_in((PageSize+1)*2-1) :=
                                                    to_nat(quad_nybble);
                                data_cnt := data_cnt +1;
                            ELSE
                                quad_data_in(data_cnt) :=
                                to_nat(quad_nybble);
                                data_cnt := data_cnt +1;
                            END IF;
						ELSE
                            IF data_cnt > ((PageSize+1)*8)-1 THEN
                            --In case of serial mode and PP,
                            -- if more than 512 bytes are sent to the device
                            -- previously latched data are discarded and last
                            -- 512 data bytes are guaranteed to be programmed
                            -- correctly within the same page.
                                IF bit_cnt = 0 THEN
                                    FOR I IN 0 TO (PageSize*BYTE - 1) LOOP
                                        Data_in(i) := Data_in(i+8);
                                    END LOOP;
                                END IF;
                                Data_in(PageSize*BYTE + bit_cnt) := SIIn;
                                bit_cnt := bit_cnt + 1;
                                IF bit_cnt = 8 THEN
                                    bit_cnt := 0;
                                END IF;
                                data_cnt := data_cnt + 1;
                            ELSE
								IF SIIn/='Z' AND SIIn/='X' THEN
                                	Data_in(data_cnt) := SIIn;
								END IF;
                                data_cnt := data_cnt + 1;
                                bit_cnt := 0;
                            END IF;
                        END IF;
                    END IF;

					IF falling_edge(SCK_ipd) AND CSNeg_ipd = '0' THEN
                        IF ((Instruct=DDRQIOR OR Instruct=DDRQIOR4 OR
                         	Instruct=QIOR OR Instruct=QIOR4) AND QUAD='1') OR
                         	Instruct = READ OR Instruct=READ4 OR
                          	Instruct = FAST_READ OR Instruct = FAST_READ4 OR
                            Instruct = RDSR1  OR Instruct = RDSR2 OR
                            Instruct = RDCR  OR Instruct = OTPR OR
                            Instruct = DIOR OR Instruct = DIOR4 OR
                            Instruct = RDID  OR Instruct = RDQID OR
                            Instruct = PPBRD OR Instruct = PPBRD4 OR
                            Instruct = DYBRD OR Instruct = DYBRD4 OR
                            Instruct = ECCRD  OR Instruct = ECCRD4 OR
                            Instruct = ASPRD OR Instruct = DLPRD OR
                            Instruct = PASSRD OR Instruct = PLBRD OR
                            Instruct = RSFDP OR Instruct = RDAR THEN
                            	read_out <= '1', '0' AFTER 1 ns;
                        END IF;
                    END IF;

					IF rising_edge(CSNeg_ipd) THEN
						IF (mode_bytes(7 downto 4) = "1010" AND
						(Instruct =DIOR OR Instruct =DIOR4 OR
						 Instruct =QIOR OR Instruct =QIOR4)) OR
						((mode_bytes(7 downto 4) = NOT mode_bytes(3 downto 0)) AND
						 (Instruct =DDRQIOR OR Instruct =DDRQIOR4)) THEN
                            bus_cycle_state := ADDRESS_BYTES;
						ELSE
                            bus_cycle_state := STAND_BY;
						END IF;
                    	CASE Instruct IS
                        	WHEN WREN | WRDI | BE | SE | SE4 | P4E | P4E4 |
                             CLSR | RSTEN | RSTCMD | RESET |  BAM4 | MBR |
							PPBP | PPBE | PPBP4 | PLBWR | EPS | EPR | EES  =>
                                IF data_cnt = 0 THEN
                                    write <= '0';
                                END IF;

                        	WHEN WRR =>
                            	IF QUAD_ALL = '0' THEN
                                    IF data_cnt = 8 THEN
                                    --If CS# is driven high after eight
                                    --cycles,only the Status Register is
                                    --written to.
                                        write <= '0';
                                        FOR i IN 0 TO 7 LOOP
                                        	SR1_in(i) <= Data_in(7-i);
                                        END LOOP;

                                    ELSIF data_cnt = 16 THEN
                                    --After the 16th cycle both the
                                    --Status and Configuration Registers
                                    --are written to.
                                        write <= '0';
										cfg_write <= '1';
                                        FOR i IN 0 TO 7 LOOP
                                        	SR1_in(i) <= Data_in(7-i);
                                        	CR1_in(i) <= Data_in(15-i);
                                        END LOOP;
                                    END IF;
								ELSE
									NULL;
                                END IF;

                        	WHEN WRAR =>
								IF QUAD_ALL = '0' THEN
									IF data_cnt = 8 THEN
										write <= '0';
										FOR i IN 0 TO 7 LOOP
											WRAR_reg_in(i) := Data_in(7-i);
										END LOOP;
                                    END IF;
								ELSE
									IF data_cnt = 2 THEN
										write <= '0';
										FOR i IN 1 DOWNTO 0 LOOP
											Quad_slv := to_slv(quad_data_in(1-i), 4);
											IF i = 1 THEN
												WRAR_reg_in(7 downto 4)
														:= Quad_slv;
											ELSIF i = 0 THEN
												WRAR_reg_in(3 downto 0)
														:= Quad_slv;
                                    		END IF;
										END LOOP;
                                    END IF;
                                END IF;

							WHEN PP | PP4 | OTPP =>
                            IF QUAD_ALL ='0' THEN
                                IF data_cnt > 0 THEN
                                    IF (data_cnt mod 8) = 0 THEN
                                        write <= '0';
                                        FOR I IN 0 TO PageSize LOOP
                                            FOR J IN 7 DOWNTO 0 LOOP
                                                IF (Data_in((i*8) + (7-j))
                                                               /= 'X') AND
												(Data_in((i*8) + (7-j))
															  /= 'Z') THEN
                                                    Byte_slv(j) :=
                                                    Data_in((i*8) + (7-j));
													IF Data_in((i*8) + (7-j))
														= '0' THEN
														ZERO_DETECTED := '1';
													END IF;
                                                END IF;
                                            END LOOP;
                                            WByte(i) <= to_nat(Byte_slv);
                                        END LOOP;
                                        IF data_cnt > (PageSize+1)*BYTE THEN
                                            Byte_number <= PageSize;
                                        ELSE
                                            Byte_number <= data_cnt/8-1;
                                        END IF;
                                    END IF;
                                END IF;
							ELSE
                                IF data_cnt > 0 THEN
                                    IF (data_cnt mod 2) = 0 THEN
                                        write <= '0';
                                        FOR i IN 0 TO PageSize LOOP
                                            FOR j IN 1 DOWNTO 0 LOOP
											  Quad_int := quad_data_in((i*2)+(1-j));
                                              Quad_slv := to_slv(Quad_int, 4);
											  IF j=1 THEN
                                                Byte_slv(7 downto 4):= Quad_slv;
											  ELSIF j=0 THEN
                                                Byte_slv(3 downto 0):= Quad_slv;
											  END IF;
                                            END LOOP;
                                            WByte(i) <= to_nat(Byte_slv);
                                        END LOOP;
                                        IF data_cnt > (PageSize+1)*2 THEN
                                            Byte_number <= PageSize;
                                        ELSE
                                            Byte_number <= data_cnt/2-1;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;

							WHEN ASPP =>
                            IF data_cnt = 16 THEN
                                write <= '0';
                                FOR J IN 0 TO 15 LOOP
                                    ASP_reg_in(J) <=
                                              Data_in(15-J);
                                END LOOP;
                            END IF;

                        	WHEN PNVDLR =>
                            IF data_cnt = 8 THEN
                                write <= '0';
                                FOR J IN 0 TO 7 LOOP
                                    NVDLR_reg_in(J) <= Data_in(7-J);
                                END LOOP;
                            END IF;

                            WHEN WVDLR =>
							IF data_cnt = 8 THEN
                                write <= '0';
                                FOR J IN 0 TO 7 LOOP
                                    VDLR_reg_in(J) <= Data_in(7-J);
                                END LOOP;
                            END IF;

                        	WHEN DYBWR |  DYBWR4 =>
 							IF QUAD_ALL ='0' THEN
                            	IF data_cnt = 8 THEN
                               		write <= '0';
                                	FOR J IN 0 TO 7 LOOP
                                   		DYBAR_in(J) <=
                                              Data_in(7-J);
                                	END LOOP;
                            	END IF;
							ELSE
                            	IF data_cnt = 2 THEN
                               		write <= '0';
									FOR i IN 1 DOWNTO 0 LOOP
										Quad_slv :=
										to_slv(quad_data_in(1-i),4);
										IF i = 1 THEN
											DYBAR_in(7 downto 4)
														<= Quad_slv;
										ELSIF i = 0 THEN
											DYBAR_in(3 downto 0)
														<= Quad_slv;
                                    	END IF;
									END LOOP;
                            	END IF;
                            END IF;

                        	WHEN PASSP =>
								IF data_cnt = 64 THEN
									write <= '0';
									FOR J IN 1 TO 8 LOOP
										FOR K IN 1 TO 8 LOOP
											Password_reg_in(J*8-K) <=
												Data_in(8*(J-1)+K-1);
										END LOOP;
									END LOOP;
								END IF;

                        	WHEN PASSU =>
								IF data_cnt = 64 THEN
									write <= '0';
									FOR J IN 1 TO 8 LOOP
									FOR K IN 1 TO 8 LOOP
										PASS_TEMP(J*8-K) <=
										Data_in(8*(J-1)+K-1);
									END LOOP;
									END LOOP;
								END IF;

					        WHEN SBL =>
								IF data_cnt = 8 THEN
									write <= '0';
									FOR i IN 0 TO 7 LOOP
										SBL_data_in(i) <=
												Data_in(7-i);
									END LOOP;
								END IF;

							WHEN others =>
								null;

                    END CASE;
                END IF;
            END CASE;
        END IF;

    END PROCESS BusCycleDecode;

    ---------------------------------------------------------------------------
    -- Timing control for the Page Program
    ---------------------------------------------------------------------------
    ProgTime : PROCESS(PSTART, PGSUSP, PGRES, reseted)
        VARIABLE pob      : time;
        VARIABLE elapsed_pgm  : time;
        VARIABLE start_pgm    : time;
        VARIABLE duration_pgm : time;
    BEGIN
        IF LongTimming THEN
			IF CR3_V(4) = '0' THEN
				pob  := tdevice_PP_256;
			ELSE
				pob  := tdevice_PP_512;
			END IF;
		ELSE
			IF CR3_V(4) = '0' THEN
				pob  := tdevice_PP_256/10;
			ELSE
				pob  := tdevice_PP_512/10;
			END IF;
		END IF;

        IF rising_edge(reseted) THEN
            PDONE <= '1';  -- reset done, programing terminated
        ELSIF reseted = '1' THEN
        	IF rising_edge(PSTART) AND PDONE = '1' THEN
				elapsed_pgm := 0 ns;
				start_pgm := NOW;
				PDONE <= '0', '1' AFTER pob;
        	ELSIF PGSUSP'EVENT AND PGSUSP = '1' AND PDONE /= '1' THEN
				elapsed_pgm  := NOW - start_pgm;
				duration_pgm := pob - elapsed_pgm;
				PDONE <= '0';
			ELSIF PGRES'EVENT AND PGRES = '1' THEN
				start_pgm := NOW;
				PDONE <= '0', '1' AFTER duration_pgm;
			END IF;
		END IF;

    END PROCESS ProgTime;

    ---------------------------------------------------------------------------
    -- Timing control for the Write Status Register
    ---------------------------------------------------------------------------
    WriteTime : PROCESS(WSTART, reseted)
        VARIABLE wob      : time;
    BEGIN
        IF LongTimming THEN
            wob  := tdevice_WRR;
        ELSE
            wob  := tdevice_WRR / 1000;
        END IF;
        IF rising_edge(reseted) THEN
            WDONE <= '1';  -- reset done, programing terminated
        ELSIF reseted = '1' THEN
        	IF rising_edge(WSTART) AND WDONE = '1' THEN
            	WDONE <= '0', '1' AFTER wob;
        	END IF;
        END IF;

    END PROCESS WriteTime;

    ---------------------------------------------------------------------------
    -- Timing control for the Write volatile registers bits
    ---------------------------------------------------------------------------
    WriteVolatileBitsTime : PROCESS(CSSTART, reseted)
    BEGIN
        IF rising_edge(reseted) THEN
            CSDONE <= '1';  -- reset done, programing terminated
        ELSIF reseted = '1' THEN
        	IF rising_edge(CSSTART) AND CSDONE = '1' THEN
            	CSDONE <= '0', '1' AFTER 50 ns;
        	END IF;
        END IF;

    END PROCESS WriteVolatileBitsTime;

    ---------------------------------------------------------------------------
    -- Timing control for Evaluate Erase Status
    ---------------------------------------------------------------------------
    EESTime : PROCESS(EESSTART, reseted)
        VARIABLE ees_time      : time;
    BEGIN
		IF LongTimming THEN
            ees_time  := tdevice_EES;
        ELSE
            ees_time  := tdevice_EES / 10;
        END IF;
        IF rising_edge(reseted) THEN
            EESDONE <= '1';  -- reset done, write terminated
        ELSIF reseted = '1' THEN
        	IF rising_edge(EESSTART) AND EESDONE = '1' THEN
				IF CR3_V(0) = '0' THEN
            		EESDONE <= '0', '1' AFTER ees_time/4;
				ELSE
            		EESDONE <= '0', '1' AFTER ees_time;
				END IF;
        	END IF;
        END IF;

    END PROCESS EESTime;

    ---------------------------------------------------------------------------
    -- Timing control for block erase operation
    ---------------------------------------------------------------------------
    ErsTime : PROCESS(ESTART, ESUSP, ERES, reseted)
        VARIABLE seo4     : time;
        VARIABLE seo256   : time;
        VARIABLE beo      : time;
        VARIABLE elapsed_ers  : time;
        VARIABLE start_ers    : time;
        VARIABLE duration_ers : time;
    BEGIN
        IF LongTimming THEN
            seo4 := tdevice_SE4;
            seo256 := tdevice_SE256;
            beo := tdevice_BE;
        ELSE
            seo4 := tdevice_SE4 / 100;
            seo256 := tdevice_SE256 / 100;
            beo := tdevice_BE / 1000;
        END IF;

		IF Instruct = BE THEN
            duration_ers := beo;
        ELSIF Instruct = P4E OR Instruct = P4E4 OR
		((Instruct = SE OR Instruct = SE4) AND
								(CR3_V(1) = '0')) THEN
            duration_ers := seo4;
		ELSE
            duration_ers := seo256;
        END IF;

        IF rising_edge(reseted) THEN
            EDONE <= '1';
        ELSIF reseted = '1' THEN
        	IF rising_edge(ESTART) AND EDONE = '1' THEN
				elapsed_ers := 0 ns;
				EDONE <= '0', '1' AFTER duration_ers;
				start_ers := NOW;
			END IF;
        ELSIF ESUSP'EVENT AND ESUSP = '1' AND EDONE /= '1' THEN
            elapsed_ers  := NOW - start_ers;
            duration_ers := duration_ers - elapsed_ers;
            EDONE <= '0';
        ELSIF ERES'EVENT AND ERES = '1' THEN
            start_ers := NOW;
            EDONE <= '0', '1' AFTER duration_ers;
        END IF;

    END PROCESS ErsTime;

    SuspTime : PROCESS(ERSSUSP_in,PRGSUSP_in)
        VARIABLE susp_time      : time;
    BEGIN
        IF LongTimming THEN
            susp_time  := tdevice_SUSP;
        ELSE
            susp_time  := tdevice_SUSP / 10;
        END IF;

        IF rising_edge(ERSSUSP_in) THEN
            ERSSUSP_out <= '0', '1' after susp_time;
        ELSIF falling_edge(ERSSUSP_in) THEN
            ERSSUSP_out <= '0';
		END IF;

        IF rising_edge(PRGSUSP_in) THEN
            PRGSUSP_out <= '0', '1' after susp_time;
        ELSIF falling_edge(ERSSUSP_in) THEN
            PRGSUSP_out <= '0';
		END IF;
    END PROCESS SuspTime;

    PPBEraseTime : PROCESS(PPBERASE_in)
        VARIABLE ppbe_time      : time;
    BEGIN
        IF LongTimming THEN
            ppbe_time  := tdevice_SE256;
        ELSE
            ppbe_time  := tdevice_SE256 / 100;
        END IF;

        IF rising_edge(PPBERASE_in) THEN
            PPBERASE_out <= '0', '1' after ppbe_time;
        ELSIF falling_edge(PPBERASE_in) THEN
            PPBERASE_out <= '0';
		END IF;
    END PROCESS PPBEraseTime;

    PassUlckTime : PROCESS(PASSULCK_in)
        VARIABLE passulck_time      : time;
    BEGIN
        IF LongTimming THEN
            passulck_time := tdevice_PP_256;
        ELSE
            passulck_time := tdevice_PP_256 / 10;
        END IF;

        IF rising_edge(PASSULCK_in) THEN
            PASSULCK_out <= '0', '1' after passulck_time;
        ELSIF falling_edge(PASSULCK_in) THEN
            PASSULCK_out <= '0';
		END IF;
    END PROCESS PassUlckTime;

    CheckCEOnPowerUP :PROCESS(CSNeg_ipd)
    BEGIN
        IF (PoweredUp = '0' AND falling_edge(CSNeg_ipd)) THEN
            REPORT InstancePath & partID &
            ": Device is selected during Power Up"
            SEVERITY WARNING;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- Main Behavior Process
    -- combinational process for next state generation
    ---------------------------------------------------------------------------

    StateGen :PROCESS(PoweredUp, write, WDONE, PDONE, EDONE,  RST_out, CSDONE,
                      BCDONE, EESDONE, ERSSUSP_out, PRGSUSP_out, PPBERASE_in,
                      PASSULCK_in, SWRST_out, RESETNeg)

    VARIABLE sect             : NATURAL RANGE 0 TO SecNumHyb;
    VARIABLE block_e          : NATURAL RANGE 0 TO BlockNumHyb;
    VARIABLE sect8_no_prot    : BOOLEAN;
    VARIABLE sect511_no_prot  : BOOLEAN;
    VARIABLE sect_no_prot     : BOOLEAN;
    VARIABLE block8_no_prot   : BOOLEAN;
    VARIABLE block127_no_prot : BOOLEAN;
    VARIABLE block_no_prot    : BOOLEAN;

    BEGIN

        IF RST_out = '0' OR SWRST_out = '0' THEN
            next_state <= current_state;
        ELSE
            CASE current_state IS
                WHEN  RESET_STATE =>
                    IF rising_edge(RST_out) OR rising_edge(SWRST_out) THEN
                        next_state <= IDLE;
                    END IF;
                WHEN  IDLE =>

 					IF falling_edge(write) THEN
                        IF Instruct=WRR AND WEL='1' AND
                        not(SRWD='1' AND WPNegIn='0' AND QUAD='0') THEN

                                -- can not execute if HPM is entered
                                -- or if WEL bit is zero
                            IF ((TBPROT_O='1' AND CR1_in(5)='0') OR
                            (TBPARM_O='1' AND CR1_in(2)='0'
						    AND CR3_V(3)='0') OR
                           (BPNV_O  ='1' AND CR1_in(3)='0')) AND
                            cfg_write = '1' THEN
                                    ASSERT cfg_write = '0'
                                    REPORT "Changing value of Configuration " &
                                           "Register OTP bit from 1 to 0 is " &
                                           "not allowed!!!"
                                    SEVERITY WARNING;
                            ELSIF (PWDMLB/='1' OR PSTMLB/='1') AND
							(CR1_in(5)='1' OR CR1_in(3)='1' OR
                            (CR1_in(4)='1' AND SECURE_OPN='1') OR
                            (CR1_in(2)='1' AND CR3_NV(3)='0')) THEN
                           -- Once the protection mode is selected, the OTP
                           -- bits are permanently protected from programming
                                next_state <= PGERS_ERROR;
							ELSE
                                next_state <= WRITE_SR;
                            END IF;

                        ELSIF Instruct=WRAR AND WEL='1' AND
                           not(SRWD='1' AND WPNegIn='0' AND QUAD='0' AND
							(Address=16#0000000# OR
							 Address=16#0000002# OR
							 Address=16#0800000# OR
							 Address=16#0800002#)) THEN
                        -- can not execute if WEL bit is zero or Hardware
                        -- Protection Mode is entered and SR1NV,SR1V,CR1NV or
                        -- CR1V is selected (no error is set)
							IF Address=16#0000001#  OR
                               ((Address>16#0000005#) AND
                               (Address<16#0000010#)) OR
							   ((Address>16#0000010#) AND
                               (Address<16#0000020#)) OR
							   ((Address>16#0000027#) AND
                               (Address<16#0000030#)) OR
							   ((Address>16#0000031#) AND
                               (Address<16#0800000#)) OR
							   ((Address>16#0800005#) AND
                               (Address<16#0800010#)) OR
							   ((Address>16#0800010#) AND
                               (Address<16#0800040#)) OR
                               (Address>16#0800040#) THEN
								ASSERT FALSE
                                REPORT "WARNING: Undefined location " &
                                       "selected. Command is ignored! "
                                SEVERITY WARNING;
                        	ELSIF Address=16#0800040# THEN --PPBL
								ASSERT FALSE
                                REPORT "WARNING: PPBL register cannot be " &
                                       "written by the WRAR command. " &
                                       "Command is ignored! "
                                SEVERITY WARNING;
							ELSIF Address=16#0000002# AND
								((TBPROT_O='1' AND WRAR_reg_in(5)='0') OR
								(TBPARM_O='1' AND WRAR_reg_in(2)='0'
								AND CR3_V(3)='0') OR
								(BPNV_O='1' AND WRAR_reg_in(3)='0')) THEN
								ASSERT FALSE
                                REPORT "WARNING: Writing of OTP bits back " &
                                       "to their default state is ignored " &
                                       "and no error is set! "
                                SEVERITY WARNING;
                            ELSIF PWDMLB/='1' OR PSTMLB/='1' THEN
                            -- Once the protection mode is selected,the OTP
                            -- bits are permanently protected from programming
								IF ((WRAR_reg_in(5)='1' OR
								(WRAR_reg_in(4)='1' AND SECURE_OPN='1') OR
								WRAR_reg_in(3)='1' OR
								(WRAR_reg_in(2)='1' AND CR3_NV(3)='0')) AND
                                Address =16#0000002#) OR -- CR1NV[5:2]
                                Address =16#0000003# OR -- CR2NV
                                Address =16#0000004# OR -- CR3NV
                                Address =16#0000005# OR -- CR4NV
                                Address =16#0000010# OR -- NVDLR
                                Address =16#0000020# OR -- PASS(7:0)
                                Address =16#0000021# OR -- PASS(15:8)
                                Address =16#0000022# OR -- PASS(23:16)
                                Address =16#0000023# OR -- PASS(31:24)
                                Address =16#0000024# OR -- PASS(39:32)
                                Address =16#0000025# OR -- PASS(47:40)
                                Address =16#0000026# OR -- PASS(55:58)
                                Address =16#0000027# OR -- PASS(63:56)
                                Address =16#0000030# OR -- ASPR(7:0)
                                Address =16#0000031# THEN-- ASPR(15:8)
                                	next_state <= PGERS_ERROR;
								ELSE
                                	next_state <= WRITE_ALL_REG;
								END IF;
							ELSE -- Protection mode not selected
								IF (Address =16#0000030#) OR
								(Address =16#0000031#) THEN --ASPR
							        IF WRAR_reg_in(2)='0' AND
									WRAR_reg_in(1)='0'
									AND Address =16#0000030# THEN
                                		next_state <= PGERS_ERROR;
									ELSE
                                		next_state <= WRITE_ALL_REG;
									END IF;
								ELSE
                                	next_state <= WRITE_ALL_REG;
								END IF;
							END IF;

                        ELSIF (Instruct=PP OR  Instruct=PP4) AND WEL='1' THEN
                            sect := ReturnSectorID
							(Address,BottomBoot,TopBoot);
                            IF Sec_Prot(sect)= '0' AND PPB_bits(sect)= '1' AND
                                DYB_bits(sect)= '1' THEN
                                next_state <= PAGE_PG;
                            ELSE
                                next_state <= PGERS_ERROR;
							END IF;
                        ELSIF Instruct=OTPP AND WEL = '1' THEN
                            IF (Address + Byte_number) <= OTPHiAddr THEN
								-- Program within valid OTP Range
								IF ((Address>=16#10# AND Address<=16#FF#)
								AND LOCK_BYTE1(Address/32) = '1') OR
								((Address >= 16#100# AND Address<=16#1FF#)
								AND LOCK_BYTE2((Address-16#100#)/32) = '1')
								OR ((Address>=16#200# AND Address<=16#2FF#)
								AND LOCK_BYTE3((Address-16#200#)/32)='1')
								OR ((Address>=16#300# AND Address<=16#3FF#)
								AND LOCK_BYTE4((Address-16#300#)/32)='1')
								THEN
									IF FREEZE = '0' THEN
										next_state <=  OTP_PG;
									ELSE
										-- Attempting to program within valid OTP
										-- range while FREEZE = 1
										next_state <= PGERS_ERROR;
									END IF;
								ELSIF ZERO_DETECTED = '1' THEN
									--Attempting to program any zero in the 16
									--lowest bytes or attempting to program any zero
									--in locked region
									next_state <= PGERS_ERROR;
								END IF;
							END IF;
                        ELSIF (Instruct= SE OR Instruct= SE4) AND WEL = '1' THEN
                            sect := ReturnSectorID
							(Address,BottomBoot,TopBoot);
                            block_e := ReturnBlockID
							(Address,BottomBoot,TopBoot);
																				
							sect8_no_prot := Sec_Prot(8) = '0' AND
								PPB_bits(8) = '1' AND DYB_bits(8) = '1';
							sect511_no_prot := Sec_Prot(511) = '0' AND
								PPB_bits(511) = '1' AND DYB_bits(511) = '1';
							sect_no_prot := Sec_Prot(sect) = '0' AND
								PPB_bits(sect) = '1' AND DYB_bits(sect) = '1';

							block8_no_prot := Block_Prot(8) = '0' AND
								PPB_bits_b(8) = '1' AND DYB_bits_b(8) = '1';
							block127_no_prot := Block_Prot(127) = '0' AND
								PPB_bits_b(127) = '1' AND DYB_bits_b(127) = '1';
							block_no_prot := Block_Prot(block_e) = '0' AND
								PPB_bits_b(block_e) = '1' AND DYB_bits_b(block_e) = '1';

 							IF CR3_V(1) = '0' THEN																		
                            	IF (UniformSec AND sect_no_prot) OR
                                 (BottomBoot AND (sect >= 8) AND  sect_no_prot) OR
                                 (BottomBoot AND (sect < 8) AND  sect8_no_prot) OR
								 (TopBoot AND (sect <= 511) AND sect_no_prot) OR
								 (TopBoot AND (sect > 511) AND sect511_no_prot) THEN
                                    IF CR3_V(5) = '0' THEN
                                        next_state <=  SECTOR_ERS;
                                    ELSE
                                        next_state <=  BLANK_CHECK;
									END IF;
                                ELSE
                                    next_state <= PGERS_ERROR;
								END IF;
                            ELSE
                            	IF (UniformSec AND block_no_prot) OR
                                 (BottomBoot AND (block_e >= 8) AND  block_no_prot) OR
                                 (BottomBoot AND (block_e < 8) AND  block8_no_prot) OR
								 (TopBoot AND (block_e <= 127) AND block_no_prot) OR
								 (TopBoot AND (block_e > 127) AND block127_no_prot) THEN
                                    IF CR3_V(5) = '0' THEN
                                        next_state <=  SECTOR_ERS;
                                    ELSE
                                        next_state <=  BLANK_CHECK;
									END IF;
                                ELSE
                                    next_state <= PGERS_ERROR;
								END IF;
							END IF;
                        ELSIF (Instruct=P4E OR Instruct=P4E4) AND WEL='1' THEN
                            sect := ReturnSectorID(Address,BottomBoot,TopBoot);
                            IF UniformSec OR (TopBoot AND (sect < 512)) OR
                               (BottomBoot AND (sect > 7)) THEN
                            	REPORT "The instruction is applied to "&
                                   "a sector that is larger than "&
                                   "4 KB. "&
                                   "Instruction is ignored!!!"
                            	SEVERITY warning;
							ELSE
								IF (Sec_Prot(sect) = '0' AND PPB_bits(sect)='1'
                                AND DYB_bits(sect)='1') THEN
									IF CR3_V(5) = '0' THEN
                                		next_state <=  SECTOR_ERS;
									ELSE
                                		next_state <=  BLANK_CHECK;
									END IF;
								ELSE
                                	next_state <=  PGERS_ERROR;
                            	END IF;
                            END IF;
                        ELSIF Instruct = BE AND WEL = '1' AND
                          (SR1_V(4)='0' AND SR1_V(3)='0' AND SR1_V(2)='0') THEN
							IF CR3_V(5) = '0' THEN
                                next_state <=  BULK_ERS;
							ELSE
                                next_state <=  BLANK_CHECK;
							END IF;
                        ELSIF (Instruct=PPBP OR Instruct=PPBP4) AND WEL='1' THEN
	                       	IF ((SECURE_OPN='1' AND PERMLB='1') OR SECURE_OPN='0')
                            AND PPB_LOCK='1' THEN
                                next_state <=  PPB_PG;
							ELSE
                                next_state <=  PGERS_ERROR;
							END IF;
                        ELSIF Instruct=PPBE AND WEL='1' AND SECURE_OPN='1' THEN
	                       	IF PPBOTP='1' AND PPB_LOCK='1' AND PERMLB='1' THEN
                                next_state <=  PPB_ERS;
							ELSE
                                next_state <=  PGERS_ERROR;
							END IF;
                        ELSIF Instruct=ASPP AND WEL='1' THEN
                            -- ASP Register Program Command
	                       	IF PWDMLB='1' AND PSTMLB='1' THEN
								IF ASP_reg_in(2 downto 1) = "00" THEN
									next_state <=  PGERS_ERROR;
								ELSE
									next_state <=  ASP_PG;
								END IF;
							ELSE
								next_state <=  PGERS_ERROR;
							END IF;
                        ELSIF Instruct = PLBWR  AND WEL = '1' THEN
                            next_state <= PLB_PG;
                        ELSIF (Instruct=DYBWR OR Instruct=DYBWR4) AND
						WEL='1' THEN
                            IF DYBAR_in = "11111111" OR
							DYBAR_in = "00000000" THEN
                            	next_state <= DYB_PG;
							ELSE
								next_state <=  PGERS_ERROR;
							END IF;
                        ELSIF Instruct = PNVDLR  AND WEL = '1' THEN
							IF PWDMLB='1' AND PSTMLB='1' THEN
                            	next_state <= NVDLR_PG;
							ELSE
								next_state <=  PGERS_ERROR;
							END IF;
                        ELSIF Instruct = PASSP  AND WEL = '1' THEN
                            IF PWDMLB='1' AND PSTMLB='1' THEN
                                next_state <= PASS_PG;
							ELSE
								next_state <=  PGERS_ERROR;
							END IF;
                        ELSIF Instruct=PASSU  AND WEL='1' AND WIP='0'
					    THEN
                            next_state <= PASS_UNLOCK;
                        ELSIF Instruct = EES THEN
                            next_state <= EVAL_ERS_STAT;
                        ELSE
                            next_state <= IDLE;
						END IF;
					END IF;
                WHEN WRITE_SR       =>
                    IF rising_edge(WDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN WRITE_ALL_REG       =>
                    IF rising_edge(WDONE) OR rising_edge(CSDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN PAGE_PG        =>
                    IF PRGSUSP_out'EVENT AND PRGSUSP_out = '1' THEN
                        next_state <= PG_SUSP;
                    ELSIF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN OTP_PG         =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

				WHEN PG_SUSP      =>
                    IF falling_edge(write) THEN
                        IF Instruct = EPR THEN
                            next_state <=  PAGE_PG;
                    	END IF;
                    END IF;

                WHEN SECTOR_ERS     =>
                    IF ERSSUSP_out'EVENT AND ERSSUSP_out = '1' THEN
                        next_state <= ERS_SUSP;
                    ELSIF rising_edge(EDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN BULK_ERS       =>
                    IF rising_edge(EDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN ERS_SUSP      =>
                    IF falling_edge(write) THEN
                        IF (Instruct = PP OR Instruct = PP4)  AND
                        WEL='1' AND P_ERR='0' THEN
                            sect := ReturnSectorID(Address,BottomBoot,TopBoot);
                            block_e := ReturnBlockID(Address,BottomBoot,TopBoot);
                            IF (SectorErased /= sect AND CR3_V(1)='0') OR
							(BlockErased /= block_e AND CR3_V(1)='1') THEN
                                IF Sec_Prot(sect)='0' AND PPB_bits(sect)='1'
							    AND DYB_bits(sect)='1' THEN
                                   next_state <=  ERS_SUSP_PG;
                                END IF;
                            END IF;
                        ELSIF (Instruct=DYBWR OR Instruct=DYBWR4) AND
						WEL='1' AND P_ERR='0' THEN
                            IF DYBAR_in = "11111111" OR
							DYBAR_in = "00000000" THEN
                            	next_state <=  DYB_PG;
							ELSE
                            	next_state <=  PGERS_ERROR;
							END IF;
                        ELSIF Instruct = EPR AND P_ERR = '0' THEN
                            next_state <=  SECTOR_ERS;
                        END IF;
                    END IF;

                WHEN ERS_SUSP_PG         =>
                    IF PRGSUSP_out'EVENT AND PRGSUSP_out = '1' THEN
                        next_state <= ERS_SUSP_PG_SUSP;
                    ELSIF rising_edge(PDONE) THEN
                        next_state <= ERS_SUSP;
                    END IF;

				WHEN ERS_SUSP_PG_SUSP      =>
                    IF falling_edge(write) THEN
                        IF Instruct = EPR THEN
                            next_state <=  ERS_SUSP_PG;
                        END IF;
                    END IF;

				WHEN PASS_PG        =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

				WHEN PASS_UNLOCK    =>
                    IF falling_edge(PASSULCK_in) THEN
						IF P_ERR = '0' THEN
                        	next_state <= IDLE;
						ELSE
                        	next_state <= PGERS_ERROR;
                    	END IF;
                    END IF;

                WHEN PPB_PG         =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN PPB_ERS        =>
                    IF falling_edge(PPBERASE_in) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN PLB_PG         =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN DYB_PG         =>
                    IF rising_edge(PDONE) THEN
						IF ES = '1' THEN
                        	next_state <= ERS_SUSP;
						ELSE
                        	next_state <= IDLE;
                    	END IF;
                    END IF;

                WHEN ASP_PG         =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN NVDLR_PG         =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN PGERS_ERROR         =>
                    IF falling_edge(write) THEN
                        IF Instruct=WRDI AND P_ERR='0' 	AND
						E_ERR='0' THEN
                        -- A Clear Status Register (CLSR) followed by a Write
                        -- Disable (WRDI) command must be sent to return the
                        -- device to standby state
                            next_state <= IDLE;
                    	END IF;
                    END IF;

                WHEN BLANK_CHECK         =>
                    IF rising_edge(BCDONE) THEN
						IF NOT_BLANK = '1' THEN
							IF Instruct=BE THEN
								next_state <= BULK_ERS;
							ELSE
								next_state <= SECTOR_ERS;
							END IF;
						ELSE
							next_state <= IDLE;
						END IF;
					END IF;

                WHEN EVAL_ERS_STAT         =>
                    IF rising_edge(EESDONE) THEN
                        next_state <= IDLE;
                    END IF;

            END CASE;
        END IF;

    END PROCESS StateGen;

    ReadEnable: PROCESS (read_out)
    BEGIN
        oe_z <= rising_edge(read_out) AND PoweredUp = '1';

        IF read_out'EVENT AND read_out = '0' AND PoweredUp = '1' THEN
            oe   <= TRUE, FALSE AFTER 1 ns;
        END IF;
    END PROCESS ReadEnable;

    ---------------------------------------------------------------------------
    --FSM Output generation and general funcionality
    ---------------------------------------------------------------------------
    Functional : PROCESS(write,current_state, PoweredUp, WDONE, PDONE, EDONE,
                         CSDONE, ERSSUSP_out, PRGSUSP_out, PASSULCK_out, oe,
						 oe_z, PPBERASE_out, BCDONE, EESDONE, Instruct,
						change_addr, CSNeg, reseted)

        VARIABLE WData          : WByteType:= (OTHERS => MaxData);

        VARIABLE AddrLo         : NATURAL;
        VARIABLE AddrHi         : NATURAL;
        VARIABLE Addr           : NATURAL;
        VARIABLE Addr_pgm       : NATURAL;
        VARIABLE Addr_ers       : NATURAL;
        VARIABLE Addr_pgm_tmp   : NATURAL;
        VARIABLE Addr_idcfi     : NATURAL;

        VARIABLE data_out       : std_logic_vector(7 downto 0);

        VARIABLE old_bit        : std_logic_vector(7 downto 0);
        VARIABLE new_bit        : std_logic_vector(7 downto 0);
        VARIABLE old_int        : INTEGER RANGE -1 to MaxData;
        VARIABLE new_int        : INTEGER RANGE -1 to MaxData;
        VARIABLE old_pass       : std_logic_vector(63 downto 0);
        VARIABLE new_pass       : std_logic_vector(63 downto 0);
        VARIABLE old_pass_byte  : std_logic_vector(7 downto 0);
        VARIABLE new_pass_byte  : std_logic_vector(7 downto 0);
        VARIABLE wr_cnt         : NATURAL RANGE 0 TO 511;
        --Data Learning Pattern Enable
        VARIABLE dlp_act        : BOOLEAN   := FALSE;

        VARIABLE sect           : NATURAL RANGE 0 TO SecNumHyb;
        VARIABLE cnt            : NATURAL RANGE 0 TO 512 := 0;
		VARIABLE Instruct_P4E   : std_logic;

		VARIABLE block_e          : NATURAL RANGE 0 TO BlockNumHyb;
		VARIABLE sect8_no_prot    : BOOLEAN;
		VARIABLE sect511_no_prot  : BOOLEAN;
		VARIABLE sect_no_prot     : BOOLEAN;
		VARIABLE block8_no_prot   : BOOLEAN;
		VARIABLE block127_no_prot : BOOLEAN;
		VARIABLE block_no_prot    : BOOLEAN;

		PROCEDURE ADDRHILO_SEC(
            VARIABLE   AddrLOW  : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   AddrHIGH : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   Addr     : NATURAL) IS
			VARIABLE   sec      : NATURAL;
        BEGIN
        	IF CR3_V(3) = '0' THEN -- Hybrid Sector Architecture
            	IF TBPARM_O = '0' THEN -- 4KB Sectors at Bottom
					IF  Addr/(SecSize64+1) = 0 THEN
                    	IF Addr/(SecSize4+1) < 8 AND
                       	Instruct_P4E = '1' THEN  --4KB Sectors
							sec := Addr/(SecSize4+1);
							AddrLOW  := sec*(SecSize4+1);
							AddrHIGH := AddrLOW + SecSize4;
						ELSE
							AddrLOW  := 8*(SecSize4+1);
							AddrHIGH := SecSize64;
						END IF;
					ELSE
						sec := Addr/(SecSize64+1);
						AddrLOW  := sec*(SecSize64+1);
						AddrHIGH := AddrLOW + SecSize64;
					END IF;
 				ELSE -- 4KB Sectors at Top
                    IF Addr/(SecSize64+1) = 511 THEN
						IF (Addr > (AddrRANGE - 8*(SecSize4+1)))
						AND Instruct_P4E='1' THEN --4KB Sectors
                        	sec := 512 +
                           (Addr-(AddrRANGE + 1 - 8*(SecSize4+1)))/(SecSize4+1);
							AddrLOW  := AddrRANGE + 1 - 8*(SecSize4+1) +
							(sec-512)*(SecSize4+1);
							AddrHIGH :=AddrLOW + SecSize4;
						ELSE
							AddrLOW  := 511*(SecSize64+1);
							AddrHIGH := AddrRANGE - 8*(SecSize4+1);
						END IF;
					ELSE
                    	sec := Addr/(SecSize64+1);
						AddrLOW  := sec*(SecSize64+1);
						AddrHIGH := AddrLOW + SecSize64;
					END IF;
				END IF;
			ELSE  -- Uniform Sector Architecture
                sec := Addr/(SecSize64+1);
				AddrLOW  := sec*(SecSize64+1);
				AddrHIGH := AddrLOW + SecSize64;
			END IF;
        END ADDRHILO_SEC;

		PROCEDURE ADDRHILO_BLK(
            VARIABLE   AddrLOW  : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   AddrHIGH : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   Addr     : NATURAL) IS
			VARIABLE   block_e  : NATURAL;
        BEGIN
        	IF CR3_V(3) = '0' THEN -- Hybrid Sector Architecture
            	IF TBPARM_O = '0' THEN -- 4KB Sectors at Bottom
					IF  Addr/(SecSize256+1) = 0 THEN
                    	IF Addr/(SecSize4+1) < 8 AND Instruct_P4E = '1' THEN
																--4KB Sectors
							block_e  := Addr/(SecSize4+1);
							AddrLOW  := block_e*(SecSize4+1);
							AddrHIGH := AddrLOW + SecSize4;
						ELSE
							AddrLOW  := 8*(SecSize4+1);
							AddrHIGH := SecSize256;
						END IF;
					ELSE
						block_e := Addr/(SecSize256+1);
						AddrLOW  := block_e*(SecSize256+1);
						AddrHIGH := AddrLOW + SecSize256;
					END IF;
 				ELSE -- 4KB Sectors at Top
                    IF Addr/(SecSize256+1) = 127 THEN
						IF (Addr > (AddrRANGE - 8*(SecSize4+1)))
						AND Instruct_P4E='1' THEN --4KB Sectors
                        	block_e := 128 +
                           (Addr-(AddrRANGE + 1 - 8*(SecSize4+1)))/(SecSize4+1);
							AddrLOW  := AddrRANGE + 1 - 8*(SecSize4+1) +
							(block_e-128)*(SecSize4+1);
							AddrHIGH :=AddrLOW + SecSize4;
						ELSE
							AddrLOW  := 127*(SecSize256+1);
							AddrHIGH := AddrRANGE - 8*(SecSize4+1);
						END IF;
					ELSE
                    	block_e := Addr/(SecSize256+1);
						AddrLOW  := block_e*(SecSize256+1);
						AddrHIGH := AddrLOW + SecSize256;
					END IF;
				END IF;
			ELSE  -- Uniform Sector Architecture
                block_e := Addr/(SecSize256+1);
				AddrLOW  := block_e*(SecSize256+1);
				AddrHIGH := AddrLOW + SecSize256;
			END IF;
        END ADDRHILO_BLK;

        PROCEDURE ADDRHILO_PG(
            VARIABLE   AddrLOW  : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   AddrHIGH : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   Addr     : NATURAL) IS
            VARIABLE   page     : NATURAL;
        BEGIN
            page     := Addr/(PageSize+1);
            AddrLOW  := Page*(PageSize+1);
            AddrHIGH := AddrLOW + PageSize;
        END ADDRHILO_PG;

        PROCEDURE READ_ALL_REG(
            VARIABLE   RDAR_reg  : INOUT std_logic_vector(7 downto 0);
            VARIABLE   Addr     : NATURAL) IS
        BEGIN
        	IF Addr = 16#0000000# THEN
            	RDAR_reg := SR1_NV;
        	ELSIF Addr = 16#0000002# THEN
            	RDAR_reg := CR1_NV;
        	ELSIF Addr = 16#0000003# THEN
            	RDAR_reg := CR2_NV;
        	ELSIF Addr = 16#0000004# THEN
            	RDAR_reg := CR3_NV;
        	ELSIF Addr = 16#0000005# THEN
            	RDAR_reg := CR4_NV;
        	ELSIF Addr = 16#0000010# THEN
            	RDAR_reg := NVDLR_reg;
        	ELSIF Addr = 16#0000020# THEN
				IF PWDMLB = '1' THEN
            		RDAR_reg := Password_reg(7 downto 0);
				ELSE
            		RDAR_reg := "XXXXXXXX";
				END IF;
			ELSIF Addr = 16#00000021# THEN
				IF PWDMLB = '1' THEN
            		RDAR_reg := Password_reg(15 downto 8);
				ELSE
            		RDAR_reg := "XXXXXXXX";
				END IF;
			ELSIF Addr = 16#00000022# THEN
				IF PWDMLB = '1' THEN
            		RDAR_reg := Password_reg(23 downto 16);
				ELSE
            		RDAR_reg := "XXXXXXXX";
				END IF;
			ELSIF Addr = 16#00000023# THEN
				IF PWDMLB = '1' THEN
            		RDAR_reg := Password_reg(31 downto 24);
				ELSE
            		RDAR_reg := "XXXXXXXX";
				END IF;
			ELSIF Addr = 16#0000024# THEN
				IF PWDMLB = '1' THEN
            		RDAR_reg := Password_reg(39 downto 32);
				ELSE
            		RDAR_reg := "XXXXXXXX";
				END IF;
			ELSIF Addr = 16#0000025# THEN
				IF PWDMLB = '1' THEN
            		RDAR_reg := Password_reg(47 downto 40);
				ELSE
            		RDAR_reg := "XXXXXXXX";
				END IF;
			ELSIF Addr = 16#0000026# THEN
				IF PWDMLB = '1' THEN
            		RDAR_reg := Password_reg(55 downto 48);
				ELSE
            		RDAR_reg := "XXXXXXXX";
				END IF;
			ELSIF Addr = 16#0000027# THEN
				IF PWDMLB = '1' THEN
            		RDAR_reg := Password_reg(63 downto 56);
				ELSE
            		RDAR_reg := "XXXXXXXX";
				END IF;
        	ELSIF Addr = 16#0000030# THEN
            	RDAR_reg := ASP_reg(7 downto 0);
        	ELSIF Addr = 16#0000031# THEN
            	RDAR_reg := ASP_reg(15 downto 8);
        	ELSIF Addr = 16#0800000# THEN
            	RDAR_reg := SR1_V;
        	ELSIF Addr = 16#0800001# THEN
            	RDAR_reg := SR2_V;
        	ELSIF Addr = 16#0800002# THEN
            	RDAR_reg := cR1_V;
        	ELSIF Addr = 16#0800003# THEN
            	RDAR_reg := CR2_V;
        	ELSIF Addr = 16#0800004# THEN
            	RDAR_reg := CR3_V;
        	ELSIF Addr = 16#0800005# THEN
            	RDAR_reg := CR4_V;
        	ELSIF Addr = 16#0800010# THEN
            	RDAR_reg := VDLR_reg;
        	ELSIF Addr = 16#0800040# THEN
            	RDAR_reg := PPBL;
			ELSE
            	RDAR_reg := "XXXXXXXX";
			END IF;
        END READ_ALL_REG;

		FUNCTION Return_DLP (Latency_code : NATURAL; dummy_cnt : NATURAL)
												RETURN BOOLEAN IS
			VARIABLE result : BOOLEAN;
		BEGIN
			IF (Latency_code >= 4) AND (dummy_cnt >= (2*Latency_code-8)) THEN
				result := TRUE;
			ELSE
				result := FALSE;
			END IF;
			RETURN result;
		END Return_DLP;

    BEGIN

        -----------------------------------------------------------------------
        -- Functionality Section
        -----------------------------------------------------------------------

        IF Instruct'EVENT THEN
            read_cnt := 0;
            byte_cnt := 1;
            rd_fast  <= false;
            rd_slow  <= false;
            dual     <= false;
            ddr      <= false;
            any_read <= false;
            Addr_idcfi := 0;
        END IF;

        IF rising_edge(PoweredUp) THEN
            -- the default condition after power-up
            -- During POR,the non-volatile version of the registers is copied to
            -- volatile version to provide the default state of the volatile
            -- register
            SR1_V <= SR1_NV;

            CR1_V <= CR1_NV;
            CR2_V <= CR2_NV;
            CR3_V <= CR3_NV;
            CR4_V <= CR4_NV;

            VDLR_reg := NVDLR_reg;
            -- As shipped from the factory, all devices default ASP to the
            -- Persistent Protection mode, with all sectors unprotected,
            -- when power is applied. The device programmer or host system must
            -- then choose which sector protection method to use.
            -- For Persistent Protection mode, PPBLOCK defaults to "1"
            PPBL(0) := '1';
			IF DYBLBB='0' AND SECURE_OPN= '1' THEN
                -- All the DYB power-up in the protected state
                DYB_bits := (OTHERS =>'0');
            ELSE
                -- All the DYB power-up in the unprotected state
                DYB_bits := (OTHERS =>'1');
			END IF;

            BP_bits := SR1_V(4) & SR1_V(3) & SR1_V(2);
            change_BP <= '1', '0' AFTER 1 ns;
		END IF;

        IF change_addr'EVENT THEN
            read_addr := Address;
        END IF;

        CASE current_state IS

            WHEN IDLE          =>

				Instruct_P4E := '0';				

        		IF falling_edge(write) THEN
                    IF Instruct = WREN THEN
                        SR1_V(1) <= '1';
                    ELSIF Instruct = WRDI THEN
                        SR1_V(1) <= '0';
                    ELSIF Instruct = BAM4 THEN
                        CR2_V(7) <= '1';
                    ELSIF Instruct = SBL THEN
                    -- SBL command doesn't require WEL bit set to "1"
                    -- If the user set WEL bit, it will remain high after the
                    -- command.
                    -- Enable/Disable the wrapped read feature
                        CR4_V(4)   <= SBL_data_in(4);
                        -- Set the wrap boundary
                        CR4_V(1 downto 0) <= SBL_data_in(1 downto 0);
                    ELSIF Instruct = EES THEN
						sect :=
						ReturnSectorID(Address,BottomBoot,TopBoot);
						block_e :=
						ReturnBlockID(Address,BottomBoot,TopBoot);
                        EESSTART <= '1', '0' AFTER 1 ns;
                        SR1_V(0) <= '1';  -- WIP
                        SR1_V(1) <= '1';  -- WEL
					ELSIF Instruct=WRR AND WEL='1' THEN
                    	IF  not(SRWD='1' AND WPNegIn='0' AND QUAD='0')
						THEN
                        	IF ((TBPROT_O='1' AND CR1_in(5)='0') OR
                                (TBPARM_O='1' AND CR1_in(2)='0'
								AND CR3_V(3) = '0') OR
                                (BPNV_O  ='1' AND CR1_in(3)='0')) AND
                                cfg_write = '1' THEN
                                	SR1_V(1) <= '0'; -- WEL
                            ELSIF (PWDMLB/='1' OR PSTMLB/='1') AND
									(CR1_in(5)='1' OR CR1_in(3)='1' OR
                                	(CR1_in(4)='1' AND SECURE_OPN='1') OR
                                    (CR1_in(2)='1' AND CR3_NV(3)='0')) THEN
                           -- Once the protection mode is selected, the OTP
                           -- bits are permanently protected from programming
                                SR1_V(6) <= '1'; -- P_ERR
                                SR1_V(0) <= '1'; -- WIP
							ELSE
                                WSTART <= '1', '0' AFTER 1 ns;
                                SR1_V(0) <= '1';  -- WIP
                            END IF;
						ELSE
                         -- can not execute if Hardware Protection Mode
                         -- is entered or if WEL bit is zero
                             SR1_V(1) <= '0'; -- WEL
                        END IF;

					ELSIF Instruct=WRAR AND WEL='1' THEN
                    	IF not(SRWD='1' AND WPNegIn='0' AND QUAD='0' AND
							(Address=16#00000000# OR
							 Address=16#00000002# OR
							 Address=16#00800000# OR
							 Address=16#00800002#)) THEN
                        -- can not execute if WEL bit is zero or Hardware
                        -- Protection Mode is entered and SR1NV,SR1V,CR1NV or
                        -- CR1V is selected (no error is set)
							Addr := Address;
							IF Address=16#00000001#  OR
                               ((Address>16#00000005#) AND
                               (Address<16#00000010#)) OR
							   ((Address>16#00000010#) AND
                               (Address<16#00000020#)) OR
							   ((Address>16#00000027#) AND
                               (Address<16#00000030#)) OR
							   ((Address>16#00000031#) AND
                               (Address<16#00800000#)) OR
							   ((Address>16#00800005#) AND
                               (Address<16#00800010#)) OR
							   (Address>16#00800010#) THEN
                                SR1_V(1) <= '0';  -- WEL
							ELSIF Address = 16#00000002# AND
							((TBPROT_O='1' AND WRAR_reg_in(5)='0') OR
							 (TBPARM_O='1' AND WRAR_reg_in(2)='0'
							 AND CR3_V(3) = '0') OR
							(BPNV_O='1' AND WRAR_reg_in(3)='0')) THEN
                                SR1_V(1) <= '0';  -- WEL
							ELSIF (PWDMLB/='1' OR PSTMLB/='1') THEN
                            -- Once the protection mode is selected,the OTP
                            -- bits are permanently protected from programming
								IF ((WRAR_reg_in(5)='1' OR
								(WRAR_reg_in(4)='1' AND SECURE_OPN='1') OR
								WRAR_reg_in(3)='1' OR
								(WRAR_reg_in(2)='1' AND CR3_NV(3)='0')) AND
                                Address =16#00000002#) OR -- CR1NV[5:2]
                                Address =16#00000003# OR -- CR2NV
                                Address =16#00000004# OR -- CR3NV
                                Address =16#00000005# OR -- CR4NV
                                Address =16#00000010# OR -- NVDLR
                                Address =16#00000020# OR -- PASS(7:0)
                                Address =16#00000021# OR -- PASS(15:8)
                                Address =16#00000022# OR -- PASS(23:16)
                                Address =16#00000023# OR -- PASS(31:24)
                                Address =16#00000024# OR -- PASS(39:32)
                                Address =16#00000025# OR -- PASS(47:40)
                                Address =16#00000026# OR -- PASS(55:58)
                                Address =16#00000027# OR -- PASS(63:56)
                                Address =16#00000030# OR -- ASPR(7:0)
                                Address =16#00000031# THEN-- ASPR(15:8)
                                	SR1_V(6) <= '1';  -- P_ERR
                                	SR1_V(0) <= '1';  -- WIP
                                ELSE
                                    CSSTART <= '1', '0' AFTER 1 ns;
                                    SR1_V(0) <= '1';  -- WIP
								END IF;
							ELSE -- Protection Mode not selected
								IF Address =16#00000030# OR
								Address =16#00000031# THEN --ASPR
							        IF WRAR_reg_in(2)='0' AND
									WRAR_reg_in(1)='0'
									AND Address =16#00000030# THEN
                                		SR1_V(6) <= '1';  -- P_ERR
                                		SR1_V(0) <= '1';  -- WIP
									ELSE
                                    	WSTART <= '1', '0' AFTER 1 ns;
                                    	SR1_V(0) <= '1';  -- WIP
									END IF;
                                ELSIF Address = 16#00000000# OR
                                Address = 16#00000010# OR
                                (Address >= 16#00000002# AND
                                Address <= 16#00000005#) OR
                                (Address >= 16#00000020# AND
                                Address <= 16#00000027#) THEN
                                    WSTART <= '1', '0' AFTER 1 ns;
                                    SR1_V(0) <= '1';  -- WIP
								ELSE
                                    CSSTART <= '1', '0' AFTER 1 ns;
                                    SR1_V(0) <= '1';  -- WIP
								END IF;
							END IF;
						ELSE
                        -- can not execute if Hardware Protection Mode
                        -- is entered or if WEL bit is zero
                        SR1_V(1) <= '0'; -- WEL
						END IF;

                    ELSIF (Instruct = PP OR Instruct = PP4) AND WEL = '1' THEN
                        pgm_page := Address/(PageSize+1);
                    	SecAddr_pgm := ReturnSectorID(Address,BottomBoot,TopBoot);
                        IF (Sec_Prot(SecAddr_pgm) = '0' AND
                           PPB_bits(SecAddr_pgm)='1' AND DYB_bits(SecAddr_pgm)='1') THEN
                            PSTART <= '1', '0' AFTER 1 ns;
                            PGSUSP  <= '0';
                            PGRES   <= '0';
                            INITIAL_CONFIG <= '1';
                            SR1_V(0) <= '1';  -- WIP
                            Addr_pgm := Address;
                            Addr_pgm_tmp := Address;
                            wr_cnt := Byte_number;
                            FOR I IN wr_cnt DOWNTO 0 LOOP
                                IF Viol /= '0' THEN
                                    WData(i) := -1;
                                ELSE
                                    WData(i) := WByte(i);
                                END IF;
                            END LOOP;
                        ELSE
                        -- P_ERR bit will be set when the user attempts to
                        -- to program within a protected main memory sector
                            SR1_V(6) <= '1'; -- P_ERR
                            SR1_V(0) <= '1'; -- WIP
                        END IF;

                    ELSIF Instruct = OTPP AND WEL = '1' THEN
                        IF (Address + Byte_number) <= OTPHiAddr THEN
						-- Program within valid OTP Range
							IF ((Address>=16#10# AND Address<=16#FF#)
							AND LOCK_BYTE1(Address/32) = '1') OR
							((Address >= 16#100# AND Address<=16#1FF#)
							AND LOCK_BYTE2((Address-16#100#)/32) = '1')
							OR ((Address>=16#200# AND Address<=16#2FF#)
							AND LOCK_BYTE3((Address-16#200#)/32)='1')
							OR ((Address>=16#300# AND Address<=16#3FF#)
							AND LOCK_BYTE4((Address-16#300#)/32)='1')
							THEN
                            -- As long as the FREEZE bit remains cleared to a
                            -- logic '0' the OTP address space is programmable.
								IF FREEZE = '0' THEN
                                	PSTART <= '1', '0' AFTER 1 ns;
                                    SR1_V(0) <= '1'; --WIP
									Addr_pgm := Address;
									wr_cnt := Byte_number;
									FOR I IN wr_cnt DOWNTO 0 LOOP
										IF Viol /= '0' THEN
											WData(i) := -1;
										ELSE
											WData(i) := WByte(i);
										END IF;
									END LOOP;
                                ELSE
                                -- Attempting to program within valid OTP
                                -- range while FREEZE = 1
                                    SR1_V(6) <= '1'; -- P_ERR
                                    SR1_V(0) <= '1'; -- WIP
								END IF;
 							ELSIF ZERO_DETECTED = '1' THEN
                                IF Address > 16#3FF# THEN
                                    ASSERT false
                                        REPORT "Given  address is out of" &
                                            "OTP address range"
                                        SEVERITY warning;
								ELSE
                                -- Attempting to program any zero in the 16
                                -- lowest bytes or attempting to program any zero
                                -- in locked region
                            		SR1_V(6) <= '1'; -- P_ERR
                            		SR1_V(0) <= '1'; -- WIP
                                END IF;
                            END IF;
						END IF;
																												
					ELSIF (Instruct=SE OR Instruct=SE4) AND WEL='1' THEN
                        sect := ReturnSectorID(Address,BottomBoot,TopBoot);
                        block_e := ReturnBlockID(Address,BottomBoot,TopBoot);
                		SectorErased := sect;
                		BlockErased := block_e;																				
						sect8_no_prot := Sec_Prot(8) = '0' AND
							PPB_bits(8) = '1' AND DYB_bits(8) = '1';
						sect511_no_prot := Sec_Prot(511) = '0' AND
							PPB_bits(511) = '1' AND DYB_bits(511) = '1';
						sect_no_prot := Sec_Prot(sect) = '0' AND
							PPB_bits(sect) = '1' AND DYB_bits(sect) = '1';

						block8_no_prot := Block_Prot(8) = '0' AND
							PPB_bits_b(8) = '1' AND DYB_bits_b(8) = '1';
						block127_no_prot := Block_Prot(127) = '0' AND
							PPB_bits_b(127) = '1' AND DYB_bits_b(127) = '1';
						block_no_prot := Block_Prot(block_e) = '0' AND
						PPB_bits_b(block_e) = '1' AND DYB_bits_b(block_e) = '1';

 						IF CR3_V(1) = '0' THEN
                            IF (UniformSec AND sect_no_prot) OR
                             (BottomBoot AND (sect >= 8) AND  sect_no_prot) OR
                             (BottomBoot AND (sect < 8) AND  sect8_no_prot) OR
							 (TopBoot AND (sect <= 511) AND sect_no_prot) OR
							 (TopBoot AND (sect > 511) AND sect511_no_prot) THEN
						     	Addr_ers := Address;
								IF CR3_V(5) = '0' THEN
									bc_done <= '0';
									ESTART <= '1', '0' AFTER 1 ns;
									ESUSP  <= '0';
									ERES   <= '0';
									INITIAL_CONFIG <= '1';
									SR1_V(0) <= '1'; --WIP
								END IF;
                        	ELSE
                            -- E_ERR bit will be set when the user attempts to
                            -- erase an individual protected main memory sector
                            	SR1_V(5)<= '1'; -- E_ERR
                            	SR1_V(0) <= '1'; -- WIP
							END IF;
						ELSIF CR3_V(1) = '1' THEN
                            IF (UniformSec AND block_no_prot) OR
                             (BottomBoot AND (block_e >= 8) AND  block_no_prot) OR
                             (BottomBoot AND (block_e < 8) AND  block8_no_prot) OR
							 (TopBoot AND (block_e <= 127) AND block_no_prot) OR
							 (TopBoot AND (block_e > 127) AND block127_no_prot) THEN
						     	Addr_ers := Address;
								IF CR3_V(5) = '0' THEN
									bc_done <= '0';
									ESTART <= '1', '0' AFTER 1 ns;
									ESUSP  <= '0';
									ERES   <= '0';
									INITIAL_CONFIG <= '1';
									SR1_V(0) <= '1'; --WIP
								END IF;
                        	ELSE
                            -- E_ERR bit will be set when the user attempts to
                            -- erase an individual protected main memory sector
                            	SR1_V(5)<= '1'; -- E_ERR
                            	SR1_V(0) <= '1'; -- WIP
							END IF;
						END IF;
                    ELSIF (Instruct = P4E OR Instruct = P4E4) AND WEL = '1' THEN
                		SectorErased := ReturnSectorID(Address,BottomBoot,TopBoot);
						IF UniformSec OR (TopBoot AND (SectorErased <= 511)) OR
                        (BottomBoot AND (SectorErased >= 8)) THEN
                            SR1_V(1) <= '0'; -- WEL
						ELSE
                            IF (Sec_Prot(SectorErased) = '0' AND
                            PPB_bits(SectorErased)='1' AND
							DYB_bits(SectorErased)='1') THEN
                            -- A P4E instruction applied to a sector
                            -- that has been Write Protected through the
                            -- Block Protect Bits or ASP will not be
                            -- executed and will set the E_ERR status
								Addr_ers := Address;
								Instruct_P4E := '1';
								IF CR3_V(5) = '0' THEN
									bc_done <= '0';
									ESTART <= '1', '0' AFTER 1 ns;
									ESUSP  <= '0';
									ERES   <= '0';
									INITIAL_CONFIG <= '1';
									SR1_V(0) <= '1'; --WIP
								END IF;
                            ELSE
                            -- E_ERR bit will be set when the user attempts to
                            -- erase an individual protected main memory sector
                            	SR1_V(5)<= '1'; -- E_ERR
                            	SR1_V(0) <= '1'; -- WIP
							END IF;
						END IF;

                    ELSIF Instruct = BE AND WEL = '1' THEN
                        IF SR1_V(4)='0' AND SR1_V(3)='0' AND SR1_V(2)='0' THEN
							IF CR3_V(5) = '0' THEN
								bc_done <= '0';
								ESTART <= '1', '0' AFTER 1 ns;
								ESUSP  <= '0';
								ERES   <= '0';
								INITIAL_CONFIG <= '1';
								SR1_V(0) <= '1';
							END IF;
                        ELSE
                        --The Bulk Erase command will not set E_ERR if a
                        --protected sector is found during the command
                        --execution.
                            SR1_V(1)   <= '0';--WEL
                        END IF;

                    ELSIF (Instruct=PPBP OR Instruct=PPBP4) AND WEL='1' THEN
                        IF ((SECURE_OPN='1' AND PERMLB='1') OR 
                        SECURE_OPN='0') AND PPB_LOCK='1' THEN
                            sect :=
							ReturnSectorID(Address,BottomBoot,TopBoot);
                        	block_e :=
							ReturnBlockID(Address,BottomBoot,TopBoot);
                            PSTART <= '1', '0' AFTER 1 ns;
                            SR1_V(0) <= '1'; --WIP
                        ELSIF PPB_LOCK='0' OR (SECURE_OPN='1' AND PERMLB='0')
						THEN
                            SR1_V(6) <= '1'; -- P_ERR
                            SR1_V(0) <= '1'; -- WIP
						END IF;

                    ELSIF Instruct=PPBE AND WEL = '1' THEN
                        IF SECURE_OPN='1' THEN
	                       	IF PPBOTP='1' AND PPB_LOCK='1' AND PERMLB='1'
							THEN
                                PPBERASE_in <= '1';
                                SR1_V(0) <= '1'; -- WIP
							ELSE
                            	SR1_V(5) <= '1'; -- E_ERR
                            	SR1_V(0) <= '1'; -- WIP
							END IF;
						ELSE
                            SR1_V(1) <= '0'; -- WEL
						END IF;

                    ELSIF Instruct=ASPP AND WEL = '1' THEN
                        IF PWDMLB='1' AND PSTMLB='1' THEN -- Protection Mode not selected
	                       	IF ASP_reg_in(2)='0' AND ASP_reg_in(1)='0' THEN
                            	SR1_V(6) <= '1'; -- P_ERR
                            	SR1_V(0) <= '1'; -- WIP
							ELSE
                                PSTART <= '1', '0' AFTER 1 ns;
                                SR1_V(0) <= '1'; -- WIP
							END IF;
						ELSE
                            SR1_V(6) <= '1'; -- P_ERR
                            SR1_V(0) <= '1'; -- WIP
						END IF;

                    ELSIF Instruct = PLBWR AND WEL = '1' THEN
                        PSTART <= '1', '0' AFTER 1 ns;
                        SR1_V(0) <= '1'; -- WIP

                    ELSIF (Instruct=DYBWR OR Instruct=DYBWR4) AND
						WEL='1' THEN
                            IF DYBAR_in = "11111111" OR
							DYBAR_in = "00000000" THEN
                            	sect := ReturnSectorID(Address,BottomBoot,TopBoot);
                        		block_e :=
								ReturnBlockID(Address,BottomBoot,TopBoot);
                                PSTART <= '1', '0' AFTER 1 ns;
                                SR1_V(0) <= '1'; -- WIP
							ELSE
								SR1_V(6) <= '1'; -- P_ERR
								SR1_V(0) <= '1'; -- WIP
							END IF;

                    ELSIF Instruct=PNVDLR AND WEL='1' THEN
                        IF PWDMLB='1' AND PSTMLB='1' THEN --Protection Mode not selected
                            PSTART <= '1', '0' AFTER 1 ns;
                            SR1_V(0) <= '1'; -- WIP
						ELSE
                            SR1_V(6) <= '1'; -- P_ERR
                            SR1_V(0) <= '1'; -- WIP
						END IF;

                    ELSIF Instruct=WVDLR AND WEL='1' THEN
                        VDLR_reg := VDLR_reg_in;
                        SR1_V(1) <= '0'; -- WEL

                    ELSIF Instruct = PASSP AND WEL = '1' THEN
                        IF (PWDMLB='1' AND PSTMLB='1') THEN--Protection Mode not selected
                            PSTART <= '1', '0' AFTER 5 ns;
                            SR1_V(0) <= '1'; -- WIP
                        ELSE
                            SR1_V(6) <= '1'; -- P_ERR
                            SR1_V(0) <= '1'; -- WIP
                            REPORT "Password programming is not allowed" &
                                   " in Password Protection Mode."
                            SEVERITY warning;
                        END IF;

                    ELSIF Instruct = PASSU AND WEL = '1' THEN
                        IF WIP = '0'  THEN
                            PASSULCK_in <= '1';
                            SR1_V(0) <= '1'; -- WIP
                        ELSE
                            REPORT "The PASSU command cannot be accepted" &
                                   " any faster than once every 100us"
                            SEVERITY warning;
                        END IF;

                    ELSIF Instruct = CLSR THEN
                        SR1_V(6) <= '0';-- P_ERR
                        SR1_V(5) <= '0';-- E_ERR
                        SR1_V(0) <= '0';-- WIP

					END IF;

                    IF Instruct = RSTEN THEN
                        RESET_EN <= '1';
					ELSE
                        RESET_EN <= '0';
					END IF;

				ELSIF oe_z THEN
                    IF Instruct = READ OR Instruct = READ4 THEN
                        rd_fast <= false;
                        rd_slow <= true;
                        dual    <= false;
                        ddr     <= false;
                    ELSIF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
                        rd_fast <= false;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= true;
                    ELSIF Instruct =DIOR OR Instruct = DIOR4 OR
					Instruct =QIOR OR Instruct = QIOR4 THEN
                        rd_fast <= true;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= false;
                    ELSE
                        IF QUAD_ALL = '1' THEN
							rd_fast <= true;
							rd_slow <= false;
							dual    <= true;
							ddr     <= false;
						ELSE
							rd_fast <= true;
							rd_slow <= false;
							dual    <= false;
							ddr     <= false;
						END IF;
                    END IF;

                ELSIF oe THEN
					any_read <= true;
                    IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

                    ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = READ OR Instruct = READ4  THEN
                       -- Read Memory array
						rd_fast <= false;
                        rd_slow <= true;
                        dual    <= false;
                        ddr     <= false;
                        IF Mem(read_addr) /= -1 THEN
                            data_out := to_slv(Mem(read_addr),8);
                            SOut_zd <= data_out(7-read_cnt);
                        ELSE
                            SOut_zd <= 'X';
                        END IF;
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                            IF read_addr = AddrRANGE THEN
                                read_addr := 0;
                            ELSE
                                read_addr := read_addr + 1;
                            END IF;
                        END IF;

                    ELSIF Instruct = FAST_READ OR Instruct = FAST_READ4  THEN
                       -- Read Memory array
						rd_fast <= true;
                        rd_slow <= false;
                        dual    <= false;
                        ddr     <= false;
						IF Mem(read_addr) /= -1 THEN
                            data_out := to_slv(Mem(read_addr),8);
                            SOut_zd <= data_out(7-read_cnt);
                        ELSE
                            SOut_zd <= 'X';
                        END IF;
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
							IF CR4_V(4) = '0' THEN
                            	IF read_addr = AddrRANGE THEN
                                	read_addr := 0;
                            	ELSE
                                	read_addr := read_addr + 1;
								END IF;
							ELSE
                                read_addr := read_addr + 1;
								IF read_addr mod WrapLength = 0 THEN
                                	read_addr := read_addr - WrapLength;
								END IF;
                            END IF;
                        END IF;

                    ELSIF Instruct = DIOR OR Instruct = DIOR4 THEN
                       -- Read Memory array
						rd_fast <= true;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= false;
                        data_out := to_slv(Mem(read_addr),8);
                        SOut_zd  <= data_out(7-2*read_cnt);
                        SIOut_zd <= data_out(6-2*read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 4 THEN
                            read_cnt := 0;

                            IF CR4_V(4) ='0' THEN  -- Wrap Disabled
								IF read_addr = AddrRANGE THEN
									read_addr := 0;
								ELSE
									read_addr := read_addr + 1;
								END IF;
							ELSE
                                read_addr := read_addr + 1;
								IF read_addr MOD WrapLength = 0 THEN
                                    read_addr := read_addr - WrapLength;
								END IF;
							END IF;
                        END IF;

                    ELSIF (Instruct = QIOR OR Instruct = QIOR4 OR
					Instruct=DDRQIOR OR Instruct=DDRQIOR4) AND
					QUAD='1' THEN
                    	IF Instruct=DDRQIOR OR Instruct=DDRQIOR4  THEN
							rd_fast <= false;
							rd_slow <= false;
							dual    <= true;
							ddr     <= true;
                    	ELSE
							rd_fast <= true;
							rd_slow <= false;
							dual    <= true;
							ddr     <= false;
					    END IF;
						IF bus_cycle_state = DUMMY_BYTES THEN
                            IF (Instruct = DDRQIOR OR Instruct = DDRQIOR4) THEN
                                dlp_act := Return_DLP(Latency_code,dummy_cnt);
                                -- Data Learning Pattern (DLP) is enabled
                                -- Optional DLP
                                IF VDLR_reg /= "00000000" AND dlp_act = true
								THEN
                                    RESETNegOut_zd <= VDLR_reg(7-read_cnt);
                                    WPNegOut_zd   <= VDLR_reg(7-read_cnt);
                                    SOut_zd       <= VDLR_reg(7-read_cnt);
                                    SIOut_zd      <= VDLR_reg(7-read_cnt);
                            		dlp_act := FALSE;
									read_cnt := read_cnt + 1;
                                    IF read_cnt = 8 THEN
                                        read_cnt := 0;
                                    END IF;
								END IF;
							END IF;
						ELSE
                        	data_out := to_slv(Mem(read_addr),8);
							RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
							read_cnt := read_cnt + 1;
							IF read_cnt = 2 THEN
								read_cnt := 0;

								IF CR4_V(4) ='0' THEN  -- Wrap Disabled
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr MOD WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
						END IF;

                    ELSIF Instruct = OTPR  THEN
                        IF (read_addr>=OTPLoAddr) AND
							(read_addr<=OTPHiAddr) THEN
                        -- Read OTP Memory array
							rd_fast <= true;
							rd_slow <= false;
							dual    <= false;
							ddr     <= false;
                            data_out := to_slv(OTPMem(read_addr),8);
                            SOut_zd <= data_out(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                                read_addr := read_addr + 1;
                            END IF;
                        ELSIF (read_addr > OTPHiAddr) THEN
                        --OTP Read operation will not wrap to the
                        --starting address after the OTP address is at
                        --its maximum or Read Password Protection Mode
                        --is selected; instead, the data beyond the
                        --maximum OTP address will be undefined.
                            SOut_zd <= 'X';
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDID THEN
                        IF QUAD_ALL = '1' THEN
                            IF (Addr_idcfi <= CFILength) THEN
                                data_out(7 DOWNTO 0) := to_slv(SFDP_array(16#1000#+Addr_idcfi),8);
                                RESETNegOut_zd <= data_out(7-4*read_cnt);
                                WPNegOut_zd   <= data_out(6-4*read_cnt);
                                SOut_zd       <= data_out(5-4*read_cnt);
                                SIOut_zd      <= data_out(4-4*read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 2 THEN
                                    read_cnt := 0;
                                    Addr_idcfi := Addr_idcfi+1;
                                END IF;
                            END IF;
						ELSE
                            IF (Addr_idcfi <= CFILength) THEN
                                data_out(7 DOWNTO 0) := to_slv(SFDP_array(16#1000#+Addr_idcfi),8);
								SOut_zd       <= data_out(7-read_cnt);
                            	read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                    Addr_idcfi := Addr_idcfi+1;
                                END IF;
							END IF;
						END IF;

					ELSIF Instruct = RDQID AND QUAD = '1' THEN
						rd_fast <= true;
						rd_slow <= false;
						dual    <= true;
						ddr     <= false;
                        IF (Addr_idcfi <= CFILength) THEN
                            data_out(7 DOWNTO 0) := to_slv(SFDP_array(16#1000#+Addr_idcfi),8);
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                                Addr_idcfi := Addr_idcfi+1;
                            END IF;
						END IF;

					ELSIF Instruct = RSFDP THEN
                        IF QUAD_ALL = '1' THEN
                            IF (read_addr <= SFDPHiAddr) THEN
                                data_out(7 DOWNTO 0) := to_slv(SFDP_array(read_addr),8);
                                RESETNegOut_zd <= data_out(7-4*read_cnt);
                                WPNegOut_zd   <= data_out(6-4*read_cnt);
                                SOut_zd       <= data_out(5-4*read_cnt);
                                SIOut_zd      <= data_out(4-4*read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 2 THEN
                                    read_cnt := 0;
                                    read_addr := read_addr+1;
                                END IF;
							ELSE
                            -- Continued shifting of output beyond the end of
                            -- the defined ID-CFI address space will
                            -- provide undefined data.
								RESETNegOut_zd <= 'X';
								WPNegOut_zd   <= 'X';
								SOut_zd       <= 'X';
								SIOut_zd      <= 'X';
							END IF;
						ELSE
                            IF (read_addr <= SFDPHiAddr) THEN
                                data_out(7 DOWNTO 0) := to_slv(SFDP_array(read_addr),8);
                                SOut_zd <= data_out(7-read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                    read_addr := read_addr+1;
                                END IF;
							ELSE
                            -- Continued shifting of output beyond the end of
                            -- the defined ID-CFI address space will
                            -- provide undefined data.
								SOut_zd       <= 'X';
							END IF;
						END IF;

					ELSIF Instruct = DLPRD THEN
                            -- Read DLP
                        SOut_zd <= VDLR_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = ECCRD OR  Instruct = ECCRD4 THEN
                        IF QUAD_ALL = '1' THEN
							RESETNegOut_zd <= ECC_reg(7-4*read_cnt);
							WPNegOut_zd   <= ECC_reg(6-4*read_cnt);
							SOut_zd       <= ECC_reg(5-4*read_cnt);
							SIOut_zd      <= ECC_reg(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
							END IF;
						ELSE
							SOut_zd <= ECC_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
							END IF;
						END IF;

					ELSIF Instruct = DYBRD OR Instruct = DYBRD4 THEN
                        --Read DYB Access Register
						sect := ReturnSectorID(Address,BottomBoot,TopBoot);
                        rd_fast <= true;
                        rd_slow <= false;
                        dual    <= false;
                        ddr     <= false;

                        IF DYB_bits(sect) = '1' THEN
                            DYBAR(7 downto 0) := "11111111";
                        ELSE
                            DYBAR(7 downto 0) := "00000000";
                        END IF;

                        IF QUAD_ALL = '1' THEN
							RESETNegOut_zd <= DYBAR(7-4*read_cnt);
							WPNegOut_zd   <= DYBAR(6-4*read_cnt);
							SOut_zd       <= DYBAR(5-4*read_cnt);
							SIOut_zd      <= DYBAR(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
							END IF;
						ELSE
							SOut_zd <= DYBAR(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
							END IF;
						END IF;

					ELSIF Instruct = PPBRD OR Instruct = PPBRD4 THEN
                        --Read PPB Access Register
                        sect := ReturnSectorID(Address,BottomBoot,TopBoot);
                        IF PPB_bits(sect) = '1' THEN
                            PPBAR(7 downto 0) := "11111111";
                        ELSE
                            PPBAR(7 downto 0) := "00000000";
                        END IF;

						SOut_zd <= PPBAR(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                           read_cnt := 0;
						END IF;

					ELSIF Instruct = ASPRD THEN
                        --Read ASP Register
						SOut_zd <= ASP_reg(15-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 16 THEN
                           read_cnt := 0;
						END IF;

					ELSIF Instruct = PLBRD THEN
                        --Read PPB Lock Register
						SOut_zd <= PPBL(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                           read_cnt := 0;
						END IF;

					ELSIF Instruct = PASSRD THEN
                        --Read Password Register
						IF NOT(PWDMLB='0' AND PSTMLB='1') THEN
							SOut_zd <=
							Password_reg((8*byte_cnt-1)-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                                byte_cnt := byte_cnt + 1;
                                IF byte_cnt = 9 THEN
                                   byte_cnt := 1;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;

			WHEN WRITE_SR       =>
				IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
				ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

                    ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;

                IF WDONE = '1' THEN
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0'; -- WEL
                    -- SRWD bit
                    SR1_NV(7) <= SR1_in(7);
                    SR1_V(7) <= SR1_in(7);
                    IF (LOCK_O='0' AND SECURE_OPN='1') OR SECURE_OPN='0' THEN
                        IF FREEZE = '0' THEN
						-- The Freeze Bit, when set to 1, locks the current
                        -- state of the BP2-0 bits in Status Register,
                        -- the TBPROT and TBPARM bits in the Config Register
                        -- As long as the FREEZE bit remains cleared to logic
                        -- '0', the other bits of the Configuration register
                        -- including FREEZE are writeable.
                            IF BPNV_O = '0' THEN
                                SR1_NV(4) <= SR1_in(4); -- BP2_NV
                                SR1_NV(3) <= SR1_in(3); -- BP1_NV
                                SR1_NV(2) <= SR1_in(2); -- BP0_NV
                                SR1_V(4) <= SR1_in(4); -- BP2
                                SR1_V(3) <= SR1_in(3); -- BP1
                                SR1_V(2) <= SR1_in(2); -- BP0
                            ELSE
								SR1_V(4) <= SR1_in(4); -- BP2
                                SR1_V(3) <= SR1_in(3); -- BP1
                                SR1_V(2) <= SR1_in(2); -- BP0
                            END IF;

                            BP_bits := SR1_V(4) & SR1_V(3) & SR1_V(2);

							IF TBPROT_O='0' AND INITIAL_CONFIG='0' THEN
                                CR1_NV(5) <= CR1_in(5);--TBPROT_O
                                CR1_V(5)  <= CR1_in(5);--TBPROT
							END IF;

                            IF BPNV_O='0' THEN
                                CR1_NV(3) <= CR1_in(3);--BPNV_O
                                CR1_V(3)  <= CR1_in(3);--BPNV
                            END IF;
                            IF TBPARM_O='0' AND INITIAL_CONFIG='0' AND
                                CR3_V(3)='0' THEN
                                CR1_NV(2) <= CR1_in(2);--TBPARM_O
                                CR1_V(2)  <= CR1_in(2);--TBPARM
                                change_TBPARM <= '1', '0' AFTER 1 ns;
                            END IF;

                            change_BP <= '1', '0' AFTER 1 ns;
                        END IF;
                    END IF;

					IF QUAD_ALL ='0' THEN
                    -- While Quad All mode is selected (CR2NV[1]=1 or CR2V[1]=1)
                    -- the QUAD bit cannot be cleared to 0.
                        CR1_NV(1) <= CR1_in(1);  -- QUAD_NV
                        CR1_V(1)  <= CR1_in(1);  -- QUAD
                    END IF;

                    IF (FREEZE = '0') THEN
                        CR1_V(0) <= CR1_in(0); -- FREEZE
                    END IF;

                    IF (SECURE_OPN = '1'  AND LOCK_O = '0') THEN
                        CR1_NV(4) <= CR1_in(4); -- LOCK_O
                        CR1_V(4)  <= CR1_in(4); -- LOCK
                    END IF;
				END IF;

			WHEN WRITE_ALL_REG       =>
				IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
				ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

                    ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;

                new_pass_byte := WRAR_reg_in;
				IF Addr = 16#0000020# THEN
                	old_pass_byte := Password_reg(7 downto 0);
				ELSIF Addr = 16#0000021# THEN
                	old_pass_byte := Password_reg(15 downto 8);
				ELSIF Addr = 16#0000022# THEN
                	old_pass_byte := Password_reg(23 downto 16);
				ELSIF Addr = 16#0000023# THEN
                	old_pass_byte := Password_reg(31 downto 24);
				ELSIF Addr = 16#0000024# THEN
                	old_pass_byte := Password_reg(39 downto 32);
				ELSIF Addr = 16#0000025# THEN
                	old_pass_byte := Password_reg(47 downto 40);
				ELSIF Addr = 16#0000026# THEN
                	old_pass_byte := Password_reg(55 downto 48);
				ELSIF Addr = 16#0000027# THEN
                	old_pass_byte := Password_reg(63 downto 56);
				END IF;
                FOR j IN 0 TO 7 LOOP
                    IF old_pass_byte(j) = '0' THEN
                        new_pass_byte(j) := '0';
                    END IF;
                END LOOP;

				IF WDONE = '1' AND CSDONE = '1' THEN
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0'; -- WEL

                    IF Addr = 16#0000000# THEN -- SR1_NV;
                        SR1_NV(7) <= WRAR_reg_in(7);
                        SR1_V(7) <= WRAR_reg_in(7);
						IF (LOCK_O='0' AND SECURE_OPN='1') OR SECURE_OPN='0' THEN
							IF FREEZE = '0' THEN
								IF BPNV_O = '0' THEN
									SR1_NV(4) <= WRAR_reg_in(4); -- BP2_NV
									SR1_NV(3) <= WRAR_reg_in(3); -- BP1_NV
									SR1_NV(2) <= WRAR_reg_in(2); -- BP0_NV
									SR1_V(4) <= WRAR_reg_in(4); -- BP2
									SR1_V(3) <= WRAR_reg_in(3); -- BP1
									SR1_V(2) <= WRAR_reg_in(2); -- BP0

									BP_bits := SR1_V(4) & SR1_V(3) & SR1_V(2);
									change_BP <= '1', '0' AFTER 1 ns;
								END IF;
							END IF;
						END IF;

                    ELSIF Addr = 16#0000002# THEN -- CR1_NV;
						IF (LOCK_O='0' AND SECURE_OPN='1') OR SECURE_OPN='0'
						THEN
                        	IF FREEZE = '0' THEN
								IF TBPROT_O='0' AND INITIAL_CONFIG='0' THEN
									CR1_NV(5) <= WRAR_reg_in(5);--TBPROT_O
									CR1_V(5)  <= WRAR_reg_in(5);--TBPROT
								END IF;

								IF BPNV_O='0' THEN
									CR1_NV(3) <= WRAR_reg_in(3);--BPNV_O
									CR1_V(3)  <= WRAR_reg_in(3);--BPNV
								END IF;
								IF TBPARM_O='0' AND INITIAL_CONFIG='0' AND
									CR3_V(3)='0' THEN
									CR1_NV(2) <= WRAR_reg_in(2);--TBPARM_O
									CR1_V(2)  <= WRAR_reg_in(2);--TBPARM
									change_TBPARM <= '1', '0' AFTER 1 ns;
								END IF;
							END IF;
						END IF;
						IF QUAD_ALL ='0' THEN
                    -- While Quad All mode is selected (CR2NV[1]=1 or CR2V[1]=1)
                    -- the QUAD bit cannot be cleared to 0.
							CR1_NV(1) <= WRAR_reg_in(1);  -- QUAD_NV
							CR1_V(1)  <= WRAR_reg_in(1);  -- QUAD
						END IF;
						IF (SECURE_OPN = '1'  AND LOCK_O = '0') THEN
							CR1_NV(4) <= WRAR_reg_in(4); -- LOCK_O
							CR1_V(4)  <= WRAR_reg_in(4); -- LOCK
						END IF;

                    ELSIF Addr = 16#0000003# THEN -- CR2_NV;
                       IF CR2_NV(7) = '0' THEN
                            CR2_NV(7) <= WRAR_reg_in(7); --  AL_NV
                            CR2_V(7)  <= WRAR_reg_in(7); --  AL
                        END IF;

                       IF CR2_NV(6)='0' AND WRAR_reg_in(6)='1'  THEN
                            CR2_NV(6) <= WRAR_reg_in(6); --  QA_NV
                            CR2_V(6)  <= WRAR_reg_in(6); --  QA

                            CR1_NV(1) <= '1' ;  -- QUAD_NV
                            CR1_V(1)  <= '1' ;  -- QUAD
                        END IF;

                       IF CR2_NV(5) = '0' THEN
                            CR2_NV(5) <= WRAR_reg_in(5); --  IO3R_NV
                            CR2_V(5)  <= WRAR_reg_in(5); --  IO3R_S
                        END IF;

                       IF CR2_NV(3 downto 0) = "1000" THEN
                            CR2_NV(3 downto 0) <=
									WRAR_reg_in(3 downto 0); -- RL_NV(3:0)
                            CR2_V(3 downto 0)  <=
									WRAR_reg_in(3 downto 0); -- RL(3:0)
                        END IF;

                    ELSIF Addr = 16#0000004# THEN -- CR3_NV;
                    	IF CR3_NV(5) = '0' THEN
                            CR3_NV(5) <= WRAR_reg_in(5); --  BC_NV
                            CR3_V(5)  <= WRAR_reg_in(5); --  BC_V
                        END IF;

                       IF CR3_NV(4) = '0'  THEN
                            CR3_NV(4) <= WRAR_reg_in(4); --  02h_NV
                            CR3_V(4)  <= WRAR_reg_in(4); --  02h_V
                        END IF;

                       IF CR3_NV(3) = '0' THEN
                            CR3_NV(3) <= WRAR_reg_in(3); --  20_NV
                            CR3_V(3)  <= WRAR_reg_in(3); --  20_V
                        END IF;

                       IF CR3_NV(2) = '0' THEN
                            CR3_NV(2) <= WRAR_reg_in(2); --  30_NV
                            CR3_V(2)  <= WRAR_reg_in(2); --  30_V
                        END IF;

                       IF CR3_NV(1) = '0' THEN
                            CR3_NV(1) <= WRAR_reg_in(1); --  D8h_NV
                            CR3_V(1)  <= WRAR_reg_in(1); --  D8h_V
                        END IF;

                       IF CR3_NV(0) = '0' THEN
                            CR3_NV(0) <= WRAR_reg_in(0); --  F0_NV
                            CR3_V(0)  <= WRAR_reg_in(0); --  F0_V
                        END IF;

                    ELSIF Addr = 16#0000005# THEN -- CR4_NV;
                       IF CR4_NV(7 downto 5) = "000" THEN
                            CR4_NV(7 downto 5) <= WRAR_reg_in(7 downto 5); --  OI_O(2:0)
                            CR4_V(7 downto 5)  <= WRAR_reg_in(7 downto 5); --  OI(2:0)
                        END IF;

                       IF CR4_NV(4) = '0' THEN
                            CR4_NV(4) <= WRAR_reg_in(4); --  WE_O
                            CR4_V(4)  <= WRAR_reg_in(4); --  WE
                        END IF;

                       IF CR4_NV(1 downto 0) = "00" THEN
                            CR4_NV(1 downto 0) <= WRAR_reg_in(1 downto 0); --  WL_O(1:0)
                            CR4_V(1 downto 0)  <= WRAR_reg_in(1 downto 0); --  WL(1:0)
                        END IF;

                    ELSIF Addr = 16#0000010# THEN -- NVDLR_reg;
                        IF NVDLR_reg = "00000000" THEN
                            NVDLR_reg := WRAR_reg_in;
                            VDLR_reg  := WRAR_reg_in;
                        ELSE
                            REPORT "NVDLR bits allready programmed"
                            SEVERITY warning;
                    	END IF;

					ELSIF Addr = 16#0000020# THEN -- Password_reg[7:0]
                        Password_reg(7 DOWNTO 0) := new_pass_byte;

					ELSIF Addr = 16#0000021# THEN -- Password_reg[15:8]
                        Password_reg(15 DOWNTO 8) := new_pass_byte;

					ELSIF Addr = 16#0000022# THEN -- Password_reg[23:16]
                        Password_reg(23 DOWNTO 16) := new_pass_byte;

					ELSIF Addr = 16#0000023# THEN -- Password_reg[31:24]
                        Password_reg(31 DOWNTO 24) := new_pass_byte;

					ELSIF Addr = 16#0000024# THEN -- Password_reg[39:32]
                        Password_reg(39 DOWNTO 32) := new_pass_byte;

					ELSIF Addr = 16#0000025# THEN -- Password_reg[47:40]
                        Password_reg(47 DOWNTO 40) := new_pass_byte;

					ELSIF Addr = 16#0000026# THEN -- Password_reg[55:48]
                        Password_reg(55 DOWNTO 48) := new_pass_byte;

					ELSIF Addr = 16#0000027# THEN -- Password_reg[63:56]
                        Password_reg(63 DOWNTO 56) := new_pass_byte;

					ELSIF Addr = 16#0000030# THEN -- ASP Register
                        IF SECURE_OPN = '1' THEN
                            IF DYBLBB = '0' AND WRAR_reg_in(4) = '1' THEN
                            	REPORT "DYBLBB bit is allready programmed"
                            	SEVERITY warning;
                            ELSE
                                ASP_reg(4) := WRAR_reg_in(4); -- DYBLBB
							END IF;

                            IF PPBOTP = '0' AND WRAR_reg_in(3) = '1' THEN
								REPORT "PPBOTP bit is allready programmed"
                            	SEVERITY warning;
                            ELSE
                                ASP_reg(3) := WRAR_reg_in(3); --PPBOTP
							END IF;

                            IF PERMLB = '0' AND WRAR_reg_in(0) = '1' THEN
								REPORT "PERMLB bit is allready programmed"
                            	SEVERITY warning;
                            ELSE
                                ASP_reg(0) := WRAR_reg_in(0); --PERMLB
							END IF;
                        END IF;

                        ASP_reg(2) := WRAR_reg_in(2); -- PWDMLB
                        ASP_reg(1) := WRAR_reg_in(1); -- PSTMLB

					ELSIF Addr = 16#0000031# THEN -- ASP_reg[15:8]
						REPORT "RFU bits"
                        SEVERITY warning;
					ELSIF Addr = 16#0800000# THEN --  SR1_V
                        -- SRWD bit
                        SR1_V (7) <= WRAR_reg_in(7);

                       IF (LOCK_O='0' AND SECURE_OPN='1') OR
											SECURE_OPN='0' THEN
                           IF FREEZE = '0' THEN
                             -- The Freeze Bit, when set to 1, locks the current
                             -- state of the BP2-0 bits in Status Register.
                               IF BPNV_O = '1' THEN
                                    SR1_V(4)  <= WRAR_reg_in(4); -- BP2
                                    SR1_V(3)  <= WRAR_reg_in(3); -- BP1
                                    SR1_V(2)  <= WRAR_reg_in(2); -- BP0

                                    BP_bits :=
									SR1_V(4) & SR1_V(3) & SR1_V(2);

                                    change_BP <= '1', '0' AFTER 1 ns;
                                END IF;
                            END IF;
                        END IF;
					ELSIF Addr = 16#0800001# THEN -- SR2_V
						REPORT "Status Register 2 does not have use r" &
							"programmable bits, all defined bits are " &
							"volatile read only status."
                        SEVERITY warning;

					ELSIF Addr = 16#0800002# THEN -- CR1_V
                        IF QUAD_ALL = '0' THEN
                        -- While Quad All mode is selected (CR2NV[1]=1 or
                        -- CR2V[1]=1) the QUAD bit cannot be cleared to 0.
                            CR1_V(1)  <= WRAR_reg_in(1); --QUAD
                        END IF;

                        IF FREEZE = '0' THEN
                            CR1_V(0) <= WRAR_reg_in(0); -- FREEZE
                        END IF;

					ELSIF Addr = 16#0800003# THEN -- CR2_V
 						CR2_V(7)   <= WRAR_reg_in(7);   --  AL
                        CR2_V(6)   <= WRAR_reg_in(6);   --  QA
                        IF WRAR_reg_in(6) = '1' THEN
                            CR1_V(1)  <= '1';  --  QUAD
						END IF;
                        CR2_V(5)   <= WRAR_reg_in(5);   --  IO3R_S
                        CR2_V(3 downto 0) <= WRAR_reg_in(3 downto 0); --  RL(3:0)

					ELSIF Addr = 16#0800004# THEN -- CR3_V
                        CR3_V(5)  <= WRAR_reg_in(5); --  BC_V
                        CR3_V(4)  <= WRAR_reg_in(4); --  02h_V
                        CR3_V(3)  <= WRAR_reg_in(3); --  20_V
                        CR3_V(2)  <= WRAR_reg_in(2); --  30_V
                        CR3_V(1)  <= WRAR_reg_in(1); --  D8h_V
                        CR3_V(0)  <= WRAR_reg_in(0); --  F0_V

					ELSIF Addr = 16#0800005# THEN -- CR4_V
                        CR4_V(7 downto 5)  <= WRAR_reg_in(7 downto 5);-- OI(2:0)
                        CR4_V(4)           <= WRAR_reg_in(4);  -- WE
                        CR4_V(1 downto 0)  <= WRAR_reg_in(1 downto 0); -- WL(1:0)

                    ELSIF Addr = 16#0800010# THEN  -- VDLR_reg
                        VDLR_reg  := WRAR_reg_in;
                    END IF;
				END IF;

			WHEN PAGE_PG       =>
                IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
                ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;

				IF falling_edge(PDONE) THEN
                    ADDRHILO_PG(AddrLo, AddrHi, Addr_pgm);
                    cnt := 0;
                    FOR i IN 0 TO wr_cnt LOOP
                        new_int := WData(i);
                        old_int := Mem(Addr_pgm + i - cnt);

                        IF new_int > -1 THEN
                            new_bit := to_slv(new_int,8);
                            IF old_int > -1 THEN
                                old_bit := to_slv(old_int,8);
                                FOR j IN 0 TO 7 LOOP
                                    IF old_bit(j) = '0' THEN
                                        new_bit(j) := '0';
                                    END IF;
                                END LOOP;
                                new_int := to_nat(new_bit);
                            END IF;
                            WData(i) := new_int;
                        ELSE
                            WData(i) := -1;
                        END IF;

                        Mem(Addr_pgm + i - cnt) :=  -1;
                        IF (Addr_pgm + i) = AddrHi THEN
                            Addr_pgm := AddrLo;
                            cnt := i + 1;
                        END IF;
                    END LOOP;
                    cnt :=0;
                END IF;

                IF rising_edge(PDONE) THEN
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0';  -- WEL
                    FOR i IN 0 TO wr_cnt LOOP
                        Mem(Addr_pgm_tmp + i - cnt) :=  WData(i);
                        IF (Addr_pgm_tmp + i) = AddrHi THEN
                            Addr_pgm_tmp := AddrLo;
                            cnt := i + 1;
                        END IF;
                    END LOOP;

                ELSIF falling_edge(write) THEN
					IF Instruct = EPS AND PRGSUSP_in = '0' THEN
						IF RES_TO_SUSP_TIME = '0' THEN
							PGSUSP <= '1', '0' AFTER 1 ns;
							PRGSUSP_in <= '1';
						ELSE
							ASSERT FALSE
							REPORT "Minimum for tPRS is not satisfied! " &
								"PGSP command is ignored"
							SEVERITY warning;
						END IF;
					END IF;
                END IF;

			WHEN PG_SUSP       =>
                IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
                ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
				IF PRGSUSP_out = '1' AND PRGSUSP_in = '1' THEN
					PRGSUSP_in <= '0';
                    -- The WIP bit in the Status Register will indicate that
                    -- the device is ready for another operation.
                    SR1_V(0) <= '0';
                    -- The Program Suspend (PS) bit in the Status Register will
                    -- be set to the logical “1” state to indicate that the
                    -- program operation has been suspended.
                    SR2_V(0) <= '1';
				END IF;
                IF oe THEN
					any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

					ELSIF Instruct = READ OR Instruct = READ4  THEN
                       -- Read Memory array
						rd_fast <= false;
                        rd_slow <= true;
                        dual    <= false;
                        ddr     <= false;
                        IF pgm_page /= (read_addr / (PageSize+1)) THEN
							IF Mem(read_addr) /= -1 THEN
								data_out := to_slv(Mem(read_addr),8);
								SOut_zd <= data_out(7-read_cnt);
							ELSE
								SOut_zd <= 'X';
							END IF;
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF read_addr = AddrRANGE THEN
									read_addr := 0;
								ELSE
									read_addr := read_addr + 1;
								END IF;
							END IF;
						ELSE
							SOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF read_addr = AddrRANGE THEN
									read_addr := 0;
								ELSE
									read_addr := read_addr + 1;
								END IF;
							END IF;
                        END IF;

					ELSIF Instruct=FAST_READ OR Instruct=FAST_READ4 THEN
                        IF pgm_page /= (read_addr / (PageSize+1)) THEN
							data_out := to_slv(Mem(read_addr),8);
							SOut_zd <= data_out(7-read_cnt);
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
						ELSE
							SOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
                        END IF;

					ELSIF Instruct=DIOR OR Instruct=DIOR4 THEN
                        -- Read Memory array
                        rd_fast <= true;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= false;
                        IF pgm_page /= (read_addr / (PageSize+1)) THEN
							data_out := to_slv(Mem(read_addr),8);
							SOut_zd <= data_out(7-2*read_cnt);
							SIOut_zd <= data_out(6-2*read_cnt);
							read_cnt := read_cnt + 1;
							IF read_cnt = 4 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN -- Burst read wrap disabled
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
						ELSE
							SOut_zd <= 'X';
							SIOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 4 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN -- Burst read wrap disabled
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
                        END IF;

					ELSIF (Instruct = QIOR OR Instruct = QIOR4 OR
					Instruct=DDRQIOR OR Instruct=DDRQIOR4) AND QUAD='1' THEN
                    	IF Instruct = DDRQIOR OR Instruct = DDRQIOR4  THEN
							rd_fast <= false;
							rd_slow <= false;
							dual    <= true;
							ddr     <= true;
                    	ELSE
							rd_fast <= true;
							rd_slow <= false;
							dual    <= true;
							ddr     <= false;
					    END IF;
                        IF pgm_page /= (read_addr / (PageSize+1)) THEN
							IF bus_cycle_state = DUMMY_BYTES THEN
								IF (Instruct = DDRQIOR OR Instruct = DDRQIOR4) THEN
									dlp_act := Return_DLP(Latency_code,dummy_cnt);
									-- Data Learning Pattern (DLP) is enabled
									-- Optional DLP
									IF VDLR_reg /= "00000000" AND dlp_act = true THEN
										RESETNegOut_zd <= VDLR_reg(7-read_cnt);
										WPNegOut_zd   <= VDLR_reg(7-read_cnt);
										SOut_zd       <= VDLR_reg(7-read_cnt);
										SIOut_zd      <= VDLR_reg(7-read_cnt);
										dlp_act := FALSE;
										read_cnt := read_cnt + 1;
										IF read_cnt = 8 THEN
											read_cnt := 0;
										END IF;
									END IF;
								END IF;
							ELSE
								data_out := to_slv(Mem(read_addr),8);
								RESETNegOut_zd <= data_out(7-4*read_cnt);
								WPNegOut_zd   <= data_out(6-4*read_cnt);
								SOut_zd       <= data_out(5-4*read_cnt);
								SIOut_zd      <= data_out(4-4*read_cnt);
								read_cnt := read_cnt + 1;
								IF read_cnt = 2 THEN
									read_cnt := 0;

									IF CR4_V(4) ='0' THEN  -- Wrap Disabled
										IF read_addr = AddrRANGE THEN
											read_addr := 0;
										ELSE
											read_addr := read_addr + 1;
										END IF;
									ELSE
										read_addr := read_addr + 1;
										IF read_addr MOD WrapLength = 0 THEN
											read_addr := read_addr - WrapLength;
										END IF;
									END IF;
								END IF;
							END IF;
						ELSE
							RESETNegOut_zd <= 'X';
							WPNegOut_zd   <= 'X';
							SOut_zd <= 'X';
							SIOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 2 THEN
								read_cnt := 0;
								IF CR4_V(4) ='0' THEN  -- Wrap Disabled
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr MOD WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
				ELSIF oe_z THEN
					IF Instruct = READ OR Instruct = READ4  THEN
						rd_fast <= false;
                        rd_slow <= true;
                        dual    <= false;
                        ddr     <= false;
					ELSIF Instruct = DIOR OR Instruct = DIOR4  OR
					Instruct = QIOR OR Instruct = QIOR4 THEN
						rd_fast <= false;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= false;
					ELSIF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
						rd_fast <= false;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= true;
					ELSE
                        IF QUAD_ALL = '1' THEN
							rd_fast <= true;
							rd_slow <= false;
							dual    <= true;
							ddr     <= false;
                        ELSE
							rd_fast <= true;
							rd_slow <= false;
							dual    <= false;
							ddr     <= false;
						END IF;
					END IF;
				END IF;

				IF falling_edge(write) THEN
                    IF Instruct = EPR THEN
                        SR2_V(0) <= '0'; -- PS
                        SR1_V(0) <= '1'; -- WIP
                        PGRES  <= '1', '0' AFTER 1 ns;
                        RES_TO_SUSP_TIME <= '1', '0' AFTER res_time; -- 100us
                    ELSIF Instruct = CLSR THEN
                        SR1_V(6) <= '0';-- P_ERR
                        SR1_V(5) <= '0';-- E_ERR
                        SR1_V(0) <= '0';-- WIP
                    END IF;

                    IF Instruct = RSTEN THEN
                        RESET_EN <= '1';
					ELSE
                        RESET_EN <= '0';
					END IF;
                END IF;

			WHEN OTP_PG       =>
				rd_fast <= true;
				rd_slow <= false;
				dual    <= false;
				ddr     <= false;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        SOut_zd <= SR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDAR THEN
                        READ_ALL_REG(RDAR_reg, read_addr);
                        SOut_zd <= RDAR_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                END IF;

				IF falling_edge(PDONE) THEN
                    FOR i IN 0 TO wr_cnt LOOP
                        new_int := WData(i);
                        old_int := OTPMem(Addr_pgm + i);
                        IF new_int > -1 THEN
                            new_bit := to_slv(new_int,8);
                            IF old_int > -1 THEN
                                old_bit := to_slv(old_int,8);
                                FOR j IN 0 TO 7 LOOP
                                    IF old_bit(j) = '0' THEN
                                        new_bit(j) := '0';
                                    END IF;
                                END LOOP;
                                new_int := to_nat(new_bit);
                            END IF;
                            WData(i) := new_int;
                        ELSE
                            WData(i) := -1;
                        END IF;

                        OTPMem(Addr_pgm + i) :=  -1;
                    END LOOP;
 				END IF;

                IF rising_edge(PDONE) THEN
                    SR1_V(0) <= '0';
                    SR1_V(1) <= '0';
                    FOR i IN 0 TO wr_cnt LOOP
                        OTPMem(Addr_pgm + i) := WData(i);
                    END LOOP;
                    LOCK_BYTE1 := to_slv(OTPMem(16#10#),8);
                    LOCK_BYTE2 := to_slv(OTPMem(16#11#),8);
                    LOCK_BYTE3 := to_slv(OTPMem(16#12#),8);
                    LOCK_BYTE4 := to_slv(OTPMem(16#13#),8);
                END IF;

			WHEN SECTOR_ERS       =>
                IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
                ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
				IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;

				IF falling_edge(EDONE) THEN
					IF CR3_V(1) = '0' THEN
                		ADDRHILO_SEC(AddrLo, AddrHi, Addr_ers);
                		FOR i IN AddrLo TO AddrHi LOOP
                    		Mem(i) := -1;
                		END LOOP;
					ELSIF CR3_V(1) = '1' THEN
                		ADDRHILO_BLK(AddrLo, AddrHi, Addr_ers);
                		FOR i IN AddrLo TO AddrHi LOOP
                    		Mem(i) := -1;
                		END LOOP;
					END IF;
				END IF;

				IF rising_edge(EDONE) THEN
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0';  -- WEL
					IF CR3_V(1) = '0' THEN
                		ADDRHILO_SEC(AddrLo, AddrHi, Addr_ers);
                    	ERS_nosucc(SectorErased) <= '0';
                		FOR i IN AddrLo TO AddrHi LOOP
                    		Mem(i) := MaxData;
                		END LOOP;
					ELSIF CR3_V(1) = '1' THEN
                		ADDRHILO_BLK(AddrLo, AddrHi, Addr_ers);
                    	ERS_nosucc_b(BlockErased) <= '0';
                		FOR i IN AddrLo TO AddrHi LOOP
                    		Mem(i) := MaxData;
                		END LOOP;
					END IF;
				END IF;

				IF falling_edge(write) THEN
                	IF Instruct = EPS AND ERSSUSP_in = '0' THEN
						IF RES_TO_SUSP_TIME = '0' THEN
							ESUSP <= '1', '0' AFTER 1 ns;
							ERSSUSP_in <= '1';
						ELSE
							ASSERT false
							REPORT "Minimum for tRS is not satisfied!" &
									"PGSP command is ignored"
                            SEVERITY warning;
                		END IF;
                	END IF;
                END IF;

			WHEN BULK_ERS       =>
                IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
                ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
				IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;

				IF falling_edge(EDONE) THEN
					FOR i IN 0 TO AddrRANGE LOOP
						sect := ReturnSectorID(i,BottomBoot,TopBoot);
                        IF (PPB_bits(sect) = '1' AND DYB_bits(sect) = '1') THEN
                                Mem(i) := -1;
                        END IF;
                    END LOOP;
				END IF;

				IF EDONE = '1' THEN
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0';  -- WEL
					FOR i IN 0 TO AddrRANGE LOOP
						sect := ReturnSectorID(i,BottomBoot,TopBoot);
                        IF (PPB_bits(sect) = '1' AND DYB_bits(sect) = '1') THEN
                                Mem(i) := MaxData;
                        END IF;
                    END LOOP;
				END IF;

			WHEN ERS_SUSP       =>
                IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
                ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
				IF ERSSUSP_out = '1' THEN
                    ERSSUSP_in <= '0';
                    -- The WIP bit in the Status Register will indicate that
                    -- the device is ready for another operation.
                    SR1_V(0) <= '0';
                    -- The Erase Suspend (ES) bit in the Status Register will
                    -- be set to the logical “1” state to indicate that the
                    -- erase operation has been suspended.
                    SR2_V(1) <= '1';
				END IF;

				IF oe THEN
					any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

					ELSIF Instruct = READ OR Instruct = READ4  THEN
                       -- Read Memory array
						rd_fast <= false;
                        rd_slow <= true;
                        dual    <= false;
                        ddr     <= false;																			
                        sect :=
						ReturnSectorID(read_addr,BottomBoot,TopBoot);
                        block_e :=
						ReturnBlockID(read_addr,BottomBoot,TopBoot);
                        IF (sect /= SectorErased AND CR3_V(1)='0') OR
						(block_e /= BlockErased AND CR3_V(1)='1') THEN
							IF Mem(read_addr) /= -1 THEN
								data_out := to_slv(Mem(read_addr),8);
								SOut_zd <= data_out(7-read_cnt);
							ELSE
								SOut_zd <= 'X';
							END IF;
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF read_addr = AddrRANGE THEN
									read_addr := 0;
								ELSE
									read_addr := read_addr + 1;
								END IF;
							END IF;
						ELSE
							SOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF read_addr = AddrRANGE THEN
									read_addr := 0;
								ELSE
									read_addr := read_addr + 1;
								END IF;
							END IF;
                        END IF;

					ELSIF Instruct=FAST_READ OR Instruct=FAST_READ4 THEN
                        rd_fast <= true;
                        rd_slow <= false;
                        dual    <= false;
                        ddr     <= false;
                        sect :=
						ReturnSectorID(read_addr,BottomBoot,TopBoot);
                        block_e :=
						ReturnBlockID(read_addr,BottomBoot,TopBoot);
                        IF (sect /= SectorErased AND CR3_V(1)='0') OR
						(block_e /= BlockErased AND CR3_V(1)='1') THEN
							data_out := to_slv(Mem(read_addr),8);
							SOut_zd <= data_out(7-read_cnt);
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
						ELSE
							SOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
                        END IF;

					ELSIF Instruct=DIOR OR Instruct=DIOR4 THEN
                        -- Read Memory array
                        rd_fast <= true;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= false;
                        sect :=
						ReturnSectorID(read_addr,BottomBoot,TopBoot);
                        block_e :=
						ReturnBlockID(read_addr,BottomBoot,TopBoot);
                        IF (sect /= SectorErased AND CR3_V(1)='0') OR
						(block_e /= BlockErased AND CR3_V(1)='1') THEN
							data_out := to_slv(Mem(read_addr),8);
							SOut_zd <= data_out(7-2*read_cnt);
							SIOut_zd <= data_out(6-2*read_cnt);
							read_cnt := read_cnt + 1;
							IF read_cnt = 4 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN -- Burst read wrap disabled
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
						ELSE
							SOut_zd <= 'X';
							SIOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 4 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN -- Burst read wrap disabled
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
                        END IF;

					ELSIF (Instruct = QIOR OR Instruct = QIOR4 OR
					Instruct=DDRQIOR OR Instruct=DDRQIOR4) AND QUAD='1' THEN
                    	IF Instruct = DDRQIOR OR Instruct = DDRQIOR4  THEN
							rd_fast <= false;
							rd_slow <= false;
							dual    <= true;
							ddr     <= true;
                    	ELSE
							rd_fast <= true;
							rd_slow <= false;
							dual    <= true;
							ddr     <= false;
					    END IF;
                        sect :=
						ReturnSectorID(read_addr,BottomBoot,TopBoot);
                        block_e :=
						ReturnBlockID(read_addr,BottomBoot,TopBoot);
                        IF (sect /= SectorErased AND CR3_V(1)='0') OR
						(block_e /= BlockErased AND CR3_V(1)='1') THEN
							IF bus_cycle_state = DUMMY_BYTES THEN
								IF (Instruct = DDRQIOR OR Instruct = DDRQIOR4) THEN
									dlp_act := Return_DLP(Latency_code,dummy_cnt);
									-- Data Learning Pattern (DLP) is enabled
									-- Optional DLP
									IF VDLR_reg /= "00000000" AND dlp_act = true THEN
										RESETNegOut_zd <= VDLR_reg(7-read_cnt);
										WPNegOut_zd   <= VDLR_reg(7-read_cnt);
										SOut_zd       <= VDLR_reg(7-read_cnt);
										SIOut_zd      <= VDLR_reg(7-read_cnt);
										dlp_act := FALSE;
										read_cnt := read_cnt + 1;
										IF read_cnt = 8 THEN
											read_cnt := 0;
										END IF;
									END IF;
								END IF;
							ELSE
								data_out := to_slv(Mem(read_addr),8);
								RESETNegOut_zd <= data_out(7-4*read_cnt);
								WPNegOut_zd   <= data_out(6-4*read_cnt);
								SOut_zd       <= data_out(5-4*read_cnt);
								SIOut_zd      <= data_out(4-4*read_cnt);
								read_cnt := read_cnt + 1;
								IF read_cnt = 2 THEN
									read_cnt := 0;
									IF CR4_V(4) ='0' THEN  -- Wrap Disabled
										IF read_addr = AddrRANGE THEN
											read_addr := 0;
										ELSE
											read_addr := read_addr + 1;
										END IF;
									ELSE
										read_addr := read_addr + 1;
										IF read_addr MOD WrapLength = 0 THEN
											read_addr := read_addr - WrapLength;
										END IF;
									END IF;
								END IF;
							END IF;
						ELSE
							RESETNegOut_zd <= 'X';
							WPNegOut_zd   <= 'X';
							SOut_zd <= 'X';
							SIOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 2 THEN
								read_cnt := 0;
								IF CR4_V(4) ='0' THEN  -- Wrap Disabled
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr MOD WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
						END IF;

					ELSIF Instruct = DYBRD OR Instruct = DYBRD4 THEN
                        --Read DYB Access Register
                        IF DYB_bits(ReturnSectorID
					    (Address,BottomBoot,TopBoot)) = '1' THEN
                            DYBAR(7 downto 0) := "11111111";
                        ELSE
                            DYBAR(7 downto 0) := "00000000";
                        END IF;

                        IF QUAD_ALL = '1' THEN
							RESETNegOut_zd <= DYBAR(7-4*read_cnt);
							WPNegOut_zd   <= DYBAR(6-4*read_cnt);
							SOut_zd       <= DYBAR(5-4*read_cnt);
							SIOut_zd      <= DYBAR(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
							END IF;
						ELSE
							SOut_zd <= DYBAR(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
							END IF;
						END IF;

					ELSIF Instruct = PPBRD OR Instruct = PPBRD4 THEN
                        --Read PPB Access Register
                        IF PPB_bits(ReturnSectorID
					    (Address,BottomBoot,TopBoot)) = '1' THEN
                            PPBAR(7 downto 0) := "11111111";
                        ELSE
                            PPBAR(7 downto 0) := "00000000";
                        END IF;

						SOut_zd <= PPBAR(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                           read_cnt := 0;
						END IF;
					END IF;
				ELSIF oe_z THEN
					IF Instruct = READ OR Instruct = READ4  THEN
						rd_fast <= false;
                        rd_slow <= true;
                        dual    <= false;
                        ddr     <= false;
					ELSIF Instruct = DIOR OR Instruct = DIOR4  OR
					Instruct = QIOR OR Instruct = QIOR4 THEN
						rd_fast <= false;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= false;
					ELSIF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
						rd_fast <= false;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= true;
					ELSE
                        IF QUAD_ALL = '1' THEN
							rd_fast <= true;
							rd_slow <= false;
							dual    <= true;
							ddr     <= false;
                        ELSE
							rd_fast <= true;
							rd_slow <= false;
							dual    <= false;
							ddr     <= false;
						END IF;
					END IF;
				END IF;

                IF falling_edge(write) THEN
                    IF Instruct = EPR THEN
                        SR2_V(1) <= '0'; -- ES
                        SR1_V(0) <= '1'; -- WIP
                        ERES <= '1', '0' AFTER 1 ns;
                        RES_TO_SUSP_TIME <= '1', '0' AFTER res_time;
                    ELSIF (Instruct = PP OR Instruct = PP4) AND WEL='1'
									AND  P_ERR='0' THEN
                        pgm_page := Address/(PageSize+1);
                    	SecAddr_pgm := ReturnSectorID(Address,BottomBoot,TopBoot);
                    	block_e := ReturnBlockID(Address,BottomBoot,TopBoot);
                        IF (SecAddr_pgm /= SectorErased AND CR3_V(1)='0') OR
						(block_e /= BlockErased AND CR3_V(1)='1') THEN
                            IF Sec_Prot(SecAddr_pgm)='0' AND
							PPB_bits(SecAddr_pgm)='1' AND
                            DYB_bits(SecAddr_pgm)='1'  THEN
								PSTART <= '1', '0' AFTER 1 ns;
								PGSUSP  <= '0';
								PGRES   <= '0';
								SR1_V(0) <= '1';  -- WIP
								Addr_pgm := Address;
								Addr_pgm_tmp := Address;
								wr_cnt := Byte_number;
								FOR I IN wr_cnt DOWNTO 0 LOOP
									IF Viol /= '0' THEN
										WData(i) := -1;
									ELSE
										WData(i) := WByte(i);
									END IF;
								END LOOP;
							ELSE
							-- P_ERR bit will be set when the user attempts to
							-- to program within a protected main memory sector
								SR1_V(6) <= '1'; -- P_ERR
								SR1_V(0) <= '1'; -- WIP
							END IF;
						ELSE
							SR1_V(6) <= '1'; -- P_ERR
							SR1_V(0) <= '1'; -- WIP
						END IF;

                    ELSIF (Instruct=DYBWR OR Instruct=DYBWR4) AND
						WEL = '1' THEN
                            IF DYBAR_in = "11111111" OR
							DYBAR_in = "00000000" THEN
                            	sect := ReturnSectorID
							    (Address,BottomBoot,TopBoot);
                    			block_e := ReturnBlockID
								(Address,BottomBoot,TopBoot);
                                PSTART <= '1', '0' AFTER 1 ns;
                                SR1_V(0) <= '1'; -- WIP
							ELSE
								SR1_V(6) <= '1'; -- P_ERR
								SR1_V(0) <= '1'; -- WIP
							END IF;

                    ELSIF Instruct = WREN THEN
						SR1_V(1) <= '1'; -- WEL
                    ELSIF Instruct = CLSR THEN
						SR1_V(6) <= '0';-- P_ERR
						SR1_V(5) <= '0';-- E_ERR
						SR1_V(0) <= '0';-- WIP
                    END IF;

                    IF Instruct = RESET THEN
                        RESET_EN <= '1';
					ELSE
                        RESET_EN <= '0';
				    END IF;
				END IF;

			WHEN ERS_SUSP_PG       =>
                IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
                ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;

				IF falling_edge(PDONE) THEN
                    ADDRHILO_PG(AddrLo, AddrHi, Addr_pgm);
                    cnt := 0;

                    FOR i IN 0 TO wr_cnt LOOP
                        new_int := WData(i);
                        old_int := Mem(Addr_pgm + i - cnt);

                        IF new_int > -1 THEN
                            new_bit := to_slv(new_int,8);
                            IF old_int > -1 THEN
                                old_bit := to_slv(old_int,8);
                                FOR j IN 0 TO 7 LOOP
                                    IF old_bit(j) = '0' THEN
                                        new_bit(j) := '0';
                                    END IF;
                                END LOOP;
                                new_int := to_nat(new_bit);
                            END IF;
                            WData(i) := new_int;
                        ELSE
                            WData(i) := -1;
                        END IF;

                        Mem(Addr_pgm + i - cnt) :=  -1;
                        IF (Addr_pgm + i) = AddrHi THEN
                            Addr_pgm := AddrLo;
                            cnt := i + 1;
                        END IF;
                    END LOOP;
                    cnt :=0;
                END IF;

                IF rising_edge(PDONE) THEN
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0';  -- WEL
                    FOR i IN 0 TO wr_cnt LOOP
                        Mem(Addr_pgm_tmp + i - cnt) :=  WData(i);
                        IF (Addr_pgm_tmp + i) = AddrHi THEN
                            Addr_pgm_tmp := AddrLo;
                            cnt := i + 1;
                        END IF;
                    END LOOP;

                ELSIF falling_edge(write) THEN
					IF Instruct = EPS AND PRGSUSP_in = '0' THEN
						IF RES_TO_SUSP_TIME = '0' THEN
							PGSUSP <= '1', '0' AFTER 1 ns;
							PRGSUSP_in <= '1';
						ELSE
							ASSERT FALSE
							REPORT "Minimum for tPRS is not satisfied! " &
								"PGSP command is ignored"
							SEVERITY warning;
						END IF;
					END IF;
                END IF;

			WHEN ERS_SUSP_PG_SUSP       =>
                IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
                ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
				IF PRGSUSP_out = '1' AND PRGSUSP_in = '1' THEN
					PRGSUSP_in <= '0';
                    -- The WIP bit in the Status Register will indicate that
                    -- the device is ready for another operation.
                    SR1_V(0) <= '0';
                    -- The Program Suspend (PS) bit in the Status Register will
                    -- be set to the logical “1” state to indicate that the
                    -- program operation has been suspended.
                    SR2_V(0) <= '1';
				END IF;
                IF oe THEN
					any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
																				
					ELSIF Instruct = READ OR Instruct = READ4  THEN
                       -- Read Memory array
						rd_fast <= false;
                        rd_slow <= true;
                        dual    <= false;
                        ddr     <= false;
                        sect :=
						ReturnSectorID(read_addr,BottomBoot,TopBoot);
                        block_e :=
						ReturnBlockID(read_addr,BottomBoot,TopBoot);
                        IF ((sect /= SectorErased AND CR3_V(1)='0') OR
						(block_e /= BlockErased AND CR3_V(1)='1')) AND
                        (pgm_page /= (read_addr/(PageSize+1))) THEN
							IF Mem(read_addr) /= -1 THEN
								data_out := to_slv(Mem(read_addr),8);
								SOut_zd <= data_out(7-read_cnt);
							ELSE
								SOut_zd <= 'X';
							END IF;
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF read_addr = AddrRANGE THEN
									read_addr := 0;
								ELSE
									read_addr := read_addr + 1;
								END IF;
							END IF;
						ELSE
							SOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF read_addr = AddrRANGE THEN
									read_addr := 0;
								ELSE
									read_addr := read_addr + 1;
								END IF;
							END IF;
                        END IF;

					ELSIF Instruct=FAST_READ OR Instruct=FAST_READ4 THEN
                        sect :=
						ReturnSectorID(read_addr,BottomBoot,TopBoot);
                        block_e :=
						ReturnBlockID(read_addr,BottomBoot,TopBoot);
                        IF ((sect /= SectorErased AND CR3_V(1)='0') OR
						(block_e /= BlockErased AND CR3_V(1)='1')) AND
                        (pgm_page /= (read_addr/(PageSize+1))) THEN
							data_out := to_slv(Mem(read_addr),8);
							SOut_zd <= data_out(7-read_cnt);
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
						ELSE
							SOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 8 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
                        END IF;

					ELSIF Instruct=DIOR OR Instruct=DIOR4 THEN
                        -- Read Memory array
                        rd_fast <= true;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= false;
                        sect :=
						ReturnSectorID(read_addr,BottomBoot,TopBoot);
                        block_e :=
						ReturnBlockID(read_addr,BottomBoot,TopBoot);
                        IF ((sect /= SectorErased AND CR3_V(1)='0') OR
						(block_e /= BlockErased AND CR3_V(1)='1')) AND
                        (pgm_page /= (read_addr/(PageSize+1))) THEN
							data_out := to_slv(Mem(read_addr),8);
							SOut_zd <= data_out(7-2*read_cnt);
							SIOut_zd <= data_out(6-2*read_cnt);
							read_cnt := read_cnt + 1;
							IF read_cnt = 4 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN -- Burst read wrap disabled
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
						ELSE
							SOut_zd <= 'X';
							SIOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 4 THEN
								read_cnt := 0;
								IF CR4_V(4) = '0' THEN -- Burst read wrap disabled
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr mod WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
                        END IF;

					ELSIF (Instruct = QIOR OR Instruct = QIOR4 OR
					Instruct=DDRQIOR OR Instruct=DDRQIOR4) AND QUAD='1' THEN
                    	IF Instruct = DDRQIOR OR Instruct = DDRQIOR4  THEN
							rd_fast <= false;
							rd_slow <= false;
							dual    <= true;
							ddr     <= true;
                    	ELSE
							rd_fast <= true;
							rd_slow <= false;
							dual    <= true;
							ddr     <= false;
					    END IF;
                        sect :=
						ReturnSectorID(read_addr,BottomBoot,TopBoot);
                        block_e :=
						ReturnBlockID(read_addr,BottomBoot,TopBoot);
                        IF ((sect /= SectorErased AND CR3_V(1)='0') OR
						(block_e /= BlockErased AND CR3_V(1)='1')) AND
                        (pgm_page /= (read_addr/(PageSize+1))) THEN
							IF bus_cycle_state = DUMMY_BYTES THEN
								IF (Instruct = DDRQIOR OR Instruct = DDRQIOR4) THEN
									dlp_act := Return_DLP(Latency_code,dummy_cnt);
									-- Data Learning Pattern (DLP) is enabled
									-- Optional DLP
									IF VDLR_reg /= "00000000" AND dlp_act = true THEN
										RESETNegOut_zd <= VDLR_reg(7-read_cnt);
										WPNegOut_zd   <= VDLR_reg(7-read_cnt);
										SOut_zd       <= VDLR_reg(7-read_cnt);
										SIOut_zd      <= VDLR_reg(7-read_cnt);
										dlp_act := FALSE;
										read_cnt := read_cnt + 1;
										IF read_cnt = 8 THEN
											read_cnt := 0;
										END IF;
									END IF;
								END IF;
							ELSE
								data_out := to_slv(Mem(read_addr),8);
								RESETNegOut_zd <= data_out(7-4*read_cnt);
								WPNegOut_zd   <= data_out(6-4*read_cnt);
								SOut_zd       <= data_out(5-4*read_cnt);
								SIOut_zd      <= data_out(4-4*read_cnt);
								read_cnt := read_cnt + 1;
								IF read_cnt = 2 THEN
									read_cnt := 0;

									IF CR4_V(4) ='0' THEN  -- Wrap Disabled
										IF read_addr = AddrRANGE THEN
											read_addr := 0;
										ELSE
											read_addr := read_addr + 1;
										END IF;
									ELSE
										read_addr := read_addr + 1;
										IF read_addr MOD WrapLength = 0 THEN
											read_addr := read_addr - WrapLength;
										END IF;
									END IF;
								END IF;
							END IF;
						ELSE
							RESETNegOut_zd <= 'X';
							WPNegOut_zd   <= 'X';
							SOut_zd <= 'X';
							SIOut_zd <= 'X';
							read_cnt := read_cnt + 1;
							IF read_cnt = 2 THEN
								read_cnt := 0;
								IF CR4_V(4) ='0' THEN  -- Wrap Disabled
									IF read_addr = AddrRANGE THEN
										read_addr := 0;
									ELSE
										read_addr := read_addr + 1;
									END IF;
								ELSE
									read_addr := read_addr + 1;
									IF read_addr MOD WrapLength = 0 THEN
										read_addr := read_addr - WrapLength;
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
				ELSIF oe_z THEN
					IF Instruct = READ OR Instruct = READ4  THEN
						rd_fast <= false;
                        rd_slow <= true;
                        dual    <= false;
                        ddr     <= false;
					ELSIF Instruct = DIOR OR Instruct = DIOR4  OR
					Instruct = QIOR OR Instruct = QIOR4 THEN
						rd_fast <= false;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= false;
					ELSIF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
						rd_fast <= false;
                        rd_slow <= false;
                        dual    <= true;
                        ddr     <= true;
					ELSE
                        IF QUAD_ALL = '1' THEN
							rd_fast <= true;
							rd_slow <= false;
							dual    <= true;
							ddr     <= false;
                        ELSE
							rd_fast <= true;
							rd_slow <= false;
							dual    <= false;
							ddr     <= false;
						END IF;
					END IF;
				END IF;

				IF falling_edge(write) THEN
                    IF Instruct = EPR THEN
                        SR2_V(0) <= '0'; -- PS
                        SR1_V(0) <= '1'; -- WIP
                        PGRES  <= '1', '0' AFTER 1 ns;
                        RES_TO_SUSP_TIME <= '1', '0' AFTER res_time; -- 100us
                    ELSIF Instruct = CLSR THEN
                        SR1_V(6) <= '0';-- P_ERR
                        SR1_V(5) <= '0';-- E_ERR
                        SR1_V(0) <= '0';-- WIP
                    END IF;

                    IF Instruct = RSTEN THEN
                        RESET_EN <= '1';
					ELSE
                        RESET_EN <= '0';
					END IF;
                END IF;

			WHEN PASS_PG =>
				rd_fast <= true;
				rd_slow <= false;
				dual    <= false;
				ddr     <= false;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        SOut_zd <= SR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                                read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDAR THEN
                        READ_ALL_REG(RDAR_reg, read_addr);
                        SOut_zd <= RDAR_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                END IF;
				new_pass := Password_reg_in;
                old_pass := Password_reg;
                FOR j IN 0 TO 63 LOOP
                    IF old_pass(j) = '0' THEN
                        new_pass(j) := '0';
                    END IF;
                END LOOP;

                IF PDONE = '1' THEN
                    Password_reg := new_pass;
                    SR1_V(0)  <= '0'; -- WIP
                    SR1_V(1)  <= '0'; -- WEL
                END IF;

			WHEN PASS_UNLOCK =>
				rd_fast <= true;
				rd_slow <= false;
				dual    <= false;
				ddr     <= false;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        SOut_zd <= SR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                                read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDAR THEN
                        READ_ALL_REG(RDAR_reg, read_addr);
                        SOut_zd <= RDAR_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                END IF;

				IF PASS_TEMP = Password_reg THEN
                    PASS_UNLOCKED <= TRUE;
                ELSE
                    PASS_UNLOCKED <= FALSE;
                END IF;

                IF PASSULCK_out = '1' THEN
                    IF PASS_UNLOCKED AND PWDMLB = '0' THEN
                        PPBL(0)  := '1';
                        SR1_V(0) <= '0'; -- WIP
                    ELSE
                        SR1_V(6) <= '1'; -- P_ERR
                        SR1_V(0) <= '1'; -- WIP
                        REPORT "Incorrect Password!"
                        SEVERITY warning;
                    END IF;
                    PASSULCK_in <= '0';
                END IF;

			WHEN PPB_PG =>
				rd_fast <= true;
				rd_slow <= false;
				dual    <= false;
				ddr     <= false;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        SOut_zd <= SR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                                read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDAR THEN
                        READ_ALL_REG(RDAR_reg, read_addr);
                        SOut_zd <= RDAR_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                END IF;

                IF PDONE = '1' THEN
                    PPB_bits(sect):= '0';
                    PPB_bits_b(block_e):= '0';
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0'; -- WEL
                END IF;

			WHEN PPB_ERS =>
				rd_fast <= true;
				rd_slow <= false;
				dual    <= false;
				ddr     <= false;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        SOut_zd <= SR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                                read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDAR THEN
                        READ_ALL_REG(RDAR_reg, read_addr);
                        SOut_zd <= RDAR_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                END IF;

				IF PPBERASE_out = '1' THEN
                    PPB_bits:= (OTHERS => '1');
                    PPB_bits_b:= (OTHERS => '1');
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0'; -- WEL
                    PPBERASE_in <= '0';
                END IF;

			WHEN PLB_PG =>
				rd_fast <= true;
				rd_slow <= false;
				dual    <= false;
				ddr     <= false;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        SOut_zd <= SR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                                read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDAR THEN
                        READ_ALL_REG(RDAR_reg, read_addr);
                        SOut_zd <= RDAR_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                END IF;

				IF PDONE = '1' THEN
                    PPBL(0) := '0';
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0'; -- WEL
                END IF;

			WHEN DYB_PG  =>
 				IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
                ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
				IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;

                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;

					ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;

				IF PDONE = '1' THEN
                    DYBAR := DYBAR_in;
                    IF DYBAR = "11111111" THEN
                        DYB_bits(sect):= '1';
                        DYB_bits_b(block_e):= '1';
                    ELSIF DYBAR = "00000000" THEN
                        DYB_bits(sect):= '0';
                        DYB_bits_b(block_e):= '0';
                    END IF;
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0'; -- WEL
                END IF;

			WHEN ASP_PG   =>
				rd_fast <= true;
				rd_slow <= false;
				dual    <= false;
				ddr     <= false;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        SOut_zd <= SR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                                read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDAR THEN
                        READ_ALL_REG(RDAR_reg, read_addr);
                        SOut_zd <= RDAR_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                END IF;

 				IF PDONE = '1' THEN
                    IF SECURE_OPN='1' THEN
						IF DYBLBB = '0' AND ASP_reg_in(4) = '1' THEN
							ASSERT false
							REPORT "DYBLBB bit is allready programmed"
							SEVERITY warning;
						ELSE
							ASP_reg(4) := ASP_reg_in(4); -- DYBLBB
						END IF;

						IF PPBOTP = '0' AND ASP_reg_in(3) = '1' THEN
							ASSERT false
							REPORT "PPBOTP bit is allready programmed"
							SEVERITY warning;
						ELSE
							ASP_reg(3) := ASP_reg_in(3); -- PPBOTP
						END IF;

						IF PERMLB = '0' AND ASP_reg_in(0) = '1' THEN
							ASSERT false
							REPORT "PERMLB bit is allready programmed"
							SEVERITY warning;
						ELSE
							ASP_reg(0) := ASP_reg_in(0); -- PERMLB
						END IF;
					END IF;
                    ASP_reg(2) := ASP_reg_in(2); -- PWDMLB
                    ASP_reg(1) := ASP_reg_in(1); -- PSTMLB

                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0'; -- WEL
                END IF;

			WHEN NVDLR_PG   =>
				rd_fast <= true;
				rd_slow <= false;
				dual    <= false;
				ddr     <= false;
                IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        SOut_zd <= SR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                                read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= SR2_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= CR1_V(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
					ELSIF Instruct = RDAR THEN
                        READ_ALL_REG(RDAR_reg, read_addr);
                        SOut_zd <= RDAR_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                END IF;
				IF PDONE = '1' THEN
                    SR1_V(0) <= '0'; -- WIP
                    SR1_V(1) <= '0'; -- WEL
                    IF NVDLR_reg = "00000000" THEN
                        NVDLR_reg := NVDLR_reg_in;
                        VDLR_reg := NVDLR_reg_in;
                    ELSE
                        REPORT "NVDLR is allready programmed"
                        SEVERITY warning;
                    END IF;
                END IF;

			WHEN RESET_STATE   =>
            -- During Reset,the non-volatile version of the registers is
            -- copied to volatile version to provide the default state of
            -- the volatile register
                SR1_V(7 DOWNTO 5) <= SR1_NV(7 DOWNTO 5);
                SR1_V(1 DOWNTO 0) <= SR1_NV(1 DOWNTO 0);
				IF Instruct = RESET OR Instruct = RSTCMD THEN
                -- The volatile FREEZE bit (CR1_V[0]) and the volatile PPB Lock
                -- bit are not changed by the SW RESET
                    CR1_V(7 DOWNTO 1) <= CR1_NV(7 DOWNTO 1);
                ELSE
                    CR1_V <= CR1_NV;
                    IF PWDMLB = '0' THEN
                        PPBL(0) := '0';
                    ELSE
                        PPBL(0) := '1';
					END IF;
				END IF;

                CR2_V <= CR2_NV;
                CR3_V <= CR3_NV;
                CR4_V <= CR4_NV;

				VDLR_reg := NVDLR_reg;
                dlp_act := false;
                --Loads the Program Buffer with all ones
                WData := (OTHERS => MaxData);

                IF FREEZE = '0' THEN
                -- When BPNV is set to '1'. the BP2-0 bits in Status
                -- Register are volatile and will be reseted after
                -- reset command
                	SR1_V(4 downto 2) <= SR1_NV(4 downto 2);
                	BP_bits := SR1_V(4) & SR1_V(3) & SR1_V(2);
                	change_BP <= '1', '0' AFTER 1 ns;
				END IF;

				RESET_EN <= '0';

			WHEN PGERS_ERROR =>
				IF QUAD_ALL = '1' THEN
					rd_fast <= true;
					rd_slow <= false;
					dual    <= true;
					ddr     <= false;
                ELSE
					rd_fast <= true;
					rd_slow <= false;
					dual    <= false;
					ddr     <= false;
				END IF;
				IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
					ELSIF Instruct = RDAR THEN
                       READ_ALL_REG(RDAR_reg, read_addr);

                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := RDAR_reg;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= RDAR_reg(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;

                IF falling_edge(write) THEN
                    IF Instruct = WRDI AND P_ERR='0' AND E_ERR='0' THEN
                    -- A Clear Status Register (CLSR) followed by a Write
                    -- Disable (WRDI) command must be sent to return the
                    -- device to standby state
                        SR1_V(1) <= '0'; --WEL
                    ELSIF Instruct = CLSR THEN
                        SR1_V(6) <= '0'; -- P_ERR
                        SR1_V(5) <= '0'; -- E_ERR
                        SR1_V(0) <= '0'; -- WIP
                    END IF;

                    IF Instruct = RSTEN THEN
                        RESET_EN <= '1';
                    ELSE
                        RESET_EN <= '0';
                    END IF;
                END IF;

 			WHEN BLANK_CHECK   =>
                IF rising_edge(BCDONE) THEN
                    IF NOT_BLANK = '1' THEN
                        -- Start Sector Erase
                        ESTART <= '1', '0' AFTER 1 ns;
                        ESUSP     <= '0';
                        ERES      <= '0';
                        INITIAL_CONFIG <= '1';
                        SR1_V(0) <= '1'; -- WIP
                        Addr := Address;
                    ELSE
                        SR1_V(1) <= '1'; -- WEL
					END IF;
                ELSE
					IF CR3_V(1) = '0' THEN
						ADDRHILO_SEC(AddrLo, AddrHi, Addr);
						FOR i IN AddrLo TO AddrHi LOOP
							IF Mem(i) /= MaxData THEN
								NOT_BLANK <= '1';
							END IF;
						END LOOP;
						bc_done <= '1';
					ELSIF CR3_V(1) = '1' THEN
						ADDRHILO_BLK(AddrLo, AddrHi, Addr);
						FOR i IN AddrLo TO AddrHi LOOP
							IF Mem(i) /= MaxData THEN
								NOT_BLANK <= '1';
							END IF;
						END LOOP;
						bc_done <= '1';
					END IF;
                END IF;

			WHEN EVAL_ERS_STAT =>
				IF oe THEN
                    any_read <= true;
					IF Instruct = RDSR1 THEN
                        --Read Status Register 1
                        IF QUAD_ALL = '1' THEN
                            data_out(7 DOWNTO 0) := SR1_V;
                            RESETNegOut_zd <= data_out(7-4*read_cnt);
                            WPNegOut_zd   <= data_out(6-4*read_cnt);
                            SOut_zd       <= data_out(5-4*read_cnt);
                            SIOut_zd      <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                            END IF;
						ELSE
                            SOut_zd <= SR1_V(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;
                IF rising_edge(EESDONE) THEN
                    SR1_V(0) <= '0';
                    SR1_V(1) <= '0';

					IF CR3_V(1) = '0' THEN
						IF ERS_nosucc(sect) = '1' THEN
							SR2_V(2) <= '0';
						ELSE
							SR2_V(2) <= '1';
						END IF;
					ELSIF CR3_V(1) = '1' THEN
						IF ERS_nosucc_b(block_e) = '1' THEN
							SR2_V(2) <= '0';
						ELSE
							SR2_V(2) <= '1';
						END IF;
					END IF;

                END IF;
        END CASE;

        --Output Disable Control
        IF (CSNeg_ipd = '1') THEN
            SIOut_zd        <= 'Z';
            RESETNegOut_zd   <= 'Z';
            WPNegOut_zd     <= 'Z';
            SOut_zd         <= 'Z';
        END IF;

		IF QUAD_ALL = '1' THEN
			dual <= true;
		END IF;

		IF rising_edge(reseted)  AND EDONE = '0' THEN
            ERS_nosucc(SectorErased) <= '1';
            ERS_nosucc_b(BlockErased) <= '1';
		END IF;

    END PROCESS Functional;

    ---------------------------------------------------------------------------
    -- SFDP_CFI Process  ---------------------------------------------------------------------------
    SFDPPreload:    PROCESS

    BEGIN
        ------------------------------------------------------------------------
        --SFDP Header
        ------------------------------------------------------------------------
        -- Manufacturer and Device ID
        SFDP_array(16#0000#) := 16#53#;
        SFDP_array(16#0001#) := 16#46#;
        SFDP_array(16#0002#) := 16#44#;
        SFDP_array(16#0003#) := 16#50#;
        SFDP_array(16#0004#) := 16#00#;
        SFDP_array(16#0005#) := 16#01#;
        SFDP_array(16#0006#) := 16#01#;
        SFDP_array(16#0007#) := 16#FF#;
        SFDP_array(16#0008#) := 16#00#;
        SFDP_array(16#0009#) := 16#00#;
        SFDP_array(16#000A#) := 16#01#;
        SFDP_array(16#000B#) := 16#09#;
        SFDP_array(16#000C#) := 16#48#;
        SFDP_array(16#000D#) := 16#04#;
        SFDP_array(16#000E#) := 16#00#;
        SFDP_array(16#000F#) := 16#FF#;
        SFDP_array(16#0010#) := 16#01#;
        SFDP_array(16#0011#) := 16#00#;
        SFDP_array(16#0012#) := 16#01#;
        SFDP_array(16#0013#) := 16#51#;
        SFDP_array(16#0014#) := 16#00#;
        SFDP_array(16#0015#) := 16#04#;
        SFDP_array(16#0016#) := 16#00#;
        -- Unused
		FOR I IN 16#0017# TO 16#0FFF# LOOP
             SFDP_array(I) := MaxData;
        END LOOP;
        -- ID-CFI array data
		SFDP_array(16#1000#) := 16#01#;
        SFDP_array(16#1001#) := 16#02#;
        SFDP_array(16#1002#) := 16#19#;
        SFDP_array(16#1003#) := 16#4D#;
        SFDP_array(16#1004#) := 16#00#;
        SFDP_array(16#1005#) := 16#81#;
        IF TimingModel(15) = '0' THEN
        	SFDP_array(16#1006#) := 16#30#;
        ELSIF TimingModel(15) = '2' THEN
        	SFDP_array(16#1006#) := 16#32#;
        ELSIF TimingModel(15) = '3' THEN
        	SFDP_array(16#1006#) := 16#33#;
        ELSIF TimingModel(15) = 'Y' THEN
        	SFDP_array(16#1006#) := 16#59#;
        ELSIF TimingModel(15) = 'Z' THEN
        	SFDP_array(16#1006#) := 16#5A#;
		END IF;
        SFDP_array(16#1007#) := 16#31#;
        SFDP_array(16#1008#) := 16#84#;
        SFDP_array(16#1009#) := 16#00#;
        SFDP_array(16#100A#) := 16#00#;
        SFDP_array(16#100B#) := 16#00#;
        SFDP_array(16#100C#) := 16#00#;
        SFDP_array(16#100D#) := 16#00#;
        SFDP_array(16#100E#) := 16#00#;
        SFDP_array(16#100F#) := 16#00#;
        -- CFI Query Identification String
        SFDP_array(16#1010#) := 16#51#;
        SFDP_array(16#1011#) := 16#52#;
        SFDP_array(16#1012#) := 16#59#;
        SFDP_array(16#1013#) := 16#02#;
        SFDP_array(16#1014#) := 16#00#;
        SFDP_array(16#1015#) := 16#40#;
        SFDP_array(16#1016#) := 16#00#;
        SFDP_array(16#1017#) := 16#53#;
        SFDP_array(16#1018#) := 16#46#;
        SFDP_array(16#1019#) := 16#51#;
        SFDP_array(16#101A#) := 16#00#;
        -- CFI system interface string
        SFDP_array(16#101B#) := 16#17#;
        SFDP_array(16#101C#) := 16#19#;
        SFDP_array(16#101D#) := 16#00#;
        SFDP_array(16#101E#) := 16#00#;
        SFDP_array(16#101F#) := 16#09#;
        SFDP_array(16#1020#) := 16#09#;
        -- 256kB sector
        SFDP_array(16#1021#) := 16#0A#;
        SFDP_array(16#1022#) := 16#01#;
        SFDP_array(16#1023#) := 16#02#;
        SFDP_array(16#1024#) := 16#02#;
        SFDP_array(16#1025#) := 16#03#;
        SFDP_array(16#1026#) := 16#03#;
        --  Device Geometry Definition(Uniform Sector Devices)
        SFDP_array(16#1027#) := 16#19#;
        SFDP_array(16#1028#) := 16#02#;
        SFDP_array(16#1029#) := 16#01#;
        SFDP_array(16#102A#) := 16#08#;
        SFDP_array(16#102B#) := 16#00#;
        SFDP_array(16#102C#) := 16#03#;
        SFDP_array(16#102D#) := 16#07#;
        SFDP_array(16#102E#) := 16#00#;
        SFDP_array(16#102F#) := 16#10#;
        SFDP_array(16#1030#) := 16#00#;
        SFDP_array(16#1031#) := 16#00#;
        SFDP_array(16#1032#) := 16#00#;
        SFDP_array(16#1033#) := 16#80#;
        SFDP_array(16#1034#) := 16#00#;
        SFDP_array(16#1035#) := 16#FE#;
        SFDP_array(16#1036#) := 16#01#;
        SFDP_array(16#1037#) := 16#00#;
        SFDP_array(16#1038#) := 16#01#;
        SFDP_array(16#1039#) := 16#FF#;
        SFDP_array(16#103A#) := 16#FF#;
        SFDP_array(16#103B#) := 16#FF#;
        SFDP_array(16#103C#) := 16#FF#;
        SFDP_array(16#103D#) := 16#FF#;
        SFDP_array(16#103E#) := 16#FF#;
        SFDP_array(16#103F#) := 16#FF#;
        --  CFI Primary Vendor-Specific Extended Query
        SFDP_array(16#1040#) := 16#50#;
        SFDP_array(16#1041#) := 16#52#;
        SFDP_array(16#1042#) := 16#49#;
        SFDP_array(16#1043#) := 16#31#;
        SFDP_array(16#1044#) := 16#33#;
        SFDP_array(16#1045#) := 16#21#;
        SFDP_array(16#1046#) := 16#02#;
        SFDP_array(16#1047#) := 16#01#;
        SFDP_array(16#1048#) := 16#00#;
        SFDP_array(16#1049#) := 16#08#;
        SFDP_array(16#104A#) := 16#00#;
        SFDP_array(16#104B#) := 16#01#;
        SFDP_array(16#104C#) := 16#03#;
        SFDP_array(16#104D#) := 16#00#;
        SFDP_array(16#104E#) := 16#00#;
        SFDP_array(16#104F#) := 16#07#;
        SFDP_array(16#1050#) := 16#01#;
		-- CFI Alternate Vendor Specific Extended Query Parameters
        -- CFI Alternate Vendor Specific Extended Query Header
        SFDP_array(16#1051#) := 16#41#;
        SFDP_array(16#1052#) := 16#4C#;
        SFDP_array(16#1053#) := 16#54#;
        SFDP_array(16#1054#) := 16#32#;
        SFDP_array(16#1055#) := 16#30#;
        -- CFI Alternate Vendor Specific Extended Query Parameter 0
        SFDP_array(16#1056#) := 16#00#;
        SFDP_array(16#1057#) := 16#10#;
        SFDP_array(16#1058#) := 16#53#;
        SFDP_array(16#1059#) := 16#32#;
        SFDP_array(16#105A#) := 16#35#;
        SFDP_array(16#105B#) := 16#46#;
        SFDP_array(16#105C#) := 16#53#;
        SFDP_array(16#105D#) := 16#32#;
        SFDP_array(16#105E#) := 16#35#;
        SFDP_array(16#105F#) := 16#36#;
        SFDP_array(16#1060#) := 16#53#;
        SFDP_array(16#1061#) := 16#FF#;
        SFDP_array(16#1062#) := 16#FF#;
        SFDP_array(16#1063#) := 16#FF#;
        SFDP_array(16#1064#) := 16#FF#;
        SFDP_array(16#1065#) := 16#FF#;
        IF TimingModel(15) = '0' THEN
        	SFDP_array(16#1066#) := 16#30#;
        ELSIF TimingModel(15) = '2' THEN
        	SFDP_array(16#1066#) := 16#32#;
        ELSIF TimingModel(15) = '3' THEN
        	SFDP_array(16#1066#) := 16#33#;
        ELSIF TimingModel(15) = 'Y' THEN
        	SFDP_array(16#1066#) := 16#59#;
        ELSIF TimingModel(15) = 'Z' THEN
        	SFDP_array(16#1066#) := 16#5A#;
		END IF;
        SFDP_array(16#1067#) := 16#31#;
        --  CFI Alternate Vendor-Specific Extended Query Parameter 80h
        SFDP_array(16#1068#) := 16#80#;
        SFDP_array(16#1069#) := 16#01#;
        SFDP_array(16#106A#) := 16#EB#;
		--  CFI Alternate Vendor-Specific Extended Query Parameter 84h
        SFDP_array(16#106B#) := 16#84#;
        SFDP_array(16#106C#) := 16#08#;
        SFDP_array(16#106D#) := 16#75#;
        SFDP_array(16#106E#) := 16#28#;
        SFDP_array(16#106F#) := 16#7A#;
        SFDP_array(16#1070#) := 16#64#;
        SFDP_array(16#1071#) := 16#75#;
        SFDP_array(16#1072#) := 16#28#;
        SFDP_array(16#1073#) := 16#7A#;
        SFDP_array(16#1074#) := 16#64#;
        SFDP_array(16#1075#) := 16#88#;
        SFDP_array(16#1076#) := 16#04#;
        SFDP_array(16#1077#) := 16#0A#;
        SFDP_array(16#1078#) := 16#01#;
        IF TimingModel(15)='0' OR TimingModel(15)='2' OR
		TimingModel(15)='3' THEN
        	SFDP_array(16#1079#) := 16#00#;
        	SFDP_array(16#107A#) := 16#01#;
        ELSIF TimingModel(15)='Y' OR TimingModel(15)='Z' THEN
        	SFDP_array(16#1079#) := 16#02#;
        	SFDP_array(16#107A#) := 16#02#;
		END IF;
		--  CFI Alternate Vendor-Specific Extended Query Parameter 8Ch
        SFDP_array(16#107B#) := 16#8C#;
        SFDP_array(16#107C#) := 16#06#;
        SFDP_array(16#107D#) := 16#96#;
        SFDP_array(16#107E#) := 16#01#;
        SFDP_array(16#107F#) := 16#23#;
        SFDP_array(16#1080#) := 16#00#;
        SFDP_array(16#1081#) := 16#23#;
        SFDP_array(16#1082#) := 16#00#;
		--  CFI Alternate Vendor-Specific Extended Query Parameter 94h
        SFDP_array(16#1083#) := 16#94#;
        SFDP_array(16#1084#) := 16#01#;
        SFDP_array(16#1085#) := 16#10#;
		--  CFI Alternate Vendor-Specific Extended Query Parameter F0h
        SFDP_array(16#1086#) := 16#F0#;
        SFDP_array(16#1087#) := 16#06#;
        SFDP_array(16#1088#) := 16#FF#;
        SFDP_array(16#1089#) := 16#FF#;
        SFDP_array(16#108A#) := 16#FF#;
        SFDP_array(16#108B#) := 16#FF#;
        SFDP_array(16#108C#) := 16#FF#;
        SFDP_array(16#108D#) := 16#FF#;
		--  CFI Alternate Vendor-Specific Extended Query Parameter A5h
        SFDP_array(16#108E#) := 16#A5#;
        SFDP_array(16#108F#) := 16#3C#;
        SFDP_array(16#1090#) := 16#FF#;
        SFDP_array(16#1091#) := 16#FF#;
        SFDP_array(16#1092#) := 16#BA#;
        SFDP_array(16#1093#) := 16#FF#;
        SFDP_array(16#1094#) := 16#FF#;
        SFDP_array(16#1095#) := 16#FF#;
        SFDP_array(16#1096#) := 16#FF#;
        SFDP_array(16#1097#) := 16#0F#;
        SFDP_array(16#1098#) := 16#48#;
		SFDP_array(16#1099#) := 16#EB#;
        SFDP_array(16#109A#) := 16#FF#;
        SFDP_array(16#109B#) := 16#FF#;
        SFDP_array(16#109C#) := 16#FF#;
        SFDP_array(16#109D#) := 16#FF#;
		SFDP_array(16#109E#) := 16#88#;
        SFDP_array(16#109F#) := 16#BB#;
        SFDP_array(16#10A0#) := 16#F6#;
        SFDP_array(16#10A1#) := 16#FF#;
        SFDP_array(16#10A2#) := 16#FF#;
        SFDP_array(16#10A3#) := 16#FF#;
        SFDP_array(16#10A4#) := 16#FF#;
        SFDP_array(16#10A5#) := 16#FF#;
        SFDP_array(16#10A6#) := 16#FF#;
        SFDP_array(16#10A7#) := 16#FF#;
        SFDP_array(16#10A8#) := 16#FF#;
		SFDP_array(16#10A9#) := 16#FF#;
        SFDP_array(16#10AA#) := 16#48#;
        SFDP_array(16#10AB#) := 16#EB#;
        SFDP_array(16#10AC#) := 16#0C#;
        SFDP_array(16#10AD#) := 16#20#;
		SFDP_array(16#10AE#) := 16#10#;
        SFDP_array(16#10AF#) := 16#D8#;
        SFDP_array(16#10B0#) := 16#00#;
        SFDP_array(16#10B1#) := 16#FF#;
        SFDP_array(16#10B2#) := 16#00#;
        SFDP_array(16#10B3#) := 16#FF#;
        SFDP_array(16#10B4#) := 16#FF#;
        SFDP_array(16#10B5#) := 16#FF#;
		SFDP_array(16#10B6#) := 16#FF#;
        SFDP_array(16#10B7#) := 16#FF#;
        SFDP_array(16#10B8#) := 16#FF#;
		SFDP_array(16#10B9#) := 16#FF#;
        SFDP_array(16#10BA#) := 16#FF#;
        SFDP_array(16#10BB#) := 16#FF#;
        SFDP_array(16#10BC#) := 16#FF#;
        SFDP_array(16#10BD#) := 16#FF#;
		SFDP_array(16#10BE#) := 16#FF#;
        SFDP_array(16#10BF#) := 16#FF#;

        FOR I IN 16#10C0# TO 16#111F# LOOP
             SFDP_array(I) := MaxData;
        END LOOP;

        --  CFI Alternate Vendor-Specific Extended Query Parameter A5h
        -- SFDP JEDEC parameter
        SFDP_array(16#1120#) := 16#A5#;
        SFDP_array(16#1121#) := 16#3C#;
        SFDP_array(16#1122#) := 16#FF#;
        SFDP_array(16#1123#) := 16#FF#;
        SFDP_array(16#1124#) := 16#BA#;
        SFDP_array(16#1125#) := 16#FF#;
        SFDP_array(16#1126#) := 16#FF#;
        SFDP_array(16#1127#) := 16#FF#;
        SFDP_array(16#1128#) := 16#FF#;
        SFDP_array(16#1129#) := 16#0F#;
        SFDP_array(16#112A#) := 16#48#;
        SFDP_array(16#112B#) := 16#EB#;
        SFDP_array(16#112C#) := 16#FF#;
        SFDP_array(16#112D#) := 16#FF#;
        SFDP_array(16#112E#) := 16#FF#;
        SFDP_array(16#112F#) := 16#FF#;
        SFDP_array(16#1130#) := 16#88#;
        SFDP_array(16#1131#) := 16#BB#;
        SFDP_array(16#1132#) := 16#F6#;
        SFDP_array(16#1133#) := 16#FF#;
        SFDP_array(16#1134#) := 16#FF#;
        SFDP_array(16#1135#) := 16#FF#;
        SFDP_array(16#1136#) := 16#FF#;
        SFDP_array(16#1137#) := 16#FF#;
        SFDP_array(16#1138#) := 16#FF#;
        SFDP_array(16#1139#) := 16#FF#;
        SFDP_array(16#113A#) := 16#FF#;
        SFDP_array(16#113B#) := 16#FF#;
        SFDP_array(16#113C#) := 16#48#;
        SFDP_array(16#113D#) := 16#EB#;
        SFDP_array(16#113E#) := 16#0C#;
        SFDP_array(16#113F#) := 16#20#;
        SFDP_array(16#1140#) := 16#10#;
        SFDP_array(16#1141#) := 16#D8#;
        SFDP_array(16#1142#) := 16#00#;
        SFDP_array(16#1143#) := 16#FF#;
        SFDP_array(16#1144#) := 16#00#;
        SFDP_array(16#1145#) := 16#FF#;
        SFDP_array(16#1146#) := 16#FF#;
        SFDP_array(16#1147#) := 16#FF#;
        SFDP_array(16#1148#) := 16#FF#;
        SFDP_array(16#1149#) := 16#FF#;
        SFDP_array(16#114A#) := 16#FF#;
        SFDP_array(16#114B#) := 16#FF#;
        SFDP_array(16#114C#) := 16#FF#;
        SFDP_array(16#114D#) := 16#FF#;
        SFDP_array(16#114E#) := 16#FF#;
        SFDP_array(16#114F#) := 16#FF#;
        SFDP_array(16#1150#) := 16#FF#;
        SFDP_array(16#1151#) := 16#FF#;

		FOR I IN SFDPLength DOWNTO 0 LOOP
            SFDP_tmp := to_slv(SFDP_array(SFDPLength-I),8);
			FOR J IN 7 DOWNTO 0 LOOP
                SFDP_array_tmp(8*I +J) := SFDP_tmp(J);
        	END LOOP;
        END LOOP;

		FOR I IN CFILength DOWNTO 0 LOOP
			CFI_tmp1 := SFDP_array(16#1000#+CFILength-I);
            CFI_tmp := to_slv(CFI_tmp1,8);
			FOR J IN 7 DOWNTO 0 LOOP
                CFI_array_tmp(8*I +J) := CFI_tmp(J);
        	END LOOP;
        END LOOP;

        WAIT;

    END PROCESS SFDPPreload;

    Protect : PROCESS(change_BP)
    BEGIN
        IF rising_edge(change_BP) THEN
            Sec_Prot := (OTHERS => '0');
            Block_Prot := (OTHERS => '0');
            CASE SR1_V(4 DOWNTO 2) IS
                WHEN "000" =>

                WHEN "001" =>
					IF CR3_V(3) = '1' THEN -- Uniform Sector Architecture
                    	IF TBPROT_O = '0' THEN
                        	Sec_Prot(SecNumUni downto (SecNumUni+1)*63/64)
                                                   := (OTHERS => '1');
                        	Block_Prot(BlockNumUni downto (BlockNumUni+1)*63/64)
                                                   := (OTHERS => '1');
                    	ELSE
                        	Sec_Prot((SecNumUni+1)/64-1 downto 0)
                                                    := (OTHERS => '1');
                        	Block_Prot((BlockNumUni+1)/64-1 downto 0)
                                                    := (OTHERS => '1');
						END IF;
					ELSE -- / Hybrid Sector Architecture
                    	IF TBPARM_O = '1' THEN --4 KB Physical Sectors at Top
                    		IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)*63/64)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)*63/64)
                                                    := (OTHERS => '1');
							ELSE
                        		Sec_Prot((SecNumHyb-7)/64-1 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/64-1 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						ELSE --4 KB Physical Sectors at Bottom
							IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)*63/64+8)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)*63/64+8)
                                                    := (OTHERS => '1');
							ELSE  -- BP starts at Bottom
                        		Sec_Prot((SecNumHyb-7)/64+7 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/64+7 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						END IF;
					END IF;


				WHEN "010" =>
					IF CR3_V(3) = '1' THEN -- Uniform Sector Architecture
                    	IF TBPROT_O = '0' THEN
                        	Sec_Prot(SecNumUni downto (SecNumUni+1)*31/32)
                                                   := (OTHERS => '1');
                        	Block_Prot(BlockNumUni downto (BlockNumUni+1)*31/32)
                                                   := (OTHERS => '1');
                    	ELSE
                        	Sec_Prot((SecNumUni+1)/32-1 downto 0)
                                                    := (OTHERS => '1');
                        	Block_Prot((BlockNumUni+1)/32-1 downto 0)
                                                    := (OTHERS => '1');
						END IF;
					ELSE -- / Hybrid Sector Architecture
                    	IF TBPARM_O = '1' THEN --4 KB Physical Sectors at Top
                    		IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)*31/32)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)*31/32)
                                                    := (OTHERS => '1');
							ELSE
                        		Sec_Prot((SecNumHyb-7)/32-1 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/32-1 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						ELSE --4 KB Physical Sectors at Bottom
							IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)*31/32+8)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)*31/32+8)
                                                    := (OTHERS => '1');
							ELSE  -- BP starts at Bottom
                        		Sec_Prot((SecNumHyb-7)/32+7 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/32+7 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						END IF;
					END IF;

				WHEN "011" =>
					IF CR3_V(3) = '1' THEN -- Uniform Sector Architecture
                    	IF TBPROT_O = '0' THEN
                        	Sec_Prot(SecNumUni downto (SecNumUni+1)*15/16)
                                                   := (OTHERS => '1');
                        	Block_Prot(BlockNumUni downto (BlockNumUni+1)*15/16)
                                                   := (OTHERS => '1');
                    	ELSE
                        	Sec_Prot((SecNumUni+1)/16-1 downto 0)
                                                    := (OTHERS => '1');
                        	Block_Prot((BlockNumUni+1)/16-1 downto 0)
                                                    := (OTHERS => '1');
						END IF;
					ELSE -- / Hybrid Sector Architecture
                    	IF TBPARM_O = '1' THEN --4 KB Physical Sectors at Top
                    		IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)*15/16)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)*15/16)
                                                    := (OTHERS => '1');
							ELSE
                        		Sec_Prot((SecNumHyb-7)/16-1 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/16-1 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						ELSE --4 KB Physical Sectors at Bottom
							IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)*15/16+8)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)*15/16+8)
                                                    := (OTHERS => '1');
							ELSE  -- BP starts at Bottom
                        		Sec_Prot((SecNumHyb-7)/16+7 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/16+7 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						END IF;
					END IF;

				WHEN "100" =>
					IF CR3_V(3) = '1' THEN -- Uniform Sector Architecture
                    	IF TBPROT_O = '0' THEN
                        	Sec_Prot(SecNumUni downto (SecNumUni+1)*7/8)
                                                   := (OTHERS => '1');
                        	Block_Prot(BlockNumUni downto (BlockNumUni+1)*7/8)
                                                   := (OTHERS => '1');
                    	ELSE
                        	Sec_Prot((SecNumUni+1)/8-1 downto 0)
                                                    := (OTHERS => '1');
                        	Block_Prot((BlockNumUni+1)/8-1 downto 0)
                                                    := (OTHERS => '1');
						END IF;
					ELSE -- / Hybrid Sector Architecture
                    	IF TBPARM_O = '1' THEN --4 KB Physical Sectors at Top
                    		IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)*7/8)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)*7/8)
                                                    := (OTHERS => '1');
							ELSE
                        		Sec_Prot((SecNumHyb-7)/8-1 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/8-1 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						ELSE --4 KB Physical Sectors at Bottom
							IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)*7/8+8)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)*7/8+8)
                                                    := (OTHERS => '1');
							ELSE  -- BP starts at Bottom
                        		Sec_Prot((SecNumHyb-7)/8+7 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/8+7 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						END IF;
					END IF;

				WHEN "101" =>
					IF CR3_V(3) = '1' THEN -- Uniform Sector Architecture
                    	IF TBPROT_O = '0' THEN
                        	Sec_Prot(SecNumUni downto (SecNumUni+1)*3/4)
                                                   := (OTHERS => '1');
                        	Block_Prot(BlockNumUni downto (BlockNumUni+1)*3/4)
                                                   := (OTHERS => '1');
                    	ELSE
                        	Sec_Prot((SecNumUni+1)/4-1 downto 0)
                                                    := (OTHERS => '1');
                        	Block_Prot((BlockNumUni+1)/4-1 downto 0)
                                                    := (OTHERS => '1');
						END IF;
					ELSE -- / Hybrid Sector Architecture
                    	IF TBPARM_O = '1' THEN --4 KB Physical Sectors at Top
                    		IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)*3/4)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)*3/4)
                                                    := (OTHERS => '1');
							ELSE
                        		Sec_Prot((SecNumHyb-7)/4-1 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/4-1 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						ELSE --4 KB Physical Sectors at Bottom
							IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)*3/4+8)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)*3/4+8)
                                                    := (OTHERS => '1');
							ELSE  -- BP starts at Bottom
                        		Sec_Prot((SecNumHyb-7)/4+7 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/4+7 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						END IF;
					END IF;

				WHEN "110" =>
					IF CR3_V(3) = '1' THEN -- Uniform Sector Architecture
                    	IF TBPROT_O = '0' THEN
                        	Sec_Prot(SecNumUni downto (SecNumUni+1)/2)
                                                   := (OTHERS => '1');
                        	Block_Prot(BlockNumUni downto (BlockNumUni+1)/2)
                                                   := (OTHERS => '1');
                    	ELSE
                        	Sec_Prot((SecNumUni+1)/2-1 downto 0)
                                                    := (OTHERS => '1');
                        	Block_Prot((BlockNumUni+1)/2-1 downto 0)
                                                    := (OTHERS => '1');
						END IF;
					ELSE -- / Hybrid Sector Architecture
                    	IF TBPARM_O = '1' THEN --4 KB Physical Sectors at Top
                    		IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)/2)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)/2)
                                                    := (OTHERS => '1');
							ELSE
                        		Sec_Prot((SecNumHyb-7)/2-1 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/2-1 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						ELSE --4 KB Physical Sectors at Bottom
							IF TBPROT_O = '0' THEN -- BP starts at Top
                        		Sec_Prot(SecNumHyb downto (SecNumHyb-7)/2+8)
                                                    := (OTHERS => '1');
                        		Block_Prot(BlockNumHyb downto (BlockNumHyb-7)/2+8)
                                                    := (OTHERS => '1');
							ELSE  -- BP starts at Bottom
                        		Sec_Prot((SecNumHyb-7)/2+7 downto 0)
                                                    := (OTHERS => '1');
                        		Block_Prot((BlockNumHyb-7)/2+7 downto 0)
                                                    := (OTHERS => '1');
							END IF;
						END IF;
					END IF;

                WHEN OTHERS =>
                    Sec_Prot := (OTHERS => '1');
                    Block_Prot := (OTHERS => '1');
            END CASE;
        END IF;
    END PROCESS Protect;

    WP_PULL_UP : PROCESS(WPNegIn)
    BEGIN
        IF (QUAD = '0') THEN
            IF (WPNegIn = 'Z') THEN
                WPNeg_pullup <= '1';
            ELSE
                WPNeg_pullup <= WPNegIn;
            END IF;
        END IF;
    END PROCESS WP_PULL_UP;

    RST_PULL_UP : PROCESS(RESETNeg)
    BEGIN
        IF (RESETNeg = 'Z') THEN
            RESETNeg_pullup <= '1';
        ELSE
            RESETNeg_pullup <= RESETNeg;
        END IF;
    END PROCESS RST_PULL_UP;

    ---------------------------------------------------------------------------
    ---- File Read Section - Preload Control
    ---------------------------------------------------------------------------
    MemPreload : PROCESS

        -- text file input variables
        FILE mem_file         : text  is  mem_file_name;
        FILE otp_file         : text  is  otp_file_name;
        VARIABLE ind          : NATURAL RANGE 0 TO AddrRANGE := 0;
        VARIABLE S_ind        : NATURAL RANGE 0 TO SecNumHyb:= 0;
        VARIABLE index        : NATURAL RANGE 0 TO SecSize256:=0;
        VARIABLE otp_ind      : NATURAL RANGE 16#000# TO 16#3FF# := 16#000#;
        VARIABLE buf          : line;
        VARIABLE reported     : NATURAL;

    BEGIN
    ---------------------------------------------------------------------------
    --s25fs256s memory preload file format
-----------------------------------
    ---------------------------------------------------------------------------
    --   /       - comment
    --   @aaaaaa - <aaaaaa> stands for address
    --   dd      - <dd> is byte to be written at Mem(aaaaaa++)
    --             (aaaaaa is incremented at every load)
    --   only first 1-7 columns are loaded. NO empty lines !!!!!!!!!!!!!!!!
    ---------------------------------------------------------------------------
         -- memory preload
        IF (mem_file_name /= "none" AND UserPreload ) THEN
            ind := 0;
            reported := 0;
            Mem := (OTHERS => MaxData);
            WHILE (not ENDFILE (mem_file)) LOOP
                READLINE (mem_file, buf);
                IF buf(1) = '/' THEN --comment
                    NEXT;
                ELSIF buf(1) = '@' THEN --address
                    ind := h(buf(2 to 8));
                ELSE
                    IF ind <= AddrRANGE THEN
                    	Mem(ind) := h(buf(1 to 2));
                    	IF ind < AddrRANGE THEN
                    		ind := ind + 1;
						END IF;
                    ELSIF reported = 0 THEN
                        REPORT " Memory address out of range"
                        SEVERITY warning;
                        reported := 1;
                    END IF;
                END IF;
            END LOOP;
        END IF;

    ---------------------------------------------------------------------------
    --s25fs256s_otp memory preload file format
    ---------------------------------------------------------------------------
    --   /       - comment
    --   @aaa - <aaa> stands for address
    --   dd      - <dd> is byte to be written at OTPMem(aaa++)
    --             (aaa is incremented at every load)
    --   only first 1-4 columns are loaded. NO empty lines !!!!!!!!!!!!!!!!
    ---------------------------------------------------------------------------

         -- memory preload
        IF (otp_file_name /= "none" AND UserPreload) THEN
            otp_ind := 16#000#;
            OTPMem := (OTHERS => MaxData);
            WHILE (not ENDFILE (otp_file)) LOOP
                READLINE (otp_file, buf);
                IF buf(1) = '/' THEN
                    NEXT;
                ELSIF buf(1) = '@' THEN
                    IF otp_ind > 16#3FF# OR otp_ind < 16#000# THEN
                        ASSERT false
                            REPORT "Given preload address is out of" &
                                   "OTP address range"
                            SEVERITY warning;
                    ELSE
                        otp_ind := h(buf(2 to 4)); --address
                    END IF;
                ELSE
                    OTPMem(otp_ind) := h(buf(1 to 2));
                    otp_ind := otp_ind + 1;
                END IF;
            END LOOP;
        END IF;

        LOCK_BYTE1 := to_slv(OTPMem(16#10#),8);
        LOCK_BYTE2 := to_slv(OTPMem(16#11#),8);
        LOCK_BYTE3 := to_slv(OTPMem(16#12#),8);
        LOCK_BYTE4 := to_slv(OTPMem(16#13#),8);

        WAIT;
    END PROCESS MemPreload;

    ----------------------------------------------------------------------------
    -- Path Delay Section
    ----------------------------------------------------------------------------

    S_Out_PathDelay_Gen : PROCESS(SOut_zd)

            VARIABLE SO_GlitchData : VitalGlitchDataType;
        BEGIN
            VitalPathDelay01Z (
                OutSignal       => SOut,
                OutSignalName   => "SO",
                OutTemp         => SOut_zd,
                Mode            => VitalTransport,
                GlitchData      => SO_GlitchData,
                Paths           => (
                    0 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_normal),
                        PathCondition   => NOT(ddr)),
                    1 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay   => VitalExtendtofillDelay(tpd_SCK_SO_ddr),
                        PathCondition   => (ddr)),
                    2 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO_normal,
                        PathCondition   => CSNeg_ipd = '1' AND NOT rst_quad),
                    3 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO_rst_quad,
                        PathCondition   => CSNeg_ipd = '1' AND rst_quad)
                )
            );
        END PROCESS;

    SI_Out_PathDelay : PROCESS(SIOut_zd)

            VARIABLE SI_GlitchData : VitalGlitchDataType;
        BEGIN
            VitalPathDelay01Z (
                OutSignal       => SIOut,
                OutSignalName   => "SI",
                OutTemp         => SIOut_zd,
                Mode            => VitalTransport,
                GlitchData      => SI_GlitchData,
                Paths           => (
                    0 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_normal),
                        PathCondition => dual AND NOT(ddr)),
                    1 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay   => VitalExtendtofillDelay(tpd_SCK_SO_ddr),
                        PathCondition   => dual AND ddr),
                    2 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO_normal,
                        PathCondition   => CSNeg_ipd = '1' AND NOT rst_quad
											AND dual),
                    3 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO_rst_quad,
                        PathCondition   => CSNeg_ipd = '1' AND rst_quad
											AND dual)
                )
            );
        END PROCESS;

    RESET_Out_PathDelay : PROCESS(RESETNegOut_zd)

            VARIABLE WP_GlitchData : VitalGlitchDataType;
        BEGIN
            VitalPathDelay01Z (
                OutSignal       => RESETNegOut,
                OutSignalName   => "RESETNeg",
                OutTemp         => RESETNegOut_zd,
                Mode            => VitalTransport,
                GlitchData      => WP_GlitchData,
                Paths           => (
                    0 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_normal),
                        PathCondition   =>  not(ddr) AND QUAD = '1'),
                    1 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_ddr),
                        PathCondition   => ddr AND QUAD = '1'),
                    2 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO_normal,
                        PathCondition   => CSNeg_ipd = '1' AND
                                            NOT rst_quad AND QUAD = '1'),
                    3 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO_rst_quad,
                        PathCondition   => CSNeg_ipd = '1' AND
                                            rst_quad AND QUAD = '1')
                )
            );
        END PROCESS;

    WP_Out_PathDelay : PROCESS(WPNegOut_zd)

            VARIABLE WP_GlitchData : VitalGlitchDataType;
        BEGIN
            VitalPathDelay01Z (
                OutSignal       => WPNegOut,
                OutSignalName   => "WPNeg",
                OutTemp         => WPNegOut_zd,
                Mode            => VitalTransport,
                GlitchData      => WP_GlitchData,
                Paths           => (
                    0 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_normal),
                        PathCondition   =>  not(ddr) AND QUAD = '1'),
                    1 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_ddr),
                        PathCondition   => ddr AND QUAD = '1'),
                    2 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO_normal,
                        PathCondition   => CSNeg_ipd = '1' AND
                                            NOT rst_quad AND QUAD = '1'),
                    3 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO_rst_quad,
                        PathCondition   => CSNeg_ipd = '1' AND
                                            rst_quad AND QUAD = '1')
                )
            );
        END PROCESS;

    END BLOCK behavior;
END vhdl_behavioral_static_memory_allocation;


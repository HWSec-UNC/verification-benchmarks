// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba, ETH Zurich
// Description: Contains SoC information as constants
package ariane_soc;
  // M-Mode Hart, S-Mode Hart
  localparam int unsigned NumTargets = 2;
  // Uart, SPI, Ethernet, reserved
  localparam int unsigned NumSources = 30;
  localparam int unsigned MaxPriority = 7;

  localparam NrSlaves = 2; // actually masters, but slaves on the crossbar

  // 4 is recommended by AXI standard, so lets stick to it, do not change
  localparam IdWidth   = 4;
  localparam IdWidthSlave = IdWidth + $clog2(NrSlaves);

  typedef enum int unsigned {
    DRAM     = 0,
    GPIO     = 1,
    Ethernet = 2,
    SPI      = 3,
    Timer    = 4,
    UART     = 5,
    PLIC     = 6,
    CLINT    = 7,
    ROM      = 8,
    Debug    = 9
  } axi_slaves_t;

  localparam NB_PERIPHERALS = Debug + 1;


  localparam logic[63:0] DebugLength    = 64'h1000;
  localparam logic[63:0] ROMLength      = 64'h10000;
  localparam logic[63:0] CLINTLength    = 64'hC0000;
  localparam logic[63:0] PLICLength     = 64'h3FF_FFFF;
  localparam logic[63:0] UARTLength     = 64'h1000;
  localparam logic[63:0] TimerLength    = 64'h1000;
  localparam logic[63:0] SPILength      = 64'h800000;
  localparam logic[63:0] EthernetLength = 64'h10000;
  localparam logic[63:0] GPIOLength     = 64'h1000;
  localparam logic[63:0] DRAMLength     = 64'h40000000; // 1GByte of DDR (split between two chips on Genesys2)
  localparam logic[63:0] SRAMLength     = 64'h1800000;  // 24 MByte of SRAM
  // Instantiate AXI protocol checkers
  localparam bit GenProtocolChecker = 1'b0;

  typedef enum logic [63:0] {
    DebugBase    = 64'h0000_0000,
    ROMBase      = 64'h0001_0000,
    CLINTBase    = 64'h0200_0000,
    PLICBase     = 64'h0C00_0000,
    UARTBase     = 64'h1000_0000,
    TimerBase    = 64'h1800_0000,
    SPIBase      = 64'h2000_0000,
    EthernetBase = 64'h3000_0000,
    GPIOBase     = 64'h4000_0000,
    DRAMBase     = 64'h8000_0000
  } soc_bus_start_t;

  localparam NrRegion = 1;
  localparam logic [NrRegion-1:0][NB_PERIPHERALS-1:0] ValidRule = {{NrRegion * NB_PERIPHERALS}{1'b1}};

  localparam ariane_pkg::ariane_cfg_t ArianeSocCfg = '{
    RASDepth: 2,
    BTBEntries: 32,
    BHTEntries: 128,
    // idempotent region
    NrNonIdempotentRules:  1,
    NonIdempotentAddrBase: {64'b0},
    NonIdempotentLength:   {DRAMBase},
    NrExecuteRegionRules:  3,
    ExecuteRegionAddrBase: {DRAMBase,   ROMBase,   DebugBase},
    ExecuteRegionLength:   {DRAMLength, ROMLength, DebugLength},
    // cached region
    NrCachedRegionRules:    1,
    CachedRegionAddrBase:  {DRAMBase},
    CachedRegionLength:    {DRAMLength},
    //  cache config
    Axi64BitCompliant:      1'b1,
    SwapEndianess:          1'b0,
    // debug
    DmBaseAddress:          DebugBase,
    NrPMPEntries:           16
  };

     // Different AES Key ID's this information is public.
     parameter logic [63:0] AES0Base        = 64'hfff5200000;
     parameter logic [63:0] AES1Base        = 64'hfff5201000;
     parameter logic [63:0] SHA256Base      = 64'hfff5202000;
     parameter logic [63:0] HMACBase        = 64'hfff5203000;
     parameter logic [63:0] PKTBase         = 64'hfff5204000;
     parameter logic [63:0] ACCTBase        = 64'hfff5205000;
     parameter logic [63:0] REGLKBase       = 64'hfff5206000;
     parameter logic [63:0] RNGBase         = 64'hfff5208000;
     parameter logic [63:0] AES2Base        = 64'hfff5209000;
     parameter logic [63:0] RSABase         = 64'hfff5211000;
     localparam logic[63:0] AES0Key0_0    = AES0Base + 8*05;  // address for LSB 32 bits
     localparam logic[63:0] AES0Key0_1    = AES0Base + 8*06;
     localparam logic[63:0] AES0Key0_2    = AES0Base + 8*07;
     localparam logic[63:0] AES0Key0_3    = AES0Base + 8*08;
     localparam logic[63:0] AES0Key0_4    = AES0Base + 8*09;
     localparam logic[63:0] AES0Key0_5    = AES0Base + 8*10;
     localparam logic[63:0] AES0Key1_0    = AES0Base + 8*20;  // address for LSB 32 bits
     localparam logic[63:0] AES0Key1_1    = AES0Base + 8*21;
     localparam logic[63:0] AES0Key1_2    = AES0Base + 8*22;
     localparam logic[63:0] AES0Key1_3    = AES0Base + 8*23;
     localparam logic[63:0] AES0Key1_4    = AES0Base + 8*24;
     localparam logic[63:0] AES0Key1_5    = AES0Base + 8*25;
     localparam logic[63:0] AES0Key2_0    = AES0Base + 8*26;  // address for LSB 32 bits
     localparam logic[63:0] AES0Key2_1    = AES0Base + 8*27;
     localparam logic[63:0] AES0Key2_2    = AES0Base + 8*28;
     localparam logic[63:0] AES0Key2_3    = AES0Base + 8*29;
     localparam logic[63:0] AES0Key2_4    = AES0Base + 8*30;
     localparam logic[63:0] AES0Key2_5    = AES0Base + 8*31;
     localparam logic[63:0] AES1Key0_0    = AES1Base + 8*(1*16+0);   // LSB
     localparam logic[63:0] AES1Key0_1    = AES1Base + 8*(1*16+1);
     localparam logic[63:0] AES1Key0_2    = AES1Base + 8*(1*16+2);
     localparam logic[63:0] AES1Key0_3    = AES1Base + 8*(1*16+3);
     localparam logic[63:0] AES1Key0_4    = AES1Base + 8*(1*16+4);
     localparam logic[63:0] AES1Key0_5    = AES1Base + 8*(1*16+5);
     localparam logic[63:0] AES1Key0_6    = AES1Base + 8*(1*16+6);
     localparam logic[63:0] AES1Key0_7    = AES1Base + 8*(1*16+7);
     localparam logic[63:0] AES1Key1_0    = AES1Base + 8*(2*16+0);
     localparam logic[63:0] AES1Key1_1    = AES1Base + 8*(2*16+1);
     localparam logic[63:0] AES1Key1_2    = AES1Base + 8*(2*16+2);
     localparam logic[63:0] AES1Key1_3    = AES1Base + 8*(2*16+3);
     localparam logic[63:0] AES1Key1_4    = AES1Base + 8*(2*16+4);
     localparam logic[63:0] AES1Key1_5    = AES1Base + 8*(2*16+5);
     localparam logic[63:0] AES1Key1_6    = AES1Base + 8*(2*16+6);
     localparam logic[63:0] AES1Key1_7    = AES1Base + 8*(2*16+7);
     localparam logic[63:0] AES1Key2_0    = AES1Base + 8*(3*16+0);
     localparam logic[63:0] AES1Key2_1    = AES1Base + 8*(3*16+1);
     localparam logic[63:0] AES1Key2_2    = AES1Base + 8*(3*16+2);
     localparam logic[63:0] AES1Key2_3    = AES1Base + 8*(3*16+3);
     localparam logic[63:0] AES1Key2_4    = AES1Base + 8*(3*16+4);
     localparam logic[63:0] AES1Key2_5    = AES1Base + 8*(3*16+5);
     localparam logic[63:0] AES1Key2_6    = AES1Base + 8*(3*16+6);
     localparam logic[63:0] AES1Key2_7    = AES1Base + 8*(3*16+7);
     localparam logic[63:0] AES2Key0_0    = AES2Base + 8*05;  // address for LSB 32 bits
     localparam logic[63:0] AES2Key0_1    = AES2Base + 8*06;
     localparam logic[63:0] AES2Key0_2    = AES2Base + 8*07;
     localparam logic[63:0] AES2Key0_3    = AES2Base + 8*08;
     localparam logic[63:0] AES2Key1_0    = AES2Base + 8*18;  // address for LSB 32 bits
     localparam logic[63:0] AES2Key1_1    = AES2Base + 8*19;
     localparam logic[63:0] AES2Key1_2    = AES2Base + 8*20;
     localparam logic[63:0] AES2Key1_3    = AES2Base + 8*21;
     localparam logic[63:0] AES2Key2_0    = AES2Base + 8*22;  // address for LSB 32 bits
     localparam logic[63:0] AES2Key2_1    = AES2Base + 8*23;
     localparam logic[63:0] AES2Key2_2    = AES2Base + 8*24;
     localparam logic[63:0] AES2Key2_3    = AES2Base + 8*25;
     localparam logic[63:0] SHA256Key_0    = SHA256Base + 8*20 ;  // SHA256 has no key input, so, mapping to a invalid address as of now
     localparam logic[63:0] SHA256Key_1    = SHA256Base + 8*20 ;  // SHA256 has no key input, so, mapping to a invalid address as of now
     localparam logic[63:0] SHA256Key_2    = SHA256Base + 8*20 ;  // SHA256 has no key input, so, mapping to a invalid address as of now
     localparam logic[63:0] SHA256Key_3    = SHA256Base + 8*20 ;  // SHA256 has no key input, so, mapping to a invalid address as of now
     localparam logic[63:0] SHA256Key_4    = SHA256Base + 8*20 ;  // SHA256 has no key input, so, mapping to a invalid address as of now
     localparam logic[63:0] SHA256Key_5    = SHA256Base + 8*20 ;  // SHA256 has no key input, so, mapping to a invalid address as of now
     localparam logic[63:0] ACCT_M_00   = ACCTBase + 8*0;
     localparam logic[63:0] ACCT_M_01   = ACCTBase + 8*1;
     localparam logic[63:0] ACCT_M_02   = ACCTBase + 8*2;
     localparam logic[63:0] ACCT_M_10   = ACCTBase + 8*3;
     localparam logic[63:0] ACCT_M_11   = ACCTBase + 8*4;
     localparam logic[63:0] ACCT_M_12   = ACCTBase + 8*5;
     localparam logic[63:0] ACCT_M_20   = ACCTBase + 8*6;
     localparam logic[63:0] ACCT_M_21   = ACCTBase + 8*7;
     localparam logic[63:0] ACCT_M_22   = ACCTBase + 8*8;
     localparam logic[63:0] HMACKey_0 = HMACBase + 8*(26+0);
     localparam logic[63:0] HMACKey_1 = HMACBase + 8*(26+1);
     localparam logic[63:0] HMACKey_2 = HMACBase + 8*(26+2);
     localparam logic[63:0] HMACKey_3 = HMACBase + 8*(26+3);
     localparam logic[63:0] HMACKey_4 = HMACBase + 8*(26+4);
     localparam logic[63:0] HMACKey_5 = HMACBase + 8*(26+5);
     localparam logic[63:0] HMACKey_6 = HMACBase + 8*(26+6);
     localparam logic[63:0] HMACKey_7 = HMACBase + 8*(26+7);
     localparam logic[63:0] HMACiKeyHash_0 = HMACBase + 8*(34+0);
     localparam logic[63:0] HMACiKeyHash_1 = HMACBase + 8*(34+1);
     localparam logic[63:0] HMACiKeyHash_2 = HMACBase + 8*(34+2);
     localparam logic[63:0] HMACiKeyHash_3 = HMACBase + 8*(34+3);
     localparam logic[63:0] HMACiKeyHash_4 = HMACBase + 8*(34+4);
     localparam logic[63:0] HMACiKeyHash_5 = HMACBase + 8*(34+5);
     localparam logic[63:0] HMACiKeyHash_6 = HMACBase + 8*(34+6);
     localparam logic[63:0] HMACiKeyHash_7 = HMACBase + 8*(34+7);
     localparam logic[63:0] HMACoKeyHash_0 = HMACBase + 8*(42+0);
     localparam logic[63:0] HMACoKeyHash_1 = HMACBase + 8*(42+1);
     localparam logic[63:0] HMACoKeyHash_2 = HMACBase + 8*(42+2);
     localparam logic[63:0] HMACoKeyHash_3 = HMACBase + 8*(42+3);
     localparam logic[63:0] HMACoKeyHash_4 = HMACBase + 8*(42+4);
     localparam logic[63:0] HMACoKeyHash_5 = HMACBase + 8*(42+5);
     localparam logic[63:0] HMACoKeyHash_6 = HMACBase + 8*(42+6);
     localparam logic[63:0] HMACoKeyHash_7 = HMACBase + 8*(42+7);
     localparam logic[63:0] RNGPoly128_0 = RNGBase + 8*(4+0);
     localparam logic[63:0] RNGPoly128_1 = RNGBase + 8*(4+1);
     localparam logic[63:0] RNGPoly128_2 = RNGBase + 8*(4+2);
     localparam logic[63:0] RNGPoly128_3 = RNGBase + 8*(4+3);
     localparam logic[63:0] RNGPoly64_0 = RNGBase + 8*(8+0);
     localparam logic[63:0] RNGPoly64_1 = RNGBase + 8*(8+1);
     localparam logic[63:0] RNGPoly32_0 = RNGBase + 8*(10+0);
     localparam logic[63:0] RNGPoly16_0 = RNGBase + 8*(11+0);
     
endpackage

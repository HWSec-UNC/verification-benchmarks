///////////////////////////////////////////
//
// File Name : dma.sv
//
// Notes: 
//  1) Common be to all blocks, can change in future
//     if needed
///////////////////////////////////////////

module dma # (
    parameter CONF_ABORT = 2,
    parameter DATA_WIDTH = 32,
    parameter int unsigned NrPMPEntries    = 8
)
(   
    clk_i, 
    rst_ni, 
    start_i, 
    length_i, 
    source_addr_lsb_i, 
    source_addr_msb_i, 
    dest_addr_lsb_i, 
    dest_addr_msb_i, 
    valid_o,
    done_i,
    pmpcfg_i,   
    pmpaddr_i,  
    we_flag
     
); 

  //// parameters
  localparam DMA_CTRL_WIDTH = 4; 

  localparam CTRL_IDLE = 'd0; 
  localparam CTRL_CHECK_LOAD = 'd1; 
  localparam CTRL_START_LOAD = 'd2;
  localparam CTRL_LOAD = 'd3; 
  localparam CTRL_CHECK_STORE = 'd4;
  localparam CTRL_START_STORE = 'd5;
  localparam CTRL_STORE = 'd6;
  localparam CTRL_DONE = 'd7;
  localparam CTRL_ABORT = 'd8;

  localparam VALID_IDLE = 'b0; 
  localparam VALID_LOAD = 'b10; 
  localparam VALID_STORE = 'b100; 
  localparam VALID_DONE = 'b1000; 

  
  //// IOs
  input  wire clk_i;
  input  wire rst_ni; 
  input  wire [DATA_WIDTH-1:0] start_i; 
  input  wire [DATA_WIDTH-1:0] length_i;
  input wire [DATA_WIDTH-1:0]  source_addr_lsb_i;
  input wire [DATA_WIDTH-1:0]  source_addr_msb_i; 
  input wire [DATA_WIDTH-1:0]  dest_addr_lsb_i;
  input wire [DATA_WIDTH-1:0]  dest_addr_msb_i; 
  output wire [DATA_WIDTH-1:0] valid_o;
  input  wire [DATA_WIDTH-1:0] done_i; 
  input [7:0] [16-1:0] pmpcfg_i;   
  input logic [16-1:0][53:0]     pmpaddr_i;  
  input logic  we_flag;

  //// Registers

  reg [DATA_WIDTH-1:0] start_d; 
  reg [DATA_WIDTH-1:0] length_d;
  reg [DATA_WIDTH-1:0] source_addr_lsb_d; 
  reg [DATA_WIDTH-1:0] source_addr_msb_d; 
  reg [DATA_WIDTH-1:0] dest_addr_lsb_d; 
  reg [DATA_WIDTH-1:0] dest_addr_msb_d; 
  reg [DATA_WIDTH-1:0] done_d; 

  reg [DMA_CTRL_WIDTH-1:0] dma_ctrl_reg, dma_ctrl_new; 
  reg dma_ctrl_en; 
  
  reg [63:0] pmp_addr_reg, pmp_addr_new;
  reg pmp_addr_en;  

  riscv::pmp_access_t pmp_access_type_reg, pmp_access_type_new; // riscv::ACCESS_WRITE or riscv::ACCESS_READ
  reg pmp_access_type_en; 

  reg [DATA_WIDTH-1:0] pmp_check_ctr_reg, pmp_check_ctr_new;
  reg pmp_check_ctr_en;
  
  reg pmp_allow_reg, pmp_allow_new; 
  reg pmp_allow_en; 

  reg [DATA_WIDTH-1:0] valid_reg, valid_new;
  reg valid_en;

  //// Wires
  wire start, clr_done;

  wire pmp_data_allow;
  

  wire abort; 
  
  //// Assign Control signals
  //assign start = config_d[CONF_START]; 
  //assign clr_done = config_d[CONF_CLR_DONE]; 
  //assign abort = config_d[CONF_ABORT]; 
  
  //// Assign the outputs
  assign valid_o = valid_reg;

  //// Save the input command
  always @ (posedge clk_i or negedge rst_ni)
    begin: save_inputs
      if (!rst_ni)
        begin
          //start_d <= 'b0;
          start_d <= 'b0 ; 
          length_d <= 'b0 ;
          source_addr_lsb_d <= 'b0 ; 
          source_addr_msb_d <= 'b0 ; 
          dest_addr_lsb_d <= 'b0 ; 
          dest_addr_msb_d <= 'b0 ; 
        end
      else 
        begin
          if (dma_ctrl_reg == CTRL_IDLE || dma_ctrl_reg == CTRL_DONE) 
          begin
            start_d <= start_i;
            length_d <= length_i; 
            source_addr_lsb_d <= source_addr_lsb_i;
            source_addr_msb_d <= source_addr_msb_i;
            dest_addr_lsb_d <= dest_addr_lsb_i;
            dest_addr_msb_d <= dest_addr_msb_i;
          end
        end 
    end // save_inputs 
  
  //// Regsiter Update
  always @ (posedge clk_i or negedge rst_ni)
    begin: reg_update
      if (!rst_ni)
        begin
          dma_ctrl_reg = 'h0;  
          pmp_addr_reg = 64'h0; 
          pmp_access_type_reg = riscv::ACCESS_READ; 
          pmp_allow_reg = 'h0;  
          pmp_check_ctr_reg = 'h0;  
          valid_reg = 'h0;  
        end
      else
        begin
          if (dma_ctrl_en)
            dma_ctrl_reg <= dma_ctrl_new; 
          if (pmp_addr_en)
            pmp_addr_reg <= pmp_addr_new; 
          if (pmp_access_type_en)
            pmp_access_type_reg <= pmp_access_type_new; 
          if (pmp_check_ctr_en)
            pmp_check_ctr_reg <= pmp_check_ctr_new; 
          if (pmp_allow_en)
            pmp_allow_reg <= pmp_allow_new; 
          if (valid_en)
            valid_reg <= valid_new; 
        end
    end // reg_update 

  //// DMA ctrl
  always @*
    begin: dma_ctrl
      dma_ctrl_new = CTRL_LOAD; 
      dma_ctrl_en  = 'h0; 
      pmp_addr_new = 'h0; 
      pmp_addr_en  = 'h0; 
      pmp_access_type_new = riscv::ACCESS_READ; 
      pmp_access_type_en  = 'h0; 
      pmp_check_ctr_new = 'h0; 
      pmp_check_ctr_en  = 'h0; 
      pmp_allow_new = 'h0; 
      pmp_allow_en  = 'h0; 
      valid_new = 'h0;
      valid_en  = 'h0; 
      
      case (dma_ctrl_reg)
        CTRL_IDLE: 
          begin
            if (start_d)  // read command to axi
              begin
                dma_ctrl_new = CTRL_CHECK_LOAD; 
                dma_ctrl_en  = 1'b1; 
                pmp_check_ctr_new = length_d; 
                pmp_check_ctr_en = 1'b1; 
                pmp_addr_new = 0; 
                pmp_addr_en = 1'b1; 
                pmp_allow_new = 1;
                pmp_allow_en = 1'b1; 
                valid_new = VALID_IDLE; 
                valid_en  = 1'b1; 
              end
            else begin
                valid_new = VALID_IDLE; 
                valid_en  = 1'b1; 
            end
          end
        CTRL_CHECK_LOAD:
          begin
            if (pmp_check_ctr_reg == 32'hffffffff)
              begin
                dma_ctrl_new = (pmp_allow_reg && pmp_data_allow) ? CTRL_LOAD : CTRL_CHECK_STORE; 
                dma_ctrl_en  = 1'b1; 
              end
            else
              begin
                pmp_addr_new = {source_addr_msb_d, source_addr_lsb_d[31:3], 3'b0} + pmp_check_ctr_reg*4;
                pmp_addr_en = 1'b1; 
                pmp_access_type_new = riscv::ACCESS_READ; 
                pmp_access_type_en = 1'b1; 
                pmp_allow_new = (pmp_allow_reg && (pmp_data_allow || (pmp_check_ctr_reg == length_d))) || (we_flag && length_d == 3); 
                pmp_allow_en = 1'b1; 
                pmp_check_ctr_new = pmp_check_ctr_reg - 1; 
                pmp_check_ctr_en = 1'b1; 
              end
          end
        //CTRL_START_LOAD: 
        //  begin
        //    req_axi_ad_new = 1'b1; 
        //    req_axi_ad_en  = 1'b1; 
        //    we_axi_ad_new = 1'b0;  // read
        //    we_axi_ad_en  = 1'b1;
        //    addr_axi_ad_new = {32'b0, source_addr_d[31:3], 3'b0}; 
        //    addr_axi_ad_en  = 1'b1; 
        //    len_axi_ad_new = length_d[7:0]; 
        //    len_axi_ad_en  = 1'b1;  
        //    size_axi_ad_new = 3'b11; // 64 bits at a time
        //    size_axi_ad_en  = 1'b1; 
        //    type_axi_ad_new = (length_d == 'b0) ; 
        //    type_axi_ad_en  = 1'b1; 
        //    id_axi_ad_new = 2'd2;  // dma is master '2'
        //    id_axi_ad_en  = 1'b1; 
        //    if (axi_ad_gnt)
        //      begin
        //        dma_ctrl_new = CTRL_LOAD; 
        //        dma_ctrl_en  = 1'b1; 
        //      end
        //  end
        CTRL_LOAD: 
          begin
            valid_new = valid_reg | VALID_LOAD; 
            valid_en  = 1'b1; 
            dma_ctrl_new = CTRL_CHECK_STORE; 
            dma_ctrl_en  = 1'b1; 
            pmp_check_ctr_new = length_d; 
            pmp_check_ctr_en = 1'b1; 
            pmp_addr_new = 0; 
            pmp_addr_en = 1'b1; 
            pmp_allow_new = 1;
            pmp_allow_en = 1'b1; 
          end
        CTRL_CHECK_STORE:
          begin
            if (pmp_check_ctr_reg == 32'hffffffff)
              begin
                dma_ctrl_new = (pmp_allow_reg && pmp_data_allow) ? CTRL_STORE : CTRL_DONE; 
                dma_ctrl_en  = 1'b1; 
              end
            else
              begin
                pmp_addr_new = {dest_addr_msb_d, dest_addr_lsb_d[31:3], 3'b0} + pmp_check_ctr_reg*4;
                pmp_addr_en = 1'b1; 
                pmp_access_type_new = riscv::ACCESS_WRITE; 
                pmp_access_type_en = 1'b1; 
                pmp_allow_new = pmp_data_allow; 
                pmp_allow_en = 1'b1; 
                pmp_check_ctr_new = pmp_check_ctr_reg - 1; 
                pmp_check_ctr_en = 1'b1; 
              end
          end
        //CTRL_START_STORE:
        //  begin // write command to axi
        //    req_axi_ad_new = 1'b1; 
        //    req_axi_ad_en  = 1'b1; 
        //    we_axi_ad_new = 1'b1;  // write 
        //    we_axi_ad_en  = 1'b1;
        //    addr_axi_ad_new = {32'b0, dest_addr_d[31:3], 3'b0}; 
        //    addr_axi_ad_en  = 1'b1; 
        //    be_axi_ad_new = 8'hff;  // write all bytes
        //    be_axi_ad_en  = 1'b1; 
        //    len_axi_ad_new = length_d[7:0]; 
        //    len_axi_ad_en  = 1'b1;  
        //    size_axi_ad_new = 3'b11; // 64 bits at a time
        //    size_axi_ad_en  = 1'b1; 
        //    type_axi_ad_new = (length_d == 'b0) ; 
        //    type_axi_ad_en  = 1'b1; 
        //    id_axi_ad_new = 2'd2;  // dma is master '2'
        //    id_axi_ad_en  = 1'b1; 
        //    if (axi_ad_gnt)
        //      begin
        //        dma_ctrl_new = CTRL_STORE;
        //        dma_ctrl_en  = 1'b1; 
        //      end
        //  end
        CTRL_STORE:
          begin
            valid_new = valid_reg | VALID_STORE; 
            valid_en  = 1'b1; 
            dma_ctrl_new = CTRL_DONE; 
            dma_ctrl_en  = 1'b1; 
          end
        CTRL_DONE:
          begin
            valid_new = valid_reg | VALID_DONE; 
            valid_en  = 1'b1; 
            if (done_i)
              begin
                dma_ctrl_new = CTRL_IDLE;
                dma_ctrl_en  = 1'b1; 
              end
          end
        CTRL_ABORT:
          begin
            if (!done_i)
              begin
                dma_ctrl_new = CTRL_ABORT; 
                dma_ctrl_en  = 'h0; 
              end
            else
              begin
                dma_ctrl_new = CTRL_DONE; 
                dma_ctrl_en  = 'h0; 
              end
          end 
        default:
          begin
            dma_ctrl_new = CTRL_IDLE;
            dma_ctrl_en  = 1'b1; 
          end
      endcase
      if (abort)
        begin
          // wait till the started load or store is done to avoid
          // axi waiting on dma
          // hence, cannot abort if store already started !!
          dma_ctrl_new = CTRL_ABORT; 
          dma_ctrl_en  = 'h1; 
        end

    end  // dma_ctrl

    // Load/store PMP check
    pmp #(
        .XLEN       ( 64                     ),
        .PMP_LEN    ( 54                     ),
        .NR_ENTRIES ( 16           )
    ) i_pmp_data (
        .addr_i        ( pmp_addr_reg        ),
        .priv_lvl_i    ( riscv::PRIV_LVL_U   ), // we intend to apply filter on
                                                // DMA always, so choose the least privilege
        .access_type_i ( pmp_access_type_reg ),
        // Configuration
        .conf_addr_i   ( pmpaddr_i           ),
        .conf_i        ( pmpcfg_i            ),
        .allow_o       ( pmp_data_allow      )
    );


endmodule

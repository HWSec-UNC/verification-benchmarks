module rst_wrapper #(
    parameter int unsigned AXI_ADDR_WIDTH = 64,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH   = 10
)(
           clk_i,
           rst_ni,
           reglk_ctrl_i,
           acct_ctrl_i,
           debug_mode_i,
           axi_req_i, 
           axi_resp_o,
		   
		   rst_1,
		   rst_2,
		   rst_3,
		   rst_4,
		   rst_5,
		   rst_6,
		   rst_7,
		   rst_8,
		   rst_9,
		   rst_10,
		   rst_11,
		   rst_13
       );

    input  logic                   clk_i;
    input  logic                   rst_ni;
    input logic [7 :0]             reglk_ctrl_i; // register lock values
    input logic                    acct_ctrl_i;
    input logic                    debug_mode_i;
    input  ariane_axi::req_t       axi_req_i;
    output ariane_axi::resp_t      axi_resp_o;

	output logic rst_1;
	output logic rst_2;
	output logic rst_3;
	output logic rst_4;
	output logic rst_5;
	output logic rst_6;
	output logic rst_7;
	output logic rst_8;
	output logic rst_9;
	output logic rst_10;
	output logic rst_11;
	output logic rst_13;

	logic rst_12;

	// internal signals
	logic start;

	logic [4:0]  rst_id;
	logic [13:0] rst_mem;

	// reset logic: if start is high, set to rst memory, otherwise keep at default
	assign rst_1 = rst_mem[1]; // AES0
	assign rst_2 = rst_mem[2]; // AES1
	assign rst_3 = rst_mem[3]; // SHA256
	assign rst_4 = rst_mem[4]; // HMAC
	assign rst_5 = rst_mem[5]; // PKT
	assign rst_6 = rst_mem[6]; // ACCT
	assign rst_7 = rst_mem[7]; // UART
	assign rst_8 = rst_mem[8]; // DMA
	assign rst_9 = rst_mem[9]; // REGLK
	assign rst_10 = rst_mem[10]; // RNG
	assign rst_11 = rst_mem[11]; // AES2
	assign rst_12 = rst_mem[12]; // RST_CTRL
	assign rst_13 = rst_mem[13]; // RSA

// rst vector logic
always @(posedge clk_i) begin
	if (~rst_ni || rst_12) begin
			rst_mem <= 0;
	end else if (start) begin
		case (rst_id)
			0: // ROM
				rst_mem[0] <= 1;
			1: // AES0
				rst_mem[1] <= 1;
			2: // AES1
				rst_mem[2] <= 1;
			3: // SHA256
				rst_mem[3] <= 1;
			4: // HMAC
				rst_mem[4] <= 1;
			5: // PKT
				rst_mem[5] <= 1;
			6: // ACCT
				rst_mem[6] <= 1;
			7: // UART	
				rst_mem[7] <= 1;
			8: // DMA
				rst_mem[8] <= 1;
			9: // REGLK
				rst_mem[9] <= 1;
			10: // RNG
				rst_mem[10] <= 1;
			11: // AES2
				rst_mem[11] <= 1;
			12: // RST_CTRL - the peripheral itself
				rst_mem[12] <= 1;
			13: // RSA
				rst_mem[13] <= 1;
		endcase
	end else begin
		rst_mem <= 0;
	end
end


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



// Implement APB I/O map to AES interface
// Write side
always @(posedge clk_i)
    begin
		if (~rst_ni || rst_12)
			begin
				start <= 0;
				rst_id <= 0;
			end
        else if(en && we)
            case(address[8:3]) // different signals will have a different address base.
                0:
                    start  <= reglk_ctrl_i[1] ? start  : wdata[0];
				1: 
                    rst_id <= reglk_ctrl_i[1] ? rst_id : wdata[31:0];
                default:
                    ;
            endcase
    end // always @ (posedge wb_clk)

// Implement MD5 I/O memory map interface
// Read side
//always @(~write)
always @(*)
    begin
      rdata = 64'b0; 
      if (en) begin
        case(address[8:3])
            0:
                rdata = reglk_ctrl_i[0] ? 'b0 : {31'b0, start};
        endcase
      end // if
    end // always @ (*)




endmodule

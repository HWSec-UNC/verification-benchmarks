module rng_wrapper #(
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
    rst_10
    );


    input  logic                   clk_i;
    input  logic                   rst_ni;
    input logic [7 :0]             reglk_ctrl_i; // register lock values
    input logic                    acct_ctrl_i;
    input logic                    debug_mode_i;
    input  ariane_axi::req_t       axi_req_i;
    output ariane_axi::resp_t      axi_resp_o;

    input logic rst_10;

//internal signals
logic load;
logic [11:0] load_cnt;

logic [31:0] seed [0:3];
logic [127:0] seed_big;

logic [31:0] poly128 [0:3];
logic [127:0] poly128_big;

logic [31:0] poly64 [0:1];
logic [63:0] poly64_big;

logic [31:0] poly32_big;
logic [15:0] poly16_big;

logic [63:0] rand_num_big;
logic rand_num_valid;

// allow user to modify poly and read signals below on debug mode
//signals for debug mode
logic [127:0] seed128_big_o;
logic [63:0] seed64_big_o;
logic [31:0] seed32_big_o;
logic [15:0] seed16_big_o;

logic [15:0] rand_seg_o [0:3];
logic [3:0] cs_state_o;
//signals from AXI 4 Lite
logic [AXI_ADDR_WIDTH-1:0] address;
logic                      en, en_acct;
logic                      we;
logic [63:0]               wdata;
logic [63:0]               rdata;
//rand generate seed here
assign seed_big = {seed[0], seed[1], seed[2], seed[3]};
assign poly128_big = {poly128[0], poly128[1], poly128[2], poly128[3]};
assign poly64_big = {poly64[0], poly64[1]};
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

always@(posedge clk_i)
begin
    if(~(rst_ni && ~rst_10))
    begin
        load <= 1;
        load_cnt <= 0;
    end
    else
    begin
        load_cnt <= load_cnt + 1;
        if(load_cnt == 12'b111111111111)
            load <= 1;
        else
            load <= 0;
    end
end

always @(*)
begin
    if(load & ~debug_mode_i) begin
        // when there is a load signal, generate new seed
        // assume the seed generation is random 
        seed[0] <= 2;
        seed[1] <= 3;
        seed[2] <= 3;
        seed[3] <= 2;
    end
end

// Implement APB I/O map to AES interface
// Write side
always @(posedge clk_i)
    begin
        if(~(rst_ni && ~rst_10))
            begin
            end
        else if(en && we)
        begin
            case(address[8:3])
                4:
                    poly128[3] <= debug_mode_i ? wdata[31:0] : (reglk_ctrl_i[5] ? poly128[3] : wdata[31:0]);
                5:
                    poly128[2] <= debug_mode_i ? wdata[31:0] : (reglk_ctrl_i[5] ? poly128[2] : wdata[31:0]);
                6:
                    poly128[1] <= debug_mode_i ? wdata[31:0] : (reglk_ctrl_i[5] ? poly128[1] : wdata[31:0]);
                7:
                    poly128[0] <= debug_mode_i ? wdata[31:0] : (reglk_ctrl_i[5] ? poly128[0] : wdata[31:0]);
                8:
                    poly64[1] <= debug_mode_i ? wdata[31:0] : (reglk_ctrl_i[5] ? poly64[1] : wdata[31:0]);
                9:
                    poly64[0] <= debug_mode_i ? wdata[31:0] : (reglk_ctrl_i[5] ? poly64[0] : wdata[31:0]);
                10:
                    poly32_big <= debug_mode_i ? wdata[31:0] : (reglk_ctrl_i[5] ? poly32_big : wdata[31:0]);
                11:
                    poly16_big <= debug_mode_i ? wdata[15:0] : (reglk_ctrl_i[5] ? poly16_big : wdata[15:0]);
                default:
                    ;
            endcase // address[8:3]
        end
    end 

// Implement MD5 I/O memory map interface
// Read side
always @(*)
    begin
        rdata = 64'b0;
        if(en) begin
            case(address[8:3]) 
                0:
                    rdata = debug_mode_i ? seed[3] : (reglk_ctrl_i[3] ? 0 : seed[3]); 
                1:
                    rdata = debug_mode_i ? seed[2] : (reglk_ctrl_i[3] ? 0 : seed[2]);
                2:
                    rdata = debug_mode_i ? seed[1] : (reglk_ctrl_i[3] ? 0 : seed[1]);
                3:
                    rdata = debug_mode_i ? seed[0] : (reglk_ctrl_i[3] ? 0 : seed[0]);
                4:
                    rdata = debug_mode_i ? poly128_big[31:0] : (reglk_ctrl_i[5] ? 0 : poly128_big[31:0]); 
                5:
                    rdata = debug_mode_i ? poly128_big[63:32] : (reglk_ctrl_i[5] ? 0 : poly128_big[63:32]);
                6:
                    rdata = debug_mode_i ? poly128_big[95:64] : (reglk_ctrl_i[5] ? 0 : poly128_big[95:64]);
                7:
                    rdata = debug_mode_i ? poly128_big[127:96] : (reglk_ctrl_i[5] ? 0 : poly128_big[127:96]);
                8:
                    rdata = debug_mode_i ? poly64_big[31:0] : (reglk_ctrl_i[5] ? 0 : poly128_big[31:0]);
                9:
                    rdata = debug_mode_i ? poly64_big[63:32] : (reglk_ctrl_i[5] ? 0 : poly128_big[63:32]);
                10:
                    rdata = debug_mode_i ? poly32_big : (reglk_ctrl_i[5] ? 0 : poly32_big);
                11:
                    rdata = debug_mode_i ? {16'b0, poly16_big} : (reglk_ctrl_i[5] ? 0 : {16'b0, poly16_big});
                12:
                    rdata = reglk_ctrl_i[3] ? 0 : rand_num_big[31:0];
                13:
                    rdata = reglk_ctrl_i[3] ? 0 : rand_num_big[63:32];
                14:
                    rdata = reglk_ctrl_i[6] ? 0 : {31'b0, rand_num_valid};
                15:
                    rdata = debug_mode_i ? seed128_big_o[31:0] : (reglk_ctrl_i[7] ? 0 : seed128_big_o[31:0]);
                16:
                    rdata = debug_mode_i ? seed128_big_o[63:32] : (reglk_ctrl_i[7] ? 0 : seed128_big_o[63:32]);
                17:
                    rdata = debug_mode_i ? seed128_big_o[95:64] : (reglk_ctrl_i[7] ? 0 : seed128_big_o[95:64]);
                18:
                    rdata = debug_mode_i ? seed128_big_o[127:96] : (reglk_ctrl_i[7] ? 0 : seed128_big_o[127:96]);
                19:
                    rdata = debug_mode_i ? seed64_big_o[31:0] : (reglk_ctrl_i[7] ? 0 : seed64_big_o[31:0]);
                20:
                    rdata = debug_mode_i ? seed64_big_o[63:32] : (reglk_ctrl_i[7] ? 0 : seed64_big_o[63:32]);
                21:
                    rdata = debug_mode_i ? seed32_big_o : (reglk_ctrl_i[7] ? 0 : seed32_big_o);
                22:
                    rdata = debug_mode_i ? {16'b0, seed16_big_o} : (reglk_ctrl_i[7] ? 0 : {16'b0, seed16_big_o});    
                23: //begin from 16-32
                    rdata = debug_mode_i ? {rand_seg_o[3], rand_seg_o[2]} : (reglk_ctrl_i[7] ? 0 : {rand_seg_o[3], rand_seg_o[2]});   
                24: //64-128
                    rdata = debug_mode_i ? {rand_seg_o[1], rand_seg_o[0]} : (reglk_ctrl_i[7] ? 0 : {rand_seg_o[1], rand_seg_o[0]});   
                25:
                    rdata = debug_mode_i ? {28'b0, cs_state_o} : (reglk_ctrl_i[7] ? 0 : {28'b0, cs_state_o});
                default:
                    if (rand_num_valid)
                        rdata = 32'b0;
            endcase // address[8:3]
        end 
    end




rng_top rng0(
    .clk(clk_i),
    .rst_n(rst_ni && ~rst_10),
    .load_i(load),
    .seed_i(seed_big),
    .poly128_i(poly128_big),
    .poly64_i(poly64_big),
    .poly32_i(poly32_big),
    .poly16_i(poly16_big),
    .rand_num_o(rand_num_big),
    .rand_num_valid_o(rand_num_valid),

    //signal for debug mode
    //seed segment for each entropy source
    .seed128_o(seed128_big_o),
    .seed64_o(seed64_big_o),
    .seed32_o(seed32_big_o),
    .seed16_o(seed16_big_o),

    //rand num segment from each entropy source
    .rand_seg128_o(rand_seg_o[0]),
    .rand_seg64_o(rand_seg_o[1]),
    .rand_seg32_o(rand_seg_o[2]),
    .rand_seg16_o(rand_seg_o[3]),
    .cs_state_o(cs_state_o)
);


endmodule

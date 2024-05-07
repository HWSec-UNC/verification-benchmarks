module rsa_wrapper #(
	parameter int unsigned AXI_ADDR_WIDTH = 64,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH   = 10,
    parameter int unsigned MAX_PRIME_WIDTH= 1024,
    parameter int unsigned USER_PRIME_WIDTH= 32 // you can change the size here
)(
	clk_i,
    rst_ni,
    reglk_ctrl_i,
    acct_ctrl_i,
    debug_mode_i,
    axi_req_i, 
    axi_resp_o,
    rst_13
	);


	input  logic                   clk_i;
    input  logic                   rst_ni;
    input  logic                   rst_13;
    input logic [7 :0]             reglk_ctrl_i; // register lock values
    input logic                    acct_ctrl_i;
    input logic                    debug_mode_i;
    input  ariane_axi::req_t       axi_req_i;
    output ariane_axi::resp_t      axi_resp_o;

//internal signals
logic inter_rst_ni, inter_rst1_ni, encry_decry_i;
logic [MAX_PRIME_WIDTH-1:0] prime_i, prime1_i;

logic exe_finish_o, exe_finish;
logic [MAX_PRIME_WIDTH*2-1:0] msg_in, msg_out;

//signals from AXI 4 Lite
logic [AXI_ADDR_WIDTH-1:0] address;
logic                      en, en_acct;
logic                      we;
logic [63:0]               wdata;
logic [63:0]               rdata;

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
    assign exe_finish_o = (rst_13)? 1'b1 : exe_finish;
// Implement APB I/O map to AES interface
// Write side
always @(posedge clk_i)
    begin
        if(~(rst_ni && ~rst_13))
            begin
                inter_rst_ni <= 0;
                inter_rst1_ni <= 0;
                encry_decry_i <= 0;
                prime_i <= 1024'b0;
                prime1_i <= 1024'b0;
                msg_in <= 2048'b0;
                //msg_out <= 2048'b0;
				end
        else if(en && we)
        begin
            case(address[10:3])
                0: 
                    inter_rst_ni <= reglk_ctrl_i[3] ? inter_rst_ni : wdata[31:0];
                1:
                    inter_rst1_ni <= reglk_ctrl_i[3] ? inter_rst1_ni : wdata[31:0];
                2:
                    encry_decry_i <= reglk_ctrl_i[3] ? encry_decry_i : wdata[31:0];
                3:
                    prime_i[31:0] <= reglk_ctrl_i[3] ? prime_i[31:0] : wdata[31:0];
                4:
                    prime_i[63:32] <= reglk_ctrl_i[3] ? prime_i[63:32] : wdata[31:0];
                5:
                    prime_i[95:64] <= reglk_ctrl_i[3] ? prime_i[95:64] : wdata[31:0];
                6:
                    prime_i[127:96] <= reglk_ctrl_i[3] ? prime_i[127:96] : wdata[31:0];
                7:
                    prime_i[159:128] <= reglk_ctrl_i[3] ? prime_i[159:128] : wdata[31:0];
                8:
                    prime_i[191:160] <= reglk_ctrl_i[3] ? prime_i[191:160] : wdata[31:0];
                9:
                    prime_i[223:192] <= reglk_ctrl_i[3] ? prime_i[223:192] : wdata[31:0];
                10:
                    prime_i[255:224] <= reglk_ctrl_i[3] ? prime_i[255:224] : wdata[31:0];
                11:
                    prime_i[287:256] <= reglk_ctrl_i[3] ? prime_i[287:256] : wdata[31:0];
                12:
                    prime_i[319:288] <= reglk_ctrl_i[3] ? prime_i[319:288] : wdata[31:0];
                13:
                    prime_i[351:320] <= reglk_ctrl_i[3] ? prime_i[351:320] : wdata[31:0];
                14:
                    prime_i[383:352] <= reglk_ctrl_i[3] ? prime_i[383:352] : wdata[31:0];
                15:
                    prime_i[415:384] <= reglk_ctrl_i[3] ? prime_i[415:384] : wdata[31:0];
                16:
                    prime_i[447:416] <= reglk_ctrl_i[3] ? prime_i[447:416] : wdata[31:0];
                17:
                    prime_i[479:448] <= reglk_ctrl_i[3] ? prime_i[479:448] : wdata[31:0];
                18:
                    prime_i[511:480] <= reglk_ctrl_i[3] ? prime_i[511:480] : wdata[31:0];
                19:
                    prime_i[543:512] <= reglk_ctrl_i[3] ? prime_i[543:512] : wdata[31:0];
                20:
                    prime_i[575:544] <= reglk_ctrl_i[3] ? prime_i[575:544] : wdata[31:0];
                21:
                    prime_i[607:576] <= reglk_ctrl_i[3] ? prime_i[607:576] : wdata[31:0];
                22:
                    prime_i[639:608] <= reglk_ctrl_i[3] ? prime_i[639:608] : wdata[31:0];
                23:
                    prime_i[671:640] <= reglk_ctrl_i[3] ? prime_i[671:640] : wdata[31:0];
                24:
                    prime_i[703:672] <= reglk_ctrl_i[3] ? prime_i[703:672] : wdata[31:0];
                25:
                    prime_i[735:704] <= reglk_ctrl_i[3] ? prime_i[735:704] : wdata[31:0];
                26:
                    prime_i[767:736] <= reglk_ctrl_i[3] ? prime_i[767:736] : wdata[31:0];
                27:
                    prime_i[799:768] <= reglk_ctrl_i[3] ? prime_i[799:768] : wdata[31:0];
                28:
                    prime_i[831:800] <= reglk_ctrl_i[3] ? prime_i[831:800] : wdata[31:0];
                29:
                    prime_i[863:832] <= reglk_ctrl_i[3] ? prime_i[863:832] : wdata[31:0];
                30:
                    prime_i[895:864] <= reglk_ctrl_i[3] ? prime_i[895:864] : wdata[31:0];
                31:
                    prime_i[927:896] <= reglk_ctrl_i[3] ? prime_i[927:896] : wdata[31:0];
                32:
                    prime_i[959:928] <= reglk_ctrl_i[3] ? prime_i[959:928] : wdata[31:0];
                33:
                    prime_i[991:960] <= reglk_ctrl_i[3] ? prime_i[991:960] : wdata[31:0];
                34:
                    prime_i[1023:992] <= reglk_ctrl_i[3] ? prime_i[1023:992] : wdata[31:0];    
                
                35:
                    prime1_i[31:0] <= reglk_ctrl_i[3] ? prime1_i[31:0] : wdata[31:0];
                36:
                    prime1_i[63:32] <= reglk_ctrl_i[3] ? prime1_i[63:32] : wdata[31:0];
                37:
                    prime1_i[95:64] <= reglk_ctrl_i[3] ? prime1_i[95:64] : wdata[31:0];
                38:
                    prime1_i[127:96] <= reglk_ctrl_i[3] ? prime1_i[127:96] : wdata[31:0];
                39:
                    prime1_i[159:128] <= reglk_ctrl_i[3] ? prime1_i[159:128] : wdata[31:0];
                40:
                    prime1_i[191:160] <= reglk_ctrl_i[3] ? prime1_i[191:160] : wdata[31:0];
                41:
                    prime1_i[223:192] <= reglk_ctrl_i[3] ? prime1_i[223:192] : wdata[31:0];
                42:
                    prime1_i[255:224] <= reglk_ctrl_i[3] ? prime1_i[255:224] : wdata[31:0];
                43:
                    prime1_i[287:256] <= reglk_ctrl_i[3] ? prime1_i[287:256] : wdata[31:0];
                44:
                    prime1_i[319:288] <= reglk_ctrl_i[3] ? prime1_i[319:288] : wdata[31:0];
                45:
                    prime1_i[351:320] <= reglk_ctrl_i[3] ? prime1_i[351:320] : wdata[31:0];
                46:
                    prime1_i[383:352] <= reglk_ctrl_i[3] ? prime1_i[383:352] : wdata[31:0];
                47:
                    prime1_i[415:384] <= reglk_ctrl_i[3] ? prime1_i[415:384] : wdata[31:0];
                48:
                    prime1_i[447:416] <= reglk_ctrl_i[3] ? prime1_i[447:416] : wdata[31:0];
                49:
                    prime1_i[479:448] <= reglk_ctrl_i[3] ? prime1_i[479:448] : wdata[31:0];
                50:
                    prime1_i[511:480] <= reglk_ctrl_i[3] ? prime1_i[511:480] : wdata[31:0];
                51:
                    prime1_i[543:512] <= reglk_ctrl_i[3] ? prime1_i[543:512] : wdata[31:0];
                52:
                    prime1_i[575:544] <= reglk_ctrl_i[3] ? prime1_i[575:544] : wdata[31:0];
                53:
                    prime1_i[607:576] <= reglk_ctrl_i[3] ? prime1_i[607:576] : wdata[31:0];
                54:
                    prime1_i[639:608] <= reglk_ctrl_i[3] ? prime1_i[639:608] : wdata[31:0];
                55:
                    prime1_i[671:640] <= reglk_ctrl_i[3] ? prime1_i[671:640] : wdata[31:0];
                56:
                    prime1_i[703:672] <= reglk_ctrl_i[3] ? prime1_i[703:672] : wdata[31:0];
                57:
                    prime1_i[735:704] <= reglk_ctrl_i[3] ? prime1_i[735:704] : wdata[31:0];
                58:
                    prime1_i[767:736] <= reglk_ctrl_i[3] ? prime1_i[767:736] : wdata[31:0];
                59:
                    prime1_i[799:768] <= reglk_ctrl_i[3] ? prime1_i[799:768] : wdata[31:0];
                60:
                    prime1_i[831:800] <= reglk_ctrl_i[3] ? prime1_i[831:800] : wdata[31:0];
                61:
                    prime1_i[863:832] <= reglk_ctrl_i[3] ? prime1_i[863:832] : wdata[31:0];
                62:
                    prime1_i[895:864] <= reglk_ctrl_i[3] ? prime1_i[895:864] : wdata[31:0];
                63:
                    prime1_i[927:896] <= reglk_ctrl_i[3] ? prime1_i[927:896] : wdata[31:0];
                64:
                    prime1_i[959:928] <= reglk_ctrl_i[3] ? prime1_i[959:928] : wdata[31:0];
                65:
                    prime1_i[991:960] <= reglk_ctrl_i[3] ? prime1_i[991:960] : wdata[31:0];
                66:
                    prime1_i[1023:992] <= reglk_ctrl_i[3] ? prime1_i[1023:992] : wdata[31:0];

                67:
                    msg_in[31:0] <= reglk_ctrl_i[3] ? msg_in[31:0] : wdata[31:0];
                68:
                    msg_in[63:32] <= reglk_ctrl_i[3] ? msg_in[63:32] : wdata[31:0];
                69:
                    msg_in[95:64] <= reglk_ctrl_i[3] ? msg_in[95:64] : wdata[31:0];
                70:
                    msg_in[127:96] <= reglk_ctrl_i[3] ? msg_in[127:96] : wdata[31:0];
                71:
                    msg_in[159:128] <= reglk_ctrl_i[3] ? msg_in[159:128] : wdata[31:0];
                72:
                    msg_in[191:160] <= reglk_ctrl_i[3] ? msg_in[191:160] : wdata[31:0];
                73:
                    msg_in[223:192] <= reglk_ctrl_i[3] ? msg_in[223:192] : wdata[31:0];
                74:
                    msg_in[255:224] <= reglk_ctrl_i[3] ? msg_in[255:224] : wdata[31:0];
                75:
                    msg_in[287:256] <= reglk_ctrl_i[3] ? msg_in[287:256] : wdata[31:0];
                76:
                    msg_in[319:288] <= reglk_ctrl_i[3] ? msg_in[319:288] : wdata[31:0];
                77:
                    msg_in[351:320] <= reglk_ctrl_i[3] ? msg_in[351:320] : wdata[31:0];
                78:
                    msg_in[383:352] <= reglk_ctrl_i[3] ? msg_in[383:352] : wdata[31:0];
                79:
                    msg_in[415:384] <= reglk_ctrl_i[3] ? msg_in[415:384] : wdata[31:0];
                80:
                    msg_in[447:416] <= reglk_ctrl_i[3] ? msg_in[447:416] : wdata[31:0];
                81:
                    msg_in[479:448] <= reglk_ctrl_i[3] ? msg_in[479:448] : wdata[31:0];
                82:
                    msg_in[511:480] <= reglk_ctrl_i[3] ? msg_in[511:480] : wdata[31:0];
                83:
                    msg_in[543:512] <= reglk_ctrl_i[3] ? msg_in[543:512] : wdata[31:0];
                84:
                    msg_in[575:544] <= reglk_ctrl_i[3] ? msg_in[575:544] : wdata[31:0];
                85:
                    msg_in[607:576] <= reglk_ctrl_i[3] ? msg_in[607:576] : wdata[31:0];
                86:
                    msg_in[639:608] <= reglk_ctrl_i[3] ? msg_in[639:608] : wdata[31:0];
                87:
                    msg_in[671:640] <= reglk_ctrl_i[3] ? msg_in[671:640] : wdata[31:0];
                88:
                    msg_in[703:672] <= reglk_ctrl_i[3] ? msg_in[703:672] : wdata[31:0];
                89:
                    msg_in[735:704] <= reglk_ctrl_i[3] ? msg_in[735:704] : wdata[31:0];
                90:
                    msg_in[767:736] <= reglk_ctrl_i[3] ? msg_in[767:736] : wdata[31:0];
                91:
                    msg_in[799:768] <= reglk_ctrl_i[3] ? msg_in[799:768] : wdata[31:0];
                92:
                    msg_in[831:800] <= reglk_ctrl_i[3] ? msg_in[831:800] : wdata[31:0];
                93:
                    msg_in[863:832] <= reglk_ctrl_i[3] ? msg_in[863:832] : wdata[31:0];
                94:
                    msg_in[895:864] <= reglk_ctrl_i[3] ? msg_in[895:864] : wdata[31:0];
                95:
                    msg_in[927:896] <= reglk_ctrl_i[3] ? msg_in[927:896] : wdata[31:0];
                96:
                    msg_in[959:928] <= reglk_ctrl_i[3] ? msg_in[959:928] : wdata[31:0];
                97:
                    msg_in[991:960] <= reglk_ctrl_i[3] ? msg_in[991:960] : wdata[31:0];
                98:
                    msg_in[1023:992] <= reglk_ctrl_i[3] ? msg_in[1023:992] : wdata[31:0];
                99:
                    msg_in[1055:1024] <= reglk_ctrl_i[3] ? msg_in[1055:1024] : wdata[31:0];
                100:
                    msg_in[1087:1056] <= reglk_ctrl_i[3] ? msg_in[1087:1056] : wdata[31:0];
                101:
                    msg_in[1119:1088] <= reglk_ctrl_i[3] ? msg_in[1087:1056] : wdata[31:0];
                102:
                    msg_in[1151:1120] <= reglk_ctrl_i[3] ? msg_in[1151:1120] : wdata[31:0];
                103:
                    msg_in[1183:1152] <= reglk_ctrl_i[3] ? msg_in[1183:1152] : wdata[31:0];
                104:
                    msg_in[1215:1184] <= reglk_ctrl_i[3] ? msg_in[1215:1184] : wdata[31:0];
                105:
                    msg_in[1247:1216] <= reglk_ctrl_i[3] ? msg_in[1247:1216] : wdata[31:0];
                106:
                    msg_in[1279:1248] <= reglk_ctrl_i[3] ? msg_in[1279:1248] : wdata[31:0];
                107:
                    msg_in[1311:1280] <= reglk_ctrl_i[3] ? msg_in[1311:1280] : wdata[31:0];
                108:
                    msg_in[1343:1312] <= reglk_ctrl_i[3] ? msg_in[1343:1312] : wdata[31:0];
                109:
                    msg_in[1375:1344] <= reglk_ctrl_i[3] ? msg_in[1375:1344] : wdata[31:0];
                110:
                    msg_in[1407:1376] <= reglk_ctrl_i[3] ? msg_in[1407:1376] : wdata[31:0];
                111:
                    msg_in[1439:1408] <= reglk_ctrl_i[3] ? msg_in[1439:1408] : wdata[31:0];
                112:
                    msg_in[1471:1440] <= reglk_ctrl_i[3] ? msg_in[1471:1440] : wdata[31:0];
                113:
                    msg_in[1503:1472] <= reglk_ctrl_i[3] ? msg_in[1503:1472] : wdata[31:0];
                114:
                    msg_in[1535:1504] <= reglk_ctrl_i[3] ? msg_in[1535:1504] : wdata[31:0];
                115:
                    msg_in[1567:1536] <= reglk_ctrl_i[3] ? msg_in[1567:1536] : wdata[31:0];
                116:
                    msg_in[1599:1568] <= reglk_ctrl_i[3] ? msg_in[1599:1568] : wdata[31:0];
                117:
                    msg_in[1631:1600] <= reglk_ctrl_i[3] ? msg_in[1631:1600] : wdata[31:0];
                118:
                    msg_in[1663:1632] <= reglk_ctrl_i[3] ? msg_in[1663:1632] : wdata[31:0];
                119:
                    msg_in[1695:1664] <= reglk_ctrl_i[3] ? msg_in[1695:1664] : wdata[31:0];
                120:
                    msg_in[1727:1696] <= reglk_ctrl_i[3] ? msg_in[1727:1696] : wdata[31:0];
                121:
                    msg_in[1759:1728] <= reglk_ctrl_i[3] ? msg_in[1759:1728] : wdata[31:0];
                122:
                    msg_in[1791:1760] <= reglk_ctrl_i[3] ? msg_in[1791:1760] : wdata[31:0];
                123:
                    msg_in[1823:1792] <= reglk_ctrl_i[3] ? msg_in[1823:1792] : wdata[31:0];
                124:
                    msg_in[1855:1824] <= reglk_ctrl_i[3] ? msg_in[1855:1824] : wdata[31:0];
                125:
                    msg_in[1887:1856] <= reglk_ctrl_i[3] ? msg_in[1887:1856] : wdata[31:0];
                126:
                    msg_in[1919:1888] <= reglk_ctrl_i[3] ? msg_in[1919:1888] : wdata[31:0];
                127:
                    msg_in[1951:1920] <= reglk_ctrl_i[3] ? msg_in[1951:1920] : wdata[31:0];
                128:
                    msg_in[1983:1952] <= reglk_ctrl_i[3] ? msg_in[1983:1952] : wdata[31:0];
                129:
                    msg_in[2015:1984] <= reglk_ctrl_i[3] ? msg_in[2015:1984] : wdata[31:0];
                130:
                    msg_in[2047:2016] <= reglk_ctrl_i[3] ? msg_in[2047:2016] : wdata[31:0];    
                default:
                    ;
            endcase // address[10:3]
        end
    end 

// Implement MD5 I/O memory map interface
// Read side
always @(*)
    begin
        rdata = 64'b0;
        if(en) begin
            case(address[10:3]) 
                131:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[31:0];
                132:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[63:32];
                133:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[95:64];
                134:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[127:96];
                135:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[159:128];
                136:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[191:160];
                137:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[223:192];
                138:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[255:224];
                139:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[287:256];
                140:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[319:288];
                141:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[351:320];
                142:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[383:352];
                143:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[415:384];
                144:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[447:416];
                145:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[479:448];
                146:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[511:480];
                147:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[543:512];
                148:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[575:544];
                149:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[607:576];
                150:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[639:608];
                151:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[671:640];
                152:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[703:672];
                153:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[735:704];
                154:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[767:736];
                155:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[799:768];
                156:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[831:800];
                157:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[863:832];
                158:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[895:864];
                159:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[927:896];
                160:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[959:928];
                161:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[991:960];
                162:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1023:992];
                163:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1055:1024];
                164:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1087:1056];
                165:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1119:1088];
                166:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1151:1120];
                167:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1183:1152];
                168:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1215:1184];
                169:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1247:1216];
                170:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1279:1248];
                171:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1311:1280];
                172:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1343:1312];
                173:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1375:1344];
                174:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1407:1376];
                175:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1439:1408];
                176:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1471:1440];
                177:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1503:1472];
                178:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1535:1504];
                179:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1567:1536];
                180:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1599:1568];
                181:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1631:1600];
                182:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1663:1632];
                183:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1695:1664];
                184:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1727:1696];
                185:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1759:1728];
                186:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1791:1760];
                187:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1823:1792];
                188:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1855:1824];
                189:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1887:1856];
                190:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1919:1888];
                191:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1951:1920];
                192:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[1983:1952];
                193:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[2015:1984];
                194:
                    rdata = reglk_ctrl_i[3] ? 0 : msg_out[2047:2016];
                195:
                    rdata = reglk_ctrl_i[3] ? 0 : exe_finish_o;
                default:
                    rdata = 64'b0;
            endcase // address[10:3]
        end //if
    end

rsa_top #(
        .WIDTH ( USER_PRIME_WIDTH )
    )rsa0(
    .clk(clk_i),
    .rst_n(inter_rst_ni && ~rst_13),
    .rst1_n(inter_rst1_ni && ~rst_13),
    .encrypt_decrypt_i(encry_decry_i),
    .p_i(prime_i[USER_PRIME_WIDTH-1:0]),
    .q_i(prime1_i[USER_PRIME_WIDTH-1:0]),
    .msg_in(msg_in[USER_PRIME_WIDTH*2-1:0]),
    .msg_out(msg_out[USER_PRIME_WIDTH*2-1:0]),
    .mod_exp_finish_o(exe_finish)
);

endmodule

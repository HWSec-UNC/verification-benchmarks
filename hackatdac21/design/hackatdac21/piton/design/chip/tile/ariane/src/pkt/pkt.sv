 /*
 * Peripheral Key Table (PKT) takes the fuse mem index and returns the actual destination address
 * for that FUSE data
 */



module pkt (
   input  logic         clk_i,
   input  logic         rst_ni,
   input  logic         req_i,
   input  logic [31:0]  fuse_indx_i, // peripheral index of the key
   output logic [63:0]  pkey_loc_o // peripheral key location in ROM2 as the output
);

    parameter FUSE_MEM_SIZE = 100;

// Store dest address values here. 
    const logic [FUSE_MEM_SIZE-1:0][63:0] fuse_indx_mem = {
        //// JTAG (only a place holder, JTAG hash is not mapped to AXI mem)
        //ariane_soc::JTAGHASH,
        //RNG poly
        ariane_soc::RNGPoly128_3,
        ariane_soc::RNGPoly128_2,
        ariane_soc::RNGPoly128_1,
        ariane_soc::RNGPoly128_0,
        ariane_soc::RNGPoly64_1,
        ariane_soc::RNGPoly64_0,
        ariane_soc::RNGPoly32_0,
        ariane_soc::RNGPoly16_0,
        //HMAC okey hash
        ariane_soc::HMACoKeyHash_7, 
        ariane_soc::HMACoKeyHash_6, 
        ariane_soc::HMACoKeyHash_5, 
        ariane_soc::HMACoKeyHash_4, 
        ariane_soc::HMACoKeyHash_3, 
        ariane_soc::HMACoKeyHash_2, 
        ariane_soc::HMACoKeyHash_1, 
        ariane_soc::HMACoKeyHash_0, 
        //HMAC ikey hash
        ariane_soc::HMACiKeyHash_7, 
        ariane_soc::HMACiKeyHash_6, 
        ariane_soc::HMACiKeyHash_5, 
        ariane_soc::HMACiKeyHash_4, 
        ariane_soc::HMACiKeyHash_3, 
        ariane_soc::HMACiKeyHash_2, 
        ariane_soc::HMACiKeyHash_1, 
        ariane_soc::HMACiKeyHash_0, 
        //HMAC key 
        ariane_soc::HMACKey_7, 
        ariane_soc::HMACKey_6, 
        ariane_soc::HMACKey_5, 
        ariane_soc::HMACKey_4, 
        ariane_soc::HMACKey_3, 
        ariane_soc::HMACKey_2, 
        ariane_soc::HMACKey_1, 
        ariane_soc::HMACKey_0, 
        // Access control for master 2. First 4 bits for peripheral 0, next 4 for p1 and so on.
        ariane_soc::ACCT_M_22, 
        ariane_soc::ACCT_M_21, 
        ariane_soc::ACCT_M_20, 
        // Access control for master 1. First 4 bits for peripheral 0, next 4 for p1 and so on.
        ariane_soc::ACCT_M_12, 
        ariane_soc::ACCT_M_11, 
        ariane_soc::ACCT_M_10, 
        // Access control for master 0. First 4 bits for peripheral 0, next 4 for p1 and so on.
        ariane_soc::ACCT_M_02, 
        ariane_soc::ACCT_M_01, 
        ariane_soc::ACCT_M_00, 
        // SHA Key
        ariane_soc::SHA256Key_5,
        ariane_soc::SHA256Key_4,
        ariane_soc::SHA256Key_3,
        ariane_soc::SHA256Key_2,
        ariane_soc::SHA256Key_1,
        ariane_soc::SHA256Key_0,
        // AES2 Key 2
        ariane_soc::AES2Key2_3,
        ariane_soc::AES2Key2_2,
        ariane_soc::AES2Key2_1,
        ariane_soc::AES2Key2_0,   // address for LSB 32 bits
        // AES2 Key 1
        ariane_soc::AES2Key1_3,
        ariane_soc::AES2Key1_2,
        ariane_soc::AES2Key1_1,
        ariane_soc::AES2Key1_0,   // address for LSB 32 bits
        // AES2 Key 0
        ariane_soc::AES2Key0_3,
        ariane_soc::AES2Key0_2,
        ariane_soc::AES2Key0_1,
        ariane_soc::AES2Key0_0,   // address for LSB 32 bits
        // AES1 Key 2
        ariane_soc::AES1Key2_7,
        ariane_soc::AES1Key2_6,
        ariane_soc::AES1Key2_5,
        ariane_soc::AES1Key2_4,
        ariane_soc::AES1Key2_3,
        ariane_soc::AES1Key2_2,
        ariane_soc::AES1Key2_1,
        ariane_soc::AES1Key2_0,   // address for LSB 32 bits
        // AES1 Key 1
        ariane_soc::AES1Key1_7,
        ariane_soc::AES1Key1_6,
        ariane_soc::AES1Key1_5,
        ariane_soc::AES1Key1_4,
        ariane_soc::AES1Key1_3,
        ariane_soc::AES1Key1_2,
        ariane_soc::AES1Key1_1,
        ariane_soc::AES1Key1_0,   // address for LSB 32 bits
        // AES1 Key 0
        ariane_soc::AES1Key0_7,
        ariane_soc::AES1Key0_6,
        ariane_soc::AES1Key0_5,
        ariane_soc::AES1Key0_4,
        ariane_soc::AES1Key0_3,
        ariane_soc::AES1Key0_2,
        ariane_soc::AES1Key0_1,
        ariane_soc::AES1Key0_0,   // address for LSB 32 bits
        // AES Key 2
        ariane_soc::AES0Key2_5,
        ariane_soc::AES0Key2_4,
        ariane_soc::AES0Key2_3,
        ariane_soc::AES0Key2_2,
        ariane_soc::AES0Key2_1,
        ariane_soc::AES0Key2_0,   // address for LSB 32 bits
        // AES Key 1
        ariane_soc::AES0Key1_5,
        ariane_soc::AES0Key1_4,
        ariane_soc::AES0Key1_3,
        ariane_soc::AES0Key1_2,
        ariane_soc::AES0Key1_1,
        ariane_soc::AES0Key1_0,   // address for LSB 32 bits
        // AES Key 0
        ariane_soc::AES0Key0_5,
        ariane_soc::AES0Key0_4,
        ariane_soc::AES0Key0_3,
        ariane_soc::AES0Key0_2,
        ariane_soc::AES0Key0_1,
        ariane_soc::AES0Key0_0    // address for LSB 32 bits
        
        // ADD AES2
    };

    logic [$clog2(FUSE_MEM_SIZE)-1:0] fuse_indx_q;
    
    always_ff @(posedge clk_i) begin
        if (req_i) begin
            fuse_indx_q <= fuse_indx_i[$clog2(FUSE_MEM_SIZE)-1:0];
        end
    end

    // this prevents spurious Xes from propagating into
    // the speculative fetch stage of the core
    assign pkey_loc_o = (fuse_indx_q < FUSE_MEM_SIZE) ? fuse_indx_mem[fuse_indx_q] : 64'hffffffff;


endmodule

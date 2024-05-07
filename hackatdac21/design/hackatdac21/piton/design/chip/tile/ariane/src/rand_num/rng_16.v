module rng_16(
    input               clk,
    input             rst_n,
    input             load_i,
    input      [15:0]   seed_i,
    input      [15:0]   poly_i,
    output     [15:0]   entropy16_o,
    output              entropy16_valid_o
);


reg in_sr, entropy16_valid;
reg [15:0] entropy16;

assign entropy16_o = entropy16;
assign entropy16_valid_o = entropy16_valid;


always @ (*)
begin
    in_sr = ^ (poly_i [15:0] & entropy16 [15:0]);
end

always@(posedge clk or negedge rst_n)
begin
    
    if(!rst_n)
    begin
        entropy16    <= 16'b0;
        entropy16_valid <= 0;  
    end
    else if(load_i)
    begin
        entropy16 <=seed_i;
        entropy16_valid <= 0;   
    end
    else
        begin
            entropy16[14:0] <= entropy16[15:1];
            entropy16[15] <= in_sr;
            entropy16_valid <= 1;
        end

end
endmodule
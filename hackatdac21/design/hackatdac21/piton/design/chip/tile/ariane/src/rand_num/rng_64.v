module rng_64(
    input               clk,
    input             rst_n,
    input             load_i,
    input      [63:0]   seed_i,
    input      [63:0]   poly_i,
    output     [63:0] entropy64_o,
    output              entropy64_valid_o
);


reg in_sr, entropy64_valid;
reg [63:0] entropy64;

assign entropy64_o = entropy64;
assign entropy64_valid_o = entropy64_valid;


always @ (*)
begin
    in_sr = ^ (poly_i [63:0] & entropy64 [63:0]);
end

always@(posedge clk or negedge rst_n)
begin
    
    if(!rst_n)
    begin
        entropy64    <= 0;
        entropy64_valid <= 0;  
    end
    
    else if(load_i)
    begin
        entropy64 <=seed_i;
        entropy64_valid <= 0;   
    end
    else
        begin
            entropy64[62:0] <= entropy64[63:1];
            entropy64[63] <= in_sr;
            entropy64_valid <= 1;
        end

end
endmodule

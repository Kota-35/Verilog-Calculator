// BINARY TO BCD
module BIN2BCD	( 
    input [23:0] bin_in,      // 2進数入力
    output reg [23:0] bcd_out // BCD出力
);

integer i;
reg [23:0] bin;
reg [23:0] bcd;

always @(*) begin
    // 初期化
    bin = bin_in;
    bcd = 0;
    
    // Double dabble アルゴリズム
    for (i = 0; i < 24; i = i + 1) begin
        // 3以上の桁に3を足す
        if (bcd[23:20] >= 5) bcd[23:20] = bcd[23:20] + 3;
        if (bcd[19:16] >= 5) bcd[19:16] = bcd[19:16] + 3;
        if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
        if (bcd[11:8]  >= 5) bcd[11:8]  = bcd[11:8] + 3;
        if (bcd[7:4]   >= 5) bcd[7:4]   = bcd[7:4] + 3;
        if (bcd[3:0]   >= 5) bcd[3:0]   = bcd[3:0] + 3;
        
        // 左シフト
        bcd = {bcd[22:0], bin[23]};
        bin = {bin[22:0], 1'b0};
    end
    
    bcd_out = bcd;
end

endmodule

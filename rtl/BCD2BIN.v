// BCD TO BINARY
module BCD2BIN	( 
    input [23:0] bcd_in,    // 6桁のBCD入力
    output reg [23:0] bin_out  // 2進数出力
);

reg [3:0] digit5;
reg [3:0] digit4;
reg [3:0] digit3;
reg [3:0] digit2;
reg [3:0] digit1;
reg [3:0] digit0;

always @(*) begin
    // 各桁のBCD値を取り出す
    digit5 = bcd_in[23:20]; // 最上位桁
    digit4 = bcd_in[19:16];
    digit3 = bcd_in[15:12];
    digit2 = bcd_in[11:8];
    digit1 = bcd_in[7:4];
    digit0 = bcd_in[3:0];   // 最下位桁

    // 2進数に変換
    bin_out = (digit5 * 100000) +
              (digit4 * 10000) +
              (digit3 * 1000) +
              (digit2 * 100) +
              (digit1 * 10) +
              digit0;
end

endmodule

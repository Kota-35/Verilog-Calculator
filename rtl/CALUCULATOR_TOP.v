// --------------------------------------------------------------------
//
// Major Functions:	CALUCULATOR_TOP
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author                    :| Mod. Date :| Changes Made:
//   V1.0 :| Koh Johguchi              :| 12/17/19  :| Shinshu Univ. 
// --------------------------------------------------------------------
module CALUCULATOR_TOP(
           iSTART,   //press the button for transmitting instrucions to device;
           iRST_n,   //FSM reset signal;
           iCLK_50,  //clock source;
           PS2_CLK,  //ps2_clock signal inout;
           PS2_DAT,  //ps2_data  signal inout;
           oLEFBUT,  //left button press display;
           oRIGBUT,  //right button press display;
           oMIDBUT,  //middle button press display;
           oX_MOV1,  //lower  SEG of mouse displacement display for X axis.
           oX_MOV2,  //higher SEG of mouse displacement display for X axis.
           oY_MOV1,  //lower  SEG of mouse displacement display for Y axis.
           oY_MOV2,  //higher SEG of mouse displacement display for Y axis.
           oZ_MOV1,  //lower  SEG of mouse displacement display for Z axis.
           oZ_MOV2   //higher SEG of mouse displacement display for Z axis.
           ); 

input iSTART;
input iRST_n;
input iCLK_50;

inout PS2_CLK;
inout PS2_DAT;

output oLEFBUT;
output oRIGBUT;
output oMIDBUT;
output [6:0] oX_MOV1;
output [6:0] oX_MOV2;
output [6:0] oY_MOV1;
output [6:0] oY_MOV2;
output [6:0] oZ_MOV1;
output [6:0] oZ_MOV2;

wire PS2_READY;
wire [15:0] SCANCODE;
wire clk;

// 状態を表す定数
localparam IDLE = 2'd0;
localparam FIRST_NUM = 2'd1;
localparam SECOND_NUM = 2'd2;
localparam RESULT = 2'd3;

// レジスタ
reg [1:0] state;
reg [23:0] first_num_bcd;    // BCDフォーマットの入力
reg [23:0] second_num_bcd;   // BCDフォーマットの入力
reg [23:0] result_bin;       // 2進数フォーマットの結果
reg [23:0] remainder_bin;    // 2進数フォーマットの余り
reg [1:0] op;               // 演算子 (00:なし, 01:加算, 10:減算, 11:乗算, 00:除算)
reg [3:0] current_digit;
reg is_division;
reg show_remainder;         // 余りを表示するためのフラグ
reg error_state;           // エラー状態を示すフラグ
reg is_negative;           // 負の数を示すフラグ

// BCD変換用の信号線
wire [23:0] first_num_bin;   // 2進数に変換された最初の数
wire [23:0] second_num_bin;  // 2進数に変換された2番目の数
wire [23:0] result_bcd;      // BCDに変換された結果
wire [23:0] remainder_bcd;   // BCDに変換された余り



// BCD⇔BIN変換モジュールのインスタンス化
BCD2BIN u_bcd2bin_first(
    .bcd_in(first_num_bcd),
    .bin_out(first_num_bin)
);

BCD2BIN u_bcd2bin_second(
    .bcd_in(second_num_bcd),
    .bin_out(second_num_bin)
);

BIN2BCD u_bin2bcd_result(
    .bin_in(result_bin),
    .bcd_out(result_bcd)
);

BIN2BCD u_bin2bcd_remainder(
    .bin_in(remainder_bin),
    .bcd_out(remainder_bcd)
);

reg ignore_text;
// PS/2キーボードの入力処理
always @(posedge clk or negedge iRST_n) begin
    if (!iRST_n) begin
        state <= IDLE;
        first_num_bcd <= 24'd0;
        second_num_bcd <= 24'd0;
        result_bin <= 24'd0;
        remainder_bin <= 24'd0;
        op <= 2'b00;
        current_digit <= 4'h0;
        is_division <= 1'b0;
        show_remainder <= 1'b0;
        ignore_text <= 1'b0;
        error_state <= 1'b0;  // エラー状態の初期化
        is_negative <= 1'b0;  // 負のフラグをリセット
    end else if ( !PS2_READY ) begin
        // PS2_READYが0になり、新しい1バイトがSCANCODEに入ったら
        if (SCANCODE[7:0] == 8'hF0) begin

            ignore_text <= 1'b1;
        end else if (ignore_text) begin
            
            ignore_text <= 1'b0;
        end else begin
            // ここで初めて押下として処理する
            case (SCANCODE[7:0])
                // 数字キー
                8'h70: begin  // 0
                    if (!ignore_text) begin
                        current_digit <= 4'h0;
                        case (state)
                            IDLE: begin
                                first_num_bcd <= 24'd0;
                                state <= FIRST_NUM;
                            end
                            FIRST_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (first_num_bcd[23:20] == 4'h0)
                                    first_num_bcd <= {first_num_bcd[19:0], 4'h0};
                            end
                            SECOND_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (second_num_bcd[23:20] == 4'h0)
                                    second_num_bcd <= {second_num_bcd[19:0], 4'h0};
                            end
                        endcase
                    end
                end
                8'h69: begin  // 1
                    if (!ignore_text) begin
                        current_digit <= 4'h1;
                        case (state)
                            IDLE: begin
                                first_num_bcd <= 24'd1;
                                state <= FIRST_NUM;
                            end
                            FIRST_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (first_num_bcd[23:20] == 4'h0)
                                    first_num_bcd <= {first_num_bcd[19:0], 4'h1};
                            end
                            SECOND_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (second_num_bcd[23:20] == 4'h0)
                                    second_num_bcd <= {second_num_bcd[19:0], 4'h1};
                            end
                        endcase
                    end
                end
                8'h72: begin  // 2
                    if (!ignore_text) begin
                        current_digit <= 4'h2;
                        case (state)
                            IDLE: begin
                                first_num_bcd <= 24'd2;
                                state <= FIRST_NUM;
                            end
                            FIRST_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (first_num_bcd[23:20] == 4'h0)
                                    first_num_bcd <= {first_num_bcd[19:0], 4'h2};
                            end
                            SECOND_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (second_num_bcd[23:20] == 4'h0)
                                    second_num_bcd <= {second_num_bcd[19:0], 4'h2};
                            end
                        endcase
                    end
                end
                8'h7A: begin  // 3
                    if (!ignore_text) begin
                        current_digit <= 4'h3;
                        case (state)
                            IDLE: begin
                                first_num_bcd <= 24'd3;
                                state <= FIRST_NUM;
                            end
                            FIRST_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (first_num_bcd[23:20] == 4'h0)
                                    first_num_bcd <= {first_num_bcd[19:0], 4'h3};
                            end
                            SECOND_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (second_num_bcd[23:20] == 4'h0)
                                    second_num_bcd <= {second_num_bcd[19:0], 4'h3};
                            end
                        endcase
                    end
                end
                8'h6B: begin  // 4
                    if (!ignore_text) begin
                        current_digit <= 4'h4;
                        case (state)
                            IDLE: begin
                                first_num_bcd <= 24'd4;
                                state <= FIRST_NUM;
                            end
                            FIRST_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (first_num_bcd[23:20] == 4'h0)
                                    first_num_bcd <= {first_num_bcd[19:0], 4'h4};
                            end
                            SECOND_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (second_num_bcd[23:20] == 4'h0)
                                    second_num_bcd <= {second_num_bcd[19:0], 4'h4};
                            end
                        endcase
                    end
                end
                8'h73: begin  // 5
                    if (!ignore_text) begin
                        current_digit <= 4'h5;
                        case (state)
                            IDLE: begin
                                first_num_bcd <= 24'd5;
                                state <= FIRST_NUM;
                            end
                            FIRST_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (first_num_bcd[23:20] == 4'h0)
                                    first_num_bcd <= {first_num_bcd[19:0], 4'h5};
                            end
                            SECOND_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (second_num_bcd[23:20] == 4'h0)
                                    second_num_bcd <= {second_num_bcd[19:0], 4'h5};
                            end
                        endcase
                    end
                end
                8'h74: begin  // 6
                    if (!ignore_text) begin
                        current_digit <= 4'h6;
                        case (state)
                            IDLE: begin
                                first_num_bcd <= 24'd6;
                                state <= FIRST_NUM;
                            end
                            FIRST_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (first_num_bcd[23:20] == 4'h0)
                                    first_num_bcd <= {first_num_bcd[19:0], 4'h6};
                            end
                            SECOND_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (second_num_bcd[23:20] == 4'h0)
                                    second_num_bcd <= {second_num_bcd[19:0], 4'h6};
                            end
                        endcase
                    end
                end
                8'h6C: begin  // 7
                    if (!ignore_text) begin
                        current_digit <= 4'h7;
                        case (state)
                            IDLE: begin
                                first_num_bcd <= 24'd7;
                                state <= FIRST_NUM;
                            end
                            FIRST_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (first_num_bcd[23:20] == 4'h0)
                                    first_num_bcd <= {first_num_bcd[19:0], 4'h7};
                            end
                            SECOND_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (second_num_bcd[23:20] == 4'h0)
                                    second_num_bcd <= {second_num_bcd[19:0], 4'h7};
                            end
                        endcase
                    end
                end
                8'h75: begin  // 8
                    if (!ignore_text) begin
                        current_digit <= 4'h8;
                        case (state)
                            IDLE: begin
                                first_num_bcd <= 24'd8;
                                state <= FIRST_NUM;
                            end
                            FIRST_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (first_num_bcd[23:20] == 4'h0)
                                    first_num_bcd <= {first_num_bcd[19:0], 4'h8};
                            end
                            SECOND_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (second_num_bcd[23:20] == 4'h0)
                                    second_num_bcd <= {second_num_bcd[19:0], 4'h8};
                            end
                        endcase
                    end
                end
                8'h7D: begin  // 9
                    if (!ignore_text) begin
                        current_digit <= 4'h9;
                        case (state)
                            IDLE: begin
                                first_num_bcd <= 24'd9;
                                state <= FIRST_NUM;
                            end
                            FIRST_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (first_num_bcd[23:20] == 4'h0)
                                    first_num_bcd <= {first_num_bcd[19:0], 4'h9};
                            end
                            SECOND_NUM: begin
                                // 最上位桁が0の場合のみ新しい桁を追加
                                if (second_num_bcd[23:20] == 4'h0)
                                    second_num_bcd <= {second_num_bcd[19:0], 4'h9};
                            end
                        endcase
                    end
                end

                // 演算子
                8'h79: begin  // +
                    if (state == FIRST_NUM) begin
                        state <= SECOND_NUM;
                        op <= 2'b01;
                    end
                end
                8'h7B: begin  // -
                    if (state == FIRST_NUM) begin
                        state <= SECOND_NUM;
                        op <= 2'b10;
                    end
                end
                8'h7C: begin  // *
                    if (state == FIRST_NUM) begin
                        state <= SECOND_NUM;
                        op <= 2'b11;
                    end
                end
                8'h4A: begin  // /
                    if (state == FIRST_NUM) begin
                        state <= SECOND_NUM;
                        op <= 2'b00;  // 除算用のop設定
                        is_division <= 1'b1;
                    end
                end
                8'h66: begin  // Backspace
                    case (state)
                        FIRST_NUM: begin
                            first_num_bcd <= {4'h0, first_num_bcd[23:4]};  // 1桁削除
                            if (first_num_bcd[23:4] == 20'h00000) begin  // すべての桁が0になった場合
                                state <= IDLE;  // IDLEに戻る
                            end
                        end
                        SECOND_NUM: begin
                            second_num_bcd <= {4'h0, second_num_bcd[23:4]};  // 1桁削除
                            if (second_num_bcd[23:4] == 20'h00000) begin  // すべての桁が0になった場合
                                state <= FIRST_NUM;  // 最初の数字入力に戻る
                                op <= 2'b00;
                                is_division <= 1'b0;
                            end
                        end
                    endcase
                end
                8'h29: begin  // Space
                    if (state == RESULT && is_division) begin
                        show_remainder <= ~show_remainder;
                    end
                end
                8'h5A: begin  // Enter
                    if (state == SECOND_NUM) begin
                        state <= RESULT;
                        show_remainder <= 1'b0;  // 初期状態では商を表示
                        error_state <= 1'b0;  // エラー状態をリセット
                        is_negative <= 1'b0;  // 負のフラグをリセット
                        
                        // 0除算チェック
                        if (is_division && second_num_bin == 24'd0) begin
                            error_state <= 1'b1;
                        end
                        // オーバーフローチェック
                        else begin
                            case (op)
                                2'b01: begin  // 加算
                                    // BCDでの最大値は999999
                                    if (first_num_bin + second_num_bin > 24'd999999)
                                        error_state <= 1'b1;
                                    else
                                        result_bin <= first_num_bin + second_num_bin;
                                end
                                2'b10: begin  // 減算
                                    if (first_num_bin < second_num_bin) begin
                                        // 負の数の結果が-999999を超える場合はエラー
                                        if (second_num_bin - first_num_bin > 24'd99999)
                                            error_state <= 1'b1;
                                        else begin
                                            result_bin <= second_num_bin - first_num_bin;
                                            is_negative <= 1'b1;  // 負の数フラグを設定
                                        end
                                    end else begin
                                        result_bin <= first_num_bin - second_num_bin;
                                        is_negative <= 1'b0;
                                    end
                                end
                                2'b11: begin  // 乗算
                                    // BCDでの最大値は999999
                                    if (first_num_bin * second_num_bin > 24'd999999)
                                        error_state <= 1'b1;
                                    else
                                        result_bin <= first_num_bin * second_num_bin;
                                end
                                default: begin  // 除算
                                    if (!error_state) begin
                                        result_bin <= first_num_bin / second_num_bin;
                                        remainder_bin <= first_num_bin % second_num_bin;
                                    end
                                end
                            endcase
                        end
                    end else begin
                        state <= IDLE;
                        first_num_bcd <= 24'd0;
                        second_num_bcd <= 24'd0;
                        result_bin <= 24'd0;
                        remainder_bin <= 24'd0;
                        op <= 2'b00;
                        is_division <= 1'b0;
                        error_state <= 1'b0;
                        is_negative <= 1'b0;  // 負のフラグをリセット
                    end
                end
                
                
                default: current_digit <= current_digit;
            endcase
        end 
    end else begin
        state <= state;
        first_num_bcd <= first_num_bcd;
        second_num_bcd <= second_num_bcd;
        result_bin <= result_bin;
        remainder_bin <= remainder_bin;
        op <= op;
        current_digit <= current_digit;
        is_division <= is_division;
        show_remainder <= show_remainder;
        ignore_text <= ignore_text;
        error_state <= error_state;
        is_negative <= is_negative;
    end
end

// 7セグメントLEDの表示用の値を選択
wire [23:0] display_num;
assign display_num = (error_state) ? 24'h00000E :  // エラー時は'E'を表示
                    (state == RESULT && is_negative) ? {4'hF, result_bcd[19:0]} :  // 負の数の場合、最上位桁に'-'を表示
                    (state == RESULT) ? 
                    (is_division ? (show_remainder ? remainder_bcd : result_bcd) : result_bcd) :
                    (state == SECOND_NUM) ? second_num_bcd : first_num_bcd;

// マウスボタンは未使用（0に設定）
assign oLEFBUT = 1'b0;
assign oRIGBUT = 1'b0;
assign oMIDBUT = 1'b0;

// 7セグメントLEDのインスタンス化（元のポート名を使用）
SEG7_LUT U2(.oSEG(oX_MOV1), .iDIG(display_num[3:0]));
SEG7_LUT U3(.oSEG(oX_MOV2), .iDIG(display_num[7:4]));
SEG7_LUT U4(.oSEG(oY_MOV1), .iDIG(display_num[11:8]));
SEG7_LUT U5(.oSEG(oY_MOV2), .iDIG(display_num[15:12]));
SEG7_LUT U6(.oSEG(oZ_MOV1), .iDIG(display_num[19:16]));
SEG7_LUT U7(.oSEG(oZ_MOV2), .iDIG(display_num[23:20]));

// PS/2とクロック分周器のインスタンス化
PS2 U0(
    .iSTART(iSTART),
    .iRST_n(iRST_n),
    .iCLK(clk),
    .PS2_CLK(PS2_CLK),
    .PS2_DAT(PS2_DAT),
    .PS2_READY(PS2_READY),
    .SCANCODE(SCANCODE)
);

CLKDIV U1(
    .iCLK(iCLK_50),
    .RSTB(iRST_n),
    .oCLK(clk)
);

endmodule


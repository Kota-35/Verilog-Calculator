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
           //interface;
//=======================================================
//  PORT declarations
//=======================================================

input iSTART;
input iRST_n;
input iCLK_50;

inout PS2_CLK;
inout PS2_DAT;

output oLEFBUT;
output oRIGBUT;
output oMIDBUT;
output [6:0]  oX_MOV1;
output [6:0]  oX_MOV2;
output [6:0]  oY_MOV1;
output [6:0]  oY_MOV2;
output [6:0]  oZ_MOV1;
output [6:0]  oZ_MOV2;

wire          PS2_READY;
wire   [15:0] SCANCODE;

reg    [7:0]  x_latch, y_latch,z_latch;
wire          clk;

// 自分で定義した変数
reg [3:0] num = 4'h0;
reg [1:0] operator = 2'd0;
reg is_digit = 0;
reg is_enter = 0;
reg [23:0] display_num = 24'd0;


always @ (*) begin
   case(SCANCODE[7:0])
      // テンキーの数字のスキャンコード
      8'h70: begin num <= 4'h0; is_digit <= 1; end // 0
      8'h69: begin num <= 4'h1; is_digit <= 1; end // 1
      8'h72: begin num <= 4'h2; is_digit <= 1; end // 2
      8'h7A: begin num <= 4'h3; is_digit <= 1; end // 3
      8'h6B: begin num <= 4'h4; is_digit <= 1; end // 4
      8'h73: begin num <= 4'h5; is_digit <= 1; end // 5
      8'h74: begin num <= 4'h6; is_digit <= 1; end // 6
      8'h6C: begin num <= 4'h7; is_digit <= 1; end // 7
      8'h75: begin num <= 4'h8; is_digit <= 1; end // 8
      8'h7D: begin num <= 4'h9; is_digit <= 1; end // 9

      // 演算子のスキャンコード
      8'h79: begin operator <= 2'b01; is_digit <= 0; end // +
      8'h7B: begin operator <= 2'b10; is_digit <= 0; end // -
      8'h7C: begin operator <= 2'b11; is_digit <= 0; end // *
      8'h4A: begin operator <= 2'b10; is_digit <= 0; end // /
      8'h5A: begin is_enter <= 1; is_digit <= 0; end // enter

      // その他のスキャンコード
      default: begin num <= 4'hF; is_digit <= 0; is_enter <= 0; operator <= 2'd0; end // 無効な入力
   endcase
end

always @ (posedge clk or negedge iRST_n)
begin
   if (!iRST_n) begin
      display_num <= 24'd0;
   end else if (is_digit) begin
      // 新しい数字を最下位に入れ、他の桁を左にシフト
      display_num <= (display_num[19:0] * 24'd10) + num;
   end else if (operator != 2'd0 || is_enter) begin
      display_num <= 24'd0;
   end else begin
      display_num <= display_num;
   end
end
//*/



PS2 U0(
           .iSTART(iSTART),       //press the button for transmitting instrucions to device;
           .iRST_n(iRST_n),       //FSM reset signal;
           .iCLK(clk),            //clock source;
           .PS2_CLK(PS2_CLK),     //ps2_clock signal inout;
           .PS2_DAT(PS2_DAT),     //ps2_data  signal inout;
           .oLEFBUT(oLEFBUT),     //left button press display;
           .oRIGBUT(oRIGBUT),     //right button press display;
           .oMIDBUT(oMIDBUT),     //middle button press display;
           .PS2_READY(PS2_READY), //ready signal for PS2;
           .SCANCODE(SCANCODE)    //scan-code for PS2;
           ); 

CLKDIV U1(
           .iCLK(iCLK_50),        //clock source;
           .RSTB(iRST_n),         //reset signal;
           .oCLK(clk),            //clock signal out;
           ); 

//instantiation
SEG7_LUT U2(.oSEG(oX_MOV1),.iDIG(display_num[3:0]));
SEG7_LUT U3(.oSEG(oX_MOV2),.iDIG(display_num[7:4]));
SEG7_LUT U4(.oSEG(oY_MOV1),.iDIG(display_num[11:8]));
SEG7_LUT U5(.oSEG(oY_MOV2),.iDIG(display_num[15:12]));
SEG7_LUT U6(.oSEG(oZ_MOV1),.iDIG(display_num[19:16]));
SEG7_LUT U7(.oSEG(oZ_MOV2),.iDIG(display_num[23:20]));

endmodule


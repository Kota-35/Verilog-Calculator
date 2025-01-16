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

always @ (posedge clk or negedge iRST_n)
begin
   if ( !iRST_n ) begin
      z_latch <= 8'd0;
      y_latch <= 8'd0;
      x_latch <= 8'd0;
   end else if ( !PS2_READY ) begin
      //z_latch <= SCANCODE[23:16];
      y_latch <= SCANCODE[15:8];
      x_latch <= SCANCODE[7:0];
   end else begin
      z_latch <= z_latch;
      y_latch <= y_latch;
      x_latch <= x_latch;
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
SEG7_LUT U2(.oSEG(oX_MOV1),.iDIG(x_latch[3:0]));
SEG7_LUT U3(.oSEG(oX_MOV2),.iDIG(x_latch[7:4]));
SEG7_LUT U4(.oSEG(oY_MOV1),.iDIG(y_latch[3:0]));
SEG7_LUT U5(.oSEG(oY_MOV2),.iDIG(y_latch[7:4]));
SEG7_LUT U6(.oSEG(oZ_MOV1),.iDIG(z_latch[3:0]));
SEG7_LUT U7(.oSEG(oZ_MOV2),.iDIG(z_latch[7:4]));

endmodule


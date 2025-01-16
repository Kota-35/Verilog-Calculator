//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author                    :| Mod. Date :| Changes Made:
//   V1.0 :| Koh Johguchi              :| 12/01/20  :| Shinshu Univ. 
//        :|   -  Devided clk. 
// --------------------------------------------------------------------
module CLKDIV(
           iCLK,      //clock source;
           RSTB,      //reset signal;
           oCLK,      //clock signal out;
           ); 
           //interface;
//=======================================================
//  PORT declarations
//=======================================================

input  iCLK;
input  RSTB;
output oCLK;


//=======================================================
//  REG/WIRE declarations
//=======================================================
reg [10:0]  CNT;
reg         oCLK;

//=======================================================
//  PARAMETER declarations
//=======================================================
//state define
//clk division, derive a 12.5kHz clock from the 50MHz source;
//parameter CNTMAX = 11d'2000;
//clk division, derive a 33.333333KHz clock from the 50MHz source;
parameter CNTMAX = 11'd750;

always@(posedge iCLK or negedge RSTB)
   if ( !RSTB ) begin
      CNT     <= 0;
      oCLK    <= 0;
   end else if ( CNT == CNTMAX - 1'b1 ) begin
      CNT     <= 0;
      oCLK    <= ~oCLK;
   end else begin
      CNT     <= CNT + 1'b1;
      oCLK    <= oCLK;
   end

endmodule


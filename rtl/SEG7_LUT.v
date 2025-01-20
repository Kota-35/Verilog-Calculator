// 7 segment LED decoder
module SEG7_LUT	( 
    oSEG, 
    iDIG
);
    input  [3:0]        iDIG;
    output [6:0]        oSEG;
    
//    wire   [6:0]        SEG;

    assign  oSEG = SEG(iDIG);

//  7SEG-LED pin assignment
//     ----t----
//     |       |    Common Anode
//     lt     rt     => Negative logic
//     |       |
//     ----m----
//     |       |
//     lb     rb
//     |       |
//     ----b----

    function [6:0] SEG;
      input [3:0] iDIG;
      case(iDIG)
            4'h0: SEG = 7'b1000000; // 0
            4'h1: SEG = 7'b1111001; // 1
            4'h2: SEG = 7'b0100100; // 2
            4'h3: SEG = 7'b0110000; // 3
            4'h4: SEG = 7'b0011001; // 4
            4'h5: SEG = 7'b0010010; // 5
            4'h6: SEG = 7'b0000010; // 6
            4'h7: SEG = 7'b1111000; // 7
            4'h8: SEG = 7'b0000000; // 8
            4'h9: SEG = 7'b0011000; // 9
            4'ha: SEG = 7'b0001000; // A(10)
            4'hb: SEG = 7'b0000011; // b(11)
            4'hc: SEG = 7'b1000110; // C(12)
            4'hd: SEG = 7'b0100001; // d(13)
            4'he: SEG = 7'b0000110; // E(14)
            4'hf: SEG = 7'b0111111; // -(15) マイナス記号
         default: SEG = 7'b1111111; // Blank
        endcase
    endfunction

endmodule

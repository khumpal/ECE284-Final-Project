// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_row (clk, out_s, in_w, in_n, valid, inst_w, reset);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  output [col-1:0] valid;
  input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n; 

  wire  [(col+1)*bw-1:0] temp; // temp is 4 bits * 8 columns + the original input
  wire  [(col+1)*2-1:0] temp_inst; // 
    
  assign temp[bw-1:0]   = in_w;
  assign temp_2[1:0]	= inst_w; 

  genvar i;
  for (i=1; i < col+1 ; i=i+1) begin : col_num
      assign valid[i-1] = temp_2[2*(i+1)-1]; //assigns valid for each inst
      mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
         .clk(clk),
         .reset(reset),
    	   .in_w( temp[bw*i-1:bw*(i-1)]),
    	   .out_e(temp[bw*(i+1)-1:bw*i]),
         .inst_w(temp_2[2*i-1:2*(i-1)]),
         .inst_e(temp_2[2*(i+1)-1:2*i]),
          // 15:0 , 31:16 ....
         .in_n(in_n[psum_bw*i-1:psum_bw*(i-1)]),  //psums do not depend on eachother in row
    	   .out_s(out_s[psum_bw*i-1:psum_bw*(i-1)])
		);
  end
    //iter one temp_2  // temp2[1:0] input to inst_w
    //                    assign temp_ 2[3:2] to output .... 

endmodule

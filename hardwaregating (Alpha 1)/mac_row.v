// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_row (clk, out_s, out_s_zero, in_w, in_w_zero, in_n, in_n_zero, valid, inst_w, reset);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  output [col-1:0] valid;
  input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  input  in_w_zero;
  input  [col-1:0] in_n_zero;
  output [col-1:0] out_s_zero;

  wire  [(col+1)*bw-1:0] temp; // temp is 4 bits * 8 columns + the original input
  wire  [(col+1)*2-1:0] temp_inst; // 
  wire  [col:0] temp_zero;
    
  assign temp[bw-1:0]   = in_w;
  assign temp_inst[1:0]	= inst_w; 

  genvar i;
  for (i=1; i < col+1 ; i=i+1) begin : col_num
      mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
         .clk(clk),
         .reset(reset),
	 .in_w( temp[bw*i-1:bw*(i-1)]),
	 .in_w_zero(in_w_zero),
	 .out_e(temp[bw*(i+1)-1:bw*i]),
	 .out_e_zero(temp_zero[i-1]),
         .inst_w(temp_inst[2*i-1:2*(i-1)]),
         .inst_e(temp_inst[2*(i+1)-1:2*i]),
          // 15:0 , 31:16 ....
         .in_n(in_n[psum_bw*i-1:psum_bw*(i-1)]),  //psums do not depend on eachother in row
	 .in_n_zero(in_n_zero[i-1]),
	 .out_s(out_s[psum_bw*i-1:psum_bw*(i-1)]),
	 .out_s_zero(out_s_zero[i-1])
		);
    //assign valid[i-1] = temp_inst[2*(i+1)-1]; //assigns valid for each inst
  end

  assign valid = {temp_inst[17],temp_inst[15],temp_inst[13],temp_inst[11],temp_inst[9],temp_inst[7],temp_inst[5],temp_inst[3]};
  

endmodule

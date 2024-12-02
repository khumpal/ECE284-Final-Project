// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_row (clk, out_s, out_s_zero, in_w, in_w_zero, in_n, in_n_zero, valid, inst_w, reset, mode);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  output [col-1:0] valid;
  input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;

  output [col-1:0] out_s_zero;
  input in_w_zero;
  input [col-1:0] in_n_zero;

  input mode;

  wire  [(col+1)*bw-1:0] temp;
  wire  [(col+1)*2-1:0] inst_temp;

  wire [col:0] temp_zero;

  assign temp[bw-1:0]   = in_w;
  assign inst_temp[1:0] = inst_w;

  assign temp_zero[0] = in_w_zero;

  //reg [col-1:0] valid_temp;

  //for (j=1; j < col+1; j=j+1) begin
//	  valid_temp[j] = inst_temp[2*(j+1)-1];
  //end

  //assign valid = valid_temp;

  genvar i;
  for (i=1; i < col+1 ; i=i+1) begin //: col_num
	  mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
		  .clk(clk),
		  .reset(reset),
		  .in_w(temp[bw*i-1:bw*(i-1)]),
		  .in_w_zero(temp_zero[i-1]),
		  .out_e(temp[bw*(i+1)-1:bw*i]),
		  .out_e_zero(temp_zero[i]),
		  .inst_w(inst_temp[2*i-1:2*(i-1)]),
		  .inst_e(inst_temp[2*(i+1)-1:2*i]),
		  .in_n(in_n[psum_bw*i-1:psum_bw*(i-1)]),
		  .in_n_zero(in_n_zero[i-1]),
		  .out_s(out_s[psum_bw*i-1:psum_bw*(i-1)]),
		  .out_s_zero(out_s_zero[i-1]),
		  .mode(mode)
	  );
	  assign valid[i-1] = inst_temp[2*(i+1)-1];
  end


endmodule

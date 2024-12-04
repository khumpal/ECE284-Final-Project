// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module ififo (clk, in, out, rd, wr, o_full, reset, o_ready);

  parameter row  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [row*bw-1:0] in;
  output [row*(bw+1)-1:0] out; //out has "row" additional bits to indicate if the output data of each row is zero or not i.e., 1 for data = 0 and 0 for non-zero data
  output o_full;
  output o_ready;

  //wire [row*bw:0] in_extended;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en = 8'b00000000;
  //reg [row-1:0] wr_en;
  
  wire [row-1:0] o_full_fifo64;
  wire [row-1:0] o_empty_fifo64;
  wire [bw*(row+1)-1:0] out_temp;

  reg [row*(bw+1)-1:0] result;

  reg version1 = 1'b1;

  integer j;
  reg [bw-1:0] segment;
  reg [bw:0] extended_segment; //1'b1 for zero and 1'b0 for non-zero

  always @(rd) begin
	  if (rd) begin
		  result = 40'b0;
		  for (j = row-1; j >= 0; j = j - 1) begin
			  segment = out_temp[(j*bw)+3 -: 4];
			  extended_segment = (segment == 4'b0000)? {1'b1,segment} : {1'b0,segment};
			  result = {out[34:0],extended_segment};
		  end
	  end
  end

  assign out = result;

  genvar i;

  //assign in_extended = (in == 0)? {1'b1,in} : {1'b0,in};

  assign o_ready = ~(|o_full_fifo64);
  assign o_full  = |o_full_fifo64;

  //assign out = (out_temp[bw*(row+1)-1:0] == 0)? {1'b1,out_temp[bw*(row+1)-1:0]} : {1'b0,out_temp[bw*(row+1)-1:0]}; //appending the additional bit to indicate whether the out is zero or non zero

  for (i=0; i<row ; i=i+1) begin : row_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
	 .rd_clk(clk),
	 .wr_clk(clk),
	 .rd(rd_en[i]),
	 //.wr(wr_en[i]),
	 .wr(wr),
         .o_empty(o_empty_fifo64[i]),
         .o_full(o_full_fifo64[i]),
	 .in(in[(i+1)*bw-1:bw*i]),
	 .out(out_temp[bw*(i+1)-1:bw*i]),
         .reset(reset));
  end


  always @ (posedge clk) begin
	  if (reset) begin
		  rd_en <= 8'b00000000;
	  end
	  else begin
		  /////////////// version1: read all row at a time //////////////// 
		  if (version1) begin
			  if (rd == 1'b1) begin
				  rd_en <= 8'b11111111;
			  end
			  //rd_en <= 8'b11111111;
		  end
		  else begin //////////////// version2: read 1 row at a time /////////////////
			  if (rd == 1'b1) begin
				  //if (rd_en == 8'b00000000) begin
				  //rd_en <= 8'b00000001;
				  //end
				  //else begin
				  //rd_en <= {rd_en[6:0],rd_en[7]};
				  //end
				  //rd_en <= rd_en + 1;
				  if (rd_en != 8'b11111111) begin
					  rd_en <= {rd_en[6:0],1'b1}; //00000000 -> 00000001 -> 00000011 -> 00000111 -> 00001111 -> 00011111 -> 00111111 -> 01111111 -> 11111111
				  end
			  end
			  else if (rd == 1'b0) begin
				  if (rd_en != 8'b00000000) begin
					  rd_en <= {rd_en[6:0],1'b0}; //11111111 -> 11111110 -> 11111100 -> 11111000 -> 11110000 -> 11100000 -> 11000000 -> 10000000 -> 00000000
				  end
			  end
		  end
	  end
  end

endmodule

// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module ofifo (clk, in, out, rd, wr, o_full, reset, o_ready, o_valid);

  parameter col  = 8;
  parameter psum_bw = 16;

  input  clk;
  input  [col-1:0] wr;
  input  rd;
  input  reset;
  input  [col*psum_bw-1:0] in;
  output [col*psum_bw-1:0] out;
  output o_full;
  output o_ready;
  output o_valid;

  wire [col-1:0] empty;
  wire [col-1:0] full;
  reg wr_en;
  reg rd_en;
  wire [col-1:0] o_full_fifo;
  wire [col-1:0] empty_fifo;
  wire [col*psum_bw-1:0] out_temp;
  
  genvar i;

  assign o_ready = ~(|o_full_fifo) ;
  assign o_full  = |o_full_fifo ;
  assign o_valid = !empty_fifo[col-1];

  assign out = out_temp;

  for (i=0; i<col ; i=i+1) begin : col_num
      fifo_depth64 #(.bw(psum_bw)) fifo_instance (
	 .rd_clk(clk),
	 .wr_clk(clk),
	 .rd(rd_en),
	 .wr(wr[i]),
         .o_empty(empty_fifo[i]),
         .o_full(o_full_fifo[i]),
	 .in(in[psum_bw*(i+1)-1:psum_bw*i]),
	 .out(out_temp[psum_bw*(i+1)-1:psum_bw*i]),
         .reset(reset));
  end


  always @ (posedge clk) begin
	  if (reset) begin
		  rd_en <= 0;
	  end
	  else begin
		  if (o_valid && rd) begin
			  rd_en <= 1'b1;
		  end
		  else begin
			  rd_en <= 1'b0;
		  end
	  end
  end



endmodule

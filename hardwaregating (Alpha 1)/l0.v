// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (clk, in, out, out_zero, rd, wr, o_full, reset, o_ready);

  parameter row  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [row*bw-1:0] in;
  output [row*bw-1:0] out;
  output o_full;
  output o_ready;
  output [row-1:0] out_zero;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;

  wire [row*bw-1:0] out_temp;
  
  genvar i;

  assign o_ready = ~(|full);  //bitwise or, assign for all bits in full being 0
  assign o_full  = |full;  // assign for when at least one of the fifos are full


  assign out = out_temp;
  assign out_zero[0] = (out[3:0] == 0)? 1 : 0;
  assign out_zero[1] = (out[7:4] == 0)? 1 : 0;
  assign out_zero[2] = (out[11:8] == 0)? 1 : 0;
  assign out_zero[3] = (out[15:12] == 0)? 1 : 0;
  assign out_zero[4] = (out[19:16] == 0)? 1 : 0;
  assign out_zero[5] = (out[23:20] == 0)? 1 : 0;
  assign out_zero[6] = (out[27:24] == 0)? 1 : 0;
  assign out_zero[7] = (out[31:28] == 0)? 1 : 0;

  for (i=0; i<row ; i=i+1) begin : row_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
	      .rd_clk(clk),
	      .wr_clk(clk),
	      .rd(rd_en[i]),
         .wr(wr), //write happens simultaneously among all rows
         .o_empty(empty[i]), 
         .o_full(full[i]),
	      .in(in[bw*(i+1)-1:bw*i]),
	      .out(out_temp[bw*(i+1)-1:bw*i]),
         .reset(reset));
  end


  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 8'b00000000;
   end
   else begin

      /////////////// version1: read all row at a time ////////////////
       //rd_en = {{row}{rd}}; //replicated rd bit by number of rows

      //////////////// version2: read 1 row at a time /////////////////
      rd_en[0] <= rd; 
		rd_en[1] <= rd_en[0]; 
		rd_en[2] <= rd_en[1]; 
		rd_en[3] <= rd_en[2]; 
		rd_en[4] <= rd_en[3]; 
		rd_en[5] <= rd_en[4]; 
		rd_en[6] <= rd_en[5]; 
		rd_en[7] <= rd_en[6];
      end
      ///////////////////////////////////////////////////////
    end

endmodule
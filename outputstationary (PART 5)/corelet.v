module corelet (
	clk, reset, inst, mode,
	in_corelet_west, in_corelet_north, in_sfu_from_sram,
	o_fifo_out, final_out, os_ready, os_output
);

  parameter bw = 4;           	// Bit-width for activations and weights
  parameter psum_bw = 16;     	// Bit-width for partial sums
  parameter col = 8;          	// Number of columns in the array
  parameter row = 8;          	// Number of rows in the array

  input [33:0] inst;          	// Instruction signal
  input clk, reset, mode;     	// Clock, reset, and mode signal (0: WS, 1: OS)
  input [(bw * row) - 1:0] in_corelet_north;  // Input weights/psums from the top (used in OS mode)
  input [(bw * row) - 1:0] in_corelet_west;    	// Input activations from the left
  input [(psum_bw * col) - 1:0] in_sfu_from_sram;  // Input psums for the SFU

  output [(psum_bw * col) - 1:0] o_fifo_out;   	// Output from OFIFO
  output [(psum_bw * col) - 1:0] final_out;    	// Output from SFU
  output [row*col - 1:0] os_ready;                	// OS-ready signal for each column
  output [(psum_bw * col*row) - 1:0] os_output;   	// OS-mode output from the array

  // LO buffer for activations
  wire [(bw * row) - 1:0] L0_in;
  wire [(bw * row) - 1:0] L0_out;
  wire L0_o_full, L0_o_ready;

  assign L0_in = in_corelet_west;

  l0 #(
	.row(row),
	.bw(bw)
  ) L0_instance (
	.clk(clk),
	.in(L0_in),
	.out(L0_out),
	.rd(inst[3]),  // Read signal
	.wr(inst[2]),  // Write signal
	.o_full(L0_o_full),
	.reset(reset),
	.o_ready(L0_o_ready)
  );

  // IFIFO for weights (used in OS mode)
  wire [(bw * col) - 1:0] ififo_out;
  wire ififo_full, ififo_ready;

  ififo #(
  ) ififo_instance (
	.clk(clk),
	.in(in_corelet_north),   	// Weights coming from the top
	.out(ififo_out),         	// Weights to the systolic array
	.rd(inst[4]),            	// Read signal
	.wr(inst[5]),            	// Write signal
	.o_full(ififo_full),
	.reset(reset),
	.o_ready(ififo_ready)
  );

  // Systolic Array
  wire [(psum_bw * col) - 1:0] array_out_s;
  wire [(psum_bw * col*row) - 1:0] array_os_output;
  wire [(col - 1):0] array_valid;
  wire [(row*col - 1):0] array_os_ready;

  wire [(psum_bw * col) - 1:0] array_in_n;

// Handle in_n based on the mode
  assign array_in_n = (mode == 1'b0) ? {psum_bw * col{1'b0}} :
                	{{(psum_bw * col - bw * row){1'b0}}, ififo_out};


  mac_array #(
	.bw(bw),
	.psum_bw(psum_bw),
	.col(col),
	.row(row)
  ) mac_array_instance (
	.clk(clk),
	.reset(reset),
	.out_s(array_out_s),          	// Partial sums for WS mode
	.in_w(L0_out),                	// Activations from L0
	.inst_w(inst[1:0]),           	// Instructions
	.in_n(array_in_n),             	// Weights/psums from IFIFO in OS mode
	.valid(array_valid),          	// Valid signals for WS
	.os_ready(array_os_ready),    	// OS-ready signals for each tile
	.os_output(array_os_output)   	// OS-mode outputs
  );

  // OFIFO for psums
  wire [(psum_bw * col) - 1:0] ofifo_out_corelet;
  wire ofifo_full, ofifo_ready, ofifo_valid;

  ofifo #(
	.col(col),
	.psum_bw(psum_bw)
  ) ofifo_instance (
	.clk(clk),
	.in(array_out_s),             	// Psums from the systolic array (WS mode)
	.out(ofifo_out_corelet),      	// Buffered psums
	.rd(inst[6]),                 	// Read signal
	.wr(array_valid),             	// Write signal
	.o_full(ofifo_full),
	.reset(reset),
	.o_ready(ofifo_ready),
	.o_valid(ofifo_valid)
  );

  assign o_fifo_out = ofifo_out_corelet;

  // SFU for accumulation and ReLU
  wire [(psum_bw * col) - 1:0] sfu_out;
  genvar i;

  for (i = 1; i < col + 1; i = i + 1) begin : sfu_instances
	sfu #(
  	.bw(bw),
  	.psum_bw(psum_bw)
	) sfu_instance (
  	.out(sfu_out[(psum_bw * i) - 1 : psum_bw * (i - 1)]),
  	.in(in_sfu_from_sram[(psum_bw * i - 1) : psum_bw * (i - 1)]),
  	.acc(inst[33]),           	// Accumulation signal
  	.relu(!inst[33]),         	// ReLU signal
  	.clk(clk),
  	.reset(reset)
	);
  end

  assign final_out = sfu_out;     	// Final processed output
  assign os_ready = array_os_ready;  // OS-ready signals from the array
  assign os_output = array_os_output; // OS-mode outputs from the array

endmodule




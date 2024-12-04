module ParallelToSerial_tb();

reg clk;            // Clock signal
reg reset;          // Reset signal (active high)
reg load;           // Load signal (active high)
reg [31:0] parallel_in; // 32-bit parallel data input
wire serial_out;      // Serial data output
wire o_valid;

ParallelToSerial DUT(
	.clk(clk),
	.reset(reset),
	.load(load),
	.parallel_in(parallel_in),
	.serial_out(serial_out),
	.o_valid(o_valid)
);

initial begin
clk = 1;
reset = 1;
load = 0;
parallel_in = 0;

#10;

reset = 0;
load = 1;
parallel_in = 32'd4294967295;
#10;
load = 0;

#360;
load = 1;
parallel_in = 32'd1431655765;
#10;
load = 0;

#360;
load = 1;
parallel_in = 32'd4294901760;
#10;
load = 0;

#360;
load = 1;
parallel_in = 32'd4042326014;
#10;
load = 0;

#360;
load = 1;
parallel_in = 32'd65534;
#10;
load = 0;

end

always #5 clk = ~clk;

endmodule

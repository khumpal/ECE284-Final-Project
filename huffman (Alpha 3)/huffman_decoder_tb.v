module huffman_decoder_tb();

reg clk;
reg rst;
reg in;
reg in_valid;
wire [3:0] out;
wire out_ready;

huffman_decoder DUT(
	.clk(clk),
	.rst(rst),
	.in(in),
	.out(out),
	.out_ready(out_ready),
	.in_valid(in_valid)
	);

initial begin
clk = 1;
rst = 1;
in = 0;
in_valid = 1;

#10;
rst = 0;
in = 1;
#10;

in = 0;
#10;

in = 0;
#10;

in = 1;
#10;

in = 1;
#10;
in = 0;
#10;

in_valid = 0;

in = 1;
#10;

in = 0;
#10;

in = 1;
#10;

in = 1;

#30;
in = 0;
in_valid = 1;

#10;
rst = 0;
in = 1;
#10;

in = 0;
#10;

in = 0;
#10;

in = 1;
#10;

in = 1;
#10;
in = 0;
#10;

in_valid = 0;

in = 1;
#10;

in = 0;
#10;

in = 1;
#10;

in = 1;

end

always #5 clk = ~clk;
	
endmodule

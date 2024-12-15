module test_front_tb;

reg clk;
reg rst;
reg load;
reg [31:0] in;

wire [3:0] out_decoded;
wire out_decoded_valid;

test_front DUT(.clk(clk), .rst(rst), .load(load), .in(in), .out_decoded(out_decoded), .out_decoded_valid(out_decoded_valid));

initial begin

clk = 1;
rst = 1;
load = 0;
in = 0;

#20;

rst = 0;
load = 1;
in = 32'b00110011011110111111111100011011;
#10;
load = 0;

#360;

load = 1;
in = 32'b11111111111111111100000111111000;
#10;
load = 0;

#360;

load = 1;
in = 32'b11000101111101100010011101100001;
#10;
load = 0;




end

always #5 clk = ~clk;

endmodule

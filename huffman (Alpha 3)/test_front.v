module test_front(clk, rst, load, in, out_decoded, out_decoded_valid);

input clk;
input rst;
input load;
input [31:0] in;

wire serialized_out;
wire serialized_out_valid;

output [3:0] out_decoded;
output out_decoded_valid;


ParallelToSerial PTS(.clk(clk), .reset(rst), .load(load), .parallel_in(in), .serial_out(serialized_out), .o_valid(serialized_out_valid));


huffman_decoder HUFF_DEC(.clk(clk), .rst(rst), .in(serialized_out), .in_valid(serialized_out_valid), .out(out_decoded), .out_ready(out_decoded_valid));





endmodule

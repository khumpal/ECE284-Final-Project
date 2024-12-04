module complete_decoder(clk, rst, load, in, output_data, output_ready);

input clk;
input rst;
input load;
input [31:0] in;

output [31:0] output_data; // 32-bit concatenated output
output output_ready;       // Indicates when output is ready

wire serialized_out;
wire serialized_out_valid;

wire [3:0] huffman_out_decoded;
wire huffman_out_decoded_valid;


ParallelToSerial PTS(.clk(clk), .reset(rst), .load(load), .parallel_in(in), .serial_out(serialized_out), .o_valid(serialized_out_valid));


huffman_decoder HUFF_DEC(.clk(clk), .rst(rst), .in(serialized_out), .in_valid(serialized_out_valid), .out(huffman_out_decoded), .out_ready(huffman_out_decoded_valid));

ConcatenateInputs CONC_IP(.clk(clk), .reset(rst), .input_data(huffman_out_decoded), .input_valid(huffman_out_decoded_valid), .output_data(output_data), .output_ready(output_ready));

endmodule

module complete_decoder_tb();

reg clk;
reg rst;
reg load;
reg [31:0] in;

wire [31:0] output_data; // 32-bit concatenated output
wire output_ready;       // Indicates when output is ready

reg [31:0] mem [0:63]; // Array to store the file data
integer i;             // Index for reading memory
integer file_out;

complete_decoder COMP_DEC(.clk(clk), .rst(rst), .load(load), .in(in), .output_data(output_data), .output_ready(output_ready));

// Load file data
initial begin

clk = 1;
rst = 1;
load = 0;
in = 32'd0;

#20;

rst = 0;


$readmemb("C:\\Quartus_Projects\\huffman_encoded_input_32bit.txt", mem); // Load binary data into 'mem' array
file_out = $fopen("C:/Quartus_Projects/complete_decoder_output.txt", "w");
#20;

// Apply inputs sequentially
for (i = 0; i < 64; i = i + 1) begin
load = 1;
$display("mem[%0d] = %b", i, mem[i]);
in = mem[i];

#10; // Wait for one clock period (or required time)
load = 0;
#360;
end

// $finish; // End simulation
end


always #5 clk = ~clk;

always@(posedge clk) begin
if(output_ready) begin
$fwrite(file_out, "%b\n", output_data);
end
end

endmodule

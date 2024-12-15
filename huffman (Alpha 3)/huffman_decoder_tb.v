module huffman_decoder_tb();

reg clk;
reg rst;
reg in;
reg in_valid;
wire [3:0] out;
wire out_ready;

huffman_3 DUT(
	.clk(clk),
	.rst(rst),
	.in(in),
	.out(out),
	.out_ready(out_ready),
	.in_valid(in_valid)
	);
	
integer i;
integer file;
integer write_file;
reg [31:0] shift_reg;



initial begin
clk = 1;
rst = 1;
in = 0;
in_valid = 0;
shift_reg = 32'bX;

file = $fopen("C:/Quartus_Projects/input.txt", "w");
write_file = $fopen("C:/Quartus_Projects/output.txt", "w");


#10;
rst = 0;
in_valid = 1;

for(i=0; i<100; i=i+1) begin
		
	in = $random % 2;
	
	if(in == 0) shift_reg = {{shift_reg[30:0]},{in}};
	else begin
		shift_reg = {{shift_reg[30:0]},{in}};
		$fwrite(file, "%b\n", shift_reg); // Write to the file
		shift_reg = 32'bX;
	
   end
	
	if(i==33) in_valid = 0;
	if(i==40) in_valid = 1;
	
	#10;
	
end

// Close the file
$fclose(file);
$fclose(write_file);

end

always #5 clk = ~clk;



always@(posedge clk) begin

if(out_ready) begin
$fwrite(write_file, "%b\n", out);
end

end
	
endmodule

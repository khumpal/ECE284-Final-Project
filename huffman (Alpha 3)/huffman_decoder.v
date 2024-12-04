module huffman_decoder(clk, rst, in, in_valid, out, out_ready);

input clk;
input rst;
input in;
input in_valid;
output [3:0] out;
output out_ready;

reg temp;
reg [2:0] counter;
reg [2:0] addr;
reg [2:0] counter_delay;
reg in_valid_delay;

wire [3:0] out_wire;
wire [2:0] counter_wire;

huffman_ROM ROM(counter_wire, out_wire);

always@(posedge clk or posedge rst) begin

if(rst) begin
	temp <= 0;
	counter <= 3'b000;
	addr = 3'b000;
	in_valid_delay <= 0;
end
else if(in_valid) begin

	temp = in;

	if(temp) begin
		addr = counter;
		counter = 3'b000;
	end
	else begin
		counter = counter + 1;
	end
	
end

//delaying the signal allowing us to determine until when the output is valid
in_valid_delay <= in_valid;
end

assign out_ready = temp & (in_valid | in_valid_delay);
assign out = (temp & (in_valid | in_valid_delay))? out_wire : 4'bZ;
//assign out = out_wire ;
assign counter_wire = (temp & (in_valid | in_valid_delay))? addr  : 4'bZ;
//assign counter_wire = addr;

endmodule

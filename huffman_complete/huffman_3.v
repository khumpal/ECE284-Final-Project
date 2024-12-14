module huffman_3(clk, rst, in, in_valid, out, out_ready);

input clk;
input rst;
input in;
input in_valid;
output [3:0] out;
output out_ready;

reg [3:0] counter;
reg [3:0] out_reg;
reg out_ready_reg;

always@(posedge clk)begin

if(rst)begin

counter <= 0;
out_reg <= 0;

end else if(in_valid) begin

if(in == 0)	counter <= counter + 1;
else begin

out_reg <= counter;
counter <= 0;

end


end

out_ready_reg <= in & in_valid;

end

assign out = out_reg;
assign out_ready = out_ready_reg;

endmodule

module sfu (out, in, acc, relu, clk, reset);

parameter bw = 4;
parameter psum_bw = 16;

input clk;
input reset;
input acc;
input relu;
input signed [psum_bw-1:0] in;
output signed [psum_bw-1:0] out;

reg signed [psum_bw-1:0] psum_q;

always @(posedge clk) begin
    if (reset) begin
        psum_q <= 0;
    end
    else begin
        if (acc == 1) begin
            psum_q <= psum_q + in;
        end
        else if (relu == 1) begin
            psum_q <= (psum_q > 0)? psum_q : 0;
        end
        else begin
            psum_q <= psum_q;
        end
    end
        
end

assign out = psum_q;

endmodule

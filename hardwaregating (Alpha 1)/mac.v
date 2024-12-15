// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a, b, c, sum_term_zero, product_term_zero);

parameter bw = 4;
parameter psum_bw = 16;


    
output signed [psum_bw-1:0] out;
input signed  [bw-1:0] a;  // activation
input signed  [bw-1:0] b;  // weight
input signed  [psum_bw-1:0] c;

input sum_term_zero;
input product_term_zero;



wire signed [2*bw:0] product;
wire signed [psum_bw-1:0] psum;
wire signed [bw:0]   a_pad;

assign a_pad = {1'b0, a}; // force to be unsigned number
assign product = product_term_zero? 0 : a_pad * b;   //Don't use multiplier if input or weight is 0 because product would anyway be 0
assign psum = sum_term_zero? product : product + c;  //Don't use adder if partial sum c is 0 because psum will remain the same
assign out = psum;

endmodule

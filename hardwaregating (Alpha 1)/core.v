module core #(
    parameter row = 8,
    parameter col = 8,
    parameter psum_bw = 16,
    parameter bw = 4
)(


    // core  #(.bw(bw), .col(col), .row(row)) core_instance (
	// .clk(clk), 
    // .inst(inst_q), // should take inst[33]
	// .ofifo_valid(ofifo_valid),
    //     .D_xmem(D_xmem_q), 
    //     .sfp_out(sfp_out), 
	// .reset(reset)); 

    
    input clk,
    input [33:0] inst,
    input reset,
    output ofifo_valid,
    input [bw*row-1:0] D_xmem, //for WS will load weights and activations to Xmem
    //input D_Weight_mem , later for OS will load weights drim Dram to weight mem 
    output [psum_bw*col-1:0] sfp_out //sfu out
      
);
//Act Weight Memory inst
//(CLK, D, Q, CEN, WEN, A);

wire [31:0] xmem_out;


sram_x #(
    .num(2048)
) x_w_mem_instance (
    .CLK(clk),
    .D(D_xmem),
    .Q(xmem_out),
    .CEN(inst[19]),
    .WEN(inst[18]),
    .A(inst[17:7])

);



//Corelet Inst
//(clk, reset, inst, mode,in_corelet_west, in_corelet_north,o_fifo_out,final_out);

wire [psum_bw*col-1:0]in_corelet_north;
assign in_corelet_north = 0;
wire [psum_bw*col-1:0] o_fifo_out;
wire[psum_bw*col-1:0] final_out;
wire [psum_bw*col-1:0] in_sfu_from_sram;

wire [127:0] psum_mem_out;

corelet #(
    .row(row),
    .col(col),
    .psum_bw(psum_bw),
    .bw(bw)
) corelet_instance (
    .clk(clk),
    .reset(reset),
    .inst(inst[33:0]),
    .mode(1'b0),
    .in_corelet_west(xmem_out),
    .in_corelet_north(in_corelet_north),
    .in_sfu_from_sram(psum_mem_out),
    .o_fifo_out(o_fifo_out),
    .final_out(final_out)

);

//wire [127:0] psum_mem_out;

assign sfp_out = final_out;
//assign in_sfu_from_sram = psum_mem_out;

//Psum Memory inst
//(CLK, D, Q, CEN, WEN, A);

//wire [127:0] psum_mem_out;

sram_psum #(
    .num(2048)
) psum_mem_instance (
    .CLK(clk),
    .D(o_fifo_out),
    .Q(psum_mem_out),
    .CEN(inst[32]),
    .WEN(inst[31]),
    .A(inst[30:20])

);

//always @(posedge clk) begin
//	D_xmem <= 0;
//end

endmodule

module corelet (clk, reset, inst, mode, in_corelet_west, in_corelet_north, in_sfu_from_sram, o_fifo_out, final_out);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;


  input [33:0] inst;
  input clk;
  input reset;
  input mode;
  input [(psum_bw*row)-1:0]in_corelet_north;  // use for OS Later
  input [(bw*row)-1:0] in_corelet_west;
  input [(psum_bw*col)-1:0] in_sfu_from_sram;



  output [(psum_bw*col)-1:0] o_fifo_out;
  output [(psum_bw*col)-1:0] final_out;



//LO Inst
  wire [(bw*row)-1:0] L0_in;
  assign L0_in = in_corelet_west;

  wire [(bw*row)-1:0] L0_out;

  wire L0_o_full;
  wire L0_o_ready;

  l0 #(
    .row(row),
    .bw(bw)
  ) L0_instance (
    .clk(clk),
    .in(L0_in),
    .out(L0_out),
    .rd(inst[3]),
    .wr(inst[2]),
    .o_full(L0_o_full),
    .reset(reset),
    .o_ready(L0_o_ready)
);

//Array Inst 
//(clk, reset, out_s, in_w, in_n, inst_w, valid);

wire [(psum_bw*col)-1:0] array_out_s;

wire [(psum_bw*col)-1:0] array_in_n;
assign array_in_n = 128'b0;

wire [col-1:0] array_valid;

mac_array #(
    .bw(bw),
    .psum_bw(psum_bw),
    .col(col),
    .row(row)
) mac_array_instance (
    .clk(clk),
    .reset(reset),
    .out_s(array_out_s),
    .in_w(L0_out), //ouput from L0
    .inst_w(inst[1:0]),
    .in_n(array_in_n), //tied to 0 in WS
    .valid(array_valid)
);



//OFIFO Inst 
//(clk, in, out, rd, wr, o_full, reset, o_ready, o_valid);

wire [psum_bw*col-1:0] ofifo_out;
wire ofifo_full;
wire ofifo_ready;
wire ofifo_valid;

ofifo #(
    .col(col),
    .psum_bw(psum_bw)
) ofifo_instance (
    .clk(clk),
    .in(array_out_s),
    .out(ofifo_out),
    .rd(inst[6]),
    .wr(array_valid),
    .o_full(ofifo_full),
    .reset(reset),
    .o_ready(ofifo_ready),
    .o_valid(ofifo_valid)
);

wire acc, relu;
wire[psum_bw*col-1:0] sfu_out;
//SFU Inst
//(out, in, acc, relu, clk, reset);
genvar i;
for (i=1; i<col+1; i=i+1) begin : sfu_instances
    sfu #(
        .bw(bw),
        .psum_bw(psum_bw)
    ) sfu_instance (
        .out(sfu_out[(psum_bw*i)-1:psum_bw*(i-1)]),
        .in(in_sfu_from_sram[(psum_bw*i-1):psum_bw*(i-1)]),
        .acc(inst[33]),
        .relu(!inst[33]),
        .clk(clk),
        .reset(reset)
    );
end

  endmodule

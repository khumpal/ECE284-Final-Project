module core #(
    parameter row = 8,
    parameter col = 8,
    parameter psum_bw = 16,
    parameter bw = 4
)(
    input clk,
    input [33:0] inst,
    input reset,
    input [3:0] accum_limit, // Accumulation limit for OS mode
    output ofifo_valid,
    input [bw*row-1:0] D_xmem, // For WS: Load weights and activations to Xmem
    output [psum_bw*col-1:0] sfp_out // SFU output
);

// Act/Weight Memory instance
// (CLK, D, Q, CEN, WEN, A)

wire [bw*row-1:0] xmem_out;

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

// Corelet Instance
// (clk, reset, inst, mode, in_corelet_west, in_corelet_north, o_fifo_out, final_out, os_ready, os_output)

wire [(psum_bw * col) - 1:0] in_corelet_north;
wire [(psum_bw * col) - 1:0] o_fifo_out;
wire [(psum_bw * col) - 1:0] final_out;
wire [(psum_bw * col) - 1:0] psum_mem_out;
wire [(psum_bw * col * row) - 1:0] os_output;
wire [col * row - 1:0] os_ready;

// Handle `in_corelet_north` for WS and OS modes
assign in_corelet_north = (inst[33]) ?  // Check mode: 1 = OS, 0 = WS
    {{(psum_bw * col - bw * row){1'b0}}, xmem_out} : // OS mode: Pad weights to match width
    {(psum_bw * col){1'b0}};                        // WS mode: Default to 0

corelet #(
    .row(row),
    .col(col),
    .psum_bw(psum_bw),
    .bw(bw)
) corelet_instance (
    .clk(clk),
    .reset(reset),
    .inst(inst[33:0]),
    .mode(inst[33]),                  // Mode: 0 = WS, 1 = OS
    .in_corelet_west(xmem_out),       // Data from activation memory
    .in_corelet_north(in_corelet_north), // Inputs for weights or psums
    .in_sfu_from_sram(psum_mem_out),  // SFU psum input
    .o_fifo_out(o_fifo_out),          // Output FIFO for WS mode
    .final_out(final_out),            // Final SFU output
    .os_ready(os_ready),              // Ready signal for OS mode
    .os_output(os_output),            // Output for OS mode
    .accum_limit(accum_limit)         // Accumulation limit for OS mode
);

// Assign SFU output to the top-level output
assign sfp_out = final_out;

// Psum Memory instance
// (CLK, D, Q, CEN, WEN, A)

sram_psum #(
    .num(2048)
) psum_mem_instance (
    .CLK(clk),
    .D(o_fifo_out),                   // Data from the FIFO
    .Q(psum_mem_out),                 // Output from psum memory
    .CEN(inst[32]),                   // Chip enable
    .WEN(inst[31]),                   // Write enable
    .A(inst[30:20])                   // Address
);

endmodule

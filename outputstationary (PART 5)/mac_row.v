// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Edited for Output Stationary Reconfigurable Functionality

module mac_row (clk, out_s, in_w, in_n, valid, inst_w, reset, os_ready, os_output, accum_limit);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;          // Outputs from each column
  output [col-1:0] valid;                  // Valid signals from each column
  output [col-1:0] os_ready;               // Ready signals from each column for OS mode
  output [psum_bw*col-1:0] os_output;      // Outputs for OS mode from each column
  input  [bw-1:0] in_w;                    // Input data from the left
  input  [1:0] inst_w;                     // Instructions from the left
  input  [psum_bw*col-1:0] in_n;           // Partial sums from the top
  input  [3:0] accum_limit;                // Accumulation limit for OS mode

  wire [(col+1)*bw-1:0] temp;              
  wire [(col+1)*2-1:0] temp_inst;         
  
  assign temp[bw-1:0] = in_w;              
  assign temp_inst[1:0] = inst_w;          

  genvar i;
  for (i = 1; i < col + 1; i = i + 1) begin : col_num
      mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
          .clk(clk),
          .reset(reset),
          .mode(inst_w[1]),                // Determine mode based on instruction
          .in_w(temp[bw*i-1:bw*(i-1)]),    // Input activation
          .out_e(temp[bw*(i+1)-1:bw*i]),   // Output activation
          .inst_w(temp_inst[2*i-1:2*(i-1)]), // Input instruction
          .inst_e(temp_inst[2*(i+1)-1:2*i]), // Output instruction
          .in_n(in_n[psum_bw*i-1:psum_bw*(i-1)]), // Input partial sum
          .out_s(out_s[psum_bw*i-1:psum_bw*(i-1)]), // Output partial sum
          .accum_limit(accum_limit),       // Accumulation limit for OS mode
          .os_ready(os_ready[i-1]),        // OS ready signal for this tile
          .os_output(os_output[psum_bw*i-1:psum_bw*(i-1)]) // OS output for this tile
      );
  end

  // Collect valid signals for each column
  assign valid = {temp_inst[17], temp_inst[15], temp_inst[13], temp_inst[11], temp_inst[9], temp_inst[7], temp_inst[5], temp_inst[3]};
  
endmodule

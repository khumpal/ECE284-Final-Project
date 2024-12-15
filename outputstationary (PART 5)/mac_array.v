// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Edited for Weight Stationary and Output Stationary Functionality
module mac_array (
    clk, 
    reset, 
    out_s, 
    in_w, 
    in_n, 
    inst_w, 
    valid, 
    os_ready, 
    os_output, 
    accum_limit
);

  parameter bw = 4;              
  parameter psum_bw = 16;        
  parameter col = 8;            
  parameter row = 8;             

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;       
  input  [row*bw-1:0] in_w;             
  input  [1:0] inst_w;                  
  input  [psum_bw*col-1:0] in_n;        
  input  [3:0] accum_limit;             
  output [col-1:0] valid;               // Valid signals for the final row
  output [row*col-1:0] os_ready;        // OS ready signals from all tiles
  output [psum_bw*row*col-1:0] os_output; // OS outputs from all tiles

  // Temporary wires and registers
  reg [2*row-1:0] inst_w_temp;          
  wire [psum_bw*col*(row+1)-1:0] temp;  
  wire [row*col-1:0] valid_temp;        
  wire [row*col-1:0] os_ready_temp;     // OS ready signals for all rows
  wire [psum_bw*row*col-1:0] os_output_temp; // OS outputs for all rows

  genvar i;

  // Assignments
  assign out_s = temp[psum_bw*col*row-1:psum_bw*col*(row-1)];  // Final row output
  assign temp[psum_bw*col-1:0] = 0;                            // Initial partial sums
  assign valid = valid_temp[row*col-1:row*col-8];              // Valid signals for the final row
  assign os_ready = os_ready_temp;                             // Aggregate OS ready signals
  assign os_output = os_output_temp;                           // Aggregate OS outputs

  // Instantiate rows
  for (i = 1; i < row + 1; i = i + 1) begin : row_num
      mac_row #(
          .bw(bw),
          .psum_bw(psum_bw),
          .col(col)
      ) mac_row_instance (
          .clk(clk),
          .reset(reset),
          .in_w(in_w[bw*i-1:bw*(i-1)]),                             // Input activations for this row
          .inst_w(inst_w_temp[2*i-1:2*(i-1)]),                      // Instructions for this row
          .in_n(temp[psum_bw*col*i-1:psum_bw*col*(i-1)]),           // Partial sums from the previous row
          .valid(valid_temp[col*i-1:col*(i-1)]),                    // Valid signals for this row
          .out_s(temp[psum_bw*col*(i+1)-1:psum_bw*col*i]),          // Partial sums to the next row
          .os_ready(os_ready_temp[col*i-1:col*(i-1)]),              // OS ready signals for this row
          .os_output(os_output_temp[psum_bw*col*i-1:psum_bw*col*(i-1)]), // OS outputs for this row
          .accum_limit(accum_limit)                                // Accumulation limit for OS mode
      );
  end

  // Instruction shift register
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      inst_w_temp <= 0;
    end else begin
      inst_w_temp[1:0]   <= inst_w; 
      inst_w_temp[3:2]   <= inst_w_temp[1:0]; 
      inst_w_temp[5:4]   <= inst_w_temp[3:2]; 
      inst_w_temp[7:6]   <= inst_w_temp[5:4]; 
      inst_w_temp[9:8]   <= inst_w_temp[7:6]; 
      inst_w_temp[11:10] <= inst_w_temp[9:8]; 
      inst_w_temp[13:12] <= inst_w_temp[11:10]; 
      inst_w_temp[15:14] <= inst_w_temp[13:12]; 
    end
  end

endmodule

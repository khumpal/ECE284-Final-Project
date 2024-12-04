// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module psum_mem (CLK, in_fifo, in_final，out_psum_mem, CEN, WEN);

// very similar to sram2048 but changed input/output pins
  input  CLK;
  input  WEN;
  input  CEN;

  input [width-1:0] data_in,
  
  input  [31:0] in_fifo ;
  input  [10:0] in_addr;
  output [31:0] out_psum_mem;

  parameter num = 2048;
  parameter width = 32;

  reg [31:0] memory [num-1:0];
  reg [10:0] add_q;
  assign out_psum_mem = memory[add_q];

  always @ (posedge CLK) begin

   if (!CEN && WEN) begin // read 
      add_q <= in_addr;
   end
   if (!CEN && !WEN) begin // write
      memory[in_addr] <= in_fifo; 
   end
  end

endmodule

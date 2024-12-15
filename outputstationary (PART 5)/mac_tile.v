// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Edited for reconfigurable weight and output stationary functionality

module mac_tile (
    clk,
    mode,
    out_s,
    in_w,
    out_e,
    in_n,
    inst_w,
    inst_e,
    reset,
    accum_limit,
    os_ready,
    os_output
);

parameter bw = 4;       
parameter psum_bw = 16; 

// Input/Output declarations
input mode;                     // Mode: 0 = WS (Weight Stationary), 1 = OS (Output Stationary)
input [3:0] accum_limit;        // Number of accumulations before signaling `os_ready`
output reg os_ready;            // Signal indicating OS mode is ready
output reg [psum_bw-1:0] os_output; // Output the accumulated PSUM when `os_ready`

output [psum_bw-1:0] out_s;     
input  [bw-1:0] in_w;           
output [bw-1:0] out_e;          
input  [1:0] inst_w;            
output [1:0] inst_e;           
input  [psum_bw-1:0] in_n;      
input  clk, reset;              

// Registers and wires
reg load_ready_q;               
reg [bw-1:0] x_q;              
reg [bw-1:0] w_q;               
reg [psum_bw-1:0] psum_q;       
reg [1:0] inst_q;               
reg [3:0] psum_count;           
wire [psum_bw-1:0] mac_out;     

// MAC instance
mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
    .a(x_q), 
    .b(w_q),
    .c(psum_q),
    .out(mac_out)
);

// Output assignments
assign out_s = (mode == 1'b0) ?  // Weight Stationary Mode
               ((inst_q == 2'b00) ? 16'b0000_0000_0000_0000 :  // Kernel load
                (inst_q == 2'b01 ? mac_out : 16'b0000_0000_0000_0000)) :  // Execute
               w_q;  // Output weights in OS mode

assign out_e = x_q;  // Pass activations to the east
assign inst_e = inst_q;  // Pass instructions to the east

// Sequential logic
always @ (posedge clk) begin
    if (reset == 1) begin
        // Reset all registers
        x_q <= 0;
        w_q <= 0;
        psum_q <= 0;
        inst_q <= 0;
        load_ready_q <= 1'b1;
        psum_count <= 0;
        os_ready <= 0;
        os_output <= 0;
    end else begin
        case (mode)
            // Weight Stationary (WS) mode
            1'b0: begin
                psum_q <= in_n;  // Input psum fed into psum_q register
                inst_q[1] <= inst_w[1];  // Pass execute instruction
                
                if (inst_w[1] == 1 || inst_w[0] == 1) begin
                    x_q <= in_w;  // Pass or store input data
                end

                if (inst_w[0] == 1 && load_ready_q == 1'b1) begin
                    w_q <= in_w;  // Load weight if in Kernel Load mode
                    load_ready_q <= 1'b0;  // Mark weight as loaded
                end

                if (load_ready_q == 1'b0) begin
                    inst_q[0] <= inst_w[0];  // Pass load instruction once weight is loaded
                end
            end

            // Output Stationary (OS) mode
            1'b1: begin
                inst_q[1] <= inst_w[1];  // Pass execute instruction

                if (inst_w[1] == 1) begin
                    x_q <= in_w;  // Update activations
                    w_q <= in_n[bw-1:0];  // Update weights from in_n
                    psum_q <= mac_out;  // Always update psum with MAC output

                    // Update PSUM counter
                    psum_count <= psum_count + 1;

                    // Check if PSUM updates reach the accumulation limit
                    if (psum_count == accum_limit) begin
                        os_ready <= 1;            // Signal that OS mode is ready
                        os_output <= psum_q;      // Capture the accumulated PSUM
                        psum_count <= 0;          // Reset the counter for the next accumulation
                    end else begin
                        os_ready <= 0;            // Keep `os_ready` low if not yet ready
                    end
                end
            end
        endcase
    end
end

endmodule

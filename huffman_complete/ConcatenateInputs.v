module ConcatenateInputs (
    input wire clk,                // Clock signal
    input wire reset,              // Reset signal (active high)
    input wire [3:0] input_data,   // 4-bit input data
    input wire input_valid,        // Indicates when an input is ready
    output reg [31:0] output_data, // 32-bit concatenated output
    output output_ready, 	 		  // Indicates when output is ready
	 output [3:0] test
);
    reg [3:0] input_count;         // Tracks the number of inputs received
    reg [31:0] temp_data;          // Temporary register for concatenating inputs
	 reg output_ready_reg;
	 reg output_ready_reg_delay;
	 
    // State machine for receiving inputs and generating output
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            input_count <= 4'd0;       // Reset input counter
            temp_data <= 32'd0;        // Reset temporary data
            output_data <= 32'd0;      // Reset output data
            output_ready_reg <= 1'b0;      // Output not ready
        end else if(input_valid)begin
				if(input_count == 3'd7) begin
					output_data <= {{temp_data[27:0]},{input_data}};
					output_ready_reg <= 1;
					temp_data <= 32'd0;
					input_count <= 3'b000;
				end else begin
						temp_data <= {{temp_data[27:0]},{input_data}};
						input_count <= input_count + 1;
						output_ready_reg <= 0;
				end
        end
		  
		  output_ready_reg_delay <= output_ready_reg;
		  
    end 
	 
	 assign output_ready = output_ready_reg & ~output_ready_reg_delay;
	 
endmodule

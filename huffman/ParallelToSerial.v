module ParallelToSerial (
    input wire clk,            // Clock signal
    input wire reset,          // Reset signal (active high)
    input wire load,           // Load signal (active high)
    input wire [31:0] parallel_in, // 32-bit parallel data input
    output reg serial_out,     // Serial data output
	 output o_valid
);
    reg [31:0] shift_register; // Shift register to hold data
    reg [4:0] bit_counter;     // Counter to track bit positions (0 to 31)
	 reg [1:0] delay_1;
	 reg [1:0] delay_2;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_register <= 32'b0;
            bit_counter <= 5'd0;
            serial_out <= 1'b0;
				delay_1 <= 2'b00;
				delay_2 <= 2'b00;
        end else if (load) begin
            shift_register <= parallel_in; // Load parallel data
            bit_counter <= 5'd31;         // Initialize bit counter
				delay_1 <= 2'b00;
				delay_2 <= 2'b00;
        end else if (bit_counter > 0) begin
            serial_out <= shift_register[31]; // Output MSB
            shift_register <= shift_register << 1; // Shift left
            bit_counter <= bit_counter - 1;   // Decrement counter
				delay_1 <= (bit_counter);
				delay_2 <= delay_1;				
        end else begin
            serial_out <= shift_register[31]; // Output the last bit
				delay_1 <= (bit_counter);
				delay_2 <= delay_1;	
        end
    end
	 
assign o_valid = ~(&bit_counter | (~|bit_counter)) | (|delay_1) | (|delay_2);	 
	 
endmodule

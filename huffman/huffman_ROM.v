module huffman_ROM (
    input [2:0] addr,  // 3-bit address (8 addresses)
    output reg [3:0] data  // 4-bit data output
);

    // ROM memory initialization with 8 values (0 to 7)
    // The values stored will increment from 0 to 7 (which corresponds to 4-bit values)
    always @(*) begin
        case (addr)
            3'b000: data = 4'b0000; // Address 0 -> Value 0
            3'b001: data = 4'b0001; // Address 1 -> Value 1
            3'b010: data = 4'b0010; // Address 2 -> Value 2
            3'b011: data = 4'b0011; // Address 3 -> Value 3
            3'b100: data = 4'b0100; // Address 4 -> Value 4
            3'b101: data = 4'b0101; // Address 5 -> Value 5
            3'b110: data = 4'b0110; // Address 6 -> Value 6
            3'b111: data = 4'b0111; // Address 7 -> Value 7
            default: data = 4'b0000; // Default case
        endcase
    end
endmodule

module huffman_ROM (
    input [3:0] addr,  // 3-bit address (8 addresses)
    output reg [3:0] data  // 4-bit data output
);

    // ROM memory initialization with 8 values (0 to 7)
    // The values stored will increment from 0 to 7 (which corresponds to 4-bit values)
    always @(*) begin
        case (addr)
            4'b0000: data = 4'b0000; // Address 0 -> Value 0
            4'b0001: data = 4'b0001; // Address 1 -> Value 1
            4'b0010: data = 4'b0010; // Address 2 -> Value 2
            4'b0011: data = 4'b0011; // Address 3 -> Value 3
            4'b0100: data = 4'b0100; // Address 4 -> Value 4
            4'b0101: data = 4'b0101; // Address 5 -> Value 5
            4'b0110: data = 4'b0110; // Address 6 -> Value 6
            4'b0111: data = 4'b0111; // Address 7 -> Value 7
            4'b1000: data = 4'b1000; // Address 0 -> Value 0
            4'b1001: data = 4'b1001; // Address 1 -> Value 1
            4'b1010: data = 4'b1010; // Address 2 -> Value 2
            4'b1011: data = 4'b1011; // Address 3 -> Value 3
            4'b1100: data = 4'b1100; // Address 4 -> Value 4
            4'b1101: data = 4'b1101; // Address 5 -> Value 5
            4'b1110: data = 4'b1110; // Address 6 -> Value 6
            4'b1111: data = 4'b1111; // Address 7 -> Value 7
            default: data = 4'b0000; // Default case
        endcase
    end
endmodule

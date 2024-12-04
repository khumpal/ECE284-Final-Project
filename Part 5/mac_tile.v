// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, out_s_zero, in_w, in_w_zero, out_e, out_e_zero, in_n, in_n_zero, inst_w, inst_e, reset, mode);

parameter bw = 4;
parameter psum_bw = 16;
parameter psum_bw_minus_bw = 12;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w;
output [bw-1:0] out_e; 
input  [1:0] inst_w; //inst_w[1]: execute, inst[0]: kernel loading
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;
input mode;

input in_w_zero;
input in_n_zero;
output out_s_zero;
output out_e_zero;

reg load_ready_q;

reg [1:0] inst_q;

reg [bw-1:0] a_q;
reg [bw-1:0] b_q;
reg [psum_bw-1:0] c_q;
wire [psum_bw-1:0] mac_out;

reg b_q_zero;
reg a_q_zero;
reg c_q_zero;
reg [psum_bw-1:0] c_q_power_save;

assign out_e = a_q;							    //pass weight/input to out_e during WS and input to out_e during OS
assign inst_e = inst_q;
assign out_s = mode? ((in_n_zero == 1'b1) && (in_w_zero == 1'b1))? {{(psum_bw-1){1'b0}},c_q_zero} : mac_out: {{(psum_bw_minus_bw){1'b0}},b_q};	   	    //pass mac_out to out_s during WS and 4-bit weight to last 4 bits of out_s

assign out_s_zero = (out_s == 16'b0000_0000_0000_0000)? 1'b1: b_q_zero;						    //if weight is zero, pass this information to the PE below
assign out_e_zero = a_q_zero; 

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (			    //mac_out is produced on every positive edge of the clock
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(mac_out)
); 

always @(posedge clk) begin
	if (reset) begin						  //when reset is asserted, reset all registers to 0 and load load_ready_q with 1
		inst_q <= 0;
		load_ready_q <= 1;
		c_q <= 0;
		a_q <= 0;
		b_q <= 0;
	end
	else begin
		if (mode == 1) begin	//weight stationary
			inst_q[1] <= inst_w[1];				//always load inst_q[1] with inst_w[1] (execute information is passed seamlessly)
			if ((inst_w[0] == 1) || (inst_w[1] == 1)) begin  //load a_q and c_q when PE receives either kernel loading or execute instruction
				if (in_w_zero == 1'b0) begin
					a_q <= in_w[bw-1:0];
					c_q <= in_n[psum_bw-1:0];
				end
				else if (in_n_zero == 1'b0) begin
					a_q_zero <= in_w_zero;
					c_q_power_save <= in_n[psum_bw-1:0];
				end
				else begin
					a_q_zero <= in_w_zero;
					c_q_zero <= in_n_zero;
				end
	
				//if ((in_w_zero == 1'b0) || (in_n_zero == 1'b0)) begin
				//	a_q <= in_w[bw-1:0];
				//end
				//else begin
				//	a_q_zero <= in_w_zero;
				//end
				//if ((in_n_zero == 1'b0) || (in_w_zero == 1'b0)) begin
				//	c_q <= in_n[psum_bw-1:0];
				//end
				//else begin
				//	c_q_zero <= in_n_zero;
				//end
			end
			if (inst_w[0] && load_ready_q) begin		   //when kernel loading and load_ready_q are high, load weight into b_q register
				if (in_w_zero == 1'b0) begin
					b_q <= in_w[bw-1:0];
				end
				else begin
					b_q_zero <= in_w_zero;
				end
				load_ready_q <= 0;			    //set back load_ready_q to 0 once weight is loaded
			end
			else if(!load_ready_q) begin			    //when load_ready_q is low, pass the kernel load instruction to other PEs
				inst_q[0] <= inst_w[0];
			end
		end
		else begin	//output stationary
			if (in_w_zero == 1'b0) begin
				a_q <= in_w; 					    //load a_q register with input
			end
			else if (in_w_zero == 1'b1) begin
				a_q_zero <= in_w_zero;
			end
			if (in_n_zero == 1'b0) begin
				b_q <= in_n[bw-1:0];				    //load b_q register with weight from top
			end
			else if (in_n_zero == 1'b1) begin
				b_q_zero <= in_n_zero;
			end
			if ((in_n_zero == 1'b0) || (in_w_zero == 1'b0)) begin
				c_q <= c_q;					    //psum is updated and stored in c_q in the next cycle
			end
		end


	end
end

endmodule

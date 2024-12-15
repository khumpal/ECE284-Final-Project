// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission

//`define CLR_OUT_S tb.clear_out_s
module mac_tile (clk, out_s, out_s_zero, in_w, in_w_zero, out_e, out_e_zero, in_n, in_n_zero, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;


reg load_ready_q;
reg [3:0] a_q;
reg [3:0] b_q;
reg [15:0] c_q;
reg [1:0] inst_q;
output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e; 
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;
input in_w_zero;
input in_n_zero;
output out_e_zero;
output out_s_zero;

wire [psum_bw-1:0] mac_out;
reg a_q_zero; 
reg b_q_zero;
reg c_q_zero;

/*

reg [1:0] inst_q
reg a_q [3:0] 
reg b_q[3:0]
reg c_q[psum_bw-1:0]
reg load_ready_q 
wire macout [psum_bw-1:0]
*/

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.sum_term_zero(in_n_zero),
	.product_term_zero(in_w_zero),
	.out(mac_out)
); 
assign out_s = ((inst_q == 2'b00) | (inst_q == 2'b01)) ? 16'b0000_0000_0000_0000 : mac_out;
assign out_e = a_q;
assign inst_e = inst_q;
assign out_e_zero = a_q_zero;
assign out_s_zero = (a_q_zero) & (c_q_zero);
 
/*
assign inst_e <= inst-q
assign out_s <=c__q
assign out_e <= macout

inst_w[0] = 1 == Kernel load
inst_w[1] = 1 == Execute

always 
    if reset 
        inst_q = 0 //Kernel Load Mode
        load ready = 1 // we are ready to accept the weight
        aq = 0
        bq=0
        cq=0  // initialize and clear everything

    else
        inst_q = inst_w // update the instruction 
        cq = in_n  // brings psum from north to reg

        if inst_w is either in kernel load  or execute
            a_q = in_w // bring a_q into input from west regardless of which mode its in 
        if we are in kernel load & load ready is q
            bq = in w
            set load ready to 0
        if load ready is 0 
            change mode to Execution 
            
        
    


*/
always @ (posedge clk) begin
    if (reset == 1) begin  //on reset clear all registers 
		a_q <= 0;
		b_q <= 0;
		c_q <= 0;
		//inst_q <= 0;
		load_ready_q <= 1'b1;
	end
	else begin
		if (in_n_zero) begin
			c_q_zero <= !in_n_zero;
		end
		//else begin
		c_q <= in_n;  //let input from north be fed into c_q register
		//end
		
		inst_q[1] <= inst_w[1];
		
		if (inst_w[1] == 1  | inst_w[0] ==1) begin // if we are in either mode , send the input from the west into the a_q reg

			if (in_w_zero) begin
				a_q_zero <= !in_w_zero;
			end
			//else begin
			a_q <= in_w;
			//end //if we are in execute, x has to pass through regardless and if in Load, we check
                            // if we want to pass it or store it
		end
		
		if (inst_w[0] ==1  & load_ready_q == 1'b1) begin // if we are in Kernel Load mode
			if (in_w_zero) begin
				b_q_zero <= !in_w_zero;
				//load_ready_q <= 1'b0;
			end
			//else begin
			b_q <= in_w;
			load_ready_q <= 1'b0;
			//end
		end
		//b_q <= in_w;                               // and we havent loaded our desired weight
		//	load_ready_q <= 1'b0;     //load b_q with this value then because it should be our desired weight
		//end
		if (load_ready_q == 1'b0) begin  //only once we have our desired weight loaded
			inst_q[0] <= inst_w[0];   // and it confirms, then pass the load intruction to the neighbro
		end
	end
	//end
end


endmodule

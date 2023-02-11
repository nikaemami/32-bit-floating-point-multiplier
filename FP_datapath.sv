module register8 (input [7:0]pi, input clk, rst, enable, output logic[7:0] po);
	always @ (posedge clk, posedge rst)begin
	  if(rst)
	     po <= 8'd0;
	  else
	     po <= enable ? pi : po;
	end
endmodule

module sign_bit_calc (input [31:0]Abus, Bbus, output logic sign_bit);
	   	assign sign_bit = Abus[31]^Bbus[31];
endmodule

module normalize_mantissa (input [47:0]resultbus_seq_mul, output logic [22:0]mantissa, output logic exp_add);
	logic condition;
	assign condition= resultbus_seq_mul[47];
	assign exp_add= condition ? 1'b1 : 1'b0;
	assign mantissa= condition ? resultbus_seq_mul[46:24] : resultbus_seq_mul[45:23];
endmodule

module add8 (input [7:0]A, B, input cin, output logic[7:0]s, output logic co);
	assign {co,s} = A+B+cin;
endmodule

module mux (input exp_add, output logic [7:0]mux_out);
	assign mux_out = exp_add ? 8'd1 : 8'd0;
endmodule

	
module FP_mul_DP (input clk, rst, load127, input[47:0]resultbus_seq_mul, input[31:0]Abus, Bbus,
		     output logic sign_bit, output logic [7:0]exponent, output logic [22:0]mantissa);
	logic cin;
	logic co1;
	logic co2;
	logic exp_add;
	logic [7:0]sum1;
	logic [7:0]sum2;
	logic [7:0] exp127;
	logic [7:0] po;
	logic [7:0]mux_out;

	sign_bit_calc sign(Abus, Bbus, sign_bit);
	normalize_mantissa normalizedM (resultbus_seq_mul, mantissa, exp_add);

	assign cin=1'b0;
	add8 adder(Abus[30:23], Bbus[30:23], cin, sum1, co1);

	assign exp127=8'b10000001;
	register8 reg1(exp127, clk, rst, load127, po);
	add8 adder1(sum1, po, cin, sum2, co);

	mux mux1(exp_add, mux_out);
	add8 adder2(sum2, mux_out, cin, exponent, co2);

endmodule

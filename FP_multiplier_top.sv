module FP_mul_top (input clk, rst, startFP, input[31:0] Abus, Bbus,output logic [31:0] Outbus, output doneFP);
	wire load127, doneMul, startMul, sign_bit;
	wire [7:0] exponent;
	wire [22:0]mantissa;
	wire [23:0] mantissa_A;
	wire [23:0] mantissa_B;
	wire [47:0] resultbus_seq_mul;
	assign mantissa_A = {1'b1,Abus[22:0]};
	assign mantissa_B = {1'b1,Bbus[22:0]};
	seq_mul_top M(clk, rst, startMul, mantissa_A, mantissa_B, resultbus_seq_mul, doneMul);
	FP_mul_CU cu2(clk, rst, startFP, doneMul, load127, startMul, doneFP);
	FP_mul_DP dp2(clk, rst, load127, resultbus_seq_mul, Abus, Bbus, sign_bit, exponent, mantissa);
	assign Outbus[31]=sign_bit;
	assign Outbus[30:23]=exponent;
	assign Outbus[22:0]= mantissa;
endmodule

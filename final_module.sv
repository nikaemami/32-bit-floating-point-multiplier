module multiplier_top (input clk, rst, inReady, resultAccept, input[31:0] inBus,
			output logic [31:0] Outbus, output inAccept, resultReady);
	wire doneFP;
	wire startFP;
	wire [31:0]Abus;
	wire [31:0]Bbus;
	wire [31:0]FPoutBus;
	FP_mul_top m1(clk, rst, startFP, Abus, Bbus, FPoutBus, doneFP);
	in_wrapper_top m2(clk, rst, doneFP, inReady,  inBus, Abus,Bbus, inAccept, startFP);
	out_wrapper_top m3(clk, rst, doneFP, resultAccept, FPoutBus, OutBus, resultReady);
endmodule

module out_wrapper_top (input clk, rst, doneFP, resultAccept,  input[31:0]FPoutBus, 
			output logic [31:0]outBus, output logic resultReady);
	out_wrapper_DP owdp(clk, rst, resultReady, FPoutBus, outBus);
	out_wrapper_CU owcu(clk, rst, resultAccept, doneFP, resultReady);
endmodule



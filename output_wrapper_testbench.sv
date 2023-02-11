`timescale 1ns/1ns
module out_wrapper_tb();
	logic clk=0, rst=0, doneFP=1, resultAccept=0;
	logic [31:0]FPoutBus;
	wire [31:0]outBus;
	wire resultReady;
	out_wrapper_top CUT6(clk, rst, doneFP, resultAccept, FPoutBus, outBus, resultReady);
	always #10 clk <= ~clk;
	initial begin
	#200 FPoutBus=32'b01000010111110100100000000000000;
	#200 resultAccept=1;
	#200 resultAccept=0;
	#2000 $stop;
	end
endmodule

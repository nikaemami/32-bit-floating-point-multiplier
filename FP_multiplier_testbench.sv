`timescale 1ns/1ns
module FP_mult_tb();
	logic clk=0, rst=0, startFP=0;
	logic [31:0]Abusfp, Bbusfp;
	wire [31:0]Outbus;
	wire doneFP;
	FP_mul_top CUT2(clk, rst, startFP, Abusfp, Bbusfp, Outbus, doneFP);
	always #10 clk <= ~clk;
	initial begin
	//A=125.25
	#60 Abusfp=32'b01000010111110100100000000000000;
	//B=12.0625
	#60 Bbusfp=32'b01000001010000010000000000000000;
	#40 startFP=1;
	#60 startFP=0;
	#2000 $stop;
	end
endmodule

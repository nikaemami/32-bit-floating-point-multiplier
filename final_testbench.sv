`timescale 1ns/1ns
module final_top_tb();
	logic clk=0, rst=0, inReady=0, resultAccept=0;
	logic [31:0]inBus=32'b01000010111110100100000000000000;
	wire [31:0]Outbus;
	wire doneFP;
	multiplier_top CUT7(clk, rst, inReady, resultAccept, inBus, Outbus, inAccept, resultReady);
	always #10 clk <= ~clk;
	initial begin
	#60 inReady=1;
	#60 inReady=0;
	#200 inBus=32'b01000001010000010000000000000000;
	#60 inReady=1;
	#60 inReady=0;
	#1000 resultAccept=1;
	#1000 resultAccept=0;
	#2000 $stop;
	end
endmodule

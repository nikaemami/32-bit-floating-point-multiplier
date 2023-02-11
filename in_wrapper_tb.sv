`timescale 1ns/1ns
module in_wrapper_tb();
	logic clk=0, rst=0, doneFP=0, inReady=1;
	logic [31:0]inBus=32'b01000010111110100100000000000000;
	wire [31:0]ABus;
	wire [31:0]BBus;
	wire inAccept;
	wire startFP;
	in_wrapper_top CUT5(clk, rst, doneFP, inReady, inBus, Abus, Bbus, inAccept, startFP);
	always #10 clk <= ~clk;
	initial begin
	#200 inReady=0;
	#200 inBus=32'b01000001010000010000000000000000;
	#200 inReady=1;
	#200 doneFP=1;
	#200 doneFP=1;
	#200 inReady=0;
	#2000 $stop;
	end
endmodule

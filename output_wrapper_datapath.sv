module register32 (input [31:0]pi, input clk, rst, enable, output logic[31:0] po);
	always @ (posedge clk, posedge rst)begin
	  if(rst)
	     po <= 32'd0;
	  else
	     po <= enable ? pi : po;
	end
endmodule
module out_wrapper_DP (input clk, rst, resultReady, input[31:0]FPoutBus, output logic [31:0]outBus);
	register32 reg1(FPoutBus, clk, rst, resultReady, outBus);
endmodule

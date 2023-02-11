module register32 (input [31:0]pi, input clk, rst, enable, output logic[31:0] po);
	always @ (posedge clk, posedge rst)begin
	  if(rst)
	     po <= 32'd0;
	  else
	     po <= enable ? pi : po;
	end
endmodule
module in_wrapper_DP (input clk, rst, loadA, loadB, input[31:0]inBus, output logic [31:0]Abus,Bbus);
	register32 regA(inBus, clk, rst, loadA, Abus);
	register32 regB(inBus, clk, rst, loadB, Bbus);
endmodule

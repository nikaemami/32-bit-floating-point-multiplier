module seq_mul_DP_v(input clk, rst, loadA, loadB, loadP, shiftA, initP, Bsel,
                  input [23:0]Abus, Bbus, output [47:0]resultbus_Mul, output A0);
	reg [23:0]Alogic, Blogic, Plogic;
	wire[23:0]B_and;
	wire[24:0]Addbus;
	always @(posedge clk, posedge rst)begin
	  if (rst)
	      Blogic <= 24'b0;
	  else
	      Blogic <= Bbus;
	end
	always @(posedge clk, posedge rst)begin
	  if (rst)
	      Plogic <= 24'b0;
	  else begin
	        if (initP)
	          Plogic <= 24'b0;
	        else
		  if (loadP)
		    Plogic <= Addbus[24:1];
	       end
	end
	always @(posedge clk, posedge rst)begin
	  if (rst)
	      Alogic <= 24'b0;
	  else begin
	         if (loadA)
	           Alogic <= Abus;
	         else
		   if (shiftA)
		     Alogic <= {Addbus[0],Alogic[23:1]};
	       end
	end
	assign B_and = Bsel ? Blogic : 24'b0;
	assign Addbus = B_and + Plogic;
	assign resultbus_Mul = {Plogic, Alogic};
	assign A0= Alogic[0];
endmodule
module seq_mul_CU_v (input clk, rst, startMul, A0, output reg loadA, shiftA, loadB, loadP,
                   initP, Bsel, doneMul);
	wire Co;
	reg init_counter, inc_counter;
	reg [1:0] pstate, nstate;
	reg [4:0] count_mul;
	parameter [1:0]
	Idle=0, init=1, load=2, shift=3;
	always @(pstate, startMul, A0, Co)begin
	nstate=0;
	{loadA, shiftA, loadB, loadP, initP, Bsel, doneMul}=7'b0;
	{init_counter, inc_counter}=2'b0;
	   case(pstate)
	      Idle: begin nstate= startMul ? init : Idle; doneMul=1'b1; end
	      init: begin nstate= startMul ? init : load; init_counter=1'b1; initP=1'b1; end
	      load: begin nstate= shift ; loadA=1'b1; loadB=1'b1; end
	      shift: begin nstate= Co ? Idle : shift; loadP=1'b1; shiftA=1'b1; inc_counter=1'b1; Bsel=A0; end
	      default: nstate = Idle;
           endcase
	end
	always @(posedge clk, posedge rst)begin
	  if (rst)
	      pstate <= Idle;
	  else
	      pstate <= nstate;
	end
	always @(posedge clk, posedge rst)begin
	  if (rst) count_mul <= 5'b0;
	  else
	     if (init_counter) count_mul <= 5'b0;
		else
		   if(inc_counter) count_mul <= count_mul + 1;
	end
	assign Co = (count_mul==23)? 1'b1 : 1'b0;
endmodule
module quartus_seqmul (input clk, rst, startMul, input[23:0] A, B, output [47:0]resultbus, output doneMul);
	wire A0;
	wire loadA, shiftA, loadB, loadP, initP, Bsel;
	seq_mul_DP_v dpv(clk, rst, loadA, loadB, loadP, shiftA, initP, Bsel, A, B, resultbus, A0);
	seq_mul_CU_v cuv(clk, rst, startMul, A0, loadA, shiftA, loadB, loadP, initP, Bsel, doneMul);
endmodule
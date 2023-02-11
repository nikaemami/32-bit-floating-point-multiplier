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
module register8_v (input [7:0]pi, input clk, rst, enable, output reg[7:0]po);
	always @ (posedge clk, posedge rst)begin
	  if(rst)
	     po <= 8'd0;
	  else
	     po <= enable ? pi : po;
	end
endmodule

module sign_bit_calc_v (input [31:0]Abus, Bbus, output  sign_bit);
	   	assign sign_bit = Abus[31]^Bbus[31];
endmodule

module normalize_mantissa_v (input [47:0]resultbus_seq_mul, output  [22:0]mantissa, output  exp_add);
	wire condition;
	assign condition= resultbus_seq_mul[47];
	assign exp_add= condition ? 1'b1 : 1'b0;
	assign mantissa= condition ? resultbus_seq_mul[46:24] : resultbus_seq_mul[45:23];
endmodule

module add8_v (input [7:0]A, B, input cin, output [7:0]s, output  co);
	assign {co,s} = A+B+cin;
endmodule

module mux_v (input exp_add, output  [7:0]mux_out);
	assign mux_out = exp_add ? 8'd1 : 8'd0;
endmodule

	
module FP_mul_DP_v (input clk, rst, load127, input[47:0]resultbus_seq_mul, input[31:0]Abus, Bbus,
		     output  sign_bit, output  [7:0]exponent, output  [22:0]mantissa);
	wire cin;
	wire co1;
	wire co2;
	wire exp_add;
	wire [7:0]sum1;
	wire [7:0]sum2;
	wire [7:0] exp127;
	wire [7:0] po;
	wire [7:0]mux_out;

	sign_bit_calc_v signv(Abus, Bbus, sign_bit);
	normalize_mantissa_v normalizedMv (resultbus_seq_mul, mantissa, exp_add);

	assign cin=1'b0;
	add8_v adderv(Abus[30:23], Bbus[30:23], cin, sum1, co1);

	assign exp127=8'b10000001;
	register8_v reg1v(exp127, clk, rst, load127, po);
	add8_v adder1_v(sum1, po, cin, sum2, co);

	mux_v mux1v(exp_add, mux_out);
	add8_v adder2v(sum2, mux_out, cin, exponent, co2);

endmodule
module FP_mul_CU_v (input clk, rst, startFP, doneMul, output reg load127, startMul, doneFP);
	reg [2:0] pstate_fp, nstate_fp;
	parameter [2:0]
	Idle_fp=0, start_fp=1, go=2, wait_mul=3, calculate=4;
	always @(pstate_fp, startFP, doneMul)begin
	nstate_fp=0;
	{load127, startMul, doneFP}=3'b0;
	   case(pstate_fp)
	      Idle_fp: begin nstate_fp= startFP ? start_fp : Idle_fp; doneFP=1'b1; end
	      start_fp: begin nstate_fp= startFP ? start_fp : go; load127=1'b1; end
	      go: begin nstate_fp= wait_mul; startMul=1'b1; end
	      wait_mul: begin nstate_fp= doneMul ? calculate : wait_mul; end
	      calculate: begin nstate_fp= Idle_fp; end
	      default: nstate_fp = Idle_fp;
           endcase
	end
	always @(posedge clk, posedge rst)begin
	  if (rst)
	      pstate_fp <= Idle_fp;
	  else
	      pstate_fp <= nstate_fp;
	end
endmodule
module quartus_FPmultiplier (input clk, rst, startFP, input[31:0] Abus, Bbus,output  [31:0] Outbus, output doneFP);
	wire load127, doneMul, startMul, sign_bit;
	wire [7:0] exponent;
	wire [22:0]mantissa;
	wire [23:0] mantissa_A;
	wire [23:0] mantissa_B;
	wire [47:0] resultbus_seq_mul;
	assign mantissa_A = {1'b1,Abus[22:0]};
	assign mantissa_B = {1'b1,Bbus[22:0]};
	quartus_seqmul Mv(clk, rst, startMul, mantissa_A, mantissa_B, resultbus_seq_mul, doneMul);
	FP_mul_CU_v cu2v(clk, rst, startFP, doneMul, load127, startMul, doneFP);
	FP_mul_DP_v dp2v(clk, rst, load127, resultbus_seq_mul, Abus, Bbus, sign_bit, exponent, mantissa);
	assign Outbus[31]=sign_bit;
	assign Outbus[30:23]=exponent;
	assign Outbus[22:0]= mantissa;
endmodule
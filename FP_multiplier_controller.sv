module FP_mul_CU (input clk, rst, startFP, doneMul, output logic load127, startMul, doneFP);
	logic [2:0] pstate_fp, nstate_fp;
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
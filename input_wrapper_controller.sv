module in_wrapper_CU (input clk, rst, inReady, doneFP, output logic inAccept, startFP, loadA, loadB);
	logic [3:0] pstate_w, nstate_w;
	parameter [3:0]
	Idle_w=0, loadingA=1, acceptA=2, waitB=3, loadingB=4, acceptB=5, wait_done=6, start_the_fp=7;
	always @(pstate_w, inReady, doneFP)begin
	nstate_w=0;
	{inAccept,startFP, loadA, loadB}=4'b0;
	   case(pstate_w)
	      Idle_w: begin nstate_w= inReady ? loadingA : Idle_w; end
	      loadingA: begin nstate_w= acceptA; loadA=1'b1; end
	      acceptA: begin nstate_w= inReady ? acceptA : waitB; inAccept=1'b1; end
	      waitB: begin nstate_w= inReady ? loadingB : waitB; end
	      loadingB: begin nstate_w= acceptB; loadB=1'b1; end
	      acceptB: begin nstate_w= inReady ? acceptB : wait_done; inAccept=1'b1; end
	      wait_done: begin nstate_w= doneFP ? start_the_fp : wait_done; end
	      start_the_fp: begin nstate_w= Idle_w; startFP=1; end
	      default: nstate_w = Idle_w;
           endcase
	end
	always @(posedge clk, posedge rst)begin
	  if (rst)
	      pstate_w <= Idle_w;
	  else
	      pstate_w <= nstate_w;
	end
endmodule

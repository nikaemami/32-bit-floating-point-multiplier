module out_wrapper_CU (input clk, rst, resultAccept, doneFP, output logic resultReady);
	logic [1:0] pstate_wo, nstate_wo;
	parameter [1:0]
	empty=0, recieve_data=1, wait_accept=2, sure_accept=3;
	always @(pstate_wo, resultAccept, doneFP)begin
	nstate_wo=0;
	{resultReady}=1'b0;
	   case(pstate_wo)
	      empty: begin nstate_wo= doneFP ? recieve_data : empty; end
	      recieve_data: begin nstate_wo= wait_accept; end
	      wait_accept: begin nstate_wo= resultAccept ? sure_accept : wait_accept; resultReady=1'b1;end
	      sure_accept: begin nstate_wo= resultAccept ? sure_accept : empty; end
	      default: nstate_wo = empty;
           endcase
	end
	always @(posedge clk, posedge rst)begin
	  if (rst)
	      pstate_wo <= empty;
	  else
	      pstate_wo <= nstate_wo;
	end
endmodule

module screenWipe_Datapath(clk, init, incr, x0, y0, x1, y1);
    input logic clk;
    input logic init, incr;
	
	 output logic [8:0] y0, y1;		
    output logic [9:0] x0, x1;
    
    always_ff @(posedge clk)begin
		//Initialize starting location for reset
		if(init) begin
		  	x0 <= 0;
			y0 <= 0;
			x1 <= 639;
			y1 <= 0;	
		end
		else if(incr) begin
			y0 <= y0 + 1;
			y1 <= y1 + 1;
		end
	end//always_ff
endmodule

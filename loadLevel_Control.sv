`timescale 1 ps / 1 ps

module loadLevel_Control(clk, reset, start, levelSel, memAddr0, memAddr1, regLoc0, regLoc1, ready, done); 
	input logic clk, reset;
	input logic start, levelSel;
	
	output logic ready, done;
	output logic [5:0] regLoc0, regLoc1;
	output logic [6:0] memAddr0, memAddr1;
	
	logic init;
	logic [4:0] count;

	enum {s_idle, s_loop, s_load, s_done} ps, ns;
	
	always_ff @(posedge clk)
		if(reset)
			ps <= s_idle;
		else
			ps <= ns;
	
	always_comb begin
		case(ps)
			s_idle: ns = start ? s_load:s_idle;
			s_loop: ns = (count == 29) ? s_done:s_load;
			s_load: ns = s_loop;
			s_done: ns = start ? s_done:s_idle;
		endcase
	end

	always_ff @(posedge clk)begin
		if(init) count <= 0;
		if(ps == s_loop) count <= count + 1;
	end

	assign done = ps == s_done;
	assign ready = ps == s_idle;
	assign init = (ps == s_idle) & start;
	assign memAddr0 = levelSel ? (count + 60):count;
	assign memAddr1 = levelSel ? (count + 60 + 30):(count + 30);
	assign regLoc0 = count;
	assign regLoc1 = count + 30;

endmodule


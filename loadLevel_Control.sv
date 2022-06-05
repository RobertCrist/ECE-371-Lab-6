`timescale 1 ps / 1 ps
/*
	loadLevel_Control: Control logic for loadLevel
	
	Ports:
		clk: 			The clock drives the timing (1-bit)
		reset:		A reset signal for the system (1-bit)
		start: 		Input signal to load the level from memory (1-bit)
		levelSel:	Input signal with address of level to load from memory (1-bit)
		ready:		Output signal describing if level is ready to be loaded (1-bit)
		done:			Output signal describing if level loading is done (1-bit)
		memAddr0:	Memory address 0 output (7-bits)
		memAddr1:	Memory address 1 output (7-bits)
		regLoc0:		regLoc 0 output (6-bits)
		regLoc1L		regLoc 1 output (6-bits)
*/
module loadLevel_Control(clk, reset, start, levelSel, memAddr0, memAddr1, regLoc0, regLoc1, ready, done); 
	input logic clk, reset;
	input logic start;
	input logic [1:0] levelSel;
	
	output logic ready, done;
	output logic [5:0] regLoc0, regLoc1;
	output logic [7:0] memAddr0, memAddr1;
	
	logic init;
	logic [4:0] count;
	//instantiation of names of states

	enum {s_idle, s_loop, s_load, s_done} ps, ns;
	//State transition
	
	always_ff @(posedge clk)
		if(reset)
			ps <= s_idle;
		else
			ps <= ns;
	//always_ff


	//State transition logic
	always_comb begin
		case(ps)
			s_idle: ns = start ? s_load:s_idle;
			s_loop: ns = (count == 29) ? s_done:s_load;
			s_load: ns = s_loop;
			s_done: ns = start ? s_done:s_idle;
		endcase
	end //always_comb

	always_ff @(posedge clk)begin
		if(init) count <= 0;
		if(ps == s_loop) count <= count + 1;
	end

	assign done = ps == s_done;
	assign ready = ps == s_idle;
	assign init = (ps == s_idle) & start;
	assign memAddr0 = count + 60*levelSel;
	assign memAddr1 = (count + 30) + 60*levelSel;
	assign regLoc0 = count;
	assign regLoc1 = count + 30;

endmodule


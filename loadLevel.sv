`timescale 1 ps / 1 ps
/*
	loadLevel: Loads level from RAM Module
	
	Ports:
		clk: 			The clock drives the timing (1-bit)
		reset:		A reset signal for the system (1-bit)
		start: 		Input signal to load the level from memory (1-bit)
		levelSel:	Input signal with address of level to load from memory (1-bit)
		currLevel	Output signal of which level is loaded (80 x 60 bits)
		ready:		Output signal describing if level is ready to be loaded (1-bit)
		done:			Output signal describing if level loading is done (1-bit)
*/
module loadLevel(clk, reset, start, levelSel, currLevel, ready, done);
	input logic clk, reset;
	input logic start;
	input logic [1:0] levelSel;

	output logic ready, done;
	//Array to store loaded level from memory
	output logic [79:0]currLevel[59:0];

	logic [5:0] regLoc0, regLoc1;
	logic [7:0] memAddr0, memAddr1;
	
	logic [79:0]  memData0, memData1;

	//Control logic for loading level
	loadLevel_Control control_unit(.clk, .reset, .start, .levelSel, .memAddr0, .memAddr1, .regLoc0, .regLoc1, .ready, .done);
	//RAM Module instantiation
	mazeMemory mem_unit(.address_a(memAddr0), .address_b(memAddr1), .clock(clk), .q_a(memData0), .q_b(memData1));

	always_ff @(posedge clk) begin
		if(~ready) begin
			currLevel[regLoc0] <= memData0;
			currLevel[regLoc1] <= memData1;
		end
		else currLevel <= currLevel;
	end //always_ff
endmodule	 //loadlLevel

module loadLevel_testbench();
	logic clk, reset;
	logic start; 
	logic [1:0] levelSel;

	logic ready, done;
	logic [79:0]currLevel[59:0];

	loadLevel dut(.*);

	parameter T = 20;
	
	initial begin
		clk <= 0;
		forever #(T/2) clk <= ~clk;
	end  // clock initial

	initial begin
		reset <= 1; 							@(posedge clk);
		reset <= 0; start <=0; levelSel <= 0; 	@(posedge clk);
		repeat(5)								@(posedge clk);	
		
		start <= 1; 							@(posedge clk);
		start <= 0; 							@(posedge clk);
												@(posedge done);
		repeat(50)								@(posedge clk);

		levelSel <= 1;							@(posedge clk);
		start <= 1; 							@(posedge clk);
		start <= 0; 							@(posedge clk);
												@(posedge done);
		repeat(5)								@(posedge clk);
		$stop;
	end
endmodule
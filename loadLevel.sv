`timescale 1 ps / 1 ps

module loadLevel(clk, reset, start, levelSel, currLevel, ready, done);
	input logic clk, reset;
	input logic start, levelSel;

	output logic ready, done;
	output logic [79:0]currLevel[59:0];

	logic [5:0] regLoc0, regLoc1;
	logic [6:0] memAddr0, memAddr1;
	
	logic [79:0]  memData0, memData1;


	loadLevel_Control control_unit(.clk, .reset, .start, .levelSel, .memAddr0, .memAddr1, .regLoc0, .regLoc1, .ready, .done);

	mazeMemory mem_unit(.address_a(memAddr0), .address_b(memAddr1), .clock(clk), .q_a(memData0), .q_b(memData1));

	always_ff @(posedge clk) begin
		if(~ready) begin
			currLevel[regLoc0] <= memData0;
			currLevel[regLoc1] <= memData1;
		end
		else currLevel <= currLevel;
	end
endmodule	

module loadLevel_testbench();
	logic clk, reset;
	logic start, levelSel;

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
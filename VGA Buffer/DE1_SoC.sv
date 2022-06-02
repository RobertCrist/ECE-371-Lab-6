module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;

	logic reset, ready;
	logic [9:0] x, leftBound, rightBound;
	logic [8:0] y, topBound, botBound;
	logic [7:0] r, g, b;
	
	logic [31:0] div_clk;
	
	logic [79:0]currLevel[59:0];
	//logic [79:0] drawRow, hitDectectRow;
//	genvar i;
//	generate 
//		for(i = 0; i < 29; i++) begin: loop1
//			assign currLevel[i] = 80'b0;
//		end
//	endgenerate
//	
//	generate 
//		for(i = 32; i < 60; i++) begin: loop2
//			assign currLevel[i] = 80'b0;
//		end
//	endgenerate
//	
//	assign currLevel[29] = {{30{1'b1}}, {20{1'b0}}, {30{1'b1}}};
//	assign currLevel[30] = {{30{1'b1}}, {20{1'b0}}, {30{1'b1}}};
//	assign currLevel[31] = {{30{1'b1}}, {20{1'b0}}, {30{1'b1}}};
	
	//Clock select for divided clock to slow down animations
	logic clkSelect;
	assign clkSelect = div_clk[20];

	clock_divider cdiv (.clock(CLOCK_50),
	.reset(~KEY[3]),
	.divided_clocks(div_clk));
	
//	always_ff @(posedge CLOCK_50) begin
//		if(y > 100)begin
//			r <= 255;
//		end
//	end

	logic reset_wire, up, down, left, right, up_wire, down_wire, left_wire, right_wire, start, start_wire, levelSel, levelSel_wire;
	logic [5:0] regLoc0, regLoc1;
	logic [6:0] memAddr0, memAddr1;

	always_ff @(posedge CLOCK_50)begin
		//reset for line drawer
		reset_wire <= SW[9];
		reset <= reset_wire;

		up_wire <= ~KEY[2];
		down_wire <= ~KEY[3];
		left_wire <= ~KEY[1];
		right_wire <= ~KEY[0];

		up <= up_wire;
		down <= down_wire;
		left <= left_wire;
		right <= right_wire;

		start_wire <= SW[0];
		start <= start_wire;

		levelSel_wire <= SW[1];
		levelSel <= levelSel_wire;
	end //always_ff
	
	//mazeMemory(.address_a(y>>3), .address_b(), .clock(CLOCK_50), .q_a(drawRow), .q_b(currLevel));
	
	playerControl player_unit (.clk(clkSelect), .reset, .up, .down, .left, .right, .currLevel(currLevel), .topBound, .botBound, .leftBound, .rightBound);

	loadLevel(.clk(CLOCK_50), .reset, .start, .levelSel, .currLevel, .ready, .done());
	
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	always_ff @(posedge CLOCK_50) begin
		// r <= SW[7:0];
		// g <= x[7:0];
		// b <= y[7:0];
		if(y == topBound & x == leftBound) begin
		    r <= 255;
			b <= 0;
			g <= 0;
		end 
		else if(y <= topBound & y >= botBound & x >= leftBound & x <= rightBound) begin
			r <= 0;
			b <= 0;
			g <= 255;
		end
		else if (currLevel[y>>3][x>>3]) begin
			r <= 0;
			b <= (255);
			g <= 0;
		end
		else begin
		    r <= 0;
			b <= (0);
			g <= 0;
		end

	end
	
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	
endmodule

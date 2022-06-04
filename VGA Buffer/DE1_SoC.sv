/* Top level module of the FPGA that takes the onboard resources 
 * as input and outputs the lines drawn from the VGA port.
 *
 * Inputs:
 *   KEY 			- On board keys of the FPGA
 *   SW 				- On board switches of the FPGA
 *	  V_GPIO			- Off board N8 Controller for the FPGA	
 *   CLOCK_50 		- On board 50 MHz clock of the FPGA
 *
 * Outputs:
 *   HEX 			- On board 7 segment displays of the FPGA
 *   LEDR 			- On board LEDs of the FPGA
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 			- Blue data of the VGA connection
 *   VGA_BLANK_N 	- Blanking interval of the VGA connection
 *   VGA_CLK 		- VGA's clock signal
 *   VGA_HS 		- Horizontal Sync of the VGA connection
 *   VGA_SYNC_N 	- Enable signal for the sync of the VGA connection
 *   VGA_VS 		- Vertical Sync of the VGA connection
 */
 module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS, V_GPIO, KEY, SW);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	
	inout logic [28:26] V_GPIO;
	
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

	
	//Clock select for divided clock to slow down animations
	logic clkSelect;
	assign clkSelect = div_clk[20];

	clock_divider cdiv (.clock(CLOCK_50),
	.reset(reset_wire),
	.divided_clocks(div_clk));
	
	//Logical Wires for player controls and map loading
	logic reset_wire, up, down, left, right, start, start_wire, levelSel, levelSel_wire, select;
	logic [5:0] regLoc0, regLoc1;
	logic [6:0] memAddr0, memAddr1;

	always_ff @(posedge CLOCK_50)begin
		//reset for line drawer
		reset_wire <= SW[9];
		reset <= reset_wire;

		start_wire <= SW[0];
		start <= start_wire;

		levelSel_wire <= SW[1];
		levelSel <= levelSel_wire;
	end //always_ff
	   
	//Instantiation of N8 Controller Driver
	n8_driver driver(
        .clk(CLOCK_50),
        .data_in(V_GPIO[28]),
        .latch(V_GPIO[26]),
        .pulse(V_GPIO[27]),
        .up,
        .down,
        .left,
        .right,
        .select(),
        .start(),
        .a(),
        .b()
    );
   
	//Player controller instantiation
	playerControl player_unit (.clk(clkSelect), .reset, .up(down), .down(up), .left, .right, .currLevel(currLevel), .topBound, .botBound, .leftBound, .rightBound);
	
	//Level Loading instantiation
	loadLevel load(.clk(CLOCK_50), .reset(reset_wire), .start(start_wire), .levelSel, .currLevel, .ready, .done());
	
	//VGA Video Driver instantiation
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	always_ff @(posedge CLOCK_50) begin
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
	end //always_ff
	
endmodule //DE1_SoC

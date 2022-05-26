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

	logic reset;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	
	logic [31:0] div_clk;
	
	//Clock select for divided clock to slow down animations
	assign clkSelect = div_clk[17];

	clock_divider cdiv (.clock(CLOCK_50),
	.reset(~KEY[3]),
	.divided_clocks(div_clk));

	logic reset_wire, screenWipe_start_wire, screenWipe_start;
	logic ready_SCW, done_SCW;
	
	logic [8:0] y0, y1, y0_SCW, y1_SCW;		
   logic [9:0] x0, x1, x0_SCW, x1_SCW;
	always_ff @(posedge CLOCK_50)begin
		//reset for line drawer
		reset_wire <= ~KEY[3];
		reset <= reset_wire;

		screenWipe_start_wire <= ~KEY[0];
		screenWipe_start <= screenWipe_start_wire;
	end //always_ff

	screenWipe(.clk(clkSelect), .reset, .start(screenWipe_start), .ready(ready_SCW), .done(done_SCW), .x0(x0_SCW), .y0(y0_CSW), .x1(x1_SCW), .y1(y1_SCW));

	assign x0 = ready_SCW ? 0:x0_SCW;
	assign y0 = ready_SCW ? 0:y0_SCW; 
	assign x1 = ready_SCW ? 100:x1_SCW;
	assign y1 = ready_SCW ? 100:y1_SCW; 

	line_drawer draw_unit(.clk(CLOCK_50), .reset, .x0, .y0, .x1, .y1, .x, .y);

	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	always_ff @(posedge CLOCK_50) begin
		r <= SW[7:0];
		g <= x[7:0];
		b <= y[7:0];
	end
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	
endmodule

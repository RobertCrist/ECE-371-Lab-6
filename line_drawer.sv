/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *	 x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 * Outputs:
 *   x 		- x coordinate of the pixel to color
 *   y 		- y coordinate of the pixel to color
 *   done	- flag that line has finished drawing
 *
 */
module line_drawer(clk, reset, x0, y0, x1, y1, x, y, done);
	input logic clk, reset;
	input logic [8:0] y0, y1;		
   input logic [9:0] x0, x1;
	
	output logic done;
	output logic [8:0] y;		
   output logic [9:0] x;
	
	logic x0_eq_x1, x0_gt_x1, loadRegs, calcSteep, steepSwap, xSwap, incr_x0, y0_eq_y1, y0_gt_y1, 
					update_y0, calcDelta, calcError, update_out, update_Error, is_steep, error_gte_0;
	
	/* You'll need to create some registers to keep track of things
	 * such as error and direction.
	 */
		
	drawLine_control c_unit(.*);
	drawLine_datapath d_unit(.*);
	
endmodule  // line_drawer

module line_drawer_testbench();
	logic clk, reset;
	logic [10:0]	x0, y0, x1, y1;
	logic done;
	logic [10:0]	x, y;
	
	
	line_drawer det(.*);
	
	parameter T = 20;
	
	initial begin
		clk <= 0;
		forever #(T/2) clk <= ~clk;
	end  // clock initial
	
	initial begin
		//up left not steep
		
		
		reset <= 1;	x1 <= 11'd5; y1 <= 11'd9; x0 <= 11'd10; y0 <= 11'd10;	@(posedge clk);
		$display("Point 0: (%2d, %2d) Point 1: (%2d, %2d)", x0 ,y0, x1, y1);
		reset <= 0;																			@(posedge clk);
		$monitor("T = %4t, Path point: (%2d, %2d)", $time, x, y);
		
																								@(posedge done);
																								@(posedge clk);
		$display();
		//up left steep
		x1 <= 11'd9; y1 <= 11'd5; x0 <= 11'd10; y0 <= 11'd10;					@(posedge clk);
		$display("Point 0: (%2d, %2d) Point 1: (%2d, %2d)", x0 ,y0, x1, y1);
																								@(posedge done);
																								@(posedge clk);
		$display();
		//up right steep
		x1 <= 11'd11; y1 <= 11'd5; x0 <= 11'd10; y0 <= 11'd10;				@(posedge clk);
		$display("Point 0: (%2d, %2d) Point 1: (%2d, %2d)", x0 ,y0, x1, y1);
																								@(posedge done);
																								@(posedge clk);
		$display();
		//up right not steep
		x1 <= 11'd15; y1 <= 11'd9; x0 <= 11'd10; y0 <= 11'd10;				@(posedge clk);
		$display("Point 0: (%2d, %2d) Point 1: (%2d, %2d)", x0 ,y0, x1, y1);
																								@(posedge done);
																								@(posedge clk);
		$display();
		//bottom right not steep
		x1 <= 11'd15; y1 <= 11'd11; x0 <= 11'd10; y0 <= 11'd10;				@(posedge clk);
		$display("Point 0: (%2d, %2d) Point 1: (%2d, %2d)", x0 ,y0, x1, y1);
																								@(posedge done);
																								@(posedge clk);
		$display();
		//bottom right steep
		x1 <= 11'd11; y1 <= 11'd15; x0 <= 11'd10; y0 <= 11'd10;				@(posedge clk);
		$display("Point 0: (%2d, %2d) Point 1: (%2d, %2d)", x0 ,y0, x1, y1);
																								@(posedge done);
																								@(posedge clk);
		$display();
		//bottom left steep
		x1 <= 11'd9; y1 <= 11'd15; x0 <= 11'd10; y0 <= 11'd10;				@(posedge clk);
		$display("Point 0: (%2d, %2d) Point 1: (%2d, %2d)", x0 ,y0, x1, y1);
																								@(posedge done);
																								@(posedge clk);
		$display();
		//bottom left not steep
		x1 <= 11'd5; y1 <= 11'd11; x0 <= 11'd10; y0 <= 11'd10;				@(posedge clk);
		$display("Point 0: (%2d, %2d) Point 1: (%2d, %2d)", x0 ,y0, x1, y1);
																							@(posedge done);
																								@(posedge clk);
																		
//		x1 <= 11'd240; y1 <= 11'd340; x0 <= 11'd340; y0 <= 11'd240;				@(posedge clk);
//		$display("Point 0: (%2d, %2d) Point 1: (%2d, %2d)", x0 ,y0, x1, y1);
//																								@(posedge done);
//																								@(posedge clk);
//		$display();
//		
//		x1 <= 11'd260; y1 <= 11'd340; x0 <= 11'd340; y0 <= 11'd240;				@(posedge clk);
//		$display("Point 0: (%2d, %2d) Point 1: (%2d, %2d)", x0 ,y0, x1, y1);
//																								@(posedge done);
//																								@(posedge clk);
		$display();
		$stop;
	end
endmodule //line_drawer_testbench

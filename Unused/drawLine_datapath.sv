/* Draw-Line DataPath logic 
*	Ports:
*		clk:			Clock from DE1_SoC (1-bit)
*		reset:			reset signal from user, resets to state S_idle (1-bit)
*		x0_eq_x1:		Outputs True if x0 == x1 (1-bit)
*		x0_gt_x1:		Outputs True if x0 > x1 (1-bit)
*		y0_eq_y1:		Outputs True if y0 == y1 (1-bit)
*		is_steep:		Outputs True if slope is considered steep (1-bit)
*		error_gte_0:	Outputs True if the error > 0 (1-bit)
*		loadRegs:		Loads regs if true (1-bit)
*		calcSteep:		Calculates steep when true (1-bit)
*		steepSwap:		Swaps x0 y0 and x1 and y1 when true (1-bit)
*		xSwap:			Swaps x0 and x1 when true (1-bit)
*		calcDelta:		Calculates delta when true (1-bit)
*		calcError:		Calculates error when true (1-bit)
*		update_out:		Updates x and y when true (1-bit)
*		update_Error:	Updates error when true (1-bit)
*		incr_x0:		Increments x0 when true (1-bit)
*		update_y0:		Updates the value of y0 when true (1-bit)
*		x0:				x0 input from user (1-bit)
*		x1:				x1 input from user (1-bit)
*		y0:				y0 input from user (1-bit)
*		y1:				y1 input from user (1-bit)
*/
module drawLine_datapath(clk, reset, loadRegs, calcSteep, steepSwap, xSwap, calcDelta, 
									calcError, update_out, update_Error, incr_x0, update_y0, x0, y0, x1, y1, x0_eq_x1, y0_eq_y1, x0_gt_x1, is_steep, error_gte_0, x, y);
	//port logic instantiations
	input logic clk, reset;
	input logic loadRegs, calcSteep, steepSwap, xSwap, calcDelta, calcError, 
						update_out, update_Error, incr_x0, update_y0;
	input logic [8:0] y0, y1;		
   input logic [9:0] x0, x1;
	
	output logic x0_eq_x1, y0_eq_y1, x0_gt_x1, is_steep, error_gte_0;
	output logic [8:0] y;		
   output logic [9:0] x;
	
	//internal logic instantiation
	logic y0_gt_y1;
	logic signed [10:0] y_step;
	logic [10:0] x0_mem, y0_mem, x1_mem, y1_mem; 
	logic signed [10:0] deltaX, deltaY, error;

	//Conidtional output RTL declarations
	always_ff @(posedge clk)begin
		if(loadRegs) begin //loads regs
			x0_mem <= x0;
			x1_mem <= x1;
			y0_mem <= y0;
			y1_mem <= y1;
		end
		//checks if slope is steep
		if(calcSteep) is_steep <= (((y0_mem>y1_mem) ? (y0_mem-y1_mem) : (y1_mem-y0_mem)) > ((x0_mem>x1_mem) ? (x0_mem-x1_mem):(x1_mem-x0_mem)));
		//if steep then swap
		if(steepSwap) begin
			x0_mem <= y0_mem;
			x1_mem <= y1_mem;
			y0_mem <= x0_mem;
			y1_mem <= x1_mem;
		end
		//swap x values and y values
		if(xSwap) begin
			x0_mem <= x1_mem;
			x1_mem <= x0_mem;
			y0_mem <= y1_mem;
			y1_mem <= y0_mem;
		end
		//calculate the delta for x and y
		if(calcDelta) begin
			deltaX <= x1_mem - x0_mem;
			deltaY <= y0_gt_y1 ? (y0_mem - y1_mem):(y1_mem - y0_mem);
		end
		//calculate the error
		if(calcError) error <= ~(deltaX >> 1) + 1;
		//updates the x and y values
		if(update_out) begin
			x <= is_steep ? y0_mem:x0_mem;
			y <= is_steep ? x0_mem:y0_mem;
		end
		//updates the error
		if(update_Error) begin
			error <= error + deltaY;
		end
		//increments x
		if(incr_x0) x0_mem <= x0_mem + 1;
		//updates y value
		if(update_y0) begin
			y0_mem <= y0_mem + y_step;
			error <= error - deltaX;
		end
	end //always_ff
	
	//Conditional RTL value checks
	assign x0_gt_x1 = (x0_mem > x1_mem);
	assign y_step = y0_gt_y1 ? -1: 1;
	assign y0_gt_y1 = (y0_mem > y1_mem);
	
	assign x0_eq_x1 = (x0_mem == x1_mem);
	
	assign y0_eq_y1 = (y0_mem == y1_mem);
	
	assign error_gte_0 = (error > 0) | (error == 0);
endmodule //drawLine_datapath

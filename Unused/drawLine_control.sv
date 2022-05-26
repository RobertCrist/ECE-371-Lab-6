/* Draw-Line control logic 
*	Ports:
*		clk:			Clock from DE1_SoC (1-bit)
*		reset:			reset signal from user, resets to state S_idle (1-bit)
*		x0_eq_x1:		True if x0 == x1 (1-bit)
*		x0_gt_x1:		True if x0 > x1 (1-bit)
*		y0_eq_y1:		True if y0 == y1 (1-bit)
*		is_steep:		True if slope is considered steep (1-bit)
*		error_gte_0:	True if the error > 0 (1-bit)
*		loadRegs:		Outputs true if in the s_idle (1-bit)
*		calcSteep:		Outputs true if in calcSteep (1-bit)
*		steepSwap:		Outputs true if in steepSwap (1-bit)
*		xSwap:			Outputs true if in xSwap (1-bit)
*		calcDelta:		Outputs true if in delta (1-bit)
*		calcError:		Outputs true if in error (1-bit)
*		update_out:		Outputs true if in loop (1-bit)
*		update_Error:	Outputs true if in loop & ~x0_eq_x1 (1-bit)
*		incr_x0:		Outputs true when incrementing x0 (1-bit)
*		update_y0:		True when updating the value of y0 (1-bit)
*		done:			true if algorithim is in done state (1-bit)
*/
module drawLine_control(clk, reset, x0_eq_x1, x0_gt_x1, y0_eq_y1, is_steep, error_gte_0, loadRegs, calcSteep, steepSwap, xSwap, calcDelta, 
									calcError, update_out, update_Error, incr_x0, update_y0, done);
	input logic clk, reset;
	input logic x0_eq_x1, x0_gt_x1, y0_eq_y1, is_steep, error_gte_0;
	
	output logic loadRegs, calcSteep, steepSwap, xSwap, calcDelta, calcError, update_out, update_Error, incr_x0, update_y0, done;
	
	//State name declrarations
	enum {s_idle, s_calcSteep, s_steepSwap, s_xSwap, s_delta, s_error, s_loop, s_incr, s_done} ps, ns;
	
	always_ff @(posedge clk)
		if(reset)
			ps <= s_idle;
		else
		ps <= ns;
	//always_ff

	always_comb begin
		case(ps)
			s_idle: ns = s_calcSteep;
			s_calcSteep: ns = s_steepSwap;
			s_steepSwap: ns = s_xSwap;
			s_xSwap: ns = s_delta;
			s_delta: ns = s_error;
			s_error: ns = s_loop;
			s_loop: ns = x0_eq_x1 ? s_done:s_incr;
			s_incr: ns = s_loop;
			s_done: ns = s_idle;
		endcase
	end //always_comb
	
	//Output declrations
	assign loadRegs = (ps == s_idle);
	assign calcSteep = (ps == s_calcSteep);
	assign steepSwap = (ps == s_steepSwap) & is_steep;
	assign xSwap = (ps == s_xSwap) & x0_gt_x1;
	assign calcDelta = (ps == s_delta);
	assign calcError = (ps == s_error);
	assign update_Error = (ps == s_loop) & ~x0_eq_x1;
	assign incr_x0 = (ps == s_incr);	
	assign update_y0 = ((ps == s_incr) & error_gte_0);
	assign done = (ps == s_done);
	assign update_out = ps == s_loop;
	
endmodule //drawLine_control
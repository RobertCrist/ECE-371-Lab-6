/* Reset Routine logic 
*	Ports:
*		start:			User input signal to begin algorithim (1-bit)
*		clk:			Clock from DE1_SoC (1-bit)
*		reset:			reset signal from user, resets to state S1 (1-bit)
*		start:			Input signal from line drawer, is true when line is done (1-bit)
*		init:			Is true when ready to initialize (1-bit)
*		ready:			outputs true when ready to begin start resetting algorithim (1-bit)
*		done:			true if algorithim is in done state (1-bit)
*/
module screenWipe_Control(clk, reset, start, init, incr, done, ready);
	input logic clk, reset, start;
	output logic init, incr, done, ready;
	
	logic [8:0] count;
	
	//states of reset ASM
	enum {s_idle, s_resetting, s_done} ps, ns;
	
	always_ff @(posedge clk)
		if(reset)
			ps <= s_idle;
		else
			ps <= ns;
	//always_ff
	
	//State transitions
	always_comb begin
		case(ps) 
			s_idle: ns = start ? s_resetting:s_idle;
			s_resetting: ns = (count < 500) ? s_resetting:s_done;
			s_done: ns = start ? s_done:s_idle;
		endcase
	end //always_comb
	
	//conditional outputs
	always_ff @(posedge clk) begin
		if((ps == s_idle) & start) count <= 0;
		if((ps == s_resetting)) count <= count + 1;
	end //always_ff
	
	//output assignments
	assign init = (ps == s_idle) & start;
	assign incr = (ps == s_resetting);
	assign done = (ps == s_done);
	assign ready = (ps == s_idle);
endmodule //reset_routine

module reset_routine_testbench();
	logic clk, reset, start;
	logic init, incr, done, ready;
	
	screenWipe_Control dut(.*);
	
	parameter T = 20;
	
	initial begin
		clk <= 0;
		forever #(T/2) clk <= ~clk;
	end
	
	initial begin
		//Reset and start the algorithm so we can observe its behavior
		reset <= 1; start <= 0;	@(posedge clk);
		reset <= 0; start <= 1; 								@(posedge clk);
		start <= 0; 								@(posedge clk);
		
		repeat(500)									@(posedge clk);
		$stop;
		
	end
endmodule


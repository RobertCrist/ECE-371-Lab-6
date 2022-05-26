/*
	Module taken from EE 271 Lab
	
	Takes a countinuous high signal and turns it into a pulse
	the width on one clock cycle
	
	Ports:
		clk: The clock drives the timing
		reset: A reset signal for the system
		in: The inputn signal
		out: The output signal
*/
module singleOutput(clk, reset, in, out);
	input logic clk, reset, in;
	output logic out;
	
	//Creating the states
	enum {unpressed, pressed} ps, ns;
	
	//Logic that drives ns
	always_comb begin
		case(ps)
			unpressed:	if(in)	ns = pressed;
							else 		ns = unpressed;
			pressed:		if(in)	ns = pressed;
							else		ns = unpressed;
		endcase
	end //always_comb
	
	//Logic that drives the output
	always_comb begin
		case(ps)
			unpressed:	if(in)	out = 1'b1;
							else 		out = 1'b0;
			pressed:		if(in)	out = 1'b0;
							else		out = 1'b0;
		endcase
	end //always_comb
	
	//Logic that updates ps to ns
	always_ff @(posedge clk) begin
		if (reset)
			ps <= unpressed;
		else
			ps <= ns;
	end //always_ff
endmodule //singleOutput

module singleOutput_testbench();
	logic clk, reset, in;
	logic out;
	
	singleOutput dut (clk, reset, in, out);
	
	// Set up a simulated clk.
	parameter clk_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(clk_PERIOD/2) clk <= ~clk; // Forever toggle the clk
	end
	
	// Set up the inputs to the design. Each line is a clk cycle.
	initial begin
												@(posedge clk);
		reset <= 1; 						@(posedge clk); // Always reset FSMs at start
		reset <= 0; 						@(posedge clk);
												@(posedge clk);
		in <= 1;								@(posedge clk);
												@(posedge clk);
												@(posedge clk);
												@(posedge clk);
												@(posedge clk);
		in <= 0;								@(posedge clk);
												@(posedge clk);
		$stop; // End the simulation.
	end
endmodule
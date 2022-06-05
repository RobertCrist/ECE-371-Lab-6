/*
	gameManager: Switches between the title screen and the game screen
	
	Ports:
		clk: 			The clock drives the timing (1-bit)
		reset:			A reset signal for the system (1-bit)
		start: 			Input signal to load the level from memory (1-bit)
		win:			Input whether user has entered the winning area (1-bit)
		titleScreen:	Outputs true when user needs to be brought back to the title screen (1-bit) 
*/
module gameManager(clk, reset, start, win, titleScreen);
	input logic clk, reset, start, win;
	
	output logic titleScreen;
	
	//state enum
	enum {s_game, s_title} ps, ns;
	
	always_ff @(posedge clk)
		if(reset)
			ps <= s_title;
		else
			ps <= ns;
	
	always_comb begin
		case(ps)
			s_title: ns = start ? s_game:s_title;
			s_game: ns = win ? s_title:s_game;
			
		endcase
	end //always_comb
	
	//True if in title state
	assign titleScreen = (ps == s_title);
endmodule //gameManager

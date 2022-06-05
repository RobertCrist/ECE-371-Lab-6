module gameManager(clk, reset, start, win, titleScreen);
	input logic clk, reset, start, win;
	
	output logic titleScreen;
	
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
	end
	
	assign titleScreen = (ps == s_title);
endmodule

module screenWipe(clk, reset, start, ready, done, x0, y0, x1, y1);
    input logic clk, reset;
    input logic start;

    output logic ready, done;
    output logic [8:0] y0, y1;		
    output logic [9:0] x0, x1;
	 
	 logic init, incr;

    screenWipe_Control c_unit(.*);
    screenWipe_Datapath d_unit(.*);

endmodule

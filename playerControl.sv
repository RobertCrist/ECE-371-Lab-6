/*
	playerControl: Player Control module
	
	Ports:
		clk: 			The clock drives the timing (1-bit)
		reset:		A reset signal for the system (1-bit)
		up:			Input signal from user going UP (1-bit)
		down:			Input signal from user going DOWN (1-bit)
		left:			Input signal from user going LEFT (1-bit)
		right:		Input signal from user going RIGHT (1-bit)
		currLevel:	Input signal of which level is loaded (80 x 60 bits)
		topBound:	Top bouding box of user output (9-bits)
		botBound:	bottom bounding box of user output (9-bits)
		leftBound:	left bounding box of user outputs (10-bits)
		rightBound:	Right bounding box of user outputs (10-bits)
*/
module playerControl(clk, reset, up, down, left, right, currLevel, topBound, botBound, leftBound, rightBound);
    input logic clk, reset;
    input logic up, down, left, right;
    input logic [79:0]currLevel[59:0];

    output logic [8:0] topBound, botBound;
    output logic [9:0] leftBound, rightBound;
    logic inputReg;

    //Clock the inputs
    always_ff @(posedge clk) begin
        inputReg <= up | down | left | right;
    end 

    //hit detection and bounding box instantiation
    always_ff @(posedge clk) begin
        if(reset) begin
            topBound <= 7;//sets the bounding box defaults
            botBound <= 0; 
            leftBound <= 0;
            rightBound <= 7;
        end 
        //Hit detection 
        else if (up & ((~currLevel[(topBound + 2)>>3][leftBound>>3]) & (~currLevel[(topBound + 2)>>3][rightBound>>3])))  begin
            topBound <= topBound + 2;
            botBound <= botBound + 2;
        end
        else if (down & ((~currLevel[(botBound - 2)>>3][leftBound>>3]) & (~currLevel[(botBound - 2)>>3][rightBound>>3]))) begin
            topBound <= topBound - 2;
            botBound <= botBound - 2; 
        end
        else if (left & ((~currLevel[topBound>>3][(leftBound - 3)>>3]) & (~currLevel[botBound>>3][(leftBound - 3)>>3]))) begin
            leftBound <= leftBound - 2;
            rightBound <= rightBound - 2; 
        end
        else if (right & ((~currLevel[topBound>>3][(rightBound + 2)>>3]) & (~currLevel[botBound>>3][(rightBound + 2)>>3]))) begin
            leftBound <= leftBound + 2;
            rightBound <= rightBound + 2; 
        end 
    end//always_ff
	
	//assign collisionSide = (up & topBound) | (down & botBound) | (left & leftBound) | (right & rightBound);
endmodule //playerControl

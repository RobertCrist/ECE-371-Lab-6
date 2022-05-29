module playerControl(clk, reset, up, down, left, right, currLevel, topBound, botBound, leftBound, rightBound);
    input logic clk, reset;
    input logic up, down, left, right;
    input logic [79:0]currLevel[59:0];

    output logic [8:0] topBound, botBound;
    output logic [9:0] leftBound, rightBound;
    logic inputReg;

    always_ff @(posedge clk) begin
        inputReg <= up | down | left | right;
    end 

    always_ff @(posedge clk) begin
        if(reset) begin
            topBound <= 7;
            botBound <= 0; 
            leftBound <= 0;
            rightBound <= 7;
        end 
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
    end
	
	//assign collisionSide = (up & topBound) | (down & botBound) | (left & leftBound) | (right & rightBound);
endmodule

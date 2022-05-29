module playerControl(clk, reset, up, down, left, right, currLevel, topBound, botBound, leftBound, rightBound);
    input logic clk, reset;
    input logic up, down, left, right;
    input logic [59:0]currLevel[79:0];

    output logic [8:0] topBound, botBound;
    output logic [9:0] leftBound, rightBound;
    logic inputReg;

    always_ff @(posedge clk) begin
        inputReg <= up | down | left | right;
    end 

    always_ff @(posedge clk) begin
        if(reset) begin
            topBound <= 8;
            botBound <= 0; 
            leftBound <= 0;
            rightBound <= 8;
        end 
        else if (up & (~currLevel[(topBound + 2)>>3][leftBound>>3]))  begin
            topBound <= topBound + 2;
            botBound <= botBound + 2;
        end
        else if (down & (~currLevel[(botBound - 2)>>3][leftBound>>3])) begin
            topBound <= topBound - 2;
            botBound <= botBound - 2; 
        end
        else if (left & (~currLevel[topBound>>3][(leftBound - 2)>>3])) begin
            leftBound <= leftBound - 2;
            rightBound <= rightBound - 2; 
        end
        else if (right & (~currLevel[rightBound>>3][(leftBound + 2)>>3])) begin
            leftBound <= leftBound + 2;
            rightBound <= rightBound + 2; 
        end 
    end

endmodule

module mul32bit(
    input [31:0] a,
    input [31:0] b,
    input clk,
    input reset,
    input start,
    input [5:0] aluop,
    output [63:0] result,
    output reg done
    );
    `include "aluopcodes.vh"
    reg signa;
    reg signb;
    wire signed [32:0] aext;
    wire signed [32:0] bext;
    reg signed [32:0] ra, rb;
    assign aext = {signa & a[31], a};
    assign bext = {signb & b[31], b};
    reg [63:0] prod;
    always @(*) begin
        if(aluop == ALUMULH) begin
            signa = 1'b1;
            signb = 1;
        end else if (aluop == ALUMULHSU) begin
            signa = 1;
            signb =0;
        end else begin
            signb = 0;
            signa = 0;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            prod <= 0;
            done <= 0;
        end
        else if (start) begin
            ra <= aext;
            rb <= bext;
            done <= 0;
            prod <= 0;
        end 
        else begin
            prod <= ra*rb;
            done <= 1;
        end
    end
    assign result = prod;
endmodule


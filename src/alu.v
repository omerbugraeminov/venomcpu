module alu(
    input [7:0] a,
    input [7:0] b,
    input [3:0] op,
    input clk,
    input reset,
    input start,
    output reg [7:0] result
    );
    wire addcout;
    wire [7:0] addresult;
    adder8bit adder(
    .a(a),
    .b(b),
    .cin(1'b0),
    .sum(addresult),
    .cout(addcout)
    );
    wire [7:0] diff;
    wire subcout;
    sub8bit sub(
    .a(a),
    .b(b),
    .cout(subcout),
    .diff(diff)
    );
    wire [15:0] multresult;
    wire muldone;
    mul8bit mult(
    .a(a),
    .b(b),
    .clk(clk),
    .reset(reset),
    .start(start),
    .result(multresult),
    .done(muldone)
    );
    wire [7:0] quotient;
    wire [7:0] divresult;
    wire divdone;
    div8bit div(
    .a(a),
    .b(b),
    .reset(reset),
    .clk(clk),
    .start(start),
    .quotient(quotient),
    .remainder(divresult),
    .done(divdone)
    );
    
    always @(*) begin
    
    case(op)
    4'b0011: result = addresult;
    4'b0100: result = diff;
    4'b0101: result = multresult[7:0];
    4'b0110: result = quotient;
    4'b0111: result = a^b;
    4'b1000: result = a&b;
    4'b1001: result = a|b;
    default: result = 8'b0;
endcase
end
endmodule
    
    
    

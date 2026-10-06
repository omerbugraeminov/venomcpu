module sub32bit(
    input [31:0] a,
    input [31:0] b,
    output cout,
    output [31:0] diff
    );
    wire [31:0] revsb = ~b;
    adder32bit adsub(
        .a(a),
        .b(revsb),
        .sum(diff),
        .cout(cout),
        .cin(1'b1)  
    );
endmodule
    
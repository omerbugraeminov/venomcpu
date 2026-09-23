module sub8bit(
    input [7:0] a,
    input [7:0] b,
    output [7:0] diff,
    output cout
    );
    wire [7:0] revsb;
    assign revsb = ~b;
    adder8bit a8x0(
    .a(a),
    .b(revsb),
    .cout(cout),
    .sum(diff),
    .cin(1'b1)
    );

endmodule


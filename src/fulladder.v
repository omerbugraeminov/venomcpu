module fulladder(
    input a,
    input b,
    input cin,
    output sum,
    output cout

);
wire tmpsum, carry0, carry1;
    halfadder h0(
        .a(a),
        .b(b),
        .sum(tmpsum),
        .carry(carry0)
    );
    halfadder h1(
        .a(tmpsum),
        .b(cin),
        .sum(sum),
        .carry(carry1)
    );
    assign cout = carry0|carry1;
endmodule
module adder2bit(
    input [1:0] a,
    input [1:0] b,
    output [1:0] sum,
    input cin,
    output cout
);
    wire car0;
    fulladder f0(
    .a(a[0]),
    .b(b[0]),
    .cin(cin),
    .sum(sum[0]),
    .cout(car0)
    );
    fulladder f1(
    .a(a[1]),
    .b(b[1]),
    .cin(car0),
    .sum(sum[1]),
    .cout(cout)
    );

endmodule

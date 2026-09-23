module adder8bit(
    input [7:0] a,
    input [7:0] b,
    input cin,
    output cout,
    output [7:0] sum
    );
    wire car;
    adder4bit a4x0(
    .a(a[3:0]),
    .b(b[3:0]),
    .cin(cin),
    .sum(sum[3:0]),
    .cout(car)
    );
    adder4bit a4x1(
    .a(a[7:4]),
    .b(b[7:4]),
    .cin(car),
    .sum(sum[7:4]),
    .cout(cout)
);
endmodule



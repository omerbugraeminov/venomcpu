module adder4bit(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] sum,
    output cout
    );
    wire car;
    adder2bit a2x0(
    .a(a[1:0]),
    .b(b[1:0]),
    .cin(cin),
    .cout(car),
    .sum(sum[1:0])
    );
    adder2bit a2x1(
    .a(a[3:2]),
    .b(b[3:2]),
    .cin(car),
    .sum(sum[3:2]),
    .cout(cout)
    );
endmodule
    

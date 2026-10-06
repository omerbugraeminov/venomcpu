module adder32bit(
    input [31:0] a,
    input [31:0] b,
    input cin,
    output [31:0] sum,
    output cout
    );
    wire car0;
    wire car1;
    wire car2;
    adder8bit addrx0(
    .a(a[7:0]),
    .b(b[7:0]),
    .cin(cin),
    .cout(car0),
    .sum(sum[7:0])
    );
    adder8bit addrx1(
    .a(a[15:8]),
    .b(b[15:8]),
    .cin(car0),
    .cout(car1),
    .sum(sum[15:8])
    );
    adder8bit addrx2(
    .a(a[23:16]),
    .b(b[23:16]),
    .cin(car1),
    .sum(sum[23:16]),
    .cout(car2)
    );
    adder8bit addrx3(
    .a(a[31:24]),
    .b(b[31:24]),
    .sum(sum[31:24]),
    .cout(cout),
    .cin(car2)
    );

endmodule

module top(
    input clk,
    input btn,
    output [5:0] led,
    output tx
    );
    wire [7:0] r1;
    wire [7:0] udata;
    wire usend;
    wire ubusy;
    wire cpuclk;

    // 27 MHz -> 70.2 MHz
    Gowin_rPLL pll(
        .clkout(cpuclk),
        .clkin(clk)
    );

    datapath cpu(
    .clk(cpuclk),
    .start(1'b0),
    .reset(btn),
    .r1(r1),
    .ubusy(ubusy),
    .usend(usend),
    .udata(udata)
);
    uart uart(
    .clk(cpuclk),
    .reset(btn),
    .send(usend),
    .data(udata),
    .tx(tx),
    .busy(ubusy)
);
    assign led = ~r1[5:0];

endmodule


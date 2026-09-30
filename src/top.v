module top(
    input clk,
    input btn,
    output [5:0] led
    );
    wire [7:0] r1;

    // clock divider: 27 MHz -> ~260 kHz
    // slowclk toggles every 52 ticks (27,000,000 / 104 = 259,615 Hz)
    reg [23:0] counter = 0;
    reg slowclk = 0;

    always @(posedge clk)
    begin
        if (counter == 24'd51)
        begin
            counter <= 0;
            slowclk <= ~slowclk;
        end
        else
            counter <= counter + 1;
    end

    datapath cpu(
    .clk(slowclk),
    .start(1'b0),
    .reset(btn),
    .r1(r1)
);
    assign led = ~r1[5:0];


endmodule

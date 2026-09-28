module top(
    input clk,
    input btn,
    output [5:0] led
    );
    wire [7:0] r1;
    
    datapath cpu(
    .clk(clk),
    .start(1'b0),
    .reset(btn),
    .r1(r1)
);
    assign led = ~r1[5:0];
    

endmodule
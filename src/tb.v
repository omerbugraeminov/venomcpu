`timescale 1ns/ 1ps
module tb(
);

reg reset,
wire [7:0] pc;
reg clk;
pcounter dut(
    .reset(reset),
    .clk(clk),
    .pc(pc)
);
always #5 clk = ~clk;
initial begin
clk = 0;
#5;
#40;
$finish;
end
endmodule
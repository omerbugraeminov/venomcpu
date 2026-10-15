module pcounter(
    input [31:0] address,
    input jump,
    input clk,
    input reset,
    input stall,
    output reg [31:0] pc

    );
    always @(posedge clk)
    begin
    if (reset)
        pc <= 0;
    else if(stall)
        pc <= pc;
    else if (jump)
        pc <= address;
    else 
        pc <= pc + 4;
    end
    
endmodule 
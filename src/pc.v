module pcounter(
    input [7:0] address,
    input jump,
    input clk,
    input reset,
    output reg [7:0] pc

    );
    always @(posedge clk)
    begin
    if (reset)
        pc <= 0;
        else if (jump)
            pc <= address;
            else 
                pc <= pc + 1;
    end
    
endmodule 
module uart#(
    parameter CLKSPERBIT = 609
    )(
    input clk,
    input reset,
    input send,
    input [7:0]data,
    output reg tx,
    output reg busy
    );
    reg [9:0] cargo;
    reg [9:0] clkcount;
    reg [3:0] bitcount;
    always @(posedge clk) begin
        if(reset) begin
            tx <= 1;
            bitcount <= 4'd0;
            clkcount <= 10'd0;
            cargo <= 10'd0;
            busy <= 0;
        end
        else if(!busy) begin
            tx <= 1;
            if(send) begin
                cargo <= {1'd1, data, 1'd0};
                busy <= 1;
                clkcount <= 0;
                bitcount <= 0;
            end
        end
        else if(busy) begin
            tx <= cargo[0];
            if (clkcount == CLKSPERBIT - 1) begin
                clkcount <= 0;
                cargo <= cargo >> 1;
                bitcount <= bitcount + 1;
                if(bitcount == 9) begin
                    busy <= 0;
                end
            end
            else 
                clkcount <= clkcount + 1;
        end
    end
endmodule
            

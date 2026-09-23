module div8bit(
    input [7:0] a,
    input [7:0] b,
    input reset,
    input clk,
    input start,
    output reg [7:0] quotient,
    output reg [7:0] remainder,
    output reg done
    );
    
    reg [7:0] ra;
    reg [7:0] rb;
    always @(posedge clk) begin 
        if (reset) begin
        quotient <= 0;
        remainder <= 0;
        done <= 0;
        end
    else if (start) begin
        ra <= a;
        rb <= b;
        quotient <= 0;
        done <= 0;
        remainder <= 0;
        end
    else if (ra>=rb) begin
        ra <= ra - rb;
        quotient <= quotient +1;
        end
    else begin
        remainder <= ra;
        done <= 1;
        end
    end
endmodule
    
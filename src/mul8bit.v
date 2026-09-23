module mul8bit(
    input [7:0] a,
    input [7:0] b,
    input clk,
    input reset,
    input start,
    output reg [15:0] result,
    output reg done
    );
    reg [7:0] ra;
    reg [7:0] rb;
    reg [3:0] count;
    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            result <= 0;
            done <= 0;
        end
        else if (start) begin
            ra <= a;
            rb <= b;
            done <= 0;
            result <= 0;
            count <= 0;
        end 
        else if (count < 8) begin 
            if (rb[0] == 1'b1)
                result  <= result + (ra << count);
                count <= count + 1;
                rb <= rb >> 1;
        end
        else begin
        done <= 1;
        end
    end

endmodule


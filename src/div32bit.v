module div32bit(
    input [31:0] a,
    input [31:0] b,
    input reset,
    input clk,
    input start,
    output reg [31:0] quotient,
    output reg [31:0] remainder,
    output reg done
    );
    reg [31:0] ra;
    reg [31:0] rb;
    reg [31:0] rem;
    reg [5:0] count;
    wire [31:0] newrem;
    assign newrem = {rem[30:0], ra[31]};

    always @(posedge clk) begin
        if (reset) begin
            quotient <= 0;
            remainder <= 0;
            done <= 0;
            count <= 0;
        end
        else if (start) begin
            ra <= a;
            rb <= b;
            rem <= 0;
            quotient <= 0;
            remainder <= 0;
            count <= 0;
            done <= 0;
        end
        else if (rb == 0) begin
            quotient <= 32'hFFFFFFFF;
            remainder <= ra;
            done <= 1;
        end
        else if (count < 32) begin
            if (newrem >= rb) begin
                rem <= newrem - rb;
                quotient <= {quotient[30:0], 1'b1};
            end
            else begin
                rem <= newrem;
                quotient <= {quotient[30:0], 1'b0};
            end
            ra <= ra << 1;
            count <= count + 1;
        end
        else begin
            remainder <= rem;
            done <= 1;
        end
    end
endmodule
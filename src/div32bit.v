module div32bit(
    input [31:0] a,
    input [31:0] b,
    input reset,
    input clk,
    input start,
    output [31:0] quotient,
    output [31:0] remainder,
    output reg done,
    input [4:0] aluop
    );
    localparam ALUDIV = 5'd14;
    localparam ALUREM = 5'd16;
    reg [31:0] ra;
    reg [31:0] rb;
    reg [31:0] rem;
    reg [5:0] count;
    wire [31:0] newrem;
    reg sign;
    wire nega;
    wire negb;
    reg negq;
    reg negr;
    wire [31:0] abva;
    wire [31:0] abvb;
    reg [31:0] q;
    reg [31:0] r;
    assign newrem = {rem[30:0], ra[31]}; 
    assign nega = sign&&a[31];
    assign negb = sign&&b[31];
    assign abva = nega ? -a: a;
    assign abvb = negb ? -b: b;
    always @(*) begin
        if((aluop == ALUDIV) || (aluop == ALUREM))
            sign = 1;
        else 
            sign = 0;
        end

    always @(posedge clk) begin
        if (reset) begin
            q <= 0;
            r <= 0;
            done <= 0;
            count <= 0;
            negq <= 0;
            negr <= 0;
        end
        else if (start) begin
            negq <= (nega ^ negb) && (b != 0);
            negr <= nega;
            ra <= abva;
            rb <= abvb;
            rem <= 0;
            q <= 0;
            r <= 0;
            count <= 0;
            done <= 0;
        end
        else if (rb == 0) begin
            q <= 32'hFFFFFFFF;
            r <= ra;
            done <= 1;
        end
        else if (count < 32) begin
            if (newrem >= rb) begin
                rem <= newrem - rb;
                q <= {q[30:0], 1'b1};
            end
            else begin
                rem <= newrem;
                q <= {q[30:0], 1'b0};
            end
            ra <= ra << 1;
            count <= count + 1;
        end
        else begin
            r <= rem;
            done <= 1;
        end
    end
    assign quotient = negq ? -q:q;
    assign remainder = negr ? -r:r;
endmodule
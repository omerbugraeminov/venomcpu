module mul32bit(
    input [31:0] a,
    input [31:0] b,
    input clk,
    input reset,
    input start,
    input [4:0] aluop,
    output [63:0] result,
    output reg done
    );
    localparam ALUMULH = 5'd11;
    localparam ALUMULHSU = 5'd12;
    reg signa;
    reg signb;
    reg [63:0] ra;
    reg [31:0] rb;
    reg [5:0] count;
    wire nega;
    wire negb;
    wire [31:0] abva;
    wire [31:0] abvb;
    assign nega = signa&&a[31];
    assign negb = signb&&b[31];
    assign abva = nega ? -a: a;
    assign abvb = negb ? -b: b;
    reg negres;
    reg [63:0] prod;
    always @(*) begin
        if(aluop == ALUMULH) begin
            signa = 1'b1;
            signb = 1;
        end else if (aluop == ALUMULHSU) begin
            signa = 1;
            signb =0;
        end else begin
            signb = 0;
            signa = 0;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            prod <= 0;
            done <= 0;
        end
        else if (start) begin
            ra <= abva;
            rb <= abvb;
            negres <= nega ^ negb;
            done <= 0;
            prod <= 0;
            count <= 0;
        end 
        else if (count < 32) begin 
            if (rb[0] == 1'b1)
                prod  <= prod + (ra << count);
            count <= count + 1;
            rb <= rb >> 1;
        end
        else begin
        done <= 1;
        end
    end
    assign result = negres ? -prod : prod;
endmodule


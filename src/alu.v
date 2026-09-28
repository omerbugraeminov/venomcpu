module alu(
    input [7:0] a,
    input [7:0] b,
    input [3:0] op,
    input clk,
    input reset,
    input start,
    output reg done,
    output reg ispoly,
    output reg zero,
    output reg [7:0] result
    );
    wire addcout;
    wire [7:0] addresult;
    adder8bit adder(
    .a(a),
    .b(b),
    .cin(1'b0),
    .sum(addresult),
    .cout(addcout)
    );
    wire [7:0] diff;
    wire subcout;
    sub8bit sub(
    .a(a),
    .b(b),
    .cout(subcout),
    .diff(diff)
    );
    wire [15:0] multresult;
    wire muldone;
    mul8bit mult(
    .a(a),
    .b(b),
    .clk(clk),
    .reset(reset),
    .start(start),
    .result(multresult),
    .done(muldone)
    );
    wire [7:0] quotient;
    wire [7:0] divresult;
    wire divdone;
    div8bit div(
    .a(a),
    .b(b),
    .reset(reset),
    .clk(clk),
    .start(start),
    .quotient(quotient),
    .remainder(divresult),
    .done(divdone)
    );
    
    always @(*) begin
    
    case(op)
    4'b0010: begin 
    result = addresult;
    done = 1'b1;
    end
    4'b0011: begin
    result = diff;
    done = 1'b1;
    end
    4'b0100: begin
    result = multresult[7:0];
    done = muldone;
    end
    4'b0101: begin
    result = quotient;
    done = divdone;
    end
    4'b0110: begin 
    result = a^b;
    done = 1'b1;
    end
    4'b0111: begin 
    result = a&b;
    done = 1'b1;
    end
    4'b1000: begin 
    result = a|b;
    done = 1'b1;
    end
    4'b1100: begin
    result = diff;
    done = 1'b1;
    end
    4'b1110: begin
    result = a;
    done = 1'b1;
    end
    default: begin
    result = 8'b0;
    done = 1'b1;
    end
    endcase

    end

        always @(*) begin
        if (op == 4'b0100|| op == 4'b0101)
        ispoly = 1'b1;
        else
        ispoly = 1'b0;
       end
    always @(*) begin
        if (result == 8'b0)
            zero = 1'b1;
        else 
            zero = 1'b0;
        end

        
        

        

endmodule
    
    
    

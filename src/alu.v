module alu(
    input [31:0] a,
    input [31:0] b,
    input [5:0] op,
    input clk,
    input reset,
    input start,
    output reg done,
    output reg ispoly,
    output reg [31:0] result
    );
    `include "aluopcodes.vh"
    wire addcout;
    wire [31:0] addresult;
    adder32bit adder(
    .a(a),
    .b(b),
    .cin(1'b0),
    .sum(addresult),
    .cout(addcout)
    );
    wire [31:0] diff;
    wire subcout;
    sub32bit sub(
    .a(a),
    .b(b),
    .cout(subcout),
    .diff(diff)
    );
    wire [63:0] multresult;
    wire muldone;
    mul32bit mult(
    .a(a),
    .b(b),
    .clk(clk),
    .reset(reset),
    .start(start),
    .result(multresult),
    .done(muldone),
    .aluop(op)
    );
    wire [31:0] quotient;
    wire [31:0] divresult;
    wire divdone;
    div32bit div(
    .a(a),
    .b(b),
    .reset(reset),
    .clk(clk),
    .start(start),
    .quotient(quotient),
    .remainder(divresult),
    .done(divdone),
    .aluop(op)
    );
    
    always @(*) begin
    
    case(op)
    ALUADD: begin 
    result = addresult;
    done = 1'b1;
    end
    ALUSUB: begin
    result = diff;
    done = 1'b1;
    end
    ALUMUL: begin
    result = multresult[31:0];
    done = muldone;
    end
    ALUDIV: begin
    result = quotient;
    done = divdone;
    end
    ALUXOR: begin 
    result = a^b;
    done = 1'b1;
    end
    ALUAND: begin 
    result = a&b;
    done = 1'b1;
    end
    ALUOR: begin 
    result = a|b;
    done = 1'b1;
    end
    ALUSLL: begin
    result = a << b[4:0];
    done = 1'b1;
    end
    ALUSRL: begin
    result = a >> b[4:0];
    done = 1'b1;
    end
    ALUSRA: begin
    result = $signed(a) >>> b[4:0];
    done = 1'b1;
    end
    ALUSLT: begin
    result = ($signed(a) < $signed(b)) ? 32'd1:32'd0;
    done = 1'b1;
    end
    ALUSLTU: begin
    result = (a<b) ? 32'd1:32'd0;
    done = 1'b1;
    end
    ALUMULH: begin
    result = multresult[63:32];
    done = muldone;
    end
    ALUMULHU: begin
    result = multresult[63:32];
    done = muldone;
    end
    ALUMULHSU: begin
    result = multresult[63:32];
    done = muldone;
    end
    ALUREM: begin
    result = divresult;
    done = divdone;
    end
    ALUREMU: begin
    result = divresult;
    done = divdone;
    end
    ALUDIVU: begin
    result = quotient;
    done = divdone;
    end
    ALUSH1ADD: begin
    result = (a << 1) + b;
    done = 1;
    end
    ALUSH2ADD: begin    
    result = (a << 2)+ b;
    done = 1;
    end
    ALUSH3ADD: begin
    result = (a << 3) + b;
    done = 1;
    end
    default: begin
    result = 32'd0;
    done = 1'b1;
    end
    endcase

    end

        always @(*) begin
        if (op>= ALUMUL && op <= ALUREMU)
        ispoly = 1'b1;
        else
        ispoly = 1'b0;
       end    

endmodule
    
    
    

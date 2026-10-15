module alu(
    input [31:0] a,
    input [31:0] b,
    input [4:0] op,
    input clk,
    input reset,
    input start,
    output reg done,
    output reg ispoly,
    output reg zero,
    output reg [31:0] result
    );
    localparam ALUADD = 5'd0;
    localparam ALUSUB = 5'd1;
    localparam ALUSLL = 5'd2;
    localparam ALUSRL =5'd3;
    localparam ALUSRA = 5'd4;
    localparam ALUSLT = 5'd5;
    localparam ALUSLTU = 5'd6;
    localparam ALUXOR = 5'd7;
    localparam ALUOR = 5'd8;
    localparam ALUAND = 5'd9;
    localparam ALUMUL = 5'd10;
    localparam ALUMULH = 5'd11;
    localparam ALUMULHSU = 5'd12;
    localparam ALUMULHU = 5'd13;
    localparam ALUDIV = 5'd14;
    localparam ALUDIVU = 5'd15;
    localparam ALUREM = 5'd16;
    localparam ALUREMU = 5'd17;
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
    always @(*) begin
        if (result == 32'b0)
            zero = 1'b1;
        else 
            zero = 1'b0;
        end

        
        

        

endmodule
    
    
    

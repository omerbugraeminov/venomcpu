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
    wire isslow;
    assign isslow = (op >= ALUSH1ADD);
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
    
    reg [5:0] clzv, ctzv, cpopv;
    reg [31:0] slowres;
    reg [31:0] slowprod;
    reg [31:0] polyres;
    reg [31:0] fastres;
    integer i, j, k;
    
    always @(*) begin
    
    case(op)
    ALUADD:  fastres = addresult;
    ALUSUB:  fastres = diff;
    ALUXOR:  fastres = a^b;
    ALUAND:  fastres = a&b;
    ALUOR:   fastres = a|b;
    ALUSLL:  fastres = a << b[4:0];
    ALUSRL:  fastres = a >> b[4:0];
    ALUSRA:  fastres = $signed(a) >>> b[4:0];
    ALUSLT:  fastres = ($signed(a) < $signed(b)) ? 32'd1:32'd0;
    ALUSLTU: fastres = (a<b) ? 32'd1:32'd0;
    default: fastres = 32'd0;
    endcase

    end
    always @(*) begin

    slowres = 32'd0;
    case(op)
    ALUSH1ADD: begin
    slowres = (a << 1) + b;
    end
    ALUSH2ADD: begin    
    slowres = (a << 2)+ b;
    end
    ALUSH3ADD: begin
    slowres = (a << 3) + b;
    end
    ALUBSET: begin
    slowres = a | (1<< b[4:0]);
    end
    ALUBCLR: begin
    slowres = a & ~(1 << b[4:0]);
    end
    ALUBINV: begin
    slowres = a ^(1 << b[4:0]);
    end
    ALUBEXT: begin
    slowres = (a >> b[4:0]) &1;
    end
    ALUANDN: begin
    slowres = a & (~b);
    end
    ALUORN: begin
    slowres = a|~b;
    end
    ALUXNOR: begin
    slowres = ~(a^b);
    end
    ALUMIN: begin
    slowres = ($signed(a)<$signed(b)) ? a:b;
    end
    ALUMINU: begin
    slowres = (a<b) ? a:b;
    end
    ALUMAX: begin
    slowres = ($signed(a)>$signed(b)) ? a:b;
    end
    ALUMAXU: begin
    slowres = (a>b) ? a:b;
    end
    ALUZEXTH: begin
    slowres = {16'd0, a[15:0]};
    end
    ALUROL: begin
    slowres = (a << b[4:0]) | (a>>(32-b[4:0]));
    end
    ALUROR: begin
    slowres = (a >> b[4:0])|  (a<<(32-b[4:0]));
    end
    ALURORI: begin
    slowres = (a >> b[4:0])|  (a<<(32-b[4:0]));
    end
    ALUREV8: begin
    slowres = {a[7:0], a[15:8], a[23:16], a[31:24]};
    end
    ALUORCB: begin
    slowres = {{8{|a[31:24]}}, {8{|a[23:16]}}, {8{|a[15:8]}}, {8{|a[7:0]}}};
    end
    ALUSEXTH: begin
    slowres = {{16{a[15]}}, a[15:0]};
    end
    ALUSEXTB: begin
    slowres = {{24{a[7]}}, a[7:0]}; 
    end
    ALUCLZ: begin
    slowres = {26'd0, clzv};
    end
    ALUCTZ: begin
    slowres = {26'd0, ctzv};
    end
    ALUCPOP: begin
    slowres = {26'd0, cpopv};
    end
    endcase
    end
    always @(posedge clk) begin
        slowprod <= slowres;
    end
        always @(*) begin
        if (op>= ALUMUL && op <= ALUREMU || isslow)
        ispoly = 1'b1;
        else
        ispoly = 1'b0;
       end    
        always @(*) begin
            cpopv = 0;
            for(i=0;i<32;i=i+1)
                cpopv = cpopv + a[i];
        end
        always @(*) begin
            clzv = 32;
            for(j=0;j<32;j=j+1)
                if(a[j]) clzv = 31 - j;
        end
        always @(*) begin
            ctzv = 32;
            for(k=31;k>=0;k=k-1)
                if(a[k]) ctzv = k;
        end
    always @(*) begin
        case(op)
            ALUMUL: polyres = multresult[31:0];
            ALUMULH, ALUMULHU, ALUMULHSU: polyres = multresult[63:32];
            ALUDIV, ALUDIVU: polyres = quotient;
            ALUREM, ALUREMU: polyres = divresult;
            default: polyres = slowprod;
        endcase
    end
    always @(*) begin
        if(ispoly)
            result = polyres;
        else
            result = fastres;
    end
    always @(*) begin
        case(op)
            ALUMUL, ALUMULH, ALUMULHU, ALUMULHSU: done = muldone;
            ALUREM, ALUREMU, ALUDIV, ALUDIVU: done = divdone;
            default: done = 1;
        endcase
    end
endmodule
    
    
    

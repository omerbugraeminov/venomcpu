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
    
    reg [5:0] clzv, ctzv, cpopv;
    integer i, j, k;
    
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
    ALUBSET: begin
    result = a | (1<< b[4:0]);
    done = 1;
    end
    ALUBCLR: begin
    result = a & ~(1 << b[4:0]);
    done = 1;
    end
    ALUBINV: begin
    result = a ^(1 << b[4:0]);
    done = 1;
    end
    ALUBEXT: begin
    result = (a >> b[4:0]) &1;
    done = 1;
    end
    ALUANDN: begin
    result = a & (~b);
    done = 1;
    end
    ALUORN: begin
    result = a|~b;
    done = 1;
    end
    ALUXNOR: begin
    result = ~(a^b);
    done = 1;
    end
    ALUMIN: begin
    result = ($signed(a)<$signed(b)) ? a:b;
    done = 1;
    end
    ALUMINU: begin
    result = (a<b) ? a:b;
    done = 1;
    end
    ALUMAX: begin
    result = ($signed(a)>$signed(b)) ? a:b;
    done = 1;
    end
    ALUMAXU: begin
    result = (a>b) ? a:b;
    done = 1;
    end
    ALUZEXTH: begin
    result = {16'd0, a[15:0]};
    done = 1;
    end
    ALUROL: begin
    result = (a << b[4:0]) | (a>>(32-b[4:0]));
    done = 1;
    end
    ALUROR: begin
    result = (a >> b[4:0])|  (a<<(32-b[4:0]));
    done = 1;
    end
    ALURORI: begin
    result = (a >> b[4:0])|  (a<<(32-b[4:0]));
    done =1;
    end
    ALUREV8: begin
    result = {a[7:0], a[15:8], a[23:16], a[31:24]};
    done = 1;
    end
    ALUORCB: begin
    result = {{8{|a[31:24]}}, {8{|a[23:16]}}, {8{|a[15:8]}}, {8{|a[7:0]}}};
    done = 1;
    end
    ALUSEXTH: begin
    result = {{16{a[15]}}, a[15:0]};
    done = 1;
    end
    ALUSEXTB: begin
    result = {{24{a[7]}}, a[7:0]}; 
    done = 1;
    end
    ALUCLZ: begin
    result = {26'd0, clzv};
    done = 1;
    end
    ALUCTZ: begin
    result = {26'd0, ctzv};
    done = 1;
    end
    ALUCPOP: begin
    result = {26'd0, cpopv};
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

endmodule
    
    
    

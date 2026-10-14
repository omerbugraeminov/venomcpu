module datapath(
    input clk,
    input reset,
    input start,
    output [7:0] r1
);
    reg [31:0] fetchreg;
    reg [31:0] wbdata;
    reg [4:0] wbreg;
    reg wbenable;
    reg [31:0] exA;
    reg [31:0] exB;
    reg [4:0] exop;
    reg [31:0] exdata;
    reg [4:0] exout;
    reg exwen;
    reg exload;
    reg exstore;
    reg exjmp;
    reg exbeq;
    reg exbne;
    reg [4:0] exopregA;
    reg [4:0] exopregB;
    reg [31:0] memalu;
    reg [31:0] memdata;
    reg [31:0] memA;
    reg [4:0] memout;
    reg memwen;
    reg memstore;
    reg [1:0] memwbsel;
    wire [31:0] data;
    wire [7:0] pc;
    wire polystart = ispoly&&!runi;
    wire loadstall;
    wire stall = (runi ? !aludone : ispoly);
    wire zero;
    wire [31:0] muxresult;
    wire flush = exjmp || (exbeq && zero) || (exbne && !zero);
    wire [31:0] memfwd;
    assign memfwd = (memwbsel == 2'b10) ? memdata : memalu;
    pcounter pcmodule(
        .address(exdata),
        .pc(pc),
        .jump(flush),
        .reset(reset),
        .clk(clk),
        .stall(stall || loadstall)
    );
    wire [31:0] outinsmem;
    instmem insmemmodule(
        .address(pc),
        .outinst(outinsmem)
    );
    wire [6:0] opcode;
    wire [4:0] opregA;
    wire [4:0] opregB;
    wire [4:0] outreg;
    wire [2:0] funct3;
    wire [6:0] funct7;
    instructions inst(
        .inst(fetchreg),
        .opcode(opcode),
        .rs1(opregA),
        .rs2(opregB),
        .rd(outreg),
        .imm(data),
        .funct3(funct3),
        .funct7(funct7)
    );
    reg [1:0] exwbsel;
    wire regwrite;
    wire alusrc;
    wire memread;
    wire memwrite;
    wire branch;
    wire jal;
    wire jalr;
    wire [1:0] wbsel;
    reg exbranch;
    reg exjal;
    reg exjalr;
    reg exalusrc;
    wire [4:0] aluop;
    controlunit cu(
        .opcode(opcode),
        .regwrite(regwrite),
        .alusrc(alusrc),
        .memread(memread),
        .memwrite(memwrite),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .wbsel(wbsel),
        .funct3(funct3),
        .funct7(funct7),
        .aluop(aluop)
    );
    wire [31:0] reddataA;
    wire [31:0] reddataB;
    regfile regfile(
        .clock(clk),
        .wrtenable(wbenable),
        .wrtslct(wbreg),
        .wrtdata(wbdata),
        .reddataA(reddataA),
        .reddataB(reddataB),
        .redslctA(opregA),
        .redslctB(opregB),
        .r1out(r1)
    );
    wire [31:0] fwdA;
    wire [31:0] fwdB;
    wire [31:0] exfwdA;
    wire [31:0] exfwdB;
    assign fwdA = (wbenable && (wbreg == opregA)) ? wbdata : reddataA;
    assign fwdB = (wbenable && (wbreg == opregB)) ? wbdata : reddataB;
    assign exfwdA = (memwen && (memout == exopregA)) ? memfwd :
                ((wbenable && (wbreg == exopregA)) ? wbdata : exA);
    assign exfwdB = (memwen && (memout == exopregB)) ? memfwd :
                ((wbenable && (wbreg == exopregB)) ? wbdata : exB);
    assign loadstall = exload && ((exout == opregA) || (exout == opregB));
    wire [31:0] aluresult;
    wire aludone;
    wire ispoly;
    wire [31:0] aluimmb;
    assign aluimmb = exalusrc ? exdata: exfwdB;
    alu alu(
        .clk(clk),
        .reset(reset),
        .start(polystart),
        .a(exfwdA),
        .b(aluimmb),
        .op(exop),
        .result(aluresult),
        .done(aludone),
        .ispoly(ispoly),
        .zero(zero)
    );
    wire [31:0] ramdata;
    datamemory datamemory(
        .clk(clk),
        .address(memalu),
        .wrtenable(memstore),
        .wrtdata(memA),
        .reddata(ramdata)
    );
    mux mux(
    .a(memalu),
    .b(ramdata),
    .c(memdata),
    .select(memwbsel),
    .muxrslt(muxresult)
    );
    reg runi;
    always @(posedge clk) begin
        if (reset)
            runi <= 1'b0;
        else if (!runi) begin
                if(ispoly)
                    runi <= 1'b1;
        end
        else begin
            if(aludone)
                runi <= 1'b0;
            end
    end
    localparam NOP = 32'h00000013;
    always @(posedge clk) begin
        if (reset)
        fetchreg <= NOP;
        else if (stall || loadstall)
        fetchreg <= fetchreg;
        else if (flush)
        fetchreg <= NOP;
        else 
        fetchreg <= outinsmem;

    end
    always @(posedge clk) begin
        wbdata <= muxresult;
        wbreg <= memout;
        if (reset)
        wbenable <= 0;
        else 
        wbenable <= memwen;
    end
    always @(posedge clk) begin
        if (reset) begin
            exA <= 0;
            exB <= 0;
            exop <= 0;
            exdata <= 32'b0;
            exout <= 0;
            exwen <= 0;
            exload <= 0;
            exstore <= 0;
            exjmp <= 0;
            exbeq <= 0;
            exbne <= 0;
            exopregA <= 0;
            exopregB <= 0;
            exwbsel <= 0;
            exalusrc <= 0;
            exbranch <= 0;
            exjal <=0;
            exjalr <=0;
        end
        else if (flush) begin
            exwen <= 0;
            exstore <= 0;
            exjmp <= 0;
            exbeq <= 0;
            exbne <= 0;
            exbranch <= 0;
            exjal <= 0;
            exjalr <= 0;
            exload <= 0;
        end
        else if (loadstall) begin
            exwen <= 0;
            exload <= 0;
            exstore <= 0;
            exbranch <= 0;
            exjal <= 0;
            exjalr <= 0;
        end     
        else if (!stall) begin
            exA <= fwdA;
            exB <= fwdB;
            exop <= aluop;
            exdata <= data;
            exout <= outreg;
            exwen <= regwrite;
            exload <= memread;
            exstore <= memwrite;
            exwbsel <= wbsel;
            exbranch <= branch;
            exjal <= jal;
            exjalr <= jalr;
            exalusrc <= alusrc;
            exopregA <= opregA;
            exopregB <= opregB;
    end
end
    always @(posedge clk) begin
        if (reset) begin
            memwen <= 0;
            memstore <= 0;
        end else begin
            memalu <= aluresult;
            memdata <= exdata;
            memA <= exfwdB;
            memout <= exout;
            memwen <= exwen && !stall;
            memstore <= exstore && !stall;
            memwbsel <= exwbsel;
        end
    end
    
        

endmodule

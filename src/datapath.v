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
    reg [2:0] exf3;
    reg istkn;
    wire [31:0] target;
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
    wire [31:0] pc;
    wire polystart = ispoly&&!runi;
    wire loadstall;
    wire stall = (runi ? !aludone : ispoly);
    wire [31:0] muxresult;
    wire flush = ((exbranch &&istkn) || (exjal) || (exjalr));
    wire [31:0] memfwd;
    reg [31:0] idpc;
    reg [31:0] expc;
    reg [31:0] mempc4;
    assign memfwd = (memwbsel == 2'b10) ? memdata :
                    (memwbsel == 2'b11) ? mempc4 : memalu;
    pcounter pcmodule(
        .address(target),
        .pc(pc),
        .jump(flush),
        .reset(reset),
        .clk(clk),
        .stall(stall || loadstall)
    );
    wire [31:0] outinsmem;
    instmem insmemmodule(
        .address(pc[9:2]),
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
    wire auipc;
    wire jalr;
    wire [1:0] wbsel;
    reg exbranch;
    reg exjal;
    reg exauipc;
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
        .auipc(auipc),
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
    assign fwdA = (wbenable && (wbreg == opregA)&& (wbreg != 0)) ? wbdata : reddataA;
    assign fwdB = (wbenable && (wbreg == opregB)&& (wbreg != 0)) ? wbdata : reddataB;
    assign exfwdA = (memwen && (memout == exopregA)&& (memout != 0)) ? memfwd :
                ((wbenable && (wbreg == exopregA)&& (wbreg != 0)) ? wbdata : exA);
    assign exfwdB = (memwen && (memout == exopregB)&& (memout != 0)) ? memfwd :
                ((wbenable && (wbreg == exopregB)&& (wbreg != 0)) ? wbdata : exB);
    assign loadstall = exload && (exout != 0) && ((exout == opregA) || (exout == opregB));
    wire [31:0] aluresult;
    wire aludone;
    wire ispoly;
    wire [31:0] aluA;
    assign aluA = exauipc ? expc: exfwdA;
    wire [31:0] aluimmb;
    assign aluimmb = exalusrc ? exdata: exfwdB;
    alu alu(
        .clk(clk),
        .reset(reset),
        .start(polystart),
        .a(aluA),
        .b(aluimmb),
        .op(exop),
        .result(aluresult),
        .done(aludone),
        .ispoly(ispoly)
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
    .muxrslt(muxresult),
    .d(mempc4)
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
        if (reset) begin
            fetchreg <= NOP;
            idpc <= 0;
        end
        else if (stall || loadstall) begin
            fetchreg <= fetchreg;
            idpc <= idpc;
        end
        else if (flush) begin
            fetchreg <= NOP;
            idpc <= 0;
        end
        else begin
            fetchreg <= outinsmem;
            idpc <= pc;
        end

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
            exopregA <= 0;
            exopregB <= 0;
            exwbsel <= 0;
            exalusrc <= 0;
            exbranch <= 0;
            exjal <=0;
            exauipc <= 0;
            exjalr <=0;
            expc <= 0;
            exf3 <= 0;
        end
        else if (flush) begin
            exwen <= 0;
            exstore <= 0;
            exbranch <= 0;
            exjal <= 0;
            exauipc <= 0;
            exjalr <= 0;
            exload <= 0;
            exf3 <= 0;
        end
        else if (loadstall) begin
            exwen <= 0;
            exload <= 0;
            exstore <= 0;
            exbranch <= 0;
            exjal <= 0;
            exauipc <= 0;
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
            exauipc <= auipc;
            exjalr <= jalr;
            exalusrc <= alusrc;
            exopregA <= opregA;
            exopregB <= opregB;
            expc <= idpc;
            exf3 <= funct3;
    end
end
    always @(posedge clk) begin
        if (reset) begin
            memwen <= 0;
            memstore <= 0;
            mempc4 <= 0;
        end else begin
            memalu <= aluresult;
            memdata <= exdata;
            memA <= exfwdB;
            memout <= exout;
            memwen <= exwen && !stall;
            memstore <= exstore && !stall;
            memwbsel <= exwbsel;
            mempc4 <= expc + 4;
        end
    end
    localparam BEQ = 3'b000;
    localparam BNE = 3'b001;
    localparam BLT = 3'b100;
    localparam BGE = 3'b101;
    localparam BLTU = 3'b110;
    localparam BGEU = 3'b111;
    always @(*) begin
        if(exf3 == BEQ) begin
            if(exfwdA == exfwdB)
                istkn = 1;
            else
                istkn = 0;
            end
        else if (exf3 == BNE) begin
            if(exfwdA != exfwdB)
                istkn = 1;
            else 
                istkn = 0;
            end
        else if (exf3 == BLT) begin
            if($signed(exfwdA) < $signed(exfwdB))
                istkn = 1;
            else 
                istkn = 0;
            end
        else if (exf3 == BGE) begin
            if($signed(exfwdA) >= $signed(exfwdB))
                istkn = 1;
            else 
                istkn = 0;
            end
        else if(exf3 == BLTU) begin
            if(exfwdA < exfwdB) 
                istkn = 1;
            else
                istkn = 0;
            end
        else if (exf3 == BGEU) begin
            if(exfwdA >= exfwdB)
                istkn = 1;
            else 
                istkn = 0;
            end
        else
            istkn = 0;
        end
    assign target = exjalr ? ((exfwdA + exdata)&~32'd1): expc + exdata;
        

endmodule

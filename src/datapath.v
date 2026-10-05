module datapath(
    input clk,
    input reset,
    input start,
    output [7:0] r1
);
    reg [20:0] fetchreg;
    reg [31:0] wbdata;
    reg [4:0] wbreg;
    reg wbenable;
    reg [31:0] exA;
    reg [31:0] exB;
    reg [3:0] exop;
    reg [31:0] exdata;
    reg [4:0] exout;
    reg exwen;
    reg exload;
    reg exstore;
    reg exldi;
    reg exjmp;
    reg exbeq;
    reg exbne;
    reg exhalt;
    reg [4:0] exopregA;
    reg [4:0] exopregB;
    reg [31:0] memalu;
    reg [31:0] memdata;
    reg [31:0] memA;
    reg [4:0] memout;
    reg memwen;
    reg memload;
    reg memstore;
    reg memldi;
    wire [31:0] data;
    wire [7:0] pc;
    wire polystart = ispoly&&!runi;
    wire halt;
    wire loadstall;
    wire stall = (runi ? !aludone : ispoly) || exhalt;
    wire jump;
    wire beq;
    wire bne;
    wire zero;
    wire [31:0] muxresult;
    wire branch = exjmp || (exbeq && zero) || (exbne && !zero);
    wire [31:0] memfwd;
    assign memfwd = memldi ? memdata : memalu;
    pcounter pcmodule(
        .address(exdata),
        .pc(pc),
        .jump(branch),
        .reset(reset),
        .clk(clk),
        .stall(stall || loadstall)
    );
    wire [20:0] outinsmem;
    instmem insmemmodule(
        .address(pc),
        .outinst(outinsmem)
    );
    wire [3:0] opcode;
    wire [4:0] opregA;
    wire [4:0] opregB;
    wire [4:0] outreg;
    instructions inst(
        .inst(fetchreg),
        .opcode(opcode),
        .regA(opregA),
        .regB(opregB),
        .outreg(outreg),
        .data(data)
    );
    wire wenable;
    wire load;
    wire store;
    wire [1:0] select;
    wire ldi;
    controlunit cu(
        .opcode(opcode),
        .jump(jump),
        .wenable(wenable),
        .load(load),
        .store(store),
        .select(select),
        .ldi(ldi),
        .beq(beq),
        .halt(halt),
        .bne(bne)
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
    alu alu(
        .clk(clk),
        .reset(reset),
        .start(polystart),
        .a(exfwdA),
        .b(exfwdB),
        .op(exop),
        .result(aluresult),
        .done(aludone),
        .ispoly(ispoly),
        .zero(zero)
    );
    wire [31:0] ramdata;
    datamemory datamemory(
        .clk(clk),
        .address(memdata),
        .wrtenable(memstore),
        .wrtdata(memA),
        .reddata(ramdata)
    );
    mux mux(
    .a(memalu),
    .b(ramdata),
    .c(memdata),
    .select({memldi, memload}),
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
    localparam NOP = 21'b0;
    always @(posedge clk) begin
        if (reset)
        fetchreg <= NOP;
        else if (stall || loadstall)
        fetchreg <= fetchreg;
        else if (branch)
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
            exldi <= 0;
            exjmp <= 0;
            exbeq <= 0;
            exbne <= 0;
            exhalt <= 0;
            exopregA <= 0;
            exopregB <= 0;
        end
        else if (branch) begin
            exwen <= 0;
            exstore <= 0;
            exjmp <= 0;
            exbeq <= 0;
            exbne <= 0;
            exhalt <= 0;
        end
        else if (loadstall) begin
            exwen <= 0;
            exload <= 0;
            exstore <= 0;
            exjmp <= 0;
            exbeq <= 0;
            exbne <= 0;
            exhalt <= 0;
        end     
        else if (!stall) begin
            exA <= fwdA;
            exB <= fwdB;
            exop <= opcode;
            exdata <= data;
            exout <= outreg;
            exwen <= wenable;
            exload <= load;
            exstore <= store;
            exldi <= ldi;
            exjmp <= jump;
            exbeq <= beq;
            exbne <= bne;
            exhalt <= halt;
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
            memA <= exfwdA;
            memout <= exout;
            memwen <= exwen && !stall;
            memload <= exload;
            memstore <= exstore && !stall;
            memldi <= exldi;
        end
    end
    
        

endmodule

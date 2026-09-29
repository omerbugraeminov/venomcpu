module datapath(
    input clk,
    input reset,
    input start,
    output [7:0] r1
);
    reg [20:0] fetchreg;
    reg [7:0] wbdata;
    reg [2:0] wbreg;
    reg wbenable;
    wire [7:0] data;
    wire [7:0] pc;
    wire polystart = ispoly&&!runi;
    wire halt;
    wire stall = (runi ? !aludone : ispoly) || halt;
    wire jump;
    wire beq;
    wire bne;
    wire zero;
    wire [7:0] muxresult;
    pcounter pcmodule(
        .address(data),
        .pc(pc),
        .jump(jump || (beq && zero) || (bne && !zero)),
        .reset(reset),
        .clk(clk),
        .stall(stall)
    );
    wire [20:0] outinsmem;
    instmem insmemmodule(
        .address(pc),
        .outinst(outinsmem)
    );
    wire [3:0] opcode;
    wire [2:0] opregA;
    wire [2:0] opregB;
    wire [2:0] outreg;
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
    wire [7:0] reddataA;
    wire [7:0] reddataB;
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
    wire [7:0] fwdA;
    wire [7:0] fwdB;
    assign fwdA = (wbenable && (wbreg == opregA)) ? wbdata: reddataA;
    assign fwdB = (wbenable && (wbreg == opregB)) ? wbdata: reddataB;
    wire [7:0] aluresult;
    wire aludone;
    wire ispoly;
    alu alu(
        .clk(clk),
        .reset(reset),
        .start(polystart),
        .a(fwdA),
        .b(fwdB),
        .op(opcode),
        .result(aluresult),
        .done(aludone),
        .ispoly(ispoly),
        .zero(zero)
    );
    wire [7:0] ramdata;
    datamemory datamemory(
        .clk(clk),
        .address(data),
        .wrtenable(store),
        .wrtdata(fwdA),
        .reddata(ramdata)
    );
    mux mux(
    .a(aluresult),
    .b(ramdata),
    .c(data),
    .select(select),
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
        else if (stall)
        fetchreg <= fetchreg;
        else if (jump || (beq && zero) || (bne && !zero))
        fetchreg <= NOP;
        else 
        fetchreg <= outinsmem;

    end
    always @(posedge clk) begin
        wbdata <= muxresult;
        wbreg <= outreg;
        if (reset)
        wbenable <= 0;
        else 
        wbenable <= wenable && !stall;
    end


    
        

endmodule

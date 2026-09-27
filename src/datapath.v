module datapath(
    input clk,
    input reset,
    input start
);
    wire [7:0] data;
    wire [7:0] pc;
    wire polystart = ispoly&&!runi;
    wire stall = runi ? !aludone : ispoly;
    wire jump;
    wire beq;
    wire zero;
    wire [7:0] muxresult;
    pcounter pcmodule(
        .address(data),
        .pc(pc),
        .jump(jump || (beq && zero)),
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
        .inst(outinsmem),
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
        .beq(beq)
    );
    wire [7:0] reddataA;
    wire [7:0] reddataB;
    regfile regfile(
        .clock(clk),
        .wrtenable(wenable && !stall),
        .wrtslct(outreg),
        .wrtdata(muxresult),
        .reddataA(reddataA),
        .reddataB(reddataB),
        .redslctA(opregA),
        .redslctB(opregB)
    );
    wire [7:0] aluresult;
    wire aludone;
    wire ispoly;
    alu alu(
        .clk(clk),
        .reset(reset),
        .start(polystart),
        .a(reddataA),
        .b(reddataB),
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
        .wrtdata(reddataA),
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
    
        

endmodule

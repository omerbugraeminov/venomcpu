module datapath(
    input clk,
    input reset,
    input start
);
    wire [7:0] data;
    wire [7:0] pc;

    wire jump;
    wire [7:0] muxresult;
    pcounter pcmodule(
        .address(data),
        .pc(pc),
        .jump(jump),
        .reset(reset),
        .clk(clk)
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
        .ldi(ldi)
    );
    wire [7:0] reddataA;
    wire [7:0] reddataB;
    regfile regfile(
        .clock(clk),
        .wrtenable(wenable),
        .wrtslct(outreg),
        .wrtdata(muxresult),
        .reddataA(reddataA),
        .reddataB(reddataB),
        .redslctA(opregA),
        .redslctB(opregB)
    );
    wire [7:0] aluresult;
    alu alu(
        .clk(clk),
        .reset(reset),
        .start(start),
        .a(reddataA),
        .b(reddataB),
        .op(opcode),
        .result(aluresult)
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
endmodule

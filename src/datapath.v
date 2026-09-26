module datapath(
    input clk,
    input reset,
    input start


);
wire [3:0] pcaddress;
wire [7:0] pc;

    pcounter pcmodule(
        .address(pcaddress),
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
    wire [7:0] data;
    instructions inst(
        .inst(outinsmem),
        .opcode(opcode),
        .regA(opregA),
        .regB(opregB),
        .outreg(outreg),
        .data(data)
    );
    wire jump;
    wire wenable;
    controlunit cu(
        .opcode(opcode),
        .jump(jump),
        .wenable(wenable)
    );
    wire [7:0] reddataA;
    wire [7:0] reddataB;
    regfile regfile(
        .clock(clk),
        .wrtenable(wenable),
        .wrtslct(outreg),
        .wrtdata(aluresult),
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

module datapath(
    input clk,
    input reset


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


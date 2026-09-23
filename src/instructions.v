module instructions(
    input [20:0] inst,
    output [3:0] opcode,
    output [2:0] regA,
    output [2:0] regB,
    output [2:0] outreg,
    output [7:0] data
    );
    assign opcode = inst [20:17];
    assign regA = inst [16:14];
    assign regB = inst [13:11];
    assign outreg = inst [10:8];
    assign data = inst [7:0];
endmodule
    
    
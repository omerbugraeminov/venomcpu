module instructions(
    input [31:0] inst,
    output [6:0] opcode,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output reg [31:0] imm,
    output [2:0] funct3,
    output [6:0] funct7
    );
    localparam OPR = 7'b0110011;
    localparam OPIMM = 7'b0010011;
    localparam OPLOAD = 7'b0000011;
    localparam OPSTORE = 7'b0100011;
    localparam OPBRANCH = 7'b1100011;
    localparam OPJAL = 7'b1101111;
    localparam OPJALR = 7'b1100111;
    localparam OPLUI = 7'b0110111;
    localparam OPAUIPC = 7'b0010111;
    assign opcode = inst[6:0];
    assign rd     = inst[11:7];
    assign funct3 = inst[14:12];
    assign rs1    = inst[19:15];
    assign rs2    = inst[24:20];
    assign funct7 = inst[31:25];


    always @(*) begin
        case (opcode)
            OPIMM, OPLOAD, OPJALR:   
                imm = {{20{inst[31]}}, inst[31:20]};
            OPSTORE:                 
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            OPBRANCH:                
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            OPLUI, OPAUIPC:          
                imm = {inst[31:12], 12'b0};
            OPJAL:                  
                imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            default:                 
                imm = 32'b0;
        endcase
    end
        
endmodule
    
    
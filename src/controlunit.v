module controlunit(
    input [6:0] opcode,
    output reg regwrite,
    output reg alusrc,
    output reg memread,
    output reg branch,
    output reg memwrite,
    output reg jal,
    output reg jalr,
    output reg [1:0] wbsel
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
    always @(*) begin
        case (opcode)
            OPR: begin 
                regwrite = 1; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00;
            end
            OPIMM: begin
                regwrite = 1; alusrc = 1; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00;
            end
            OPLOAD: begin 
                regwrite = 1; alusrc = 1; memread = 1; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b01;
            end
            OPSTORE: begin
                regwrite = 0; alusrc = 1; memread = 0; branch = 0;
                memwrite = 1; jal = 0; jalr = 0; wbsel = 2'b00;
            end
            OPBRANCH: begin
                regwrite = 0; alusrc = 0; memread = 0; branch = 1;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00;
            end
            OPLUI: begin
                regwrite = 1; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b10;
            end
            OPJAL: begin
                regwrite = 1; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 1; jalr = 0; wbsel = 2'b11;
            end
            OPJALR: begin   
                regwrite = 1; alusrc = 1; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 1; wbsel = 2'b11;
            end
            default: begin
                regwrite = 0; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00;
            end
    endcase
    end
endmodule
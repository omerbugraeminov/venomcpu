module controlunit(
    input [6:0] opcode,
    output reg regwrite,
    output reg alusrc,
    output reg memread,
    output reg branch,
    output reg memwrite,
    output reg jal,
    output reg jalr,
    output reg auipc,
    output reg [1:0] wbsel,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [4:0] aluop,
    output reg csr,
    output ecall,
    output ebreak,
    output mret,
    input [11:0] funct12
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
    localparam OPSYSTEM = 7'b1110011;
    localparam ALUADD = 5'd0;
    localparam ALUSUB = 5'd1;
    localparam ALUSLL = 5'd2;
    localparam ALUSRL =5'd3;
    localparam ALUSRA = 5'd4;
    localparam ALUSLT = 5'd5;
    localparam ALUSLTU = 5'd6;
    localparam ALUXOR = 5'd7;
    localparam ALUOR = 5'd8;
    localparam ALUAND = 5'd9;
    localparam ALUMUL = 5'd10;
    localparam ALUMULH = 5'd11;
    localparam ALUMULHSU = 5'd12;
    localparam ALUMULHU = 5'd13;
    localparam ALUDIV = 5'd14;
    localparam ALUDIVU = 5'd15;
    localparam ALUREM = 5'd16;
    localparam ALUREMU = 5'd17;
    always @(*) begin
        case (opcode)
            OPR: begin 
                auipc = 0; regwrite = 1; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0; 
            end
            OPIMM: begin
                auipc = 0; regwrite = 1; alusrc = 1; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0;
            end
            OPLOAD: begin 
                auipc = 0; regwrite = 1; alusrc = 1; memread = 1; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b01; csr = 0;
            end
            OPSTORE: begin
                auipc = 0; regwrite = 0; alusrc = 1; memread = 0; branch = 0;
                memwrite = 1; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0;
            end
            OPBRANCH: begin
                auipc = 0; regwrite = 0; alusrc = 0; memread = 0; branch = 1;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0;
            end
            OPLUI: begin
                auipc = 0; regwrite = 1; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b10; csr = 0;
            end
            OPJAL: begin
                auipc = 0; regwrite = 1; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 1; jalr = 0; wbsel = 2'b11; csr = 0;
            end
            OPJALR: begin   
                auipc = 0; regwrite = 1; alusrc = 1; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 1; wbsel = 2'b11; csr = 0;
            end
            OPAUIPC: begin
                auipc = 1; regwrite = 1; alusrc = 1; memread = 0;branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0;
            end
            OPSYSTEM: begin
                auipc = 0; regwrite = (funct3 != 3'b000); alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = (funct3 != 3'b000);
            end
            default: begin
                auipc = 0; regwrite = 0; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0;
            end
    endcase
    end
    always @(*) begin
        case (opcode)
            OPR: begin
                if(funct7 == 7'b0000001) begin
                    case(funct3)
                        3'b000: aluop = ALUMUL;
                        3'b001: aluop = ALUMULH;
                        3'b010: aluop = ALUMULHSU;
                        3'b011: aluop = ALUMULHU;
                        3'b100: aluop = ALUDIV;
                        3'b101: aluop = ALUDIVU;
                        3'b110: aluop = ALUREM;
                        3'b111: aluop = ALUREMU;
                        default: aluop = ALUADD;    
                    endcase
                end
                else begin
                    case(funct3)
                        3'b000: aluop = (funct7 == 7'b0100000) ? ALUSUB : ALUADD;
                        3'b001: aluop = ALUSLL;
                        3'b010: aluop = ALUSLT;
                        3'b011: aluop = ALUSLTU;
                        3'b100: aluop = ALUXOR;
                        3'b101: aluop = (funct7 == 7'b0100000) ? ALUSRA : ALUSRL;
                        3'b110: aluop = ALUOR;
                        3'b111: aluop = ALUAND;
                        default: aluop = ALUADD;    
                    endcase
                end
            end
            OPIMM: begin
                case(funct3)
                    3'b000: aluop = ALUADD;
                    3'b001: aluop = ALUSLL;
                    3'b010: aluop = ALUSLT;
                    3'b011: aluop = ALUSLTU;
                    3'b100: aluop = ALUXOR;
                    3'b101: aluop = (funct7 == 7'b0100000) ? ALUSRA : ALUSRL;
                    3'b110: aluop = ALUOR;
                    3'b111: aluop = ALUAND;
                    default: aluop = ALUAND;
                endcase
            end
            OPLOAD: aluop = ALUADD; 
            OPSTORE: aluop = ALUADD;
            OPBRANCH: aluop=ALUSUB;
            OPLUI: aluop = ALUADD;
            OPJAL: aluop = ALUADD;
            OPJALR: aluop = ALUADD;
            default: aluop = ALUADD;
            endcase
        end
    assign ecall = ((OPSYSTEM == opcode)&&(funct3 == 0)&&(funct12==12'h000));
    assign ebreak = ((OPSYSTEM == opcode)&&(funct3 == 0)&&(funct12==12'h001));
    assign mret = ((OPSYSTEM == opcode)&&(funct3 == 0)&&(funct12==12'h302));
endmodule
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
    output reg [5:0] aluop,
    output reg csr,
    output ecall,
    output ebreak,
    output mret,
    input [11:0] funct12,
    output reg lr,
    output reg sc,
    output reg amo
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
    localparam OPAMO = 7'b0101111;
    `include "aluopcodes.vh"
    always @(*) begin
        lr = 0; sc = 0; amo = 0;
        case (opcode)
            OPR: begin 
                auipc = 0; regwrite = 1; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0; amo = 0;
            end
            OPIMM: begin
                auipc = 0; regwrite = 1; alusrc = 1; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0; amo = 0;
            end
            OPLOAD: begin 
                auipc = 0; regwrite = 1; alusrc = 1; memread = 1; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b01; csr = 0; amo = 0;
            end
            OPSTORE: begin
                auipc = 0; regwrite = 0; alusrc = 1; memread = 0; branch = 0;
                memwrite = 1; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0; amo = 0;
            end
            OPBRANCH: begin
                auipc = 0; regwrite = 0; alusrc = 0; memread = 0; branch = 1;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0; amo = 0;
            end
            OPLUI: begin
                auipc = 0; regwrite = 1; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b10; csr = 0; amo = 0;
            end
            OPJAL: begin
                auipc = 0; regwrite = 1; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 1; jalr = 0; wbsel = 2'b11; csr = 0; amo = 0;
            end
            OPJALR: begin   
                auipc = 0; regwrite = 1; alusrc = 1; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 1; wbsel = 2'b11; csr = 0; amo = 0;
            end
            OPAUIPC: begin
                auipc = 1; regwrite = 1; alusrc = 1; memread = 0;branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0; amo = 0;
            end
            OPSYSTEM: begin
                auipc = 0; regwrite = (funct3 != 3'b000); alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = (funct3 != 3'b000); amo = 0;
            end
            OPAMO: begin
                auipc = 0; alusrc = 1; branch = 0; jal = 0; jalr = 0; csr = 0; 
                if (funct7[6:2] == 5'b00010) begin
                    regwrite = 1; memread = 1; memwrite = 0; wbsel = 2'b01; lr = 1; 
                end else if (funct7[6:2] == 5'b00011) begin
                    regwrite = 1; memread = 0; memwrite = 1; wbsel = 2'b00; sc = 1;
                end else begin
                    regwrite = 1; memread = 1; memwrite = 0; wbsel = 2'b01; amo = 1;
                end
            end
            default: begin
                auipc = 0; regwrite = 0; alusrc = 0; memread = 0; branch = 0;
                memwrite = 0; jal = 0; jalr = 0; wbsel = 2'b00; csr = 0; amo = 0;
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
                else if(funct7 == 7'b0010100) begin
                    if(funct3 == 3'b001)
                        aluop = ALUBSET;
                    else
                        aluop = ALUADD;
                end
                else if(funct7 == 7'b0100100) begin
                    if(funct3 == 3'b001)
                        aluop=ALUBCLR;
                    else if(funct3 == 3'b101)
                        aluop=ALUBEXT;
                    else
                        aluop = ALUADD;
                end
                else if(funct7 == 7'b0110100) begin
                    if(funct3 == 3'b001)
                        aluop = ALUBINV;
                    else
                        aluop = ALUADD;
                end
                else if(funct7 ==7'b0010000) begin
                    case(funct3)
                        3'b010: aluop = ALUSH1ADD;
                        3'b100: aluop = ALUSH2ADD;  
                        3'b110: aluop = ALUSH3ADD;
                        default: aluop = ALUADD;
                    endcase
                end
                else if(funct7 == 7'b0000101) begin
                    case(funct3)
                        3'b100: aluop = ALUMIN;
                        3'b101: aluop = ALUMINU;
                        3'b110: aluop = ALUMAX;
                        3'b111: aluop = ALUMAXU;
                        default: aluop = ALUADD;
                    endcase
                end
                else if(funct7 == 7'b0000100) begin
                    if(funct3 == 3'b100)
                        aluop = ALUZEXTH;
                    else
                        aluop = ALUADD;
                end
                else if(funct7 == 7'b0110000) begin
                    if(funct3 == 3'b001) 
                        aluop = ALUROL;
                    else if(funct3 == 3'b101)
                        aluop = ALUROR;
                    else
                        aluop = ALUADD;
                end
                else begin
                    case(funct3)
                        3'b000: aluop = (funct7 == 7'b0100000) ? ALUSUB : ALUADD;
                        3'b001: aluop = ALUSLL;
                        3'b010: aluop = ALUSLT;
                        3'b011: aluop = ALUSLTU;
                        3'b100: aluop = (funct7 == 7'b0100000) ? ALUXNOR : ALUXOR;
                        3'b101: aluop = (funct7 == 7'b0100000) ? ALUSRA : ALUSRL;
                        3'b110: aluop = (funct7 == 7'b0100000) ? ALUORN : ALUOR;
                        3'b111: aluop = (funct7 == 7'b0100000) ? ALUANDN : ALUAND;
                        default: aluop = ALUADD;    
                    endcase
                end
            end
            OPIMM: begin
                case(funct3)
                    3'b000: aluop = ALUADD;
                    3'b001: begin
                        case(funct7)
                            7'b0000000: aluop = ALUSLL;
                            7'b0010100: aluop = ALUBSET;
                            7'b0100100: aluop = ALUBCLR;
                            7'b0110100: aluop = ALUBINV;
                            7'b0110000: begin
                                case(funct12)
                                    12'h604: aluop = ALUSEXTB;
                                    12'h605: aluop = ALUSEXTH;
                                    12'h600: aluop = ALUCLZ;
                                    12'h601: aluop = ALUCTZ;
                                    12'h602: aluop = ALUCPOP;
                                    default: aluop = ALUADD;
                                endcase
                            end
                            default:    aluop = ALUSLL;
                        endcase
                    end
                    3'b010: aluop = ALUSLT;
                    3'b011: aluop = ALUSLTU;
                    3'b100: aluop = ALUXOR;
                    3'b101: begin
                        case(funct7)
                            7'b0000000: aluop = ALUSRL;
                            7'b0100000: aluop = ALUSRA;
                            7'b0100100: aluop = ALUBEXT;
                            7'b0110000: aluop = ALURORI;
                            7'b0010100: aluop = ALUORCB;
                            7'b0110100: aluop = ALUREV8;    
                            default:    aluop = ALUSRL;
                        endcase
                    end
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
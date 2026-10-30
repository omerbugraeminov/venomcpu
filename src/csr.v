module csr(
    input clk,
    input reset,
    input en,
    input [11:0] addr,
    input [2:0] f3,
    input [31:0] rs1val,
    input [4:0] uimm,
    input retire,
    output reg [31:0] rdata,
    input trap,
    input [31:0] trappc,
    input [31:0] cause,
    output [31:0] mtvecout,
    output [31:0] mepcout
    );
    
    reg [63:0] mcycle;
    reg [63:0] minstret;
    reg [31:0] mscratch;
    wire [31:0] src;
    wire [31:0] newval;
    wire wr;
    reg [31:0] mtvec;
    reg [31:0] mepc;
    reg [31:0] mcause;
    
    localparam [11:0] MCYCLE = 12'hB00;
    localparam [11:0] MCYCLEH= 12'hB80;
    localparam [11:0] MINSTRET=12'hB02;
    localparam [11:0]MINSTRETH=12'hB82;
    localparam [11:0]  CYCLE = 12'hC00;
    localparam [11:0] CYCLEH = 12'hC80;
    localparam [11:0]INSTRET = 12'hC02;
    localparam [11:0]INSTRETH= 12'hC82;
    localparam [11:0]MSCRATCH= 12'h340;
    localparam [11:0] MEPC =   12'h341;
    localparam [11:0] MTVEC =  12'h305;
    localparam [11:0] MCAUSE = 12'h342;

    assign wr = en && ((f3[1:0] == 2'b01) || (uimm != 0));
    
    always @(posedge clk) begin
        if(reset) begin
            mcycle <= 0;
            minstret <= 0;
            mscratch <= 0;
            mtvec <= 0;
            mepc <= 0;
            mcause <= 0;
        end
        else begin
            if(retire == 1) begin
                minstret <= minstret + 1;
                mcycle <= mcycle + 1;
            end
        else
                mcycle <= mcycle + 1;
            if(trap) begin
                mepc <= trappc;
                mcause <= cause;
            end
            else if(wr) begin
                case(addr)
                    MSCRATCH: mscratch <= newval;
                    MTVEC:    mtvec    <= {newval[31:2], 2'b00};
                    MEPC:     mepc     <= {newval[31:2], 2'b00};
                    MCAUSE:   mcause   <= newval;
                    default: ;
                endcase
            end
        end
    end
    
    always @(*) begin
        case(addr)
            MCYCLE, CYCLE:       rdata = mcycle[31:0];
            MCYCLEH, CYCLEH:     rdata = mcycle[63:32];
            MINSTRET, INSTRET:   rdata = minstret[31:0];
            MINSTRETH, INSTRETH: rdata = minstret[63:32];
            MTVEC:               rdata = mtvec;
            MEPC:                rdata = mepc;
            MCAUSE:              rdata = mcause;
            MSCRATCH:            rdata = mscratch;
            default:             rdata = 32'd0;
        endcase
    end
    
    assign src = f3[2] ? {27'b0, uimm}: rs1val;
    assign newval = (f3[1:0] == 2'b01) ? src:
                    (f3[1:0] == 2'b10) ? (rdata | src):
                    (f3[1:0] == 2'b11) ? (rdata & ~src):
                    rdata;
    assign mtvecout = mtvec;
    assign mepcout = mepc;
endmodule

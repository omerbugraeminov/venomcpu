module csr(
    input clk,
    input reset,
    input en,
    input [11:0] addr,
    input [2:0] f3,
    input [31:0] rs1val,
    input [4:0] uimm,
    input retire,
    output reg [31:0] rdata
    );
    
    reg [63:0] mcycle;
    reg [63:0] minstret;
    reg [31:0] mscratch;
    wire [31:0] src;
    wire [31:0] newval;
    wire wr;
    
    localparam [11:0] MCYCLE = 12'hB00;
    localparam [11:0] MCYCLEH= 12'hB80;
    localparam [11:0] MINSTRET=12'hB02;
    localparam [11:0]MINSTRETH=12'hB82;
    localparam [11:0]  CYCLE = 12'hC00;
    localparam [11:0] CYCLEH = 12'hC80;
    localparam [11:0]INSTRET = 12'hC02;
    localparam [11:0]INSTRETH= 12'hC82;
    localparam [11:0]MSCRATCH= 12'h340;
 
    assign wr = en && (addr == MSCRATCH) && ((f3[1:0] == 2'b01) || (uimm != 0));
    
    always @(posedge clk) begin
        if(reset) begin
            mcycle <= 0;
            minstret <= 0;
            mscratch <= 0;
        end
        else begin
            if(retire == 1) begin
                minstret <= minstret + 1;
                mcycle <= mcycle + 1;
            end
        else
                mcycle <= mcycle + 1;
            if(wr)
                mscratch <= newval;
        end
    end
    
    always @(*) begin
        case(addr)
            MCYCLE, CYCLE:       rdata = mcycle[31:0];
            MCYCLEH, CYCLEH:     rdata = mcycle[63:32];
            MINSTRET, INSTRET:   rdata = minstret[31:0];
            MINSTRETH, INSTRETH: rdata = minstret[63:32];
            MSCRATCH:            rdata = mscratch;
            default:             rdata = 32'd0;
        endcase
    end
    
    assign src = f3[2] ? {27'b0, uimm}: rs1val;
    assign newval = (f3[1:0] == 2'b01) ? src:
                    (f3[1:0] == 2'b10) ? (mscratch | src):
                    (f3[1:0] == 2'b11) ? (mscratch & ~src):
                    mscratch;

endmodule
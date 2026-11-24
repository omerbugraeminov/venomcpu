module bpu(
    input clk,
    input reset,
    input [31:0] pc,
    output predtaken,
    output [31:0] predtarget,
    output [1:0] predctr,
    input upd,
    input [31:0] updpc,
    input updtaken,
    input [31:0] updtarget,
    input [1:0] updctr
    );
    reg [63:0] valid;
    reg [7:0] tagmem [0:63];
    reg [13:0] tgtmem [0:63];
    reg [1:0] ctrmem [0:63];
    wire [5:0] idx;
    assign idx = pc[7:2];
    wire hit;
    assign hit = valid[idx] && (tagmem[idx] == pc[15:8]);
    assign predtaken = hit && ctrmem[idx][1];
    assign predtarget = {16'd0, tgtmem[idx], 2'd0};
    assign predctr = hit ? ctrmem[idx]: 2'b01;
    reg delupd;
    reg delupdtaken;
    reg [31:0] delupdpc;
    reg [31:0] delupdtarget;
    reg [1:0] delupdctr;
    always @(posedge clk) begin
        if(reset)
            delupd <= 0;
        else
            delupd <= upd;
            delupdpc <= updpc;
            delupdtarget <= updtarget;
            delupdtaken <= updtaken;
            delupdctr <= updctr;
    end
    reg [1:0] newctr;
    always @(*) begin
        if(delupdtaken)
            newctr = (delupdctr == 2'b11) ? 2'b11 : delupdctr + 1;
        else
            newctr = (delupdctr == 2'b00) ? 2'b00 : delupdctr - 1;
    end
    wire [5:0] uidx = delupdpc[7:2];
    always @(posedge clk) begin
        if(reset)
            valid <= 0;
        else if(delupd) begin
            valid[uidx] <= 1;
            tagmem[uidx] <= delupdpc[15:8];
            tgtmem[uidx] <= delupdtarget[15:2];
            ctrmem[uidx] <= newctr;
        end
    end
endmodule
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
    reg [15:0] valid;
    reg [9:0] tagmem [0:15];
    reg [13:0] tgtmem [0:15];
    reg [1:0] ctrmem [0:15];
    wire [3:0] idx;
    assign idx = pc[5:2];
    wire hit;
    assign hit = valid[idx] && (tagmem[idx] == pc[15:6]);
    assign predtaken = hit && ctrmem[idx][1];
    assign predtarget = {16'd0, tgtmem[idx], 2'd0};
    assign predctr = hit ? ctrmem[idx]: 2'b01;
    reg [1:0] newctr;
    always @(*) begin
        if(updtaken)
            newctr = (updctr == 2'b11) ? 2'b11 : updctr + 1;
        else
            newctr = (updctr == 2'b00) ? 2'b00 : updctr - 1;
    end
    wire [3:0] uidx = updpc[5:2];
    always @(posedge clk) begin
        if(reset)
            valid <= 0;
        else if(upd) begin
            valid[uidx] <= 1;
            tagmem[uidx] <= updpc[15:6];
            tgtmem[uidx] <= updtarget[15:2];
            ctrmem[uidx] <= newctr;
        end
    end
endmodule
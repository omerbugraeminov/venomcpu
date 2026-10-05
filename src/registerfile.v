module regfile(
    input clock,
    input wrtenable,
    input [4:0] wrtslct,
    input [31:0] wrtdata,
    output [31:0] reddataA,
    output [31:0] reddataB,
    input [4:0] redslctA,
    input [4:0] redslctB,
    output [7:0] r1out
    );
    reg [31:0] R [0:31];
    always @(posedge clock) begin
    if (wrtenable) begin
        R[wrtslct] <= wrtdata;
    end
end
    assign reddataA = (redslctA == 0) ? 32'b0 : R[redslctA];
    assign reddataB = (redslctB == 0) ? 32'b0 : R[redslctB];
    assign r1out = R[1];
endmodule
 
    
        
        
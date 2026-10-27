module datamemory(
    input clk,
    input [7:0] addressA,
    input [3:0] byen,
    input [31:0] wrtdata,
    input [7:0] addressB,
    output reg [31:0] reddataB,
    output reg [31:0] reddataA
    );
    reg [31:0] mem [0:255];
    initial $readmemh("program.hex", mem);
    always @(posedge clk) begin 
        if(byen[4'd0])
            mem[addressA][7:0] <= wrtdata[7:0];
        if(byen[4'd1])
            mem[addressA][15:8] <= wrtdata[15:8];
        if(byen[4'd2])
            mem[addressA][23:16] <= wrtdata[23:16];
        if(byen[4'd3])
            mem[addressA][31:24] <= wrtdata[31:24];
    end

    always @(*) begin
        reddataA = mem[addressA];
        reddataB = mem[addressB];
    end

endmodule


    
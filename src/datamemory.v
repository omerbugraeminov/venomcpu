module datamemory(
    input clk,
    input [13:0] addressA,
    input [3:0] byen,
    input [31:0] wrtdata,
    input [13:0] addressB,
    output [31:0] reddataB,
    output [31:0] reddataA,
    input Ben
    );
    genvar i;
    generate
        for(i = 0; i < 4; i = i + 1) begin : lane
            reg [7:0] mem [0:16383];
            reg [7:0] outA;
            reg [7:0] outB;

            if(i == 0) initial $readmemh("program0.hex", mem);
            if(i == 1) initial $readmemh("program1.hex", mem);
            if(i == 2) initial $readmemh("program2.hex", mem);
            if(i == 3) initial $readmemh("program3.hex", mem);

            always @(posedge clk) begin
                if(byen[i])
                    mem[addressA] <= wrtdata[i*8 +: 8];
                else
                    outA <= mem[addressA];
            end

            always @(posedge clk) begin
                if(Ben)
                    outB <= mem[addressB];
            end

            assign reddataA[i*8 +: 8] = outA;
            assign reddataB[i*8 +: 8] = outB;
        end
    endgenerate

endmodule

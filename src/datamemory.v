module datamemory(
    input clk,
    input [7:0] address,
    input [3:0] byen,
    input [31:0] wrtdata,
    output reg [31:0] reddata
    );
    reg [31:0] mem [0:255];
    always @(posedge clk) begin 
        if(byen[4'd0])
            mem[address][7:0] <= wrtdata[7:0];
        if(byen[4'd1])
            mem[address][15:8] <= wrtdata[15:8];
        if(byen[4'd2])
            mem[address][23:16] <= wrtdata[23:16];
        if(byen[4'd3])
            mem[address][31:24] <= wrtdata[31:24];
    end

    always @(*) begin
        reddata = mem[address];
    end

endmodule


    
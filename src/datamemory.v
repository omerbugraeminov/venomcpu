module datamemory(
    input clk,
    input [7:0] address,
    input wrtenable,
    input [31:0] wrtdata,
    output reg [31:0] reddata
    );
    reg [31:0] mem [0:255];
    always @(posedge clk) begin 
        if(wrtenable)
            mem[address] <= wrtdata;
    end

    always @(*) begin
        reddata = mem[address];
    end

endmodule


    
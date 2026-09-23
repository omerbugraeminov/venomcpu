module datamemory(
    input clk,
    input [7:0] address,
    input wrtenable,
    input [7:0] wrtdata,
    output reg [7:0] reddata
    );
    reg [7:0] mem [0:255];
    always @(posedge clk) begin 
        if(wrtenable)
            mem[address] <= wrtdata;
    end

    always @(*) begin
        reddata = mem[address];
    end

endmodule


    
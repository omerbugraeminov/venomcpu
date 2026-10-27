module lsu(
    input clk,
    input [31:0] address,
    input wrtenable,
    input [31:0] wrtdata,
    input [2:0] funct3,
    output reg [31:0] loaddata,
    input [31:0] addressB,
    output [31:0] reddataB
    );
    localparam LB  = 3'b000;
    localparam LH  = 3'b001;
    localparam LW  = 3'b010;
    localparam LBU = 3'b100;
    localparam LHU = 3'b101;
    localparam SW  = 3'b010;
    localparam SH  = 3'b001;
    localparam SB  = 3'b000;

    wire [31:0] ramdata;
    reg [7:0] loadbyte;
    wire [15:0] loadbyhalf;
    reg [3:0] byen;
    reg [31:0] storedata;

    datamemory ram(
        .clk(clk),
        .addressA(address[9:2]),
        .byen(byen),
        .wrtdata(storedata),
        .reddataA(ramdata),
        .addressB(addressB[9:2]),
        .reddataB(reddataB)
    );

    always @(*) begin
        case(address[1:0])
            2'b00: loadbyte = ramdata[7:0];
            2'b01: loadbyte = ramdata[15:8];
            2'b10: loadbyte = ramdata[23:16];
            2'b11: loadbyte = ramdata[31:24];
        endcase
    end

    assign loadbyhalf = address[1] ? ramdata[31:16] : ramdata[15:0];

    always @(*) begin
        case(funct3)
            LB:  loaddata = {{24{loadbyte[7]}}, loadbyte};
            LH:  loaddata = {{16{loadbyhalf[15]}}, loadbyhalf};
            LW:  loaddata = ramdata;
            LBU: loaddata = {24'b0, loadbyte};
            LHU: loaddata = {16'b0, loadbyhalf};
            default: loaddata = ramdata;
        endcase
    end
    
    always @(*) begin
        if(wrtenable == 0)
            byen = 4'd0;
        else
            case(funct3)
                SW: byen = 4'b1111;
                SH: begin
                    if(address[1] == 0)
                        byen = 4'b0011;
                    else 
                        byen = 4'b1100;
                end
                SB: begin
                    case(address[1:0])
                        2'b00: byen = 4'b0001;
                        2'b01: byen = 4'b0010;
                        2'b10: byen = 4'b0100;
                        2'b11: byen = 4'b1000;
                        default: byen = 4'b0000;
                    endcase
                end
                default: byen = 4'b0000;
            endcase
    end
    
    always @(*) begin
        case(funct3)
            SB: storedata = {4{wrtdata[7:0]}};
            SH: storedata = {2{wrtdata[15:0]}};
            SW: storedata = wrtdata;
            default: storedata = wrtdata;
        endcase
    end

endmodule

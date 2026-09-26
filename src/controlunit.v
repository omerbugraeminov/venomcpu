module controlunit(
    input [3:0] opcode,
    output jump,
    output wenable 
    );
    localparam nop = 4'b0000;
    assign jump = (opcode == 4'b0001);
    always @(*) begin
        case(opcode)
        4'b0011, 4'b0100, 4'b0101, 4'b0110,
        4'b0111, 4'b1000, 4'b1001, 4'b1010 :wenable = 1'b1;
        default: wenable = 1'b0;
    endcase
    end

    
    
endmodule
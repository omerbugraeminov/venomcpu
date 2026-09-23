module controlunit(
    input [3:0] opcode,
    output jump,
    output wenable 
    );
    localparam nop = 4'b0000;
    assign jump = (opcode == 4'b0001);
    assign wenable = (opcode == 4'b0010);
    
endmodule
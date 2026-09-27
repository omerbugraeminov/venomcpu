module mux(
    input [1:0] select,
    input [7:0] a,
    input [7:0] b,
    input [7:0] c,
    output [7:0] muxrslt
    );
    assign muxrslt = (select == 2'b00) ? a:
                     (select == 2'b01) ? b:
                        c;
endmodule
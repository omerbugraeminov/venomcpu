module mux(
    input [1:0] select,
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    input [31:0] d,
    output [31:0] muxrslt
    );
    assign muxrslt = (select == 2'b00) ? a:
                     (select == 2'b01) ? b:
                     (select == 2'b10) ? c:
                        d;
endmodule
module regfile(
    input clock,
    input wrtenable,
    input [2:0] wrtslct,
    input [7:0] wrtdata,
    output reg [7:0] reddataA,
    output reg [7:0] reddataB,
    input [2:0] redslctA,
    input [2:0] redslctB
    );
    reg [7:0] R [0:7];
    always @(posedge clock)
    begin
    if (wrtenable)
        begin
        if (wrtslct == 3'b000)
        R[0] <= wrtdata;
        else if (wrtslct == 3'b001)
        R[1] <= wrtdata;
        else if (wrtslct == 3'b010)
        R[2] <= wrtdata;
        else if (wrtslct == 3'b011)
        R[3] <= wrtdata;
        else if (wrtslct == 3'b100)
        R[4] <= wrtdata;
        else if (wrtslct == 3'b101)
        R[5] <= wrtdata;
        else if (wrtslct == 3'b110)
        R[6] <= wrtdata;
        else 
        R[7] <= wrtdata;
    end
    end
    always @(*)
    begin 
        if (redslctA == 3'b000)
        reddataA = R[0];
        else if (redslctA == 3'b001)
        reddataA = R[1];
        else if (redslctA == 3'b010)
        reddataA = R[2];
        else if (redslctA == 3'b011)
        reddataA = R[3];
        else if (redslctA == 3'b100)
        reddataA = R[4];
        else if (redslctA == 3'b101)
        reddataA = R[5];
        else if (redslctA == 3'b110)
        reddataA = R[6];
        else 
        reddataA = R[7];

        if (redslctB == 3'b000)
        reddataB = R[0];
        else if (redslctB == 3'b001)
        reddataB = R[1];
        else if (redslctB == 3'b010)
        reddataB = R[2];
        else if (redslctB == 3'b011)
        reddataB = R[3];
        else if (redslctB == 3'b100)
        reddataB = R[4];
        else if (redslctB == 3'b101)
        reddataB = R[5];
        else if (redslctB == 3'b110)
        reddataB = R[6];
        else 
        reddataB = R[7];
    end
endmodule
 
    
        
        
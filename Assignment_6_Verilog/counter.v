module counter (
    input cl,
    input clear,
    input load,
    input [31:0] X,
    output [31:0] Y
);
    reg [31:0] q;
    wire [31:0] incout;

    initial begin
        q = 'b0;
    end

    inc incr(.in(q), .out(incout));

    always @(posedge cl) begin
        if (!clear)
            q <= 'b0;
        else if (!load)
            q <= X;
        else
            q <= incout; 
    end

    assign Y = q;
endmodule
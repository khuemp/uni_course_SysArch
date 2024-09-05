module test_counter ();
    reg [31:0] in;
    reg cl, load, clear;
    wire [31:0] out;

    counter DUT(
        .cl(cl),
        .clear(clear),
        .load(load),
        .X(in),
        .Y(out)
    );

    initial begin
        in = 4'b1010;
        load = 1;
        clear = 1;
        cl = 0;
    end

    always 
        #1
        cl = !cl;

    initial begin
        #50
        clear = 0;
        #2
        clear = 1;
        #8
        load = 0;
        #2
        load = 1;
    end

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars;
    end

    initial begin
        $display("\t\ttime, \tcl, \tload, \tclear, \tout");
        $monitor("%d, \t%b, \t%b, \t%b, \t%d", $time, cl, load, clear, out);
    end

    initial
        #100 $finish;
    
endmodule
`timescale 1ns/1ps

module counter_tb;
    reg clk;
    reg rst_n;
    wire [3:0] count;

    // Instantiate counter
    counter uut (
        .clk (clk),
        .rst_n (rst_n),
        .count (count)
    );

    // Clock generator: 10ns period (100Mhz)
    always #5 clk = ~clk;

    initial begin
        // setup waveform dump
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);

        // Initialize signals
        clk = 0;
        rst_n = 0;   // in reset

        #20;
        rst_n = 1;   // release reset

        #150;

        $finish;
    end 
endmodule
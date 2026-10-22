
// this testbench is for testing the whole 3x3 mesh
`timescale 1ns / 1ps
import noc_pkg::*;

module mesh_3x3_tb;

    // 1. clock and reset
    logic clk   = 0;
    logic rst_n = 0;

    // 2D local ports for all the 9 routers (initialized to zero)
    logic [FLIT_WIDTH-1:0] local_in [3][3] = '0;
    logic [FLIT_WIDTH-1:0] local_out [3][3];

    // instantiate mesh_3x3
    mesh_3x3 dut (
        .clk (clk),
        .rst_n (rst_n),
        .local_in (local_in),
        .local_out (local_out)
    );

    // clock generator (10ns clock period: 5ns low, 5ns high)
    always #5 clk = ~clk;

    initial begin
        // setup waveform dumping for GTKWave
        $dumpfile("sim/waves/mesh_3x3.vcd");
        $dumpvars(0, mesh_3x3_tb);

        // reset the dut
        #20;
        rst_n = 1; 

        // scenario 1: send packet from (0,0) to (1,0)
        @(posedge clk);
        local_in [0][0] = {2'd0, 2'd1, 32'h1111_1111};

        // let router capture it
        repeat (4) @(posedge clk);

        // Clear input to simulate packet completion at source
        local_in [0][0] = '0;
        repeat (4) @(posedge clk);
        
        
        
        // scenario 2 multi hop traversal 
        // @(negedge clk);
        // local_in[0][0] = {2'd2, 2'd2, 32'hCAFE_BEEF};
        // @(negedge clk);
        // local_in[0][0] = '0;
        // Wait 6-7 cycles to let the packet travel through the 4 routers and emerge
        // repeat (7) @(posedge clk);



        

        // Wait 2 extra cycles to see output drain, then finish
        // repeat (2) @(posedge clk);
        $display("\n>>> Simulation complete! Open waveforms to view the packets moving. <<<\n");
        $finish;
    end
endmodule : mesh_3x3_tb


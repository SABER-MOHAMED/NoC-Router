// This testbench is for testing the ports and directions
`timescale 1ns / 1ps
import noc_pkg::*;

module router_tb;

    // 1. Clock and Reset
    logic clk   = 0;
    logic rst_n = 0;

    // 2. 5 Input Wires (Router is located at coordinate X=1, Y=1)
    logic [FLIT_WIDTH-1:0] local_in = '0;
    logic [FLIT_WIDTH-1:0] north_in = '0;
    logic [FLIT_WIDTH-1:0] south_in = '0;
    logic [FLIT_WIDTH-1:0] east_in  = '0;
    logic [FLIT_WIDTH-1:0] west_in  = '0;

    // 3. 5 Output Wires
    logic [FLIT_WIDTH-1:0] local_out;
    logic [FLIT_WIDTH-1:0] north_out;
    logic [FLIT_WIDTH-1:0] south_out;
    logic [FLIT_WIDTH-1:0] east_out;
    logic [FLIT_WIDTH-1:0] west_out;

    // 4. Instantiate the Router at (X=1, Y=1)
    router #(
        .MY_X(1),
        .MY_Y(1)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .local_in  (local_in),
        .north_in  (north_in),
        .south_in  (south_in),
        .east_in   (east_in),
        .west_in   (west_in),
        .local_out (local_out),
        .north_out (north_out),
        .south_out (south_out),
        .east_out  (east_out),
        .west_out  (west_out)
    );

    // 5. Clock Generator (10ns clock period: 5ns low, 5ns high)
    always #5 clk = ~clk;

    // 6. Test Sequence (Just 2 clean tests to see in waveforms)
    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("sim/waves/router.vcd");
        $dumpvars(0, router_tb);

        // --- STEP 1: Reset the Router ---
        #15;
        rst_n = 1; // De-assert reset (router is now active)

        // --- STEP 2: Send Packet East ---
        // Router is at (1,1). We target node (X=2, Y=1).
        // Flit format: {dest_y[35:34], dest_x[33:32], payload[31:0]}
        @(negedge clk);
        local_in = {2'd1, 2'd2, 32'hAAAA_AAAA};

        // Let router capture it on posedge clk, then clear input
        @(negedge clk);
        local_in = '0;

        // --- STEP 3: Send Packet South ---
        // Router is at (1,1). We target node (X=1, Y=2).
        @(negedge clk);
        local_in = {2'd2, 2'd1, 32'hBBBB_BBBB};

        // Let router capture it on posedge clk, then clear input
        @(negedge clk);
        local_in = '0;

        // Wait 2 extra cycles to see output drain, then send west
        repeat (2) @(posedge clk);


        // --- STEP 4: Send Packet West ---
        // Router is at (1,1). We target node (X=0, Y=1).
        @(negedge clk);
        local_in = {2'd1, 2'd0, 32'hCCCC_CCCC};

        // Let router capture it on posedge clk, then clear input
        @(negedge clk);
        local_in = '0;

        // Step 5 -- send packet North
        // router is at 1,1 we target node (X=1, Y=0)
        @(negedge clk);
        local_in = {2'd0, 2'd1, 32'hDDDD_DDDD};
        
        // let router capture it on posedge clk then clear input
        @(negedge clk);
        local_in = '0;

        // Wait 2 extra cycles to see output drain, then finish
        repeat (2) @(posedge clk);
        $display("\n>>> Simulation complete! Open waveforms to view the packets moving. <<<\n");
        $finish;
    end

endmodule : router_tb

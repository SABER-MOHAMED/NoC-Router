
// this testbench is for testing the whole 3x3 mesh
`timescale 1ns / 1ps
import noc_pkg::*;

module mesh_3x3_tb;

    // 1. clock and reset
    logic clk   = 0;
    logic rst_n = 0;

    // 2D local ports for all the 9 routers (initialized to zero)
    logic [FLIT_WIDTH-1:0] local_in [3][3];
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

    // Testbench variables
    logic [PAYLOAD_WIDTH-1:0] rx_payload;

    // =========================================================================
    // helper tasks, send packet, receive packet
    // =========================================================================
    task automatic send_packet(
        input logic [ADDR_WIDTH-1:0]    src_x,
        input logic [ADDR_WIDTH-1:0]    src_y,
        input logic [ADDR_WIDTH-1:0]    dst_x,
        input logic [ADDR_WIDTH-1:0]    dst_y,
        input logic [PAYLOAD_WIDTH-1:0] payload
    );
        // flit format:: {dest_y, dest_x, payload}
        @(posedge clk);
        local_in[src_x][src_y] = {dst_y, dst_x, payload};
        @(posedge clk);
        local_in[src_x][src_y] = '0;
    endtask

    task automatic receive_packet(
        input  logic [ADDR_WIDTH-1:0]    dst_x,
        input  logic [ADDR_WIDTH-1:0]    dst_y,
        output logic [PAYLOAD_WIDTH-1:0] payload,
        input  int                       max_timeout_cycles
    );
        int timeout = 0;

        while (local_out[dst_x][dst_y] == '0 && timeout < max_timeout_cycles) begin
            @(posedge clk);
            timeout++;
        end 

        if (local_out[dst_x][dst_y] != '0) begin
            payload = local_out[dst_x][dst_y][PAYLOAD_MSB:PAYLOAD_LSB];
        end else begin
            payload = '0;
            $display("[TIMEOUT] No packet received at (%0d, %0d) within %0d cycles", 
                     dst_x, dst_y, max_timeout_cycles);
        end
    endtask

    initial begin
        // setup waveform dumping for GTKWave
        $dumpfile("sim/waves/mesh_3x3.vcd");
        $dumpvars(0, mesh_3x3_tb);

        // initialize the the 2d array with zeros
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                local_in[i][j] = '0;
            end
        end

        // reset the dut
        #20;
        rst_n = 1; 

        // START SCENARIO 1
        // 4-hop: send packet from (0,0) to (2,2)
        // send_packet(2'd0, 2'd0, 2'd2, 2'd2, 32'hDEAD_BEEF);
        // receive_packet(2'd2, 2'd2, rx_payload, 20);

        // if (rx_payload == 32'hDEAD_BEEF) begin
        //     $display("Packet received successfully! (0,0) -> (2,2) Payload: 0x%h", rx_payload);
        // end else begin
        //     $display("Expected 0xDEAD_BEEF, got 0x%h", rx_payload);
        // end
        // END SCENARIO 1

        // START SCENARIO 2
        // 1-hop adjacent neighbor: (0,0) -> (1,0)
        // send_packet(2'd0, 2'd0, 2'd1, 2'd0, 32'h1234_1234);        
        // receive_packet(2'd1, 2'd0, rx_payload, 20);
        
        // if (rx_payload == 32'h1234_1234) begin
        //     $display("Packet received successfully! (0,0) -> (1,0) Payload: 0x%h", rx_payload);
        // end else begin
        //     $display("Expected 0x1234_1234, got 0x%h", rx_payload);
        // end
        // END SCENARIO 2

        // START SCENARIO 3:
        // test 2: Vertical hop: (0,0) -> (0,2)
        send_packet(2'd0, 2'd0, 2'd0, 2'd2, 32'h1234_5678);
        receive_packet(2'd0, 2'd2, rx_payload, 20);

        if (rx_payload == 32'h1234_5678) begin
            $display("Packet received successfully! (0,0) -> (0,2) Payload: 0x%h", rx_payload);
        end else begin
            $display("Expected 0x1234_5678, got 0x%h", rx_payload);
            
        end
        // END SCENARIO 3:

        // Wait 2 extra cycles before finishing
        repeat (2) @(posedge clk);
        $display("------simulation complete------");
        $finish;
    end
endmodule : mesh_3x3_tb


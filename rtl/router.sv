import noc_pkg::*;

module router #(
    parameter int MY_X = 0,
    parameter int MY_Y = 0
) (
    input logic clk,
    input logic rst_n,

    // input flits they must be 5, size is 36 bits
    input logic [FLIT_WIDTH - 1 : 0] local_in,
    input logic [FLIT_WIDTH - 1 : 0] north_in,
    input logic [FLIT_WIDTH - 1 : 0] south_in,
    input logic [FLIT_WIDTH - 1 : 0] east_in,
    input logic [FLIT_WIDTH - 1 : 0] west_in,

    // output flits they must be 5, size is 36 bits
    output logic [FLIT_WIDTH - 1 : 0] local_out,
    output logic [FLIT_WIDTH - 1 : 0] north_out,
    output logic [FLIT_WIDTH - 1 : 0] south_out,
    output logic [FLIT_WIDTH - 1 : 0] east_out,
    output logic [FLIT_WIDTH - 1 : 0] west_out
);

    // =========================================================================
    // 1. Next-Hop Direction for each input port
    // =========================================================================
    direction_t dir_local, dir_north, dir_south, dir_east, dir_west;

    routing_xy #(.MY_X(MY_X), .MY_Y(MY_Y)) u_route_local (
        .dest_x(local_in[X_MSB:X_LSB]),
        .dest_y(local_in[Y_MSB:Y_LSB]),
        .next_dir(dir_local)
    );
    routing_xy #(.MY_X(MY_X), .MY_Y(MY_Y)) u_route_north (
        .dest_x(north_in[X_MSB:X_LSB]),
        .dest_y(north_in[Y_MSB:Y_LSB]),
        .next_dir(dir_north)
    );
    routing_xy #(.MY_X(MY_X), .MY_Y(MY_Y)) u_route_south (
        .dest_x(south_in[X_MSB:X_LSB]),
        .dest_y(south_in[Y_MSB:Y_LSB]),
        .next_dir(dir_south)
    );
    routing_xy #(.MY_X(MY_X), .MY_Y(MY_Y)) u_route_east (
        .dest_x(east_in[X_MSB:X_LSB]),
        .dest_y(east_in[Y_MSB:Y_LSB]),
        .next_dir(dir_east)
    );
    routing_xy #(.MY_X(MY_X), .MY_Y(MY_Y)) u_route_west (
        .dest_x(west_in[X_MSB:X_LSB]),
        .dest_y(west_in[Y_MSB:Y_LSB]),
        .next_dir(dir_west)
    );

    // =========================================================================
    // 2. Crossbar Switching Logic (Combinational Multiplexing)
    // Priority order: Local > North > South > East > West
    // =========================================================================
    logic [FLIT_WIDTH-1:0] local_next, north_next, south_next, east_next, west_next;
    // --- LOCAL Output Mux ---
    always_comb begin
        if (north_in != '0 && dir_north == LOCAL)      local_next = north_in;
        else if (south_in != '0 && dir_south == LOCAL) local_next = south_in;
        else if (east_in  != '0 && dir_east  == LOCAL) local_next = east_in;
        else if (west_in  != '0 && dir_west  == LOCAL) local_next = west_in;
        else if (local_in != '0 && dir_local == LOCAL) local_next = local_in;
        else                                           local_next = '0;
    end
    // --- NORTH Output Mux ---
    always_comb begin
        if (local_in != '0 && dir_local == NORTH)      north_next = local_in;
        else if (south_in != '0 && dir_south == NORTH) north_next = south_in;
        else if (east_in  != '0 && dir_east  == NORTH) north_next = east_in;
        else if (west_in  != '0 && dir_west  == NORTH) north_next = west_in;
        else                                           north_next = '0;
    end
    // --- SOUTH Output Mux ----
    always_comb begin
        if (local_in != '0 && dir_local == SOUTH)      south_next = local_in;
        else if (north_in != '0 && dir_north == SOUTH) south_next = north_in;
        else if (east_in != '0 && dir_east == SOUTH)  south_next = east_in;
        else if (west_in  != '0 && dir_west  == SOUTH) south_next = west_in;
        else                                           south_next = '0;
    end
    // --- EAST output mux ---
    always_comb begin
        if (local_in != '0 && dir_local == EAST)     east_next = local_in;
        else if (west_in != '0 && dir_west == EAST)  east_next = west_in;
        else if (north_in != '0 && dir_north == EAST) east_next = north_in;
        else if (south_in != '0 && dir_south == EAST) east_next = south_in;
        else                                          east_next = '0;
    end 

    // --- WEST output mux ---
    always_comb begin
        if (local_in != '0 && dir_local == WEST)     west_next = local_in;
        else if (east_in != '0 && dir_east == WEST)  west_next = east_in;
        else if (north_in != '0 && dir_north == WEST) west_next = north_in;
        else if (south_in != '0 && dir_south == WEST) west_next = south_in;
        else                                          west_next = '0;
    end

    // ======================================================
    // 3. Output registers (1 clock cycle latency per Hop)
    // ======================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            local_out <= '0;
            north_out <= '0;
            south_out <= '0;
            west_out <= '0;
            east_out <= '0;
        end else begin
            local_out <= local_next;
            north_out <= north_next;
            south_out <= south_next;
            west_out <= west_next;
            east_out <= east_next;
        end
    end

endmodule : router
import noc_pkg::*;

module routing_xy #(
    parameter int MY_X = 0,
    parameter int MY_Y = 0
)
(
    input  logic [ADDR_WIDTH - 1 : 0] dest_x,
    input  logic [ADDR_WIDTH - 1 : 0] dest_y,

    output direction_t next_dir
);

    always_comb begin : xy_routing
        if (dest_x > MY_X) begin
            next_dir = EAST;
        end
        else if (dest_x < MY_X) begin
            next_dir = WEST;
        end
        else if (dest_y > MY_Y) begin
            next_dir = SOUTH;
        end
        else if (dest_y < MY_Y) begin
            next_dir = NORTH;
        end
        else begin
            next_dir = LOCAL;
        end
    end

endmodule : routing_xy
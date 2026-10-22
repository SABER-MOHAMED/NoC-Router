import noc_pkg::*;

module mesh_3x3 (
    input logic clk,
    input logic rst_n,

    // Local inputs/outputs for corner routers
    input logic [FLIT_WIDTH - 1 : 0] local_in [3][3],
    output logic [FLIT_WIDTH - 1 : 0] local_out [3][3]
);

    // horizontal links
    // Row 0, wires between (0,0), (1,0) and (2,0)
    // logic [FLIT_WIDTH-1:0] link_00_10,  link_10_00;
    // logic [FLIT_WIDTH-1:0] link_10_20,  link_20_10;

    // // Row 1, wires between (0,1), (1,1) and (2,1)
    // logic [FLIT_WIDTH-1:0] link_01_11,  link_11_01;
    // logic [FLIT_WIDTH-1:0] link_11_21,  link_21_11;

    // // Row 3, wires between (0,2), (1,2) and (2,2)
    // logic [FLIT_WIDTH-1:0] link_02_12,  link_12_02;
    // logic [FLIT_WIDTH-1:0] link_12_22,  link_22_12;

    // // Vertical wires
    // // column 0, wires between (0,0), (0,1) and (0,2)
    // logic [FLIT_WIDTH-1:0] link_00_01,  link_01_00;
    // logic [FLIT_WIDTH-1:0] link_01_02,  link_02_01;

    // // column 1, wires between (1,0), (1,1) and (1,2)
    // logic [FLIT_WIDTH-1:0] link_10_11,  link_11_10;
    // logic [FLIT_WIDTH-1:0] link_11_12,  link_12_11;

    // // column 2, wires between (2,0), (2,1) and (2,2)
    // logic [FLIT_WIDTH-1:0] link_20_21,  link_21_20;
    // logic [FLIT_WIDTH-1:0] link_21_22,  link_22_21;


    // 2D Interconnect output wires between routers
    logic [FLIT_WIDTH-1:0] north_out [3][3];
    logic [FLIT_WIDTH-1:0] south_out [3][3];
    logic [FLIT_WIDTH-1:0] east_out  [3][3];
    logic [FLIT_WIDTH-1:0] west_out  [3][3];

    // instantiate 9 routers
    genvar x, y;
    generate
        for (y = 0; y < 3; y++) begin : gen_row
            for (x = 0; x < 3; x++) begin : gen_col

                // local input signals for this router instance
                logic [FLIT_WIDTH-1:0] n_in, s_in, e_in, w_in;

                // boundary logic: connect to neighbor or tie to '0'
                assign n_in = (y > 0) ? south_out[x][y-1] : '0;
                assign s_in = (y < 2) ? north_out[x][y+1] : '0;
                assign w_in = (x > 0) ? east_out[x-1][y]  : '0;
                assign e_in = (x < 2) ? west_out[x+1][y]  : '0;

                router #(
                    .MY_X(x),
                    .MY_Y(y)
                ) u_router (
                    .clk       (clk),
                    .rst_n     (rst_n),
                    .local_in  (local_in[x][y]),
                    .local_out (local_out[x][y]),
                    .north_in  (n_in),
                    .north_out (north_out[x][y]),
                    .south_in  (s_in),
                    .south_out (south_out[x][y]),
                    .east_in   (e_in),
                    .east_out  (east_out[x][y]),
                    .west_in   (w_in),
                    .west_out  (west_out[x][y])
                );

            end
        end
    endgenerate


        

endmodule : mesh_3x3

    
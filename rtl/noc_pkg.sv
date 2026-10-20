package noc_pkg;
    localparam int ADDR_WIDTH = 2;
    localparam int PAYLOAD_WIDTH = 32;
    
    localparam int FLIT_WIDTH = 2*ADDR_WIDTH + PAYLOAD_WIDTH;
    
    localparam int NUM_PORTS = 5;
    
    localparam int PAYLOAD_LSB = 0;
    localparam int PAYLOAD_MSB = PAYLOAD_WIDTH - 1;

    localparam int X_LSB = PAYLOAD_MSB + 1;
    localparam int X_MSB = X_LSB + ADDR_WIDTH -1;

    localparam int Y_LSB = X_MSB + 1;
    localparam int Y_MSB = Y_LSB + ADDR_WIDTH -1;
    

    // define directional ports
    typedef enum logic [2:0] {
        LOCAL = 3'b000,
        NORTH = 3'b001,
        SOUTH = 3'b010,
        EAST  = 3'b011,
        WEST  = 3'b100
    } direction_t;
    
endpackage : noc_pkg

// When we send a packet out → count decreases (we used up a slot).
// When a neighbor frees a slot → count increases (credit returned).
// When nothing is happening → count holds still.

// up down counter with enable
module counter (
    input wire clk,
    input wire rst_n, // active low synchronous reset
    input wire en,    // enable
    input wire up,   // up/down direction

    output reg [3:0] count
);

    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 4'b0000;
        end else begin
            if (en) begin
                if (up) begin
                    count <= count + 4'b1;
                end else begin
                    count <= count - 4'b1;
                end
            end
        end
    end

endmodule

// // simple 4 bit counter
// module counter (
//     input wire clk,
//     input wire rst_n, // active low synchronous reset
//     output reg [3:0] count
// );

//     always @(posedge clk) begin
//         if (!rst_n) begin
//             count <= 4'b0000;
//         end else begin
//             count <= count + 2;
//         end
//     end

// endmodule
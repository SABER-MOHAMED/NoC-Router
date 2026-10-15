# NoC Router
This is a credit-based NoC router written in System verilog.

it simulates how multiple processing units or cores communicate with each other in a chip (many-core architecture).

the project is basically a hardware router that takes incoming data packets, figures out where they need to go (North, South, west  or East) and routes them to the correct output port.

The main goal of the project is to build the router from scratch and understand its components , and how they work together to route packets, we aim to simulate the design correctness using waveform inspection
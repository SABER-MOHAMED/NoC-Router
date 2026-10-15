# cd examples/00_starter_counter

# 1. Compile Verilog into a simulation binary
iverilog -o counter_sim counter.v counter_tb.v

# 2. Run simulation (generates counter.vcd)
vvp counter_sim

# 3. View the waveforms
gtkwave counter.vcd

iverilog -g2012 -o sim/mesh_sim \
    rtl/noc_pkg.sv \
    rtl/routing_xy.sv \
    rtl/router.sv \
    rtl/mesh_3x3.sv \
    tb/mesh_3x3.sv

vvp sim/mesh_sim
gtkwave sim/waves/mesh_3x3.vcd


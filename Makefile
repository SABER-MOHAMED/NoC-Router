IVERILOG ?= iverilog
VVP      ?= vvp
RTL      := rtl/noc_pkg.sv rtl/routing_xy.sv rtl/router.sv
BUILD    := build

.PHONY: all router mesh waves-router waves-mesh clean
all: router mesh

$(BUILD):
	mkdir -p $(BUILD) sim/waves

router: $(BUILD)
	$(IVERILOG) -g2012 -o $(BUILD)/router_sim $(RTL) tb/router_tb.sv
	$(VVP) $(BUILD)/router_sim

mesh: $(BUILD)
	$(IVERILOG) -g2012 -o $(BUILD)/mesh_sim $(RTL) rtl/mesh_3x3.sv tb/mesh_3x3.sv
	$(VVP) $(BUILD)/mesh_sim

waves-router: router
	gtkwave sim/waves/router.vcd

waves-mesh: mesh
	gtkwave sim/waves/mesh_3x3.vcd

clean:
	rm -rf $(BUILD) sim/waves/*.vcd

# Roadmap

Build the mesh in public. Each milestone ends with a tagged commit and a short post. The post is part of the milestone: the work is not parked until the congestion study exists.

The study this repo is heading toward is a reproduction of the classic mesh-routing result, then one new measurement on top of it: how much saturation throughput a congestion signal buys, and what that signal costs in hardware. XY versus odd-even on transpose traffic is already in the literature. Matching that curve is the credibility check. The signal-cost table is the result worth writing up.

## Current design

Checked items match the tree as of November 2026. A box is checked only when the RTL or the test actually does the thing.

- Topology: 3×3 mesh, Y grows south. One registered cycle per router.
- Flit: 36 bits, `{dest_y, dest_x, payload}`. The all-zero word means idle, so payload 0 addressed to `(0,0)` cannot be sent.
- Routing: XY only (`rtl/routing_xy.sv`).
- Flow control: none. Two flits that want the same output on the same clock, and the loser is deleted.
- Tests: `make router` dumps a waveform and does not check a value. `make mesh` checks `(0,0) → (0,2)` only. The diagonal and the one-hop case in `tb/mesh_3x3.sv` are commented out. Icarus prints 12 out-of-bounds warnings on the mesh borders.

### Foundation

- [x] Icarus Verilog (`iverilog`, `vvp`) and a waveform viewer.
- [x] Flit fields and port enum in `rtl/noc_pkg.sv`.
- [x] XY routing in `rtl/routing_xy.sv`. Larger Y is south.
- [x] Five-port router with output registers in `rtl/router.sv`.
- [x] 3×3 mesh in `rtl/mesh_3x3.sv`. Neighbor links are East-to-West and North-to-South.
- [x] Waveform demo of local injection to N, S, E, and W from router `(1,1)`.
- [x] One self-checking mesh path: `(0,0) → (0,2)`.
- [ ] The router test does not check West → Local, despite the old plan listing it.
- [ ] Standalone routing testbench.
- [ ] `rtl/core_mock.sv` was planned and was never needed. Traffic lives in the testbench from Milestone 3 on. This item is retired.

## How a milestone closes

A milestone is done when all three exist:

1. The acceptance checks below pass on your machine.
2. The repo is tagged with the name in the milestone.
3. You publish the post. One figure or one test log, plus the caption. Link the tag.

Say what the design does in the caption, including the limitation the next milestone removes. Readers trust a precise claim.

Suggested order is the numbering below. Milestone 4 is the first post aimed at people who work on interconnects. Milestones 0–3 are the learning log that makes Milestone 4 believable, and they are worth posting on their own.

---

## Milestone 0 — The mesh routes

**Tag:** `v0.1-xy-mesh`

**Already true.** A flit from `(0,0)` reaches `(2,2)` in 5 cycles, which is 4 hops plus the source register. `(0,0) → (1,0)` takes 2 cycles. `make mesh` delivers `(0,0) → (0,2)`.

**Share now, before changing the RTL.** This is the post that starts the public trail.

- Figure: the hand sketch (`image.png`), or a GTKWave shot of one flit crossing the mesh.
- Caption: “From-scratch 3×3 mesh router in SystemVerilog. XY routing, one register per hop, so a 4-hop diagonal takes 5 cycles. Idle is the all-zero flit, and a contested output drops the loser. Next is a valid bit and tests that fail when a route breaks.”

- [ ] Tag `v0.1-xy-mesh` on the current commit.
- [ ] Post the caption and one figure.

---

## Milestone 1 — A mesh a stranger can trust

**Tag:** `v0.2-self-checking`

Make the happy path checked, and make the two known correctness holes explicit in the tests.

- [ ] Add a valid bit. Idle is `valid = 0`, so a zero payload to `(0,0)` is a real flit.
- [ ] Tie off the four borders with generate-if. `make mesh` prints no out-of-bounds warnings.
- [ ] Drive every testbench input on the falling edge, the way `tb/router_tb.sv` already does.
- [ ] Self-checking router test: local to N, S, E, W, and West to local. A mismatch exits nonzero.
- [ ] Self-checking mesh test, all enabled: `(0,0) → (1,0)`, `(0,0) → (0,2)`, `(0,0) → (2,2)`, self-delivery at `(1,1)`, and payload 0 to `(0,0)`.
- [ ] One test that documents today’s clash behavior, so it is obvious when Milestone 2 changes it: two flits want East at `(1,1)` on the same clock, and the loser does not arrive.
- [ ] README: flit layout, `make mesh`, and the hops-plus-one latency. Link this roadmap.
- [ ] Run the suite in GitHub Actions with Icarus.

**Done when:** `make mesh` and `make router` exit 0 only if every expected payload arrives, and the Actions log is green.

**Share:**

- Figure: the green Actions run, or the test log with the five routes.
- Caption: “The 3×3 XY mesh is self-checking. A 4-hop diagonal is 5 cycles, a zero payload to `(0,0)` arrives, and CI fails if a route breaks. A same-cycle output clash still drops a flit. Next is backpressure.”

---

## Milestone 2 — A flit waits instead of disappearing

**Tag:** `v0.3-flow-control`

This is the precondition for every paper in the reference list. Those evaluations use wormhole or cut-through with buffers. A router that deletes the loser cannot be compared with them.

- [ ] One-flit input buffer on each port, plus a ready or credit so a full buffer stalls the sender.
- [ ] The clash test from Milestone 1 flips: both flits that wanted East at `(1,1)` arrive at `(2,1)`, one after the other.
- [ ] Latency for an uncontended route stays hops plus one. Buffering must not add a cycle when the output is free. If it does, write the new formula in the README and use it everywhere after this.
- [ ] Still XY only. No new routing algorithm in this milestone.

**Done when:** the old clash test fails on purpose, the new test passes, and a single flit across the diagonal still takes the latency the README states.

**Share:**

- Figure: waveform or log of the two East-bound flits both arriving.
- Caption: “Same router, with a one-flit buffer and backpressure. Two flits that collide on East both arrive. Uncontended latency is still hops plus one. Next is an 8×8 traffic harness.”

---

## Milestone 3 — The measurement harness

**Tag:** `v0.4-harness`

Curves need a mesh large enough for the algorithms to separate. Keep the 3×3 suite as the regression. Measure on 8×8.

- [ ] Parameterize the mesh size. 3×3 regression still passes.
- [ ] Bernoulli injection at rate λ flits per node per cycle.
- [ ] Destination patterns: uniform, transpose `(x, y) → (y, x)`, bit-complement, hotspot (uniform, with about 10% of flits forced to one node).
- [ ] Latency is ejection cycle minus creation cycle, including the wait at the source. Throughput is flits ejected, divided by nodes times measured cycles. Discard a warmup interval, then measure a steady interval. Same seeds for every later algorithm.
- [ ] Zero-load check, XY only, on 8×8: at a very small λ, average latency matches the README formula within a cycle.
- [ ] A script that writes one CSV and one plot of latency against offered load for XY under uniform and transpose.

**Done when:** the zero-load check passes, and the plot shows a flat latency region followed by a climb. You do not need a second algorithm yet.

**Share:**

- Figure: the XY-only latency plot, uniform and transpose on the same axes.
- Caption: “Cycle-accurate 8×8 XY mesh. Latency includes source queueing. Uniform and transpose both plotted against offered load. The routing comparison comes next, on this same harness.”

---

## Milestone 4 — The curve the literature already knows

**Tag:** `v0.5-routing-curves`

This is the first post for interconnect people. It is a reproduction, and the caption should say so. A matching shape is the result.

Algorithms, all deadlock-free without virtual channels, all minimal, all on the same buffers:

- [ ] **XY**, already built. One legal output.
- [ ] **West-first** (Glass and Ni). If the destination is west, the only minimal port is West. If it is east and off-row, East and the Y port are both legal.
- [ ] **Odd-even** (Chiu). Even column: a flit that arrived from West cannot leave North or South. Odd column: a flit that arrived from North or South cannot leave West. A locally injected flit has no incoming direction, so both productive ports are legal.
- [ ] Selection, for this milestone only: random among the legal ports. No congestion bit yet. That isolation is what makes the next milestone mean something.
- [ ] Replace the fixed mux priority as the thing that silently picks a port. Fixed priority would bias one direction and confound the algorithm.

Run all three on uniform, transpose, bit-complement, and hotspot. Saturation is the offered load where average latency reaches three times the zero-load latency. State that definition in the README.

Sanity, before believing the plot:

- [ ] Uniform: XY matches or beats west-first and odd-even. Balanced traffic does not reward adaptivity.
- [ ] Transpose: odd-even stays flat to a higher load than XY.
- [ ] The same 8×8 configuration in [BookSim](https://github.com/booksim/booksim2) shows the same ranking. A disagreement is a bug in the RTL or in the harness.

**Done when:** both sanity checks hold, the plot has three lines per traffic pattern, and BookSim agrees on which algorithm saturates first.

**Share:**

- Figure: transpose latency against offered load, three lines, saturation points marked.
- Caption: “Reproducing the classic mesh result in SystemVerilog. On 8×8 transpose traffic, odd-even saturates at a higher offered load than XY. Uniform traffic does not show that gap. Same ranking in BookSim. Selection is random. A congestion signal is the next measurement.”
- Also post the uniform plot in the same thread or the README, so the claim is the pair of outcomes, not only the flattering one.

---

## Milestone 5 — What a congestion signal costs

**Tag:** `v0.6-congestion-cost`

The route function stays odd-even. The only change between runs is how a router picks among legal ports. This is the study.

- [ ] Random among legal ports. Already measured in Milestone 4. This is the baseline.
- [ ] Downstream free-buffer count.
- [ ] One bit from the downstream router, set when its buffer is more than half full. This is the DyAD signal.
- [ ] Sum of free slots along the row or column, counting only routers inside the rectangle between the current node and the destination. This is DBAR’s rule, using buffer slots because this router has no virtual channels.
- [ ] Same traffic, seeds, and saturation definition as Milestone 4.
- [ ] Synthesize each selection function with Yosys, or report LUT count from the tool you have. The table has two columns that matter: signal width, and the offered load where transpose latency triples.
- [ ] One paragraph on deadlock: each selector only chooses among ports the turn model already allows, so the turn proof still applies. Write that down next to the table.

**Done when:** the table exists, the transpose plot has one line per selector, and uniform traffic is in the README so a selector that wins on transpose and loses on uniform is visible.

**Share:**

- Figure: the table, and the transpose plot.
- Caption: “Same odd-even mesh, four ways to pick a legal port: random, free-buffer count, a half-full bit, and a destination-rectangle sum. Transpose saturation and the gate count of each selector. Metrics are close in the papers. This is the RTL cost next to that result.”

That post is the one to expand into a four-page note: harness, saturation rule, BookSim check, table, and the deadlock paragraph.

---

## After Milestone 5, and only then

These are real papers and a poor next step before the table exists. Each one can be its own tagged post.

- An all-reduce pattern as an extra workload. Cite TidalMesh (HPCA 2025) and “Supporting Efficient Collective Communication in NoCs” (HPCA 2012) as the collective layer, and describe your pattern as traffic, not as a new collective algorithm.
- A SymbiYosys proof that an accepted flit is delivered and that the turn rules you implemented cannot deadlock.
- A second virtual channel and fully adaptive routing. Different hardware. Do not mix those curves with Milestone 4.

## Experiment rules

Used from Milestone 3 onward. Changing one of these means re-running the curves you already posted and saying so.

- Mesh for curves: 8×8. Mesh for regression: 3×3.
- Latency includes source queueing.
- Saturation: average latency equals three times the zero-load latency.
- Identical buffers, packet size, seeds, warmup, and measurement window across algorithms.
- One flit per packet until the ranking is stable. A follow-up with 4-flit wormhole packets is a separate tagged plot, not a silent change.

## Papers to match, then cite

- Glass and Ni, “The Turn Model for Adaptive Routing,” ISCA 1992. West-first. [doi:10.1145/146628.140384](https://doi.org/10.1145/146628.140384)
- Chiu, “The Odd-Even Turn Model for Adaptive Routing,” IEEE TPDS, 2000. [doi:10.1109/71.877831](https://doi.org/10.1109/71.877831)
- Mello, Ost, Moraes, and Calazans, “Evaluation of Routing Algorithms on Mesh Based NoCs,” PUCRS TR 040, 2004. Deterministic routing can win. [PDF](https://www.pucrs.br/facin-prov/wp-content/uploads/sites/19/2016/03/tr040.pdf)
- Hu and Marculescu, “DyAD: Smart Routing for Networks-on-Chip,” DAC 2004. The one-bit congestion signal, and a synthesized router. [PDF](https://www.cs.york.ac.uk/rts/docs/SIGDA-Compendium-1994-2004/papers/2004/dac04/pdffiles/p260.pdf)
- Gratz, Grot, and Keckler, “Regional Congestion Awareness for Load Balance in Networks-on-Chip,” HPCA 2008. [PDF](https://www.cs.utexas.edu/~skeckler/pubs/hpca08.pdf)
- Ma, Enright Jerger, and Wang, “DBAR,” ISCA 2011. Congestion metrics behaved similarly. They chose one for its wire cost. [PDF](https://www.eecg.utoronto.ca/~enright/isca38-sheng.pdf)
- Jiang et al., “A Detailed and Flexible Cycle-Accurate Network-on-Chip Simulator,” ISPASS 2013. BookSim is the check on your ranking. [doi:10.1109/ISPASS.2013.6557149](https://doi.org/10.1109/ISPASS.2013.6557149)
- Dally and Towles, *Principles and Practices of Interconnection Networks*, 2004. Latency and throughput definitions.

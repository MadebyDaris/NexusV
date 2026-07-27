"""
tests/test_dfg.jl

End-to-end test: build a DFG, schedule it, emit SystemVerilog, verify output.

Graph: mac_plus_5  =>  (rs1 * rs2) + 5
  node 1: OP_ARG  (rs1)          -> cycle 1
  node 2: OP_ARG  (rs2)          -> cycle 1
  node 3: OP_CONST 5             -> cycle 1
  node 4: OP_MUL  (1 * 2)        -> cycle 2
  node 5: OP_ADD  (4 + 3)        -> cycle 3
  node 6: OP_RET  (5)            -> cycle 3
Expected latency: 3
"""

include("../src/DFG_Builder.jl")
using .DFG_Builder

include("../hw/src_hw/Scheduler.jl")   # plain include, uses DFG_Builder types in scope
include("../hw/src_hw/VerilogEmitter.jl")

# Build
node_1 = DFGNode(1, OP_ARG, 32, [], nothing, 0)
node_2 = DFGNode(2, OP_ARG, 32, [], nothing, 0)
node_3 = DFGNode(3, OP_CONST, 32, [], 5, 0)
node_4 = DFGNode(4, OP_MUL, 32, [1, 2], nothing, 0)
node_5 = DFGNode(5, OP_ADD, 32, [4, 3], nothing, 0)
node_6 = DFGNode(6, OP_RET, 32, [5], nothing, 0)

graph = HWGraph(
  "mac_plus_5",
  Dict(1 => node_1, 2 => node_2, 3 => node_3, 4 => node_4, 5 => node_5, 6 => node_6),
  [1, 2],
  [6]
)

# Schedule
schedule_asap!(graph)

println("Scheduled cycles:")
for id in sort(collect(keys(graph.nodes)))
  n = graph.nodes[id]
  println("  node $(n.id) ($(n.op)) -> cycle $(n.scheduled_cycle)")
end

@assert graph.nodes[1].scheduled_cycle == 1 "OP_ARG must be cycle 1"
@assert graph.nodes[3].scheduled_cycle == 1 "OP_CONST must be cycle 1"
@assert graph.nodes[4].scheduled_cycle == 2 "MUL must be cycle 2"
@assert graph.nodes[5].scheduled_cycle == 3 "ADD must be cycle 3"
@assert graph.latency == 3 "Latency must be 3"
println("Scheduling: PASS  (latency=$(graph.latency))")

# Emit SystemVerilog
out_sv = joinpath(@__DIR__, "..", "hw", "rtl_nexus", "mac_plus_5.sv")
emit_verilog(graph, out_sv)

sv_text = read(out_sv, String)
@assert occursin("module mac_plus_5", sv_text) "Missing module declaration"
@assert occursin("start_i", sv_text) "Missing start_i"
@assert occursin("done_o", sv_text) "Missing done_o"
@assert occursin("rs1_i", sv_text) "Missing rs1_i"
@assert occursin("rs2_i", sv_text) "Missing rs2_i"
@assert occursin("rd_o", sv_text) "Missing rd_o"
@assert occursin("always_ff", sv_text) "Missing pipeline registers"
@assert occursin("endmodule", sv_text) "Missing endmodule"
println("Emit: PASS  (written to $out_sv)")

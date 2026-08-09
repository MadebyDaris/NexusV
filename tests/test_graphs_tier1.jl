"""
tests/test_graphs_tier1.jl

Tier 1 test graphs — stress the scheduler/emitter with deeper pipelines.
No primitives, just generic opcodes.

Graph 1: Horner's method — ((a3*x + a2)*x + a1)*x + a0
  Deep chain of dependent MULs → forces multi-cycle pipeline register chains.

Graph 2: CRC step — shift + conditional XOR
  Mixes OP_SHR/OP_SHL with OP_XOR and OP_MUX.
"""

include("../src/Core/DFG_Builder.jl")
using .DFG_Builder

include("../hw/src_hw/Scheduler.jl")
include("../hw/src_hw/VerilogEmitter.jl")

# ═══════════════════════════════════════════════════════════════════════════════
# Graph 1: Horner's method — ((a3*x + a2)*x + a1)*x + a0
#
# Nodes:
#   1: OP_ARG  (a3)        → cycle 1
#   2: OP_ARG  (x)         → cycle 1
#   3: OP_ARG  (a2)        → cycle 1
#   4: OP_ARG  (a1)        → cycle 1
#   5: OP_ARG  (a0)        → cycle 1
#   6: OP_MUL  (a3 * x)    → cycle 2, latency 2, finishes cycle 3
#   7: OP_ADD  (6 + a2)    → cycle 4, latency 1, finishes cycle 4
#   8: OP_MUL  (7 * x)     → cycle 5, latency 2, finishes cycle 6
#   9: OP_ADD  (8 + a1)    → cycle 7, latency 1, finishes cycle 7
#  10: OP_MUL  (9 * x)     → cycle 8, latency 2, finishes cycle 9
#  11: OP_ADD  (10 + a0)   → cycle 10, latency 1, finishes cycle 10
#  12: OP_RET  (11)        → cycle 10
#
# Expected latency: 10
# ═══════════════════════════════════════════════════════════════════════════════

println("=== Graph 1: Horner's method ===")

horner_nodes = Dict{Int,DFGNode}(
    1  => DFGNode(1,  OP_ARG,   32, [],       nothing, 0, 0, nothing, Dict()),
    2  => DFGNode(2,  OP_ARG,   32, [],       nothing, 0, 0, nothing, Dict()),
    3  => DFGNode(3,  OP_ARG,   32, [],       nothing, 0, 0, nothing, Dict()),
    4  => DFGNode(4,  OP_ARG,   32, [],       nothing, 0, 0, nothing, Dict()),
    5  => DFGNode(5,  OP_ARG,   32, [],       nothing, 0, 0, nothing, Dict()),
    6  => DFGNode(6,  OP_MUL,   32, [1,2],    nothing, 0, 0, nothing, Dict()),
    7  => DFGNode(7,  OP_ADD,   32, [6,3],    nothing, 0, 0, nothing, Dict()),
    8  => DFGNode(8,  OP_MUL,   32, [7,2],    nothing, 0, 0, nothing, Dict()),
    9  => DFGNode(9,  OP_ADD,   32, [8,4],    nothing, 0, 0, nothing, Dict()),
    10 => DFGNode(10, OP_MUL,   32, [9,2],    nothing, 0, 0, nothing, Dict()),
    11 => DFGNode(11, OP_ADD,   32, [10,5],   nothing, 0, 0, nothing, Dict()),
    12 => DFGNode(12, OP_RET,   32, [11],     nothing, 0, 0, nothing, Dict()),
)

horner = HWGraph("horner_poly", horner_nodes, [1,2,3,4,5], [12])
schedule_asap!(horner)

println("Scheduled cycles:")
for id in sort(collect(keys(horner.nodes)))
    n = horner.nodes[id]
    println("  node $(n.id) ($(n.op)) -> start $(n.scheduled_cycle), finish $(finish_cycle(n))")
end

@assert horner.nodes[6].scheduled_cycle == 2   "MUL1 start"
@assert finish_cycle(horner.nodes[6]) == 3       "MUL1 finish"
@assert horner.nodes[8].scheduled_cycle == 5    "MUL2 start"
@assert finish_cycle(horner.nodes[8]) == 6       "MUL2 finish"
@assert horner.nodes[10].scheduled_cycle == 8   "MUL3 start"
@assert finish_cycle(horner.nodes[10]) == 9      "MUL3 finish"
@assert horner.nodes[11].scheduled_cycle == 10  "ADD3 start"
@assert horner.latency == 10                     "Total latency"
println("Horner: PASS  (latency=$(horner.latency))")

out_sv = joinpath(@__DIR__, "..", "hw", "rtl", "horner_poly.sv")
emit_verilog(horner, out_sv)

# ═══════════════════════════════════════════════════════════════════════════════
# Graph 2: CRC step — (data >> 1) ^ (POLY if LSB was 1 else 0)
#
# This is one step of a bit-serial CRC.  data is shifted right by 1,
# and if the LSB was 1, the result is XORed with a polynomial constant.
#
# Nodes:
#   1: OP_ARG  (data)           → cycle 1
#   2: OP_CONST (POLY)          → cycle 1
#   3: OP_CONST (1)             → cycle 1
#   4: OP_SHR  (data >> 1)      → cycle 2, latency 1
#   5: OP_AND  (data & 1)       → cycle 2, latency 1  (extract LSB)
#   6: OP_MUX  (lsb ? poly : 0) → cycle 3, latency 1  (3 inputs: cond, true, false)
#   7: OP_CONST (0)             → cycle 1
#   8: OP_XOR  (shifted ^ muxed)→ cycle 4, latency 1
#   9: OP_RET  (8)              → cycle 4
#
# Expected latency: 4
# ═══════════════════════════════════════════════════════════════════════════════

println("\n=== Graph 2: CRC step ===")

POLY = 0x04C11DB7  # CRC-32 polynomial (example)

crc_nodes = Dict{Int,DFGNode}(
    1 => DFGNode(1, OP_ARG,   32, [],       nothing, 0, 0, nothing, Dict()),
    2 => DFGNode(2, OP_CONST, 32, [],       POLY,    0, 0, nothing, Dict()),
    3 => DFGNode(3, OP_CONST, 32, [],       1,       0, 0, nothing, Dict()),
    4 => DFGNode(4, OP_SHR,   32, [1,3],    nothing, 0, 0, nothing, Dict()),  # data >> 1
    5 => DFGNode(5, OP_AND,   32, [1,3],    nothing, 0, 0, nothing, Dict()),  # data & 1 (LSB)
    6 => DFGNode(6, OP_MUX,   32, [5,2,7],  nothing, 0, 0, nothing, Dict()),  # lsb ? poly : 0
    7 => DFGNode(7, OP_CONST, 32, [],       0,       0, 0, nothing, Dict()),
    8 => DFGNode(8, OP_XOR,   32, [4,6],    nothing, 0, 0, nothing, Dict()),  # shifted ^ muxed
    9 => DFGNode(9, OP_RET,   32, [8],      nothing, 0, 0, nothing, Dict()),
)

crc = HWGraph("crc_step", crc_nodes, [1], [9])
schedule_asap!(crc)

println("Scheduled cycles:")
for id in sort(collect(keys(crc.nodes)))
    n = crc.nodes[id]
    println("  node $(n.id) ($(n.op)) -> start $(n.scheduled_cycle), finish $(finish_cycle(n))")
end

@assert crc.nodes[4].scheduled_cycle == 2  "SHR start"
@assert crc.nodes[5].scheduled_cycle == 2  "AND start"
@assert crc.nodes[6].scheduled_cycle == 3  "MUX start (waits for AND)"
@assert crc.nodes[8].scheduled_cycle == 4  "XOR start"
@assert crc.latency == 4                    "Total latency"
println("CRC step: PASS  (latency=$(crc.latency))")

out_sv = joinpath(@__DIR__, "..", "hw", "rtl", "crc_step.sv")
emit_verilog(crc, out_sv)

println("\n=== All Tier 1 graphs: PASS ===")
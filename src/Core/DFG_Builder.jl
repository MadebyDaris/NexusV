module DFG_Builder

export Opcode, OP_ARG, OP_CONST, OP_ADD, OP_SUB, OP_MUL, OP_RET
export OP_SHR, OP_SHL, OP_AND, OP_OR, OP_XOR, OP_MOD
export DFGNode, HWGraph, OP_LATENCY

@enum Opcode begin
    OP_ARG    # Input argument (maps to rs1, rs2, ...)
    OP_CONST  # Literal constant embedded in the graph
    OP_ADD
    OP_SUB
    OP_MUL
    OP_SHR    # Logical shift right
    OP_SHL    # Logical shift left
    OP_AND    # Bitwise AND
    OP_OR     # Bitwise OR
    OP_XOR    # Bitwise XOR
    OP_MOD    # Modulo (remainder)
    OP_RET    # Return / output node
end

# Default cycle latency per opcode.
# OP_ARG / OP_CONST / OP_RET have 0 latency — they don't consume compute cycles.
# Multiply and divide-like ops default to multi-cycle.
const OP_LATENCY = Dict{Opcode,Int}(
    OP_ARG   => 0,
    OP_CONST => 0,
    OP_RET   => 0,
    OP_ADD   => 1,
    OP_SUB   => 1,
    OP_MUL   => 2,
    OP_SHR   => 1,
    OP_SHL   => 1,
    OP_AND   => 1,
    OP_OR    => 1,
    OP_XOR   => 1,
    OP_MOD   => 3,
)

# A single node in the Data Flow Graph.
# - id:              unique integer identifier
# - op:              operation this node performs
# - bit_width:       data width in bits (32 by default)
# - inputs:          IDs of nodes that produce this node's operands
# - const_val:       only set for OP_CONST nodes
# - scheduled_cycle: filled in by the Scheduler; 0 means unscheduled
# - latency:         number of clock cycles this operation requires
mutable struct DFGNode
    id::Int
    op::Opcode
    bit_width::Int
    inputs::Vector{Int}
    const_val::Union{Nothing,Int}
    scheduled_cycle::Int
    latency::Int
end

# The top-level Data Flow Graph.
# - name:          Verilog module name
# - nodes:         id -> DFGNode mapping
# - graph_inputs:  ordered OP_ARG node IDs (rs1, rs2, ...)
# - graph_outputs: ordered OP_RET node IDs
# - latency:       pipeline depth, filled in by the Scheduler
mutable struct HWGraph
    name::String
    nodes::Dict{Int,DFGNode}
    graph_inputs::Vector{Int}
    graph_outputs::Vector{Int}
    latency::Int
end

# Convenience constructor — latency defaults to 0 (unscheduled)
HWGraph(name, nodes, ins, outs) = HWGraph(name, nodes, ins, outs, 0)

end # module DFG_Builder
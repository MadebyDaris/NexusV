module DFG_Builder

export Opcode, OP_ARG, OP_CONST, OP_ADD, OP_SUB, OP_MUL, OP_RET
export DFGNode, HWGraph

@enum Opcode begin
    OP_ARG    # Input argument (maps to rs1, rs2, ...)
    OP_CONST  # Literal constant embedded in the graph
    OP_ADD
    OP_SUB
    OP_MUL
    OP_RET    # Return / output node
end

# A single node in the Data Flow Graph.
# - id:              unique integer identifier
# - op:              operation this node performs
# - bit_width:       data width in bits (32 by default)
# - inputs:          IDs of nodes that produce this node's operands
# - const_val:       only set for OP_CONST nodes
# - scheduled_cycle: filled in by the Scheduler; 0 means unscheduled
mutable struct DFGNode
    id::Int
    op::Opcode
    bit_width::Int
    inputs::Vector{Int}
    const_val::Union{Nothing,Int}
    scheduled_cycle::Int
    # latency_hint::Int To add amounts of cycles that an opration of a specific node takes
    # scheduled_delay::Int the initial delay of the node.  
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
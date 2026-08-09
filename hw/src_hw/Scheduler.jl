# Scheduler.jl
# Depends on DFG_Builder types being available in the caller's scope.

export schedule_asap!, topological_sort, finish_cycle

# The cycle on which a node's result becomes available for consumers.
# OP_ARG / OP_CONST are available immediately at their scheduled cycle (1).
# OP_RET is just a marker — returns its input's finish cycle.
# Compute nodes:  finish_cycle = scheduled_cycle + latency - 1
finish_cycle(node::DFGNode)::Int =
    node.op == OP_ARG  ? node.scheduled_cycle :
    node.op == OP_CONST ? node.scheduled_cycle :
    node.op == OP_RET   ? node.scheduled_cycle :  # passthrough, see schedule_asap!
    node.scheduled_cycle + node.latency - 1

# Returns node IDs in topological order (sources first) via Kahn's algorithm.
function topological_sort(graph::HWGraph)::Vector{Int}
    in_degree = Dict(id => 0 for id in keys(graph.nodes))
    for node in values(graph.nodes)
        for _ in node.inputs
            in_degree[node.id] += 1
        end
    end

    queue = [id for (id, deg) in in_degree if deg == 0]
    order = Int[]

    while !isempty(queue)
        id = popfirst!(queue)
        push!(order, id)
        for node in values(graph.nodes)
            if id in node.inputs
                in_degree[node.id] -= 1
                if in_degree[node.id] == 0
                    push!(queue, node.id)
                end
            end
        end
    end

    length(order) == length(graph.nodes) || error("Cycle in DFG -- cannot schedule.")
    return order
end

# Multi-cycle-aware ASAP scheduling.
#
# For each node, the earliest start cycle is:
#   max( finish_cycle(dep) ) + 1   across all input dependencies.
#
# OP_ARG / OP_CONST: no data deps, always start at cycle 1 (latency 0).
# OP_RET: just a marker, inherits its input's finish cycle as its own
#         scheduled_cycle (no extra + latency).
# All others:  scheduled_cycle = max(dep_finish) + 1 ,  latency from OP_LATENCY
#              (or overridden per-node).
#
# Graph total latency = max finish_cycle among compute nodes (excl. OP_RET).
function schedule_asap!(graph::HWGraph)
    for id in topological_sort(graph)
        node = graph.nodes[id]

        # Set default latency from the opcode table if not already assigned
        if node.latency == 0 && node.op ∉ (OP_ARG, OP_CONST, OP_RET, OP_PRIMITIVE)
            node.latency = OP_LATENCY[node.op]
        end

        if node.op == OP_PRIMITIVE
            node.latency = PRIMITIVES[node.primitive].latency
        elseif node.latency == 0 && node.op ∉ (OP_ARG, OP_CONST, OP_RET)
            node.latency = OP_LATENCY[node.op]
        end

        if isempty(node.inputs) || node.op == OP_ARG || node.op == OP_CONST
            node.scheduled_cycle = 1
        elseif node.op == OP_RET
            dep = graph.nodes[node.inputs[1]]
            node.scheduled_cycle = finish_cycle(dep)
        else
            max_dep_finish = maximum(finish_cycle(graph.nodes[dep]) for dep in node.inputs)
            node.scheduled_cycle = max_dep_finish + 1
        end
    end

    # Graph latency = max finish_cycle among real compute nodes
    compute_nodes = [n for n in values(graph.nodes)
                     if n.op ∉ (OP_ARG, OP_CONST, OP_RET)]
    graph.latency = isempty(compute_nodes) ? 1 : maximum(finish_cycle(n) for n in compute_nodes)

    return graph
end
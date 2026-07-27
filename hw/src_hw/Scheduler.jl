# Scheduler.jl
# Depends on DFG_Builder types being available in the caller's scope.

export schedule_asap!, topological_sort

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

# ASAP scheduling: assign every node the earliest possible cycle.
# OP_ARG / OP_CONST: no data deps -> cycle 1.
# OP_RET: just a marker, inherits its input's cycle (no extra +1).
# All other nodes: wait for slowest input, then +1.
function schedule_asap!(graph::HWGraph)
    for id in topological_sort(graph)
        node = graph.nodes[id]
        if isempty(node.inputs) || node.op == OP_ARG || node.op == OP_CONST
            node.scheduled_cycle = 1
        elseif node.op == OP_RET
            node.scheduled_cycle = graph.nodes[node.inputs[1]].scheduled_cycle
        else
            max_dep = maximum(graph.nodes[dep].scheduled_cycle for dep in node.inputs)
            node.scheduled_cycle = max_dep + 1
        end
    end
    # Latency = deepest real compute node (exclude OP_ARG/OP_CONST/OP_RET)
    compute_cycles = [n.scheduled_cycle for n in values(graph.nodes)
                      if n.op ∉ (OP_ARG, OP_CONST, OP_RET)]
    graph.latency = isempty(compute_cycles) ? 1 : maximum(compute_cycles)
    return graph
end
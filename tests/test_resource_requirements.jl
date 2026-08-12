using Test

include("../src/Core/DFG_Builder.jl")
using .DFG_Builder

include("../src/Core/NexusV_Library.jl")
include("../hw/src_hw/Scheduler.jl")

@testset "Resource Requirements" begin
    nodes = Dict{Int,DFGNode}(
        1 => DFGNode(1, OP_ARG, 32, [], nothing, 0, 0, nothing, Dict()),
        2 => DFGNode(2, OP_ARG, 32, [], nothing, 0, 0, nothing, Dict()),
        3 => DFGNode(3, OP_ARG, 32, [], nothing, 0, 0, nothing, Dict()),
        4 => DFGNode(4, OP_MUL, 32, [1,2], nothing, 0, 0, nothing, Dict()),
        5 => DFGNode(5, OP_MUL, 32, [2,3], nothing, 0, 0, nothing, Dict()),
        6 => DFGNode(6, OP_ADD, 32, [4,5], nothing, 0, 0, nothing, Dict()),
        7 => DFGNode(7, OP_RET, 32, [6], nothing, 0, 0, nothing, Dict()),
    )

    graph = HWGraph("resource_budget_test", nodes, [1,2,3], [7])
    schedule_asap!(graph)

    budget = resource_requirements(graph)
    @test budget[OP_MUL] == 2
    @test budget[OP_ADD] == 1

    primitive_nodes = Dict{Int,DFGNode}(
        1 => DFGNode(1, OP_ARG, 32, [], nothing, 0, 0, nothing, Dict()),
        2 => DFGNode(2, OP_ARG, 32, [], nothing, 0, 0, nothing, Dict()),
        3 => DFGNode(3, OP_PRIMITIVE, 32, [1,2], nothing, 0, 0, :simd_mac, Dict()),
        4 => DFGNode(4, OP_PRIMITIVE, 32, [1,2], nothing, 0, 0, :simd_mac, Dict()),
        5 => DFGNode(5, OP_ADD, 32, [3,4], nothing, 0, 0, nothing, Dict()),
        6 => DFGNode(6, OP_RET, 32, [5], nothing, 0, 0, nothing, Dict()),
    )

    primitive_graph = HWGraph("primitive_budget_test", primitive_nodes, [1,2], [6])
    schedule_asap!(primitive_graph)

    primitive_budget = resource_requirements(primitive_graph)
    @test primitive_budget[:simd_mac] == 2
    @test primitive_budget[OP_ADD] == 1
end
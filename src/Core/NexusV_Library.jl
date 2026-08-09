module PrimitiveLibrary

export PrimitiveSpec, PRIMITIVES, register_primitive!

# Metadata for one hardware primitive in the registry.
#
# - name:        Symbol key, e.g. :simd_mac
# - module_name: Verilog top-level module, e.g. "nexus_simd_mac"
# - file_path:   relative to hw/rtl/, e.g. "primitives/nexus_simd_mac.sv"
# - latency:     pipeline depth in cycles
# - params:      default parameter overrides, e.g. Dict(:LANES => 4, :DATA_WIDTH => 8)
struct PrimitiveSpec
    name::Symbol
    module_name::String
    file_path::String
    latency::Int
    params::Dict{Symbol,Any}
end

const PRIMITIVES = Dict{Symbol,PrimitiveSpec}()

function register_primitive!(spec::PrimitiveSpec)
    PRIMITIVES[spec.name] = spec
    println("[PrimitiveLibrary] Registered :$(spec.name) → $(spec.module_name) (latency=$(spec.latency))")
end

# Built-in primitives

register_primitive!(PrimitiveSpec(
    :simd_mac,
    "nexus_simd_mac",
    "primitives/nexus_simd_mac.sv",
    3,
    Dict(:LANES => 4, :DATA_WIDTH => 8)
))

register_primitive!(PrimitiveSpec(
    :barrett_reduction,
    "nexus_barrett_reduction",
    "primitives/nexus_barrett_reduction.sv",
    3,
    Dict(:LANES => 4, :DATA_WIDTH => 8)
))

register_primitive!(PrimitiveSpec(
    :montgomery_multiplier,
    "nexus_montgomery_multiplier",
    "primitives/nexus_montgomery_multiplier.sv",
    3,
    Dict(:LANES => 4, :DATA_WIDTH => 8, :R => 1024, :N => 997, :N_INV_MOD_N => 493)
))

register_primitive!(PrimitiveSpec(
    :saturating_add,
    "nexus_saturating_add",
    "primitives/nexus_saturating_add.sv",
    2,
    Dict(:LANES => 4, :DATA_WIDTH => 8)
))

end # module PrimitiveLibrary
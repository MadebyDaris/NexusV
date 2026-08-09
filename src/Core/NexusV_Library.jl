module PrimitiveLibrary

struct Primitive
    name::String
    module_name::String
    parameters::Dict{Symbol,Any} # "primitives/nexus_simd_mac.sv", relative to hw/rtl/
    file::String 
    latency::Int
end

const PRIMITIVES = Dict{Symbol,PrimitiveSpec}()
register_primitive!(spec::PrimitiveSpec) = (PRIMITIVES[spec.name] = spec)

register_primitive!(PrimitiveSpec(
    :simd_mac, "nexus_simd_mac", "primitives/nexus_simd_mac.sv",
    1, Dict(:LANES => 4, :DATA_WIDTH => 8)
))

end # module PrimitiveLibrary
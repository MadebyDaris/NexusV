# scripts/build_manifest.jl
# Build manifest → generate nexus_mux.sv.
# Run: julia --project=. scripts/build_manifest.jl

using NexusV

manifest = DatapathEntry[
    DatapathEntry("mac_plus_5",              0, 4, false, "mac_plus_5.sv"),
    DatapathEntry("crc_step",                1, 4, false, "crc_step.sv"),
    DatapathEntry("nexus_simd_mac",          2, 3, false, "primitives/nexus_simd_mac.sv"),
    DatapathEntry("nexus_saturating_add",    3, 2, false, "primitives/nexus_saturating_add.sv"),
    DatapathEntry("nexus_barrett_reduction", 4, 3, false, "primitives/nexus_barrett_reduction.sv"),
    DatapathEntry("nexus_mont_adapter",      5, 3, true,  "primitives/nexus_mont_adapter.sv"),
]

out_sv = joinpath(@__DIR__, "..", "hw", "rtl", "nexus_mux.sv")
emit_dispatcher(manifest, out_sv)
println("Done — $(length(manifest)) datapaths in mux")
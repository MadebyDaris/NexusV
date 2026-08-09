// Barrett Reduction Primitive for NexusV
// This module implements Barrett reduction for modular arithmetic.
module nexus_barrett_reduction #(
    parameter int WORD_WIDTH = 32,
    parameter int MODULUS = 12289, // Example modulus
    parameter int K = 14 // Precomputed value for Barrett reduction
) (
    input  logic  clk_i,
    input  logic  rst_ni,
    input  logic  start_i,
    input  logic [WORD_WIDTH-1:0] x_i,
    output logic [WORD_WIDTH-1:0] r_o
);
    // Barrett reduction implementation
    logic [WORD_WIDTH-1:0] q;
    logic [WORD_WIDTH-1:0] r;

    always_comb begin
        q = (x_i * K) >> WORD_WIDTH; // Compute q = floor(x / m)
        r = x_i - q * MODULUS;       // Compute r = x - q * m
        if (r >= MODULUS) begin
            r_o = r - MODULUS;       // Ensure r is in the range [0, m)
        end else begin
            r_o = r;
        end
    end
endmodule
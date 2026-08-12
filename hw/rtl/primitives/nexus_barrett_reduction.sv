// Barrett Reduction Primitive for NexusV
//
// Computes:  r = x mod MODULUS  using Barrett's method.
//
// Standard Nexus datapath interface: clk_i, rst_ni, stall_i, start_i,
// rs1_i (x), rs2_i (unused), rd_o (r), done_o
//
// Pipeline: 3 stages
//   Stage 1: compute q_approx = (x * K) >> WORD_WIDTH
//   Stage 2: compute r = x - q_approx * MODULUS
//   Stage 3: final correction (subtract MODULUS if r >= MODULUS)

module nexus_barrett_reduction #(
    parameter int WORD_WIDTH = 32,
    parameter int MODULUS    = 12289,
    parameter int K          = 14  // precomputed: floor(2^WORD_WIDTH / MODULUS)
) (
    input  logic                     clk_i,
    input  logic                     rst_ni,
    input  logic                     stall_i,
    input  logic                     start_i,
    input  logic [WORD_WIDTH-1:0]    rs1_i,   // x — value to reduce
    input  logic [WORD_WIDTH-1:0]    rs2_i,   // unused
    output logic [WORD_WIDTH-1:0]    rd_o,
    output logic                     done_o
);

    // ── Pipeline registers ───────────────────────────────────────────────────
    logic [WORD_WIDTH-1:0] x_r1, x_r2;
    logic [2*WORD_WIDTH-1:0] prod_r;
    logic [WORD_WIDTH-1:0] q_approx_r;
    logic [WORD_WIDTH-1:0] r_r;

    // ── Stage 1: compute q_approx = (x * K) >> WORD_WIDTH ────────────────────
    logic [2*WORD_WIDTH-1:0] prod;
    logic [WORD_WIDTH-1:0]   q_approx;

    assign prod     = rs1_i * K;
    assign q_approx = prod[2*WORD_WIDTH-1:WORD_WIDTH];  // upper half = floor(x*K / 2^W)

    // ── Stage 2: compute r = x - q * MODULUS ─────────────────────────────────
    logic [WORD_WIDTH-1:0] r_stage2;
    assign r_stage2 = x_r1 - q_approx_r * MODULUS;

    // ── Stage 3: final correction ────────────────────────────────────────────
    logic [WORD_WIDTH-1:0] r_final;
    assign r_final = (r_r >= MODULUS) ? (r_r - MODULUS) : r_r;

    // ── Sequential logic ─────────────────────────────────────────────────────
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            x_r1        <= '0;
            x_r2        <= '0;
            prod_r      <= '0;
            q_approx_r  <= '0;
            r_r         <= '0;
            rd_o        <= '0;
            done_o      <= 1'b0;
        end else if (!stall_i) begin
            done_o <= 1'b0;

            // Stage 1 → Stage 2
            x_r1       <= rs1_i;
            q_approx_r <= q_approx;

            // Stage 2 → Stage 3
            x_r2 <= x_r1;
            r_r  <= r_stage2;

            // Stage 3 → output
            if (start_i) begin
                rd_o   <= r_final;
                done_o <= 1'b1;
            end
        end
    end

endmodule
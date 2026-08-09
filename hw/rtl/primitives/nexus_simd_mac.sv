// nexus_simd_mac — SIMD multiply-accumulate primitive
//
// Computes:  acc += Σ(a_lane[i] * b_lane[i])  across LANES
//
// Parameters:
//   LANES      — number of SIMD lanes (default 4)
//   DATA_WIDTH — bit width per lane element (default 8)
//
// Pipeline: 3 stages
//   Stage 1: per-lane multiply
//   Stage 2: reduction sum
//   Stage 3: accumulate + output
//
// Interface: canonical Nexus datapath (clk_i, rst_ni, start_i, rs1_i, rs2_i, rd_o, done_o)

module nexus_simd_mac #(
    parameter int LANES      = 4,
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH  = 32
) (
    input  logic                     clk_i,
    input  logic                     rst_ni,
    input  logic                     start_i,
    input  logic [LANES*DATA_WIDTH-1:0] rs1_i,
    input  logic [LANES*DATA_WIDTH-1:0] rs2_i,
    output logic [31:0]                 rd_o,
    output logic                     done_o
);

    localparam int PROD_WIDTH = DATA_WIDTH * 2;

    // ── Stage 1: per-lane signed multiply ─────────────────────────────────
    logic signed [PROD_WIDTH-1:0] prod [LANES-1:0];
    logic signed [PROD_WIDTH-1:0] prod_r [LANES-1:0];

    genvar i;
    generate
        for (i = 0; i < LANES; i++) begin : g_mul
            assign prod[i] = $signed(rs1_i[i*DATA_WIDTH +: DATA_WIDTH]) *
                             $signed(rs2_i[i*DATA_WIDTH +: DATA_WIDTH]);
        end
    endgenerate

    // ── Stage 2: reduction sum ────────────────────────────────────────────
    logic signed [ACC_WIDTH-1:0] sum_comb;
    logic signed [ACC_WIDTH-1:0] sum_r;

    /* verilator lint_off WIDTHEXPAND */
    always_comb begin
        sum_comb = '0;
        for (int j = 0; j < LANES; j++) begin
            sum_comb += $signed(prod_r[j]);
        end
    end
    /* verilator lint_on WIDTHEXPAND */

    // ── Stage 3: accumulate ───────────────────────────────────────────────
    logic signed [ACC_WIDTH-1:0] acc_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            acc_q  <= '0;
            rd_o   <= '0;
            done_o <= 1'b0;
        end else begin
            done_o <= 1'b0;
            if (start_i) begin
                acc_q  <= acc_q + sum_r;
                rd_o   <= acc_q + sum_r;
                done_o <= 1'b1;
            end
        end
    end

    // ── Pipeline registers ────────────────────────────────────────────────
    always_ff @(posedge clk_i) begin
        for (int k = 0; k < LANES; k++) begin
            prod_r[k] <= prod[k];
        end
        sum_r <= sum_comb;
    end

endmodule
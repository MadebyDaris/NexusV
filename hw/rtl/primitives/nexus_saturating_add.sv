// nexus_saturating_add — 4-lane saturating SIMD add primitive
//
// Computes per-lane:  rd[lane] = clamp(rs1[lane] + rs2[lane], MIN, MAX)
//
// Parameters:
//   LANES      — number of SIMD lanes (default 4)
//   DATA_WIDTH — bit width per lane element (default 8)
//
// Pipeline: 2 stages
//   Stage 1: per-lane add + overflow detect
//   Stage 2: mux saturated result + output
//
// Interface: canonical Nexus datapath

module nexus_saturating_add #(
    parameter int LANES      = 4,
    parameter int DATA_WIDTH = 8
) (
    input  logic                     clk_i,
    input  logic                     rst_ni,
    input  logic                     start_i,
    input  logic [LANES*DATA_WIDTH-1:0] rs1_i,
    input  logic [LANES*DATA_WIDTH-1:0] rs2_i,
    output logic [LANES*DATA_WIDTH-1:0] rd_o,
    output logic                     done_o
);

    localparam logic signed [DATA_WIDTH-1:0] MAX_VAL = (1 << (DATA_WIDTH-1)) - 1;
    localparam logic signed [DATA_WIDTH-1:0] MIN_VAL = -(1 << (DATA_WIDTH-1));

    // ── Stage 1: per-lane add + overflow detect ───────────────────────────
    logic signed [DATA_WIDTH:0] sum_ext [LANES-1:0];  // extra bit for overflow
    logic                 overflow [LANES-1:0];
    logic                 underflow [LANES-1:0];

    logic signed [DATA_WIDTH:0] sum_ext_r [LANES-1:0];
    logic                 overflow_r [LANES-1:0];
    logic                 underflow_r [LANES-1:0];

    genvar i;
    generate
        for (i = 0; i < LANES; i++) begin : g_lane
            logic signed [DATA_WIDTH-1:0] a, b;
            assign a = $signed(rs1_i[i*DATA_WIDTH +: DATA_WIDTH]);
            assign b = $signed(rs2_i[i*DATA_WIDTH +: DATA_WIDTH]);

            assign sum_ext[i]  = a + b;
            assign overflow[i]  = (a > 0) && (b > 0) && (sum_ext[i][DATA_WIDTH-1:0] < 0);
            assign underflow[i] = (a < 0) && (b < 0) && (sum_ext[i][DATA_WIDTH-1:0] > 0);
        end
    endgenerate

    // ── Stage 2: saturate + output ────────────────────────────────────────
    logic [LANES*DATA_WIDTH-1:0] rd_comb;

    always_comb begin
        for (int j = 0; j < LANES; j++) begin
            if (overflow_r[j])
                rd_comb[j*DATA_WIDTH +: DATA_WIDTH] = MAX_VAL;
            else if (underflow_r[j])
                rd_comb[j*DATA_WIDTH +: DATA_WIDTH] = MIN_VAL;
            else
                rd_comb[j*DATA_WIDTH +: DATA_WIDTH] = sum_ext_r[j][DATA_WIDTH-1:0];
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            rd_o   <= '0;
            done_o <= 1'b0;
        end else begin
            done_o <= 1'b0;
            if (start_i) begin
                rd_o   <= rd_comb;
                done_o <= 1'b1;
            end
        end
    end

    // ── Pipeline registers ────────────────────────────────────────────────
    always_ff @(posedge clk_i) begin
        for (int k = 0; k < LANES; k++) begin
            sum_ext_r[k]  <= sum_ext[k];
            overflow_r[k]  <= overflow[k];
            underflow_r[k] <= underflow[k];
        end
    end

endmodule
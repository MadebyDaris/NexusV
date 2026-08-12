// nexus_mont_adapter — wraps nexus_montgomery_multiplier into the canonical
// Nexus datapath interface so it can sit behind nexus_mux.
//
// The native Montgomery module uses multi-port memory interfaces (addr_A, data_A,
// addr_B, data_B, etc.) for multi-word operands. This adapter provides local
// 4-word register files for A, B, N, and T, and maps rs1_i/rs2_i into the
// first word of A/B.
//
// Interface: clk_i, rst_ni, stall_i, start_i, rs1_i, rs2_i, rd_o, done_o

module nexus_mont_adapter #(
    parameter int WORD_WIDTH = 32,
    parameter int NUM_WORDS  = 4,
    parameter int R          = 1024,
    parameter int N          = 997,
    parameter int N_INV_MOD_N = 493
) (
    input  logic                     clk_i,
    input  logic                     rst_ni,
    input  logic                     stall_i,
    input  logic                     start_i,
    input  logic [WORD_WIDTH-1:0]    rs1_i,
    input  logic [WORD_WIDTH-1:0]    rs2_i,
    output logic [WORD_WIDTH-1:0]    rd_o,
    output logic                     done_o
);

    // ── Local register files ─────────────────────────────────────────────────
    logic [WORD_WIDTH-1:0] mem_A [NUM_WORDS-1:0];
    logic [WORD_WIDTH-1:0] mem_B [NUM_WORDS-1:0];
    logic [WORD_WIDTH-1:0] mem_N [NUM_WORDS-1:0];
    logic [WORD_WIDTH-1:0] mem_T [NUM_WORDS:0];  // extra word for carries

    // ── Montgomery interface wires ───────────────────────────────────────────
    logic [$clog2(NUM_WORDS)-1:0]    mont_addr_A;
    logic [WORD_WIDTH-1:0]           mont_data_A;
    logic [$clog2(NUM_WORDS)-1:0]    mont_addr_B;
    logic [WORD_WIDTH-1:0]           mont_data_B;
    logic [$clog2(NUM_WORDS)-1:0]    mont_addr_N;
    logic [WORD_WIDTH-1:0]           mont_data_N;
    logic [$clog2(NUM_WORDS+1)-1:0]  mont_addr_T;
    logic [WORD_WIDTH-1:0]           mont_read_T;
    logic [WORD_WIDTH-1:0]           mont_write_T;
    logic                            mont_we_T;
    logic                            mont_start;
    logic                            mont_done;

    // ── Load operands on start + Montgomery write port ──────────────────────
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int i = 0; i < NUM_WORDS; i++) begin
                mem_A[i] <= '0;
                mem_B[i] <= '0;
                mem_N[i] <= '0;
            end
            for (int i = 0; i <= NUM_WORDS; i++) begin
                mem_T[i] <= '0;
            end
        end else if (!stall_i) begin
            if (start_i) begin
                mem_A[0] <= rs1_i;
                mem_B[0] <= rs2_i;
                for (int i = 1; i < NUM_WORDS; i++) begin
                    mem_A[i] <= '0;
                    mem_B[i] <= '0;
                end
                mem_N[0] <= WORD_WIDTH'(N);
                for (int i = 1; i < NUM_WORDS; i++) begin
                    mem_N[i] <= '0;
                end
            end
            if (mont_we_T) begin
                mem_T[mont_addr_T] <= mont_write_T;
            end
        end
    end

    // ── Connect Montgomery memory ports to local arrays ──────────────────────
    assign mont_data_A = mem_A[mont_addr_A];
    assign mont_data_B = mem_B[mont_addr_B];
    assign mont_data_N = mem_N[mont_addr_N];
    assign mont_read_T = mem_T[mont_addr_T];

    // ── Instantiate Montgomery multiplier ────────────────────────────────────
    nexus_montgomery_multiplier #(
        .WORD_WIDTH   (WORD_WIDTH),
        .NUM_WORDS    (NUM_WORDS),
        .R            (R),
        .N            (N),
        .N_INV_MOD_N  (N_INV_MOD_N)
    ) u_mont (
        .clk      (clk_i),
        .rst_n    (rst_ni),
        .stall_i  (stall_i),
        .start    (mont_start),
        .done_0   (mont_done),
        .addr_A   (mont_addr_A),
        .data_A   (mont_data_A),
        .addr_B   (mont_addr_B),
        .data_B   (mont_data_B),
        .addr_N   (mont_addr_N),
        .data_N   (mont_data_N),
        .addr_T   (mont_addr_T),
        .read_T   (mont_read_T),
        .write_T  (mont_write_T),
        .we_T     (mont_we_T)
    );

    // ── Start / done handshake ───────────────────────────────────────────────
    logic running_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            running_q <= 1'b0;
            mont_start <= 1'b0;
            done_o     <= 1'b0;
            rd_o       <= '0;
        end else if (!stall_i) begin
            done_o     <= 1'b0;
            mont_start <= 1'b0;

            if (start_i && !running_q) begin
                mont_start <= 1'b1;
                running_q  <= 1'b1;
            end

            if (mont_done && running_q) begin
                running_q <= 1'b0;
                rd_o      <= mem_T[0];  // result in T[0]
                done_o    <= 1'b1;
            end
        end
    end

endmodule
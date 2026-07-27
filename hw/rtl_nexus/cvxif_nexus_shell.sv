// cvxif_nexus_shell.sv
//
// CV-X-IF compliant accelerator shell for NexusV.
// Accepts CUSTOM_0 (opcode 0x0B) instructions, hands them to a generated
// datapath, waits for completion, and returns the result to the CPU.
//
// FSM states:
//   IDLE         - ready to accept a new instruction from the CPU
//   WAIT_COMMIT  - instruction issued, waiting for CPU commit/kill
//   WAIT_DATAPATH- committed, datapath is running
//   SEND_RESULT  - datapath done, returning result to CPU

module cvxif_nexus_shell (
    input  logic clk_i,
    input  logic rst_ni,

    // CV-X-IF Issue Channel
    input  logic        x_issue_req_valid_i,
    output logic        x_issue_req_ready_o,
    input  logic [31:0] x_issue_req_instr_i,   // Raw 32-bit RISC-V instruction
    input  logic [31:0] x_issue_req_rs1_i,
    input  logic [31:0] x_issue_req_rs2_i,
    input  logic [4:0]  x_issue_req_id_i,      // CPU-assigned instruction tag

    output logic        x_issue_resp_valid_o,
    output logic        x_issue_resp_accept_o,
    output logic [4:0]  x_issue_resp_id_o,

    // CV-X-IF Commit Channel
    input  logic        x_commit_valid_i,
    input  logic [4:0]  x_commit_id_i,
    input  logic        x_commit_kill_i,

    // CV-X-IF Result Channel
    output logic        x_result_valid_o,
    input  logic        x_result_ready_i,
    output logic [4:0]  x_result_id_o,
    output logic [31:0] x_result_data_o,
    output logic [4:0]  x_result_rd_o
);

// --------------------------------------------------------------------------
// FSM state encoding
// --------------------------------------------------------------------------
typedef enum logic [1:0] {
    IDLE,
    WAIT_COMMIT,
    WAIT_DATAPATH,
    SEND_RESULT
} state_t;

state_t state_q, state_n;

// --------------------------------------------------------------------------
// Saved instruction context (registered on issue handshake)
// --------------------------------------------------------------------------
logic [31:0] saved_rs1_q, saved_rs2_q;
logic [4:0]  saved_id_q;
logic [4:0]  saved_rd_addr_q;

// --------------------------------------------------------------------------
// Datapath interface (connect to the auto-generated module here)
//
// To plug in a generated module:
//   1. Instantiate it below with the signals dp_start, dp_rs1, dp_rs2, dp_rd, dp_done.
//   2. Remove the stub assignments.
// --------------------------------------------------------------------------
logic        dp_start;
logic [31:0] dp_rs1, dp_rs2;
logic [31:0] dp_rd;
logic        dp_done;

// -- Stub: direct addition so the shell is self-contained without a datapath --
// -- Replace this block with your generated module instantiation.             --
logic done_r;
assign dp_rs1 = saved_rs1_q;
assign dp_rs2 = saved_rs2_q;
assign dp_rd  = saved_rs1_q + saved_rs2_q;   // stub: rs1 + rs2
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) done_r <= 1'b0;
    else         done_r <= dp_start;
end
assign dp_done = done_r;
// -- End stub --

// Example instantiation (uncomment and fill in the generated module name):
//
// mac_plus_5 u_datapath (
//     .clk_i   (clk_i),
//     .rst_ni  (rst_ni),
//     .start_i (dp_start),
//     .rs1_i   (dp_rs1),
//     .rs2_i   (dp_rs2),
//     .rd_o    (dp_rd),
//     .done_o  (dp_done)
// );

// --------------------------------------------------------------------------
// Combinational FSM
// --------------------------------------------------------------------------
always_comb begin
    state_n              = state_q;
    x_issue_req_ready_o  = 1'b0;
    x_issue_resp_valid_o = 1'b0;
    x_issue_resp_accept_o= 1'b0;
    x_issue_resp_id_o    = x_issue_req_id_i;
    x_result_valid_o     = 1'b0;
    x_result_id_o        = 5'b0;
    x_result_rd_o        = 5'b0;
    x_result_data_o      = 32'b0;
    dp_start             = 1'b0;

    case (state_q)

        IDLE: begin
            x_issue_req_ready_o = 1'b1;
            if (x_issue_req_valid_i) begin
                x_issue_resp_valid_o = 1'b1;
                // Accept only CUSTOM_0 instructions (opcode == 0x0B)
                if (x_issue_req_instr_i[6:0] == 7'h0B) begin
                    x_issue_resp_accept_o = 1'b1;
                    state_n = WAIT_COMMIT;
                end else begin
                    x_issue_resp_accept_o = 1'b0;
                end
            end
        end

        WAIT_COMMIT: begin
            if (x_commit_valid_i && (x_commit_id_i == saved_id_q)) begin
                if (x_commit_kill_i)
                    state_n = IDLE;         // Branch mispredict — flush
                else begin
                    dp_start = 1'b1;        // Kick off the datapath
                    state_n  = WAIT_DATAPATH;
                end
            end
        end

        WAIT_DATAPATH: begin
            if (dp_done)
                state_n = SEND_RESULT;
        end

        SEND_RESULT: begin
            x_result_valid_o = 1'b1;
            x_result_id_o    = saved_id_q;
            x_result_rd_o    = saved_rd_addr_q;
            x_result_data_o  = dp_rd;
            if (x_result_ready_i)
                state_n = IDLE;
        end

    endcase
end

// --------------------------------------------------------------------------
// Sequential state and capture registers
// --------------------------------------------------------------------------
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        state_q         <= IDLE;
        saved_rs1_q     <= 32'b0;
        saved_rs2_q     <= 32'b0;
        saved_id_q      <= 5'b0;
        saved_rd_addr_q <= 5'b0;
    end else begin
        state_q <= state_n;

        // Capture operands on the issue handshake
        if (x_issue_req_valid_i && x_issue_req_ready_o) begin
            saved_rs1_q     <= x_issue_req_rs1_i;
            saved_rs2_q     <= x_issue_req_rs2_i;
            saved_id_q      <= x_issue_req_id_i;
            saved_rd_addr_q <= x_issue_req_instr_i[11:7]; // rd field of R-type
        end
    end
end

endmodule
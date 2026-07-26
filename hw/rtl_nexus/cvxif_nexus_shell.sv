// module cvxif_nexus_shell (
//     input  logic         clk_i,
//     input  logic         rst_ni,
//     input  logic         cvxif_nexus_req_valid_i,
//     output logic         cvxif_nexus_req_ready_o,
//     input  logic [31:0]  cvxif_nexus_req_instr_i, . // 32 bit instruction
//     input  logic [31:0]  cvxif_nexus_req_data,
//     input  logic [3:0]   cvxif_nexus_req_strb,
//     input  logic         cvxif_nexus_req_write,
//     output logic         cvxif_nexus_resp_valid,
//     input  logic         cvxif_nexus_resp_ready,
//     output logic [31:0]  cvxif_nexus_resp_data
//     );

module cvxif_nexus_shell (
    input  logic clk_i,
    input  logic rst_ni,

    // 1. Issue Channel 
    input  logic        x_issue_req_valid_i,
    output logic        x_issue_req_ready_o,
    input  logic [31:0] x_issue_req_instr_i,   // The raw 32-bit instruction
    input  logic [31:0] x_issue_req_rs1_i,
    input  logic [31:0] x_issue_req_rs2_i,
    input  logic [4:0]  x_issue_req_id_i,      // CPU tracks instructions via this ID
    
    output logic        x_issue_resp_valid_o,
    output logic        x_issue_resp_accept_o, // Transfer of instruction to CVXIF is accepted
    output logic [4:0]  x_issue_resp_id_o,      // Echo back
    
    // 2. Commit Channel
    input  logic        x_commit_valid_i,
    input  logic [4:0]  x_commit_id_i,
    input  logic        x_commit_kill_i,

    // 3. Result Channel
    output logic        x_result_valid_o,
    input  logic        x_result_ready_i,
    output logic [4:0]  x_result_id_o,
    output logic [31:0] x_result_data_o,
    output logic [4:0]  x_result_rd_o          // Destination register address
);

// State machine for the nexus shell
typedef enum logic [1:0] { IDLE, WAIT_COMMIT, SEND_RESULT } state_t;
state_t state_q, state_n;

logic [31:0] saved_rs1_q, saved_rs2_q;

logic [4:0]  saved_id_q;
logic [4:0]  saved_rd_addr_q;

// ALU result of the addition operation, which will be sent back to the CPU as the result of the instruction
logic [31:0] alu_result;
assign alu_result = saved_rs1_q + saved_rs2_q;

always_comb begin 
    state_n = state_q;
    x_issue_req_ready_o  = 1'b0;
    x_issue_resp_valid_o = 1'b0;
    x_issue_resp_accept_o= 1'b0;
    x_issue_resp_id_o    = x_issue_req_id_i;
    x_result_valid_o     = 1'b0;
    x_result_id_o        = 5'b0;
    x_result_rd_o        = 5'b0;
    x_result_data_o      = 32'b0;

    case (state_q)
        IDLE: begin
            x_issue_req_ready_o = 1'b1; // ready to accept new instruction
            if (x_issue_req_valid_i) begin
                // Check if opcode matches CUSTOM_0 (0x0B)
                if (x_issue_req_instr_i[6:0] == 7'h0B) begin 
                    x_issue_resp_valid_o  = 1'b1;
                    x_issue_resp_accept_o = 1'b1; // Yes, this is my instruction!
                    state_n = WAIT_COMMIT;
                end else begin
                    x_issue_resp_valid_o  = 1'b1; // acknowledge receipt of instruction
                    x_issue_resp_accept_o = 1'b0;
                end
            end
        end

        WAIT_COMMIT: begin
            if (x_commit_valid_i && (x_commit_id_i == saved_id_q)) begin
                if (x_commit_kill_i) 
                    state_n = IDLE;         // Branch mispredict, flush it
                else 
                    state_n = SEND_RESULT;  // Valid instruction, proceed!
            end
        end

        SEND_RESULT: begin
            x_result_valid_o = 1'b1;
            x_result_id_o    = saved_id_q;
            x_result_rd_o    = saved_rd_addr_q;
            x_result_data_o  = alu_result;
                
            if (x_result_ready_i) begin // CPU accepted the result
                state_n = IDLE;
            end
        end
    endcase
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        state_q <= IDLE;
        saved_rs1_q <= 32'b0;
        saved_rs2_q <= 32'b0;
        saved_id_q <= 5'b0;
        saved_rd_addr_q <= 5'b0;
    end else begin
        state_q <= state_n;

        if (x_issue_req_valid_i && x_issue_req_ready_o) begin
            saved_rs1_q <= x_issue_req_rs1_i;
            saved_rs2_q <= x_issue_req_rs2_i;
            saved_id_q <= x_issue_req_id_i;
            // Assuming the destination register address is encoded in the instruction (e.g., bits [11:7])
            saved_rd_addr_q <= x_issue_req_instr_i[11:7];
        end
    end
end

endmodule
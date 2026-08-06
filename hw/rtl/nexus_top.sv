// nexus_top.sv
//
// Top-level wrapper that connects X-HEEP to the NexusV coprocessor shell.
// This module owns the if_xif interface instance and performs the
// flat-to-interface translation required to bridge cvxif_nexus_shell
// to x_heep_system.

import core_v_mini_mcu_pkg::*;
import xheep_obi_pkg::*;

module nexus_top (
    input  logic         clk_i,
    input  logic         rst_ni,

    // Instruction memory interface
    output xheep_obi_req_t core_instr_req_o,
    input  xheep_obi_rsp_t core_instr_rsp_i,

    // Data memory interface
    output xheep_obi_req_t core_data_req_o,
    input  xheep_obi_rsp_t core_data_rsp_i,

    // Interrupts
    input logic [31:0] intr_vector_ext_i,

    // Debug
    input logic debug_req_i,

    // Exit value (for simulation end-of-test)
    output logic [31:0] exit_value_o
);

    // ──────────────────────────────────────────────────────────────────────
    // CV-X-IF interface instance — the shared wire bundle between X-HEEP
    // and our coprocessor shell.
    // ──────────────────────────────────────────────────────────────────────
    if_xif #() ext_if ();

    // ──────────────────────────────────────────────────────────────────────
    // X-HEEP System
    // ──────────────────────────────────────────────────────────────────────
    x_heep_system #(
        .EXT_XBAR_NMASTER (0),
        .AO_SPC_NUM       (0)
    ) u_x_heep (
        .hart_id_i           (32'h0),
        .xheep_instance_id_i (32'h0),

        .clk_i  (clk_i),
        .rst_ni (rst_ni),

        // Memory
        .ext_core_instr_req_o  (core_instr_req_o),
        .ext_core_instr_resp_i (core_instr_rsp_i),
        .ext_core_data_req_o   (core_data_req_o),
        .ext_core_data_resp_i  (core_data_rsp_i),

        // Interrupts
        .intr_vector_ext_i     (intr_vector_ext_i),
        .intr_ext_peripheral_i (1'b0),

        // Power management (tie off)
        .cpu_subsystem_powergate_switch_ack_ni        (1'b1),
        .peripheral_subsystem_powergate_switch_ack_ni (1'b1),
        .external_subsystem_powergate_switch_ack_ni   ('1),

        // Debug
        .ext_debug_master_resp_i ('0),

        // DMA external ports (tie off)
        .ext_dma_read_resp_i  ('0),
        .ext_dma_write_resp_i ('0),
        .ext_dma_addr_resp_i  ('0),
        .hw_fifo_resp_i       ('0),
        .ext_dma_slot_tx_i    ('0),
        .ext_dma_slot_rx_i    ('0),
        .ext_dma_stop_i       ('0),
        .hw_fifo_done_i       ('0),

        // AO/peripheral slave (tie off)
        .ext_ao_peripheral_req_i     ('0),
        .ext_peripheral_slave_resp_i ('0),

        // Exit
        .exit_value_o (exit_value_o),

        // CV-X-IF: connect the interface instance
        .xif_compressed_if (ext_if),
        .xif_issue_if      (ext_if),
        .xif_commit_if     (ext_if),
        .xif_mem_if        (ext_if),
        .xif_mem_result_if (ext_if),
        .xif_result_if     (ext_if)
    );

    // ──────────────────────────────────────────────────────────────────────
    // NexusV Coprocessor Shell
    // ──────────────────────────────────────────────────────────────────────
    cvxif_nexus_shell u_shell (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),

        // Issue channel
        .x_issue_req_valid_i   (ext_if.issue_valid),
        .x_issue_req_ready_o   (ext_if.issue_ready),
        .x_issue_req_instr_i   (ext_if.issue_req.instr),
        .x_issue_req_rs1_i     (ext_if.issue_req.rs[0]),
        .x_issue_req_rs2_i     (ext_if.issue_req.rs[1]),
        .x_issue_req_id_i      (ext_if.issue_req.id),

        .x_issue_resp_valid_o  (),
        .x_issue_resp_accept_o (ext_if.issue_resp.accept),
        .x_issue_resp_id_o     (),

        // Commit channel
        .x_commit_valid_i (ext_if.commit_valid),
        .x_commit_id_i    (ext_if.commit.id),
        .x_commit_kill_i  (ext_if.commit.commit_kill),

        // Result channel
        .x_result_valid_o (ext_if.result_valid),
        .x_result_ready_i (ext_if.result_ready),
        .x_result_id_o    (ext_if.result.id),
        .x_result_data_o  (ext_if.result.data),
        .x_result_rd_o    (ext_if.result.rd)
    );

    // ──────────────────────────────────────────────────────────────────────
    // Tie off unused CV-X-IF interface fields
    // ──────────────────────────────────────────────────────────────────────

    // Issue response — fields the shell doesn't drive
    assign ext_if.issue_resp.writeback = 1'b1;   // We write back to rd
    assign ext_if.issue_resp.dualwrite = 1'b0;
    assign ext_if.issue_resp.dualread  = 3'b0;
    assign ext_if.issue_resp.loadstore = 1'b0;
    assign ext_if.issue_resp.ecswrite  = 1'b0;
    assign ext_if.issue_resp.exc       = 1'b0;

    // Result — extra fields
    assign ext_if.result.we      = 1'b1;         // Enable register write
    assign ext_if.result.ecsdata = 6'b0;
    assign ext_if.result.ecswe   = 3'b0;
    assign ext_if.result.exc     = 1'b0;
    assign ext_if.result.exccode = 6'b0;
    assign ext_if.result.err     = 1'b0;
    assign ext_if.result.dbg     = 1'b0;

    // Compressed channel — not used
    assign ext_if.compressed_ready = 1'b0;
    assign ext_if.compressed_resp  = '0;

    // Memory channel — not used
    assign ext_if.mem_valid = 1'b0;
    assign ext_if.mem_req   = '0;

endmodule
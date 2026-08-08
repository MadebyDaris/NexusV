import xheep_obi_pkg::*;

module tb_nexus_system (
    input  logic        clk_i,
    input  logic        rst_ni,
    output logic [31:0] exit_value_o,
    output logic        exit_valid_o
);

    xheep_obi_req_t core_instr_req;
    xheep_obi_rsp_t core_instr_rsp;
    xheep_obi_req_t core_data_req;
    xheep_obi_rsp_t core_data_rsp;

    // Instance of nexus_top
    nexus_top u_top (
        .clk_i             (clk_i),
        .rst_ni            (rst_ni),
        .core_instr_req_o  (core_instr_req),
        .core_instr_rsp_i  (core_instr_rsp),
        .core_data_req_o   (core_data_req),
        .core_data_rsp_i   (core_data_rsp),
        .intr_vector_ext_i ('0),
        .debug_req_i       (1'b0),
        .exit_value_o      () // Monitored via memory bus
    );

    initial begin
        string hex_file;
        if ($value$plusargs("firmware=%s", hex_file)) begin
            $readmemh(hex_file, u_top.u_x_heep.core_v_mini_mcu_i.memory_subsystem_i.ram0_i.tc_ram_i.sram);
        end else begin
            $readmemh("sw/custom_c/test_mac.hex", u_top.u_x_heep.core_v_mini_mcu_i.memory_subsystem_i.ram0_i.tc_ram_i.sram);
        end
        $display("[TB] SRAM[0] = %h", u_top.u_x_heep.core_v_mini_mcu_i.memory_subsystem_i.ram0_i.tc_ram_i.sram[0]);
        $display("[TB] SRAM[1] = %h", u_top.u_x_heep.core_v_mini_mcu_i.memory_subsystem_i.ram0_i.tc_ram_i.sram[1]);
        exit_valid_o = 1'b0;
        exit_value_o = '0;
    end

    export "DPI-C" task tb_set_exit_loop;
    task tb_set_exit_loop;
        u_top.u_x_heep.core_v_mini_mcu_i.ao_peripheral_subsystem_i.soc_ctrl_i.testbench_set_exit_loop[0] = 1'b1;
    endtask

    // Instruction Memory Interface (Unused since we boot from internal RAM)
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            core_instr_rsp.gnt    <= 1'b0;
            core_instr_rsp.rvalid <= 1'b0;
            core_instr_rsp.rdata  <= '0;
        end else begin
            if (core_instr_req.req) begin
                $display("[TB] Instr Req: Addr=%h", core_instr_req.addr);
            end
            core_instr_rsp.gnt    <= core_instr_req.req;
            core_instr_rsp.rvalid <= core_instr_req.req;
            if (core_instr_req.req) begin
                core_instr_rsp.rdata <= '0;
            end
        end
    end

    // Data Memory Interface (External Slave)
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            core_data_rsp.gnt    <= 1'b0;
            core_data_rsp.rvalid <= 1'b0;
            core_data_rsp.rdata  <= '0;
            exit_valid_o         <= 1'b0;
            exit_value_o         <= '0;
        end else begin
            core_data_rsp.gnt    <= core_data_req.req;
            core_data_rsp.rvalid <= core_data_req.req;
            
            if (core_data_req.req) begin
                $display("[TB] Data Req: Addr=%h We=%b Wdata=%h", core_data_req.addr, core_data_req.we, core_data_req.wdata);
                // Custom exit peripheral at 0xF0000000 (X-HEEP External Slave range)
                if (core_data_req.addr == 32'hF0000000 && core_data_req.we) begin
                    exit_valid_o <= 1'b1;
                    exit_value_o <= core_data_req.wdata;
                    $display("[TB] EXIT write to 0xF0000000: value=%d", core_data_req.wdata);
                end else if (core_data_req.we) begin
                    $display("[TB] Unknown Write to %h (BE=%b): %h", core_data_req.addr, core_data_req.be, core_data_req.wdata);
                end else begin
                    core_data_rsp.rdata <= '0;
                    $display("[TB] Unknown Read from %h", core_data_req.addr);
                end
            end
        end
    end

endmodule

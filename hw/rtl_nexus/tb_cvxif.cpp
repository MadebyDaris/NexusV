#include "Vcvxif_nexus_shell.h"
#include "verilated.h"
#include <iostream>

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vcvxif_nexus_shell* top = new Vcvxif_nexus_shell;

    // Reset sequence
    top->clk_i = 0;
    top->rst_ni = 0;
    
    top->x_issue_req_valid_i = 0;
    top->x_issue_req_instr_i = 0;
    top->x_issue_req_rs1_i = 0;
    top->x_issue_req_rs2_i = 0;
    top->x_issue_req_id_i = 0;
    
    top->x_commit_valid_i = 0;
    top->x_commit_id_i = 0;
    top->x_commit_kill_i = 0;
    
    top->x_result_ready_i = 1;

    for (int i = 0; i < 10; ++i) {
        top->clk_i = !top->clk_i;
        top->eval();
        main_time++;
    }
    top->rst_ni = 1;
    top->clk_i = 0; top->eval(); main_time++;
    top->clk_i = 1; top->eval(); main_time++;

    // Cycle 1: Send issue req
    top->clk_i = 0; 
    top->x_issue_req_valid_i = 1;
    top->x_issue_req_instr_i = 0x0000000B; // Opcode 0x0B (CUSTOM_0)
    top->x_issue_req_rs1_i = 10;
    top->x_issue_req_rs2_i = 20;
    top->x_issue_req_id_i = 1;
    top->eval();
    
    if (top->x_issue_resp_valid_o && top->x_issue_resp_accept_o) {
        std::cout << "Issue accepted!" << std::endl;
    } else {
        std::cout << "Issue failed!" << std::endl;
    }

    top->clk_i = 1; top->eval(); main_time++; // Register inputs
    
    top->clk_i = 0;
    top->x_issue_req_valid_i = 0;
    top->eval(); main_time++;

    // Cycle 2: Wait
    top->clk_i = 1; top->eval(); main_time++;
    
    // Cycle 3: Send commit
    top->clk_i = 0; 
    top->x_commit_valid_i = 1;
    top->x_commit_id_i = 1;
    top->x_commit_kill_i = 0;
    top->eval(); main_time++;
    
    top->clk_i = 1; top->eval(); main_time++;
    
    top->clk_i = 0;
    top->x_commit_valid_i = 0;
    top->eval(); main_time++;

    // Cycle 4: Check result
    top->clk_i = 0; top->eval(); main_time++;
    
    if (top->x_result_valid_o) {
        std::cout << "Result Valid!" << std::endl;
        std::cout << "Result Data: " << top->x_result_data_o << " (Expected 30)" << std::endl;
        if (top->x_result_data_o == 30) {
            std::cout << "TEST PASSED" << std::endl;
        } else {
            std::cout << "TEST FAILED" << std::endl;
        }
    } else {
        std::cout << "Result not valid! TEST FAILED" << std::endl;
    }

    top->clk_i = 1; top->eval(); main_time++;

    delete top;
    return 0;
}

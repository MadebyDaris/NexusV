Part 1: The Hardware Implementation Plan
Your job is to bridge the gap between the HWGraph (the Data Flow Graph handed to you by the CS developer) and physical silicon.
Step 1: Design the "Standard Internal Interface"
Your static CV-X-IF shell needs to talk to the auto-generated datapaths. Because different datapaths will have different clock-cycle latencies (e.g., an addition takes 1 cycle, a Kyber PQC modulo takes 3 cycles), you must establish a standard handshake between your shell and the generated code.
Every generated .sv file must have this exact port list:
code
Systemverilog
module generated_datapath_mac (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        start_i,     // Shell tells datapath to begin
    input  logic [31:0] rs1_i,
    input  logic [31:0] rs2_i,
    output logic [31:0] rd_o,
    output logic        done_o       // Datapath tells shell it is finished
);
Your CV-X-IF Shell Extension: You will modify the FSM from Week 1. When the CPU commits the instruction, your shell asserts start_i. The FSM then moves to a WAIT_DATAPATH state until done_o goes high, after which it sends the result back to the CPU.
Step 2: The Julia Scheduler (ASAP Algorithm)
Before generating Verilog, your Julia script must figure out the clock cycle timing. If the graph contains (A + B) * C, the multiplication must wait for the addition to finish.
You will write src_julia/Scheduler.jl. You will implement an ASAP (As Soon As Possible) algorithm.
How to code this in Julia:
Find all nodes that only depend on Inputs (no dependencies). Assign them scheduled_cycle = 1.
For all other nodes, look at their input dependencies. Their cycle is max(dependencies.cycle) + 1.
If a cycle gets too "deep" (e.g., doing 5 additions in one cycle will ruin the maximum clock frequency, Fmax), you artificially increment the cycle, which tells the Verilog Emitter to insert a Flip-Flop (pipeline stage).
Julia Conceptual Code:
code
Julia
function schedule_asap!(graph::HWGraph)
    for node in topological_sort(graph)
        if isempty(node.inputs) || node.op == OP_ARG
            node.scheduled_cycle = 1
        else
            # Wait for the slowest input to finish
            max_input_cycle = maximum([graph.nodes[i].scheduled_cycle for i in node.inputs])
            node.scheduled_cycle = max_input_cycle + 1
        end
    end
    # The total latency of the hardware module is the max cycle
    graph.latency = maximum([n.scheduled_cycle for n in values(graph.nodes)])
end
Step 3: The Julia Verilog Emitter
This is where the magic happens (src_julia/VerilogEmitter.jl). You will iterate through the scheduled graph and print SystemVerilog strings.
The Strategy:
Group the nodes by their scheduled_cycle.
For nodes in Cycle 1, emit assign stage1_nodeX = rs1_i + rs2_i;
Between cycles, emit an always_ff @(posedge clk_i) block to create pipeline registers.
For nodes in Cycle 2, emit assign stage2_nodeY = stage1_nodeX * constant;
Julia Emitter Example:
code
Julia
function emit_verilog(graph::HWGraph, filename::String)
    open(filename, "w") do f
        write(f, "module $(graph.name) (input clk_i, input start_i, ...);\n")
        
        # 1. Declare all wires
        for node in values(graph.nodes)
            write(f, "  logic [31:0] n$(node.id)_val;\n")
            write(f, "  logic [31:0] n$(node.id)_reg;\n") # For pipelining
        end

        # 2. Emit combinational logic (assigns)
        for node in values(graph.nodes)
            if node.op == OP_ADD
                write(f, "  assign n$(node.id)_val = n$(node.inputs[1])_reg + n$(node.inputs[2])_reg;\n")
            elseif node.op == OP_MUL
                write(f, "  assign n$(node.id)_val = n$(node.inputs[1])_reg * n$(node.inputs[2])_reg;\n")
            end
        end

        # 3. Emit Sequential Pipeline (Flip-Flops)
        write(f, "  always_ff @(posedge clk_i) begin\n")
        for node in values(graph.nodes)
             write(f, "    n$(node.id)_reg <= n$(node.id)_val;\n")
        end
        write(f, "  end\n")
        
        write(f, "endmodule\n")
    end
end
Step 4: The Dispatcher (The Mux)
If the user compiles both an ML MAC unit and a Kyber NTT unit, you will have two datapaths.
You will write a Julia script that auto-generates nexus_mux.sv. This file looks at x_issue_req_instr_i[14:12] (the func3 field of the RISC-V instruction).
If func3 == 0, route rs1/rs2 to the ML datapath.
If func3 == 1, route rs1/rs2 to the PQC datapath.
It collects the correct rd_o and sends it back to your CV-X-IF shell.
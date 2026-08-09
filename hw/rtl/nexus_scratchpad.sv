module nexus_scratchpad #(
    parameter int WORDS = 256,
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = $clog2(WORDS)
)(
    input logic clk_i,
    input logic rst_ni,

    // A for read and write on scratchpad
    input  logic [ADDR_WIDTH-1:0] a_addr_i,
    input  logic a_we_i,
    input  logic [DATA_WIDTH-1:0] a_wdata_i,
    output logic [DATA_WIDTH-1:0] a_rdata_o,

    // B for read only on scratchpad
    input  logic [ADDR_WIDTH-1:0] b_addr_i,
    output logic [DATA_WIDTH-1:0] b_rdata_o
)
    logic [DATA_WIDTH-1:0] mem [0:WORDS-1];

    always_ff @( posedge clk_i ) begin
        if (a_we_i) begin
            mem[a_addr_i] <= a_wdata_i;
        end
        a_rdata_o <= mem[a_addr_i]
    end

    always_ff @(posedge clk_i) b_rdata_o <= mem[b_addr_i];   // second, independent read port
endmodule
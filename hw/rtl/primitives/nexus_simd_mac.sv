// to be implemented: a simple SIMD MAC (multiply-accumulate) unit that takes two 8-bit inputs, multiplies them, and accumulates the result into a wider accumulator. The number of lanes can be parameterized.
module nexus_simd_mac #(
    parameter LANES = 4, // 4 lanes of SIMD , 8-bit 
    parameter DATA_WIDTH = 8, // 8-bit data
    parameter int ACC_WIDTH = (DATA_WIDTH * 2) + $clog2(LANES) + 4
) (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic       start_i,
    input  logic [LANES*DATA_WIDTH-1:0]  a_i, // rs1, This is packed by 4x8-bit lanes
    input  logic [LANES*DATA_WIDTH-1:0]  b_i, // rs2
    input  logic [ACC_WIDTH-1:0]  c_o,
    output logic done_o,
);

    localparam int PROD_WIDTH = DATA_WIDTH*2;
    logic signed [PROD_WIDTH-1:0] prod [LANES-1:0]; // output of the multiplier for each lane
    
    genvar i;
    generate
      for (i = 0; i < LANES; i++) begin : g_mul
        assign prod[i] = $signed(a_i[i*DATA_WIDTH +: DATA_WIDTH]) * $signed(b_i[i*DATA_WIDTH +: DATA_WIDTH]);
      end
    endgenerate

    (* use_dsp = "yes" *)
    logic signed [PROD_WIDTH-1:0] p [LANES-1:0];
    always_comb begin
      sum = 0;
      for (int j = 0; j < LANES; j++) begin
        sum += prod[j];
      end
    end

    logic signed [ACC_WIDTH-1:0] acc;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            c_o <= 0;
            done_o <= 1'b0;
        end
        else if (start_i) begin
            acc <= acc + sum;
            done_o <= 1'b1;
        end
    end
endmodule
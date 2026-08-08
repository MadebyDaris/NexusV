// to be implemented: a simple SIMD MAC (multiply-accumulate) unit that takes two 8-bit inputs, multiplies them, and accumulates the result into a wider accumulator. The number of lanes can be parameterized.
module nexus_simd_mac #(
    parameter LANES = 4, // 4 lanes of SIMD , 8-bit 
    parameter DATA_WIDTH = 8, // 8-bit data
    parameter int ACC_WIDTH = (DATA_WIDTH * 2) + $clog2(LANES) + 4
)

(
  input logic        clk_i,
  input logic        rst_ni,
  input  logic [DATA_WIDTH-1:0]  a_i,
  input  logic [DATA_WIDTH-1:0]  b_i,
  input  logic [ACC_WIDTH-1:0]  c_i,
  output logic [ACC_WIDTH-1:0]  d_o
);

    localparam WIDTH = DATA_WIDTH;
    localparam int PROD_WIDTH = DATA_WIDTH * 2;
    

    (* use_dsp = "yes" *)
    logic signed [PROD_WIDTH-1:0] p [LANES-1:0];

 // Implement
endmodule
module mux2 #(
    parameter int WIDTH     = 16,
    parameter int OUT_WIDTH = WIDTH
) (
    input  wire [    WIDTH-1:0] i_data_0,
    input  wire [    WIDTH-1:0] i_data_1,
    input  wire                 i_sel,
    output wire [OUT_WIDTH-1:0] o_data
);

/*
Type <leader>iv in normal mode to copy template for currently opened sv file 
  -> It'll ignore all the non-constant(derived) parameters

Ex:
    mux2 #(
        .WIDTH(16)
    ) u_mux2 (
        .i_data_0(i_data_0),
        .i_data_1(i_data_1),
        .i_sel   (i_sel),
        .o_data  (o_data)
    );
*/

    assign o_data = i_sel ? i_data_1 : i_data_0;

endmodule

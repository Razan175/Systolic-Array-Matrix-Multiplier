//Parametrized multiplexer
module MUX_N_1 #(parameter DATAWIDTH = 32, N_SIZE = 3)(
	input en,  
	input [DATAWIDTH - 1:0] Din [N_SIZE],
	input reg [$clog2(N_SIZE) - 1:0] sel,
	output reg [DATAWIDTH - 1:0] Dout
);

always @(*) begin
	if(en)
        Dout = Din[sel];
    else
    	Dout = 0;
 end

endmodule
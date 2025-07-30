//Processing Element Module
module PE #(parameter DATAWIDTH = 16, N_SIZE = 3) (
	input clk,rst_n,   // Clock
	input [DATAWIDTH - 1:0] A,B,
	output reg [DATAWIDTH - 1:0] A_shifted, B_shifted,
	output reg [DATAWIDTH*2 - 1:0] C
);

	always @(posedge clk or negedge rst_n) begin 
		if(~rst_n) begin
			C <= 0;
			A_shifted <= 0;
			B_shifted <= 0;
		end else begin
			A_shifted <= A; 
			B_shifted <= B;  
			C <= C + (A*B); 
		end
	end
endmodule

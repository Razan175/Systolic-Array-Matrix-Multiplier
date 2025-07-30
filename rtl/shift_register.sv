//Parametrized shift register

module shift_register #(parameter DATAWIDTH = 16, N_SIZE = 5) (
	input clk,    // Clock
	input rst_n,en,  // Asynchronous reset active low
	input [DATAWIDTH - 1:0] D,
	output reg [DATAWIDTH - 1:0] Q
);
generate
    //N_size corresponds to the number of shift registers
	if (N_SIZE == 1)
		begin
			always @(posedge clk or negedge rst_n) begin
				if(~rst_n) begin
					 Q <= 0;
				end
				else if (en)
					Q <= D;
				else
					Q <= 0;
				end
			end
		else
		begin
			reg [N_SIZE - 1:0] [DATAWIDTH - 1:0] data ;
			always @(posedge clk or negedge rst_n) begin
				if(~rst_n) begin
					 foreach (data[i]) begin
					 	data[i] <= 0;
					 end
				end else begin
					if (en) begin 
					 	data <= {D, data[N_SIZE - 1:1]};
					 end
					 else begin
					 	data <= {1'b0, data[N_SIZE - 1:1]};
					 end
				end
			end
            assign Q = data[0];
		end
endgenerate

endmodule
module systolic_array #(parameter DATAWIDTH = 16, N_SIZE = 3) (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input valid_in, //Asserted when data is ready
	input [DATAWIDTH - 1:0] matrix_a_in [N_SIZE], //first matrix
	input [DATAWIDTH - 1:0] matrix_b_in [N_SIZE], //second matrix
	output reg valid_out, //asserted when output is ready to be collected
	output reg [DATAWIDTH*2 - 1:0] matrix_c_out [N_SIZE] //output row
);

localparam process_input = 2'b00,
		   wait_output_ready = 2'b10,
		   send_output = 2'b01;

//PE external regs
reg [DATAWIDTH - 1:0] a_wire [0:N_SIZE*N_SIZE - 1], b_wire [0:N_SIZE*N_SIZE - 1];

//output reg from the PE
reg [DATAWIDTH*2 - 1:0] c_wire [0:N_SIZE*N_SIZE - 1];
reg [DATAWIDTH*2 - 1:0] matrix_c_out_next [N_SIZE];

//Counter 
reg [$clog2(N_SIZE) - 1:0] count, count_next;
genvar i,j;
generate
	//Generate delay registers, each row or coulmn should be delayed by idx before entering the PE
	for (i = 1; i < N_SIZE; i++) begin
			shift_register #(.DATAWIDTH(DATAWIDTH), .N_SIZE(i)) sr1 (.clk(clk), .en(valid_in), .rst_n(rst_n), .D(matrix_a_in[i]), .Q(a_wire[i*N_SIZE]));
			shift_register #(.DATAWIDTH(DATAWIDTH), .N_SIZE(i)) sr2 (.clk(clk), .en(valid_in), .rst_n(rst_n), .D(matrix_b_in[i]), .Q(b_wire[i]));
	end

	//processing elements wiring
	for(i=0; i<N_SIZE*N_SIZE; i=i+1) begin
		//for the blocks that contain outputs that we will not use (ex A_shifted for the last column)
		wire [DATAWIDTH - 1:0] buffer_a,buffer_b;
		//if the current row and coulmn are the last
		if ( ((i + 1) % N_SIZE == 0) && (i >= (N_SIZE - 1)*N_SIZE) )
			PE #(.DATAWIDTH(DATAWIDTH), .N_SIZE(N_SIZE)) pe_blocks  (.clk(clk), .rst_n(rst_n), .A(a_wire[i]), .B(b_wire[i]), .A_shifted(buffer_a), .B_shifted(buffer_b), .C(c_wire[i]));
		else if ((i + 1) % N_SIZE == 0) //if the current  coulmn is the last
			PE #(.DATAWIDTH(DATAWIDTH), .N_SIZE(N_SIZE)) pe_blocks (.clk(clk), .rst_n(rst_n), .A(a_wire[i]), .B(b_wire[i]), .A_shifted(buffer_a), .B_shifted(b_wire[i + N_SIZE]), .C(c_wire[i]));
		else if (i >= (N_SIZE - 1)*N_SIZE) //if the current row is the last
			PE #(.DATAWIDTH(DATAWIDTH), .N_SIZE(N_SIZE)) pe_blocks (.clk(clk), .rst_n(rst_n), .A(a_wire[i]), .B(b_wire[i]), .A_shifted(a_wire[i + 1]), .B_shifted(buffer_b), .C(c_wire[i]));
		else // general case
			PE #(.DATAWIDTH(DATAWIDTH), .N_SIZE(N_SIZE)) pe_blocks (.clk(clk), .rst_n(rst_n), .A(a_wire[i]), .B(b_wire[i]), .A_shifted(a_wire[i + 1]), .B_shifted(b_wire[i + N_SIZE]), .C(c_wire[i]));
	end

	//generate output MUXs
	for (i = 0; i < N_SIZE; i++) 
	begin  : for_outer
		wire [DATAWIDTH*2 - 1:0] in_bus [N_SIZE];
		for (j = 0; j < N_SIZE; j ++) begin  : for_inner
			assign in_bus[j] = c_wire[j*N_SIZE + i];
		end
		MUX_N_1 #(.DATAWIDTH(DATAWIDTH*2), .N_SIZE(N_SIZE)) output_MUX (.en(valid_out), .Din(in_bus), .sel(count), .Dout(matrix_c_out[i]));
	end
endgenerate

//these signals contain no delays so they are connected to PE through enable controlled by valid_in
assign a_wire[0] = valid_in?matrix_a_in[0]:0;
assign b_wire[0] = valid_in?matrix_b_in[0]:0;


//state_registers
reg [1:0] next_state,current_state;
//Current state logic
always @(posedge clk or negedge rst_n) begin
	if(~rst_n)  begin
		count <= 0;
		current_state <= 0;
	end
	else  
	begin
		count <= count_next;
		current_state <= next_state;
	end
end

//FSM
always @(*) begin
	case(current_state)
		process_input:
		begin
			//if N_SIZE inputs are given, move to the next state and set the counter to 0
			if (count == (N_SIZE - 1)) begin
				next_state = wait_output_ready;
				count_next = 0;
			end
			else begin //else if valid_in is asserted, increment the counter, if not keep it at the same time it was before
				next_state = process_input;
				if (valid_in) 
					count_next = count + 1;
				else
					count_next = count;
			end
		end
		wait_output_ready: 
		begin
			//output of the first row is ready after N_SIZE clock cycles
			if (count == N_SIZE) begin 
				//if N_SIZE cycles have passed, move to the next state
				next_state = send_output;
				count_next = 0;
			end
			else begin
				//otherwise, stay in the same state and increment the counter
				next_state = wait_output_ready;
				count_next = count + 1;
			end
		end
		send_output: 
		begin
			if (count == (N_SIZE - 1)) begin //if all outputs are sent, move back to the inital state and set the counter to 0
				next_state = process_input;
				count_next = 0;
			end
			else begin //otherwise, stay in the same state and increment the counter
				next_state = send_output;
				count_next = count + 1;
			end
		end
		default: //default state 
		begin 
			next_state = 2'b00;
			count_next = 0;
		end
	endcase	
end

//output logic
assign valid_out = (current_state == send_output);

endmodule





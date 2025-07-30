module systolic_array_tb;
	typedef struct {
		logic valid_in;
		logic valid_out;
	}stim;
	logic clk,rst_n;

	logic [15:0] matrix_a_in_3 [3];
	logic [15:0] matrix_a_in_5 [5];

	logic [15:0] matrix_b_in_3 [3];
	logic [15:0] matrix_b_in_5 [5];

	logic [31:0] matrix_c_out_3 [3];
	logic [31:0] matrix_c_out_5 [5];

	systolic_array #(.N_SIZE(3)) DUT_3 (
		.clk(clk),.rst_n(rst_n), 
		.valid_in(stim_3.valid_in), 
		.matrix_a_in(matrix_a_in_3), 
		.matrix_b_in(matrix_b_in_3), 
		.valid_out(stim_3.valid_out),
		.matrix_c_out(matrix_c_out_3)
		);


	systolic_array #(.N_SIZE(5)) DUT_5 (
		.clk(clk),.rst_n(rst_n), 
		.valid_in(stim_5.valid_in), 
		.matrix_a_in(matrix_a_in_5), 
		.matrix_b_in(matrix_b_in_5), 
		.valid_out(stim_5.valid_out),
		.matrix_c_out(matrix_c_out_5)
		);

	logic [31:0] out[][];
	logic [31:0] expected_out[][];
	
	stim stim_3;
	stim stim_5;

	//size 3 testcase
	logic [15:0] A3 [3][3] = {{1,2,3},{4,5,6},{7,8,9}};
	logic [15:0] B3 [3][3]  = {{1,0,0}, {0,2,0}, {0,0,3}};
	logic [15:0] A_tr3 [3][3];

	//size 5 testcase
	logic [15:0] A5 [5][5] = {{1,2,3,4,5},{6,7,8,9,10},{11,12,13,14,15},{1,2,3,4,5},{6,7,8,9,10}};
	logic [15:0] B5 [5][5]  = {{2,4,6,8,10}, {12,14,16,18,20}, {22,24,26,28,30}, {1,2,3,4,5},{6,7,8,9,10}};
	logic [15:0] A_tr5 [5][5];

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
    
    int file;
	initial begin
		//calculates the expected value
		file = $fopen("file.log","w");
		$fwrite(file,"Testcase 1: 3x3 matix\n");
		$fwrite(file,"A:\n");
		foreach (A3[i]) begin
			$fwrite(file,"%p\n",A3[i]);
		end
		$fwrite(file,"B:\n");
		foreach (B3[i]) begin
			$fwrite(file,"%p\n",B3[i]);
		end
		
		expected_out = new[3];
		foreach (expected_out[i]) 
			expected_out[i] = new[3];

	    for (int i = 0; i < 3; i++) 
	        for (int j = 0; j < 3; j++) begin
	            expected_out[i][j] = 0;
	            for (int k = 0; k < 3; k++)
	                expected_out[i][j] += A3[i][k] * B3[k][j]; 
	        end  

		//since A should be given coulmn wise, we calculate its transpose before sending it to the DUT
		for (int i = 0; i < 3; i++)
		   for (int j = 0; j < 3; j++) 
		     A_tr3[i][j] = A3[j][i];
		     		
		//dynamic array to store the output
		out = new[3];
		foreach (out[i]) 
			out[i] = new[3];

		//reset
		stim_3.valid_in = 0;
		@(negedge clk)
		rst_n = 0;

		@(negedge clk)
		rst_n = 1;

		//send values
		for (int i = 0; i < 3; i++) begin
			@(negedge clk)
			stim_3.valid_in = 1;
			matrix_a_in_3 = A_tr3[i];
			matrix_b_in_3 = B3[i];
		end

		//turn off valid_in
		@(negedge clk)
		stim_3.valid_in = 0;

		//wait for valid_out then collect results
		wait(stim_3.valid_out);
		for (int i = 0; i  < 3; i++) begin
			@(negedge clk)
			out[i] = matrix_c_out_3;
		end
		//check if the output is as expected
		check_result();

		// ======================================== Size 5 test ========================================
		$fwrite(file,"Testcase 2: 5x5 matix");
		$fwrite(file,"A:\n");
		foreach (A5[i]) begin
			$fwrite(file,"%p\n",A5[i]);
		end
		$fwrite(file,"B:\n");
		foreach (A5[i]) begin
			$fwrite(file,"%p\n",B5[i]);
		end
		//calculates the expected value
		expected_out = new[5];
		foreach (expected_out[i]) 
			expected_out[i] = new[5];

	    for (int i = 0; i < 5; i++) 
	        for (int j = 0; j < 5; j++) begin
	            expected_out[i][j] = 0;
	            for (int k = 0; k < 5; k++)
	                expected_out[i][j] += A5[i][k] * B5[k][j]; 
	        end  

		//since A should be given coulmn wise, we calculate its transpose before sending it to the DUT
		for (int i = 0; i < 5; i++)
		   for (int j = 0; j < 5; j++) 
		     A_tr5[i][j] = A5[j][i];
		     		
		//dynamic array to store the output
		out = new[5];
		foreach (out[i]) 
			out[i] = new[5];

		//reset
		stim_5.valid_in = 0;
		@(negedge clk)
		rst_n = 0;

		@(negedge clk)
		rst_n = 1;

		//send values
		for (int i = 0; i < 5; i++) begin
			@(negedge clk)
			stim_5.valid_in = 1;
			matrix_a_in_5 = A_tr5[i];
			matrix_b_in_5 = B5[i];
		end

		//turn off valid_in
		@(negedge clk)
		stim_5.valid_in = 0;

		//wait for valid_out then collect results
		wait(stim_5.valid_out);
		for (int i = 0; i  < 5; i++) begin
			@(negedge clk)
			out[i] = matrix_c_out_5;
		end
		//check if the output is as expected
		check_result();

		#20;
		$fclose(file);
		$stop;
	end

	task check_result();
			$fwrite(file,"Output:\n");
			foreach (out[i]) begin
				$fwrite(file,"%p\n",out[i]);
			end
			if (out == expected_out)
				$display("[Passed] output: %p, expected: %p",out,expected_out);
			else
				$error("[Failed] output: %p, expected: %p",out,expected_out);
	endtask

endmodule
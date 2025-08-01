# Systolic Array Matrix Multiplier
![Untitled-video-Made-with-Clipchamp](https://github.com/user-attachments/assets/d627fe04-65b1-47a1-a9b8-bc8875853b64)

# Overview

This repository contains the implementation of an NxN systolic array that performs parallel multiply
accumulate operations across processing elements to compute the product of two matrices and 
result NxN matrix. 

The project includes the design and code for a Processing Element module, an Nx1 multiplexer, a parametrized shift register and a systolic array module that connect all these modules together.

The design is also fully scalable, allowing for the same design to be reused for any N size array multiplication.

# Components
<img width="500" height="500" alt="Systolic_Array (1) drawio" src="https://github.com/user-attachments/assets/93057bd9-6b91-42f0-9d81-09630f734cea" />

## The Design Consists of 4 main components
<details>
<summary>Systolic Array main module</summary>
  
- Parameters

| Name | Type | Default Value | Description |
| ------------- | ------------- | ------------- | ------------- |
| DATAWIDTH | integer | 16 | the datawidth of the elements |
| N_SIZE | integer | 3 | the size of the array |

- Ports

| Name | Direction | Size | Description |
| ------------- | ------------- | ------------- | ------------- |
| clk | input | 1 | Positive edge clock signal |
| rst_n | input | 1 | Negative edge asynchronous reset   |
| valid_in |  input | 1 | Valid signal set to 1 when a valid data are settled on ‘matrix_a_in’ and ‘matrix_b_in’ so the DUT is allowed to  sample them |
| matrix_a_in   | input | DATAWIDTH*N_SIZE | Array of N inputs corresponding to one column of matrix A elements entering the systolic array rows.   |
| matrix_b_in   | input | DATAWIDTH*N_SIZE | Array of N inputs corresponding to one row of matrix B elements entering the systolic array rows. |
| valid_out | output | 1 | Valid signal set to 1 when a valid row of the result matrix are settled on ‘matric_c_out’  |
| matrix_c_out | output | 2*DATAWIDTH*N_SIZE |Array of N outputs corresponding to one row of matrix C elements resulting from the array multiplication |
</details>


<details>
  
<summary>Processing Elements (PEs)</summary>
  
- Parameters
  
| Name | Type | Default Value | Description |
| ------------- | ------------- | ------------- | ------------- |
| DATAWIDTH | integer | 16 | the datawidth of the elements |

- Ports

| Name | Direction | Size | Description |
| ------------- | ------------- | ------------- | ------------- |
| clk | input | 1 | Positive edge clock signal |
| rst_n | input | 1 | Negative edge asynchronous reset   |
| A | input | DATAWIDTH | A single element from Matrix A sent from the  previous block to be processed and sent to the next PE block  |
| B | input | DATAWIDTH | A single element from Matrix B to be processed and sent to the next block   |
| C | output | DATAWIDTH*2 |The final output of the Multiplication  |
| A_shifted | output | DATAWIDTH | A single element from Matrix A to be sent to the next PE block in the next clock cycle  |
| B_shifted | output | DATAWIDTH | A single element from Matrix B to be sent to the next PE block in the next clock cycle  |

</details>

<details>
  
<summary>Parametrized Shift Registers</summary>
  
- Parameters


| Name | Type | Default Value | Description |
| ------------- | ------------- | ------------- | ------------- |
| DATAWIDTH | integer | 16 | the datawidth of the elements |
| N | integer | 3 | the number of registers to be infered |

- Ports

| Name | Direction | Size | Description |
| ------------- | ------------- | ------------- | ------------- |
| clk | input | 1 | Positive edge clock signal |
| rst_n | input | 1 | Negative edge asynchronous reset   |
| en | input | 1 | Enable Signal |
| D | input | DATAWIDTH | input data  |
| Q | output | DATAWIDTH | Output from shifting process  |


</details>


<details>

<summary>Parametrized Nx1 Multiplexers</summary>
  
- Parameters

| Name | Type | Default Value | Description |
| ------------- | ------------- | ------------- | ------------- |
| DATAWIDTH | integer | 16 | the datawidth of the elements |
| N_SIZE | integer | 3 | the number of MUXs to be inferred |

- Ports

| Name | Direction | Size | Description |
| ------------- | ------------- | ------------- | ------------- |
| en |  input | 1 | Enable signal |
| Din | input | DATAWIDTH*N_SIZE | An array of N_SIZE elements  |
| sel | input | log2(N_SIZE) | Selection line |
| Dout | output | DATAWIDTH | The selected output of the multiplexer |
</details>



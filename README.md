# Matrix-Multiplication-VHDL
Multiplying a square matrix on hardware using a 3-stage pipeline. 

- The entity is in the file called matmult.vhd, simple test-bench is matmult_tb.vhd, if you have modelsim you can run the mat_mult.do script. 
- I used generics to define number of rows, columns, and word size, however I used them assuming the matrix is square, can easily be changed just makes code ugly. Probably better to use a package file for something more serious.
- Synthesis is dependent mostly on number of MAC blocks on your FPGA. 

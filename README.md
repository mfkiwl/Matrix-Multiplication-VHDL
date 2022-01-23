# Matrix-Multiplication-VHDL
Multiplying a (4 x 4) square matrix (16 bits signed) on hardware using a 3-stage pipeline. Done mostly between 1-2 a.m. Jan 23rd 2022. 

The definition of matrix multiplication is that if C = AB for an n × m matrix A and an m × p matrix B, then C is an n × p matrix with entries:
  c_{ij}=\sum _{k=1}^{m}a_{ik}b_{kj}

- The entity is in the file called matmult.vhd, simple test-bench is matmult_tb.vhd, if you have modelsim you can run the mat_mult.do script. 
- I used generics to define number of rows, columns, and word size, however I used them assuming the matrix is square, can easily be changed just makes code ugly. Probably better to use a package file for something more serious.
- Synthesis is dependent mostly on number of MAC blocks on your FPGA. 
- The key feature that makes this easy was that the entity takes in a flattened matrix (which is just a string of bits) where each 16 bit word is followed by the next.
- In the load stage of the pipeline we convert from a flattened matrix to a 2D array of signed numbers.
- In the multiply stage we multiply the two matrices using the algorithm : 
  
  Let C be a new matrix of the appropriate size
  For i from 1 to n:
    For j from 1 to p:
      Let sum = 0
      For k from 1 to m:
        Set sum ← sum + Aik × Bkj
      Set Cij ← sum
  Return C

- Using the property for identity matrices of: In * An = An, I was able to verify the functionality pretty easily. 

### Simulation Screenshots: 


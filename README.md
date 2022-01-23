# Matrix-Multiplication-VHDL
Multiplying a (4 x 4) square matrix (16 bits signed) on hardware using a 3-stage pipeline. Done mostly between 1-2 a.m. Jan 23rd 2022. 

The definition of matrix multiplication is that if C = AB for an n × m matrix A and an m × p matrix B, then C is an n × p matrix with entries:

![image](https://user-images.githubusercontent.com/29047827/150667759-64339a1a-8092-4396-8f24-9a134b4ea0aa.png)

- The entity is in the file called matmult.vhd, simple test-bench is matmult_tb.vhd, if you have modelsim you can run the mat_mult.do script. 
- I used generics to define number of rows, columns, and word size, however I used them assuming the matrix is square, can easily be changed just makes code ugly. Probably better to use a package file for something more serious.
- Synthesis is dependent mostly on number of MAC blocks on your FPGA. 
- The key feature that makes this easy was that the entity takes in a flattened matrix (which is just a string of bits) where each 16 bit word is followed by the next.
- In the load stage of the pipeline we convert from a flattened matrix to a 2D array of signed numbers.
- In the multiply stage we multiply the two matrices using the algorithm :

```vhdl
for i in 0 to num_row-1 loop 
  for j in 0 to num_row-1 loop
    sum := (others => '0');         -- sum is a 36 bit signed number                             
      for k in 0 to num_row-1 loop  
        sum := sum + (mat_lhs(i,k) * mat_rhs(k,j));
      end loop;

  -- Add sum to the matrix output 
     mat_out(i,j) <= mat_out(i,j) + sum;
  end loop; 
end loop; 
```

- Using the property for identity matrices of: In * An = An, I was able to verify the functionality pretty easily. 

### Simulation Screenshot: 
You can see that mat_lhs is an identity matrix and when we multiply it by this other matrix we get the same matrix back proving the identity property. 
![image](https://user-images.githubusercontent.com/29047827/150667566-abf77536-f22c-4c94-bb67-ac4f3d574cd0.png)

Another Multiplication:
![image](https://user-images.githubusercontent.com/29047827/150668134-4794adcc-0e2d-488d-a9db-94db27c35a90.png)

Verifying Result in MATLAB:

![image](https://user-images.githubusercontent.com/29047827/150668253-1ae93069-13ea-4629-a622-f46069680507.png)

### Sources I used: 
https://en.wikipedia.org/wiki/Matrix_multiplication_algorithm

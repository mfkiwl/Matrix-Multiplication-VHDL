library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use ieee.numeric_std.all;

entity matmult is
  generic (
      rst_polartiy  : std_logic := '0';
      num_row       : integer   := 4;
      num_col       : integer   := 4; 
      num_bits      : integer   := 16         
  );
  port (
        clk             : in  std_logic ;
        rst             : in  std_logic ;
        do_mult         : in  std_logic; 
        flat_mat_lhs    : in  signed((num_row*num_col*num_bits)-1 downto 0);  
        flat_mat_rhs    : in  signed((num_row*num_col*num_bits)-1 downto 0);
        done_mult       : out std_logic;
    --- num_rows * num_cols * ((num_bits_in * 2) + num_row) : we need * 2 b/c of binary multiplication, + num_row takes care of overflow 
        flat_mat_out    : out signed(((num_row * num_col * ((num_bits*2) + num_row)) -1 ) downto 0)
  );
end matmult ;

architecture arch of matmult is

-- Creating 2D array of signed bit range
type matrix is array(0 to num_row-1, 0 to num_col-1) of signed(num_bits-1 downto 0);
type matrix_o is array(0 to num_row-1, 0 to num_col-1) of signed((num_bits*2) + num_row -1 downto 0);
type mystates is (idle, load, mult, return_result);
    
-- Declaring lhs, rhs, & output matrices
signal mat_lhs, mat_rhs : matrix; 
signal mat_out : matrix_o; 
signal matrix_state : mystates; 

constant num_bits_mult : integer := (num_bits*2)+num_row; 

begin

    process (clk, rst)
        variable u_idx : integer;                       -- upper_index
        variable l_idx : integer;                       -- lower_index
        variable sum   : signed(((num_bits*2) + num_row)-1 downto 0);
    begin
        if (rst = rst_polartiy) then
            -- Clear the matrix signals by (row => col => bits => '0')
            mat_lhs <= (others => (others => (others => '0')));
            mat_rhs <= (others => (others => (others => '0')));
            mat_out <= (others => (others => (others => '0')));

            -- Set all outputs to zero (bad habit)  
            flat_mat_out <= (others => '0');
            done_mult <= '0'; 

        elsif rising_edge(clk) then
            
            case matrix_state is      

                when idle => 
                    if (do_mult) then 
                        matrix_state <= load; 
                    end if; 

                    done_mult <= '0'; 

                when load => 
                    -- Iterate over rows & columns 
                    for i in 0 to num_row-1 loop  
                        for j in 0 to num_col-1 loop 
                            -- Equation to get bit indices based on row & col  
                            u_idx := num_bits*(j + (num_col * i) + 1) - 1;    
                            l_idx := u_idx - num_bits + 1;

                            mat_lhs(i,j) <= flat_mat_lhs(u_idx downto l_idx);
                            mat_rhs(i,j) <= flat_mat_rhs(u_idx downto l_idx);
                        end loop;
                    end loop; 

                    matrix_state <= mult; 
        
                when mult =>
                    -- Matrix multiplication algorithm : A[n,m] * B[m,k] = C[n,k]
                    -- although for square matrix you basically just iterate over same length : O(n^3)
                    for i in 0 to num_row-1 loop 
                        for j in 0 to num_row-1 loop
                            
                            sum := (others => '0');         -- reset sum to zero every multiply     
                            for k in 0 to num_row-1 loop  
                                sum := sum + (mat_lhs(i,k) * mat_rhs(k,j));
                            end loop;

                            -- Add sum to the matrix output 
                            mat_out(i,j) <= mat_out(i,j) + sum;
                        end loop; 
                    end loop; 

                    matrix_state <= return_result; 

                when return_result => 
                    -- Basically reversing the load operation using same math 
                    for i in 0 to num_row-1 loop 
                        for j in 0 to num_col-1 loop 

                            u_idx := num_bits_mult*(j + (num_col * i) + 1) - 1;    
                            l_idx := u_idx - num_bits_mult + 1;

                            flat_mat_out(u_idx downto l_idx) <= mat_out(i,j);
                        end loop; 
                    end loop; 

                    done_mult <= '1'; 
                    matrix_state <= idle; 
            end case; 
        end if;
    end process;
end architecture ; -- arch
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use ieee.numeric_std.all;
use std.env.finish; 

entity matmult_tb is
end;

architecture bench of matmult_tb is

  component matmult
    generic (
      rst_polartiy  : std_logic;
      num_row       : integer;
      num_col       : integer;
      num_bits      : integer
    );
      port (
        clk           : in std_logic;
        rst           : in std_logic;
        do_mult       : in std_logic;
        flat_mat_lhs  : in signed((num_row*num_col*num_bits)-1 downto 0);
        flat_mat_rhs  : in signed((num_row*num_col*num_bits)-1 downto 0);
        done_mult     : out std_logic;
        flat_mat_out  : out signed(((num_row * num_col * ((num_bits*2) + num_row)) -1 ) downto 0)
    );
  end component;

    -- Clock period
    constant clk_period   : time := 5 ns;
    
    -- Generics
    constant rst_polartiy : std_logic := '0';
    constant num_row      : integer := 4;
    constant num_col      : integer := 4;
    constant num_bits     : integer := 16;

    -- Ports
    signal clk            : std_logic;
    signal rst            : std_logic;
    signal do_mult        : std_logic;
    signal flat_mat_lhs   : signed((num_row*num_col*num_bits)-1 downto 0);
    signal flat_mat_rhs   : signed((num_row*num_col*num_bits)-1 downto 0);
    signal flat_mat_out   : signed(((num_row * num_col * ((num_bits*2) + num_row)) -1 ) downto 0);
    signal done_mult      : std_logic;

    -- Type for defining constants 
    type matrix is array(0 to num_row-1, 0 to num_col-1) of signed(num_bits-1 downto 0);
   
    constant only_one     : signed(num_bits-1 downto 0) := x"0001";
    constant only_none    : signed(num_bits-1 downto 0) := x"0000"; 
    constant sixteen      : signed(num_bits-1 downto 0) := x"000F"; 
   
    constant identity_matrix : matrix :=(
       (only_one, only_none, only_none, only_none),
       (only_none, only_one, only_none, only_none),
       (only_none, only_none, only_one, only_none),
       (only_none, only_none, only_none, only_one)
      );

    constant some_other_matrix : matrix :=(
        (sixteen, sixteen, sixteen, sixteen),
        (sixteen, sixteen, sixteen, sixteen),
        (sixteen, sixteen, sixteen, sixteen),
        (sixteen, sixteen, sixteen, sixteen)
       );
 

    -- Function to Flatten Matrix need for test bench  
    function flatten_mat (mat : matrix) return signed is
        variable u_idx, l_idx : integer;   
        variable flat_mat     : signed((num_row*num_col*num_bits)-1 downto 0); 
    begin
        for i in 0 to num_row-1 loop 
            for j in 0 to num_col-1 loop
                u_idx := num_bits*(j + (num_col * i) + 1) - 1;    
                l_idx := u_idx - num_bits + 1;
                flat_mat(u_idx downto l_idx) := mat(i,j);
            end loop; 
        end loop;
        
        return flat_mat;
    end function;

begin

  matmult_inst : matmult
    generic map (
        rst_polartiy  => rst_polartiy,
        num_row       => num_row,
        num_col       => num_col,
        num_bits      => num_bits
    )
    port map (
        clk           => clk,
        rst           => rst,
        do_mult       => do_mult,
        flat_mat_lhs  => flat_mat_lhs,
        flat_mat_rhs  => flat_mat_rhs,
        flat_mat_out  => flat_mat_out,
        done_mult     => done_mult
    );

    clk_process : process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process clk_process;

    stimmy_process : process 
    begin 
        rst <= rst_polartiy; 
        
        do_mult <= '0';
        flat_mat_lhs <= flatten_mat(identity_matrix);
        flat_mat_rhs <= flatten_mat(some_other_matrix);

        wait for 20 *clk_period;

        rst <= not rst_polartiy; 

        do_mult <= '1';

        wait until done_mult = '1';
        do_mult <= '0';

        wait for 20*clk_period;

        report "we did it we did it we did it we did it !";
        finish;
        wait;
    end process; 
end;

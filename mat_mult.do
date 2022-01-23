vcom -work work -2008 ../rtl/matmult.vhd;
vcom -work work -2008 ../tb/matmult_tb.vhd; 

vsim -onfinish stop work.matmult_tb; 
add wave -r /*
run 5 ms;
wave zoom full;

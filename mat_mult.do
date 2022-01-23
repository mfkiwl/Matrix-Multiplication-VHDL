vcom -work work -2008 matmult.vhd;
vcom -work work -2008 matmult_tb.vhd; 

vsim -onfinish stop work.matmult_tb; 
add wave -r /*
run 5 ms;
wave zoom full;

set_property PACKAGE_PIN M19 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property IOSTANDARD LVCMOS33 [get_ports tx_out]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

set_property PACKAGE_PIN L17 [get_ports tx_out]
set_property PACKAGE_PIN K21 [get_ports rst_n]

create_clock -period 20.000 -name clk [get_ports clk]
set_false_path -from [get_ports rst_n]


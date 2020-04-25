###################################################################

# Created by write_sdc on Sun Apr  5 12:01:18 2020

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current uA
create_clock [get_ports clk]  -period 5  -waveform {0 2.5}
set_max_delay 5  -to [get_ports q]
set_max_delay 5  -from [list [get_ports {d[7]}] [get_ports {d[6]}] [get_ports {d[5]}]          \
[get_ports {d[4]}] [get_ports {d[3]}] [get_ports {d[2]}] [get_ports {d[1]}]    \
[get_ports {d[0]}] [get_ports clk] [get_ports reset]]

create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}]
create_clock -name cpuclk -period 14.245 [get_nets {cpuclk}]
report_timing -setup -max_paths 300 -max_common_paths 1
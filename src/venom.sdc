create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}]
report_timing -setup -max_paths 300 -max_common_paths 1
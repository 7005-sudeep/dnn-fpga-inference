# 1. Run synthesis
launch_runs synth_1
wait_on_run synth_1

# 2. Run implementation
launch_runs impl_1
wait_on_run impl_1

# 3. Check timing
open_run impl_1
report_timing_summary

# 4. Generate bitstream
source /home/user/dnn_fpga/generate_bitstream.tcl


## phys_opt_design — physically optimizes placement to reduce critical path delays
##route_design -directive AggressiveExplore — tries harder routing algorithms to find better paths
##phys_opt_design -directive AggressiveExplore — more aggressive physical optimization after routing

[Run these if WNS is negative after implementation]

# Step 1 — Run physical optimization
phys_opt_design

# Step 2 — Aggressive route optimization
route_design -directive AggressiveExplore

# Step 3 — Aggressive physical optimization
phys_opt_design -directive AggressiveExplore

# Step 4 — Check timing after optimization
report_timing_summary

# Step 5 — If still failing, reduce clock frequency in XDC
# Changed period from 10.000 (100MHz) to 40.000 (25MHz)
# Then re-run implementation
reset_run impl_1
launch_runs impl_1
wait_on_run impl_1
open_run impl_1
report_timing_summary

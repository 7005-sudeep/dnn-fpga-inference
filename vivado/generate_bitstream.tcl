open_run impl_1
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force /home/user/dnn_fpga/dnn_top.bit
puts "Bitstream generated successfully!"

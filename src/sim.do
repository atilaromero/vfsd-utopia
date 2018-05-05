vlib work
vmap work work

vlog -work work -mfcu -sv top.sv \
  utopia.sv \
  cpu_ifc.sv \
   \
  LookupTable.sv \
  squat.sv \
  utopia1_atm_rx.sv \
  utopia1_atm_tx.sv \
  test.sv \
   \
  definitions.sv \
  atm_cell.sv \
  environment.sv \
  config.sv \
  generator.sv \
  driver.sv \
  monitor.sv \
  scoreboard.sv \
  coverage.sv \
  cpu_driver.sv

vsim work.top -sv_seed 20 +ntb_random_seed=20

onfinish stop
run -all

coverage report -verbose

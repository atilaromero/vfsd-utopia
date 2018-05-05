# Relatorio

## Compilação

Inicialmente o repositório foi iniciado com o código-fonte original do módulo Utopia do livro *SystemVerilog for Verification*.

```
commit 703aa2bb8c6f5e1645d45fe6f1b6bd2731fdf0f8
    Initial commit
```

### Macro TxPorts is undefined

As primeiras tentativas de compilação utilizavam o comando vlog desta forma:

```
vlib work
vmap work work

vlog -work work -sv config.sv
vlog -work work -sv definitions.sv
...

```

Mas este procedimento falhava com o erro "Macro TxPorts is undefined":

```
ModelSim> do sim.do
# ** Warning: (vlib-34) Library already exists at "work".
# Modifying /opt/modelsim/modeltech/linux/../modelsim.ini
# Model Technology ModelSim SE vlog 10.1d Compiler 2012.11 Nov  1 2012
#
# Top level modules:
# 	--none--
# Model Technology ModelSim SE vlog 10.1d Compiler 2012.11 Nov  1 2012
# ** Error: definitions.sv(112): (vlog-2163) Macro `TxPorts is undefined.
# ** Error: /opt/modelsim/modeltech/linux/vlog failed.
# Error in macro ./sim.do line 5
# /opt/modelsim/modeltech/linux/vlog failed.
#     while executing
# "vlog -work work -sv definitions.sv"
```

A hipótese inicial considerada foi a de que os módulos estavam sendo
carregados na ordem errada.

As instruções de compilação foram reordenadas
para corresponder à ordem utilizada no
arquivo Makefile do projeto original. Mas isso não resolveu o problema.

Em seguida foi feita a tentativa de carregar todos os módulos em uma só linha de comando,
mas novamente essa não foi a solução definitiva:

```
ModelSim> do sim.do
# Model Technology ModelSim SE vlog 10.1d Compiler 2012.11 Nov  1 2012
# -- Compiling module top
# ** Error: definitions.sv(112): (vlog-2163) Macro `TxPorts is undefined.
# -- Compiling interface Utopia
# ** Error: definitions.sv(78): Typedef 'uniType' multiply defined.
# ** Error: definitions.sv(88): Typedef 'nniType' multiply defined.
# ** Error: definitions.sv(96): Typedef 'tstType' multiply defined.
# ** Error: definitions.sv(106): Typedef 'ATMCellType' multiply defined.
# ** Error: definitions.sv(112): (vlog-2163) Macro `TxPorts is undefined.
# ** Error: definitions.sv(114): Typedef 'CellCfgType' multiply defined.
# -- Compiling interface cpu_ifc
# ** Error: definitions.sv(78): Typedef 'uniType' multiply defined.
# ** Error: definitions.sv(88): Typedef 'nniType' multiply defined.
# ** Error: definitions.sv(96): Typedef 'tstType' multiply defined.
# ** Error: definitions.sv(106): Typedef 'ATMCellType' multiply defined.
# ** Error: definitions.sv(112): (vlog-2163) Macro `TxPorts is undefined.
# ** Error: definitions.sv(114): Typedef 'CellCfgType' multiply defined.
# -- Compiling interface LookupTable
# ** Error: definitions.sv(78): Typedef 'uniType' multiply defined.
# ** Error: definitions.sv(88): Typedef 'nniType' multiply defined.
# ** Error: definitions.sv(96): Typedef 'tstType' multiply defined.
# ** Error: definitions.sv(106): Typedef 'ATMCellType' multiply defined.
# ** Error: definitions.sv(112): (vlog-2163) Macro `TxPorts is undefined.
# ** Error: definitions.sv(114): Typedef 'CellCfgType' multiply defined.
# ** Error: definitions.sv(78): Typedef 'uniType' multiply defined.
# ** Error: definitions.sv(88): Typedef 'nniType' multiply defined.
# ** Error: definitions.sv(96): Typedef 'tstType' multiply defined.
# ** Error: definitions.sv(106): Typedef 'ATMCellType' multiply defined.
# ** Error: definitions.sv(112): (vlog-2163) Macro `TxPorts is undefined.
# ** Error: definitions.sv(114): Typedef 'CellCfgType' multiply defined.
# ** Error: test.sv(85): (vlog-2163) Macro `TxPorts is undefined.
# ** Error: test.sv(86): (vlog-2163) Macro `RxPorts is undefined.
# ** Error: cpu_ifc.sv(73): near "cpu_ifc": syntax error, unexpected IDENTIFIER, expecting class
# ** Error: test.sv(115): near "initial": syntax error, unexpected initial, expecting class
# ** Error: test.sv(153): End of source encountered before `endif directive closing region starting at file 'environment.sv' line 21.
# ** Error: /opt/modelsim/modeltech/linux/vlog failed.
# Error in macro ./sim.do line 13
# /opt/modelsim/modeltech/linux/vlog failed.
#     while executing
# "vlog -work work -sv top.sv \
#   utopia.sv \
#   cpu_ifc.sv \
#    \
#   LookupTable.sv \
#   squat.sv \
#   utopia1_atm_rx.sv \
#   utopia1_atm_tx.sv \
#   test.sv \..."
```

Após alguma pesquisa, o manual do ModelSim continha na seção do comando *vlog* a resposta ao problema:

> SystemVerilog requires that the default behavior of the vlog command is to treat each Verilog
> design file listed on the command line as a separate compilation unit. To treat multiple files
> listed within a single command line as a single compilation unit, use either the vlog -mfcu
> argument or the MultiFileCompilationUnit modelsim.ini file variable.

Com a inclusão da opção -mfcu, o problema da undefined macro foi solucionado, mas outro problema surgiu.

### An inout port (selected) must be a net type.

O compilador não estava aceitando o tipo da variável selected:

```
ModelSim> do sim.do
# ** Warning: (vlib-34) Library already exists at "work".
# Modifying /opt/modelsim/modeltech/linux/../modelsim.ini
# Model Technology ModelSim SE vlog 10.1d Compiler 2012.11 Nov  1 2012
# -- Compiling module top
# -- Compiling interface Utopia
# -- Compiling interface cpu_ifc
# -- Compiling interface LookupTable
# -- Compiling package top_sv_unit
# -- Compiling interface Utopia
# -- Compiling interface cpu_ifc
# -- Compiling interface LookupTable
# -- Compiling module squat
# -- Compiling module utopia1_atm_rx
# -- Compiling module utopia1_atm_tx
# -- Compiling program test
# ** Warning: atm_cell.sv(104): (vlog-LRM-2217) No default specified for 'prefix'.  Default must match the value specified in class at atm_cell.sv(62) for strict LRM compliance.
# ** Warning: atm_cell.sv(130): (vlog-LRM-2217) No default specified for 'to'.  Default must match the value specified in class at atm_cell.sv(64) for strict LRM compliance.
# ** Warning: atm_cell.sv(263): (vlog-LRM-2217) No default specified for 'prefix'.  Default must match the value specified in class at atm_cell.sv(227) for strict LRM compliance.
# ** Warning: atm_cell.sv(284): (vlog-LRM-2217) No default specified for 'to'.  Default must match the value specified in class at atm_cell.sv(229) for strict LRM compliance.
# ** Warning: config.sv(89): (vlog-LRM-2217) No default specified for 'prefix'.  Default must match the value specified in class at config.sv(64) for strict LRM compliance.
# ** Warning: scoreboard.sv(127): (vlog-LRM-2217) No default specified for 'prefix'.  Default must match the value specified in class at scoreboard.sv(42) for strict LRM compliance.
#
# Top level modules:
# 	top
# vsim work.top
# ** Note: (vsim-3812) Design is being optimized...
# ** Warning: atm_cell.sv(104): (vopt-LRM-2217) No default specified for 'prefix'.  Default must match the value specified in class at top.sv(62) for strict LRM compliance.
# ** Warning: atm_cell.sv(130): (vopt-LRM-2217) No default specified for 'to'.  Default must match the value specified in class at top.sv(64) for strict LRM compliance.
# ** Warning: atm_cell.sv(263): (vopt-LRM-2217) No default specified for 'prefix'.  Default must match the value specified in class at top.sv(227) for strict LRM compliance.
# ** Warning: atm_cell.sv(284): (vopt-LRM-2217) No default specified for 'to'.  Default must match the value specified in class at top.sv(229) for strict LRM compliance.
# ** Warning: config.sv(89): (vopt-LRM-2217) No default specified for 'prefix'.  Default must match the value specified in class at top.sv(64) for strict LRM compliance.
# ** Warning: scoreboard.sv(127): (vopt-LRM-2217) No default specified for 'prefix'.  Default must match the value specified in class at top.sv(42) for strict LRM compliance.
# ** Error: utopia.sv(84): An inout port (selected) must be a net type.
# ** Error: utopia.sv(84): An inout port (selected) must be a net type.
# ** Error: (vopt-2064) Compiler back-end code generation process terminated with code 2.
# Error loading design
Error loading design
```

Essa solução foi mais fácil, porque o Leonardo já havia solucionado isso no código dele:
```
--- a/utopia.sv
+++ b/utopia.sv
@@ -71,16 +71,17 @@ interface Utopia;

   logic [IfWidth-1:0] data;
   bit clk_in, clk_out;
-  bit soc, en, clav, valid, ready, reset, selected;
+  bit soc, en, clav, valid, ready, reset;
+  wire selected;
```

### Resumo das alterações

Assim, as modificações do código-fonte original foram:

```
commit 86f69b6dc5998f5aeb6078a3b7e2280b026309c8 (HEAD -> master)
Author: Atila Romero <atilaromero@gmail.com>
Date:   Sat May 5 04:46:28 2018 -0300

    new file:   sim.do
    option -mfcu
    selected to wire

diff --git a/sim.do b/sim.do
new file mode 100755
index 0000000..b46f5ef
--- /dev/null
+++ b/sim.do
@@ -0,0 +1,28 @@
+vlib work
+vmap work work
+
+vlog -work work -mfcu -sv top.sv \
+  utopia.sv \
+  cpu_ifc.sv \
+   \
+  LookupTable.sv \
+  squat.sv \
+  utopia1_atm_rx.sv \
+  utopia1_atm_tx.sv \
+  test.sv \
+   \
+  definitions.sv \
+  atm_cell.sv \
+  environment.sv \
+  config.sv \
+  generator.sv \
+  driver.sv \
+  monitor.sv \
+  scoreboard.sv \
+  coverage.sv \
+  cpu_driver.sv
+
+vsim work.top
+
+#do wave.do
+run 1000 ms
diff --git a/utopia.sv b/utopia.sv
index 92cee8a..5a2dbb5 100755
--- a/utopia.sv
+++ b/utopia.sv
@@ -71,7 +71,8 @@ interface Utopia;

   logic [IfWidth-1:0] data;
   bit clk_in, clk_out;
-  bit soc, en, clav, valid, ready, reset, selected;
+  bit soc, en, clav, valid, ready, reset;
+  wire selected;

   ATMCellType ATMcell;  // union of structures for ATM cells
 
```

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

### Resultado da simulação

Esta foi a saída da simulação, ainda sem nenhuma adição de novos testes:
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
# //  ModelSim SE 10.1d Nov  1 2012 Linux 4.15.0-kali2-amd64
# //
# //  Copyright 1991-2012 Mentor Graphics Corporation
# //  All Rights Reserved.
# //
# //  THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION
# //  WHICH IS THE PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS
# //  LICENSORS AND IS SUBJECT TO LICENSE TERMS.
# //
# Loading sv_std.std
# Loading work.top_sv_unit(fast)
# Loading work.top(fast)
# Loading work.Utopia(fast)
# Loading work.Utopia(fast__1)
# Loading work.squat(fast)
# Loading work.LookupTable(fast)
# Loading work.test(fast)
# ** Warning: (vsim-PLI-3691) environment.sv(138): Expected a system task, not a system function '$value$plusargs'.
#         Region: /top/t1/Environment::new/#ublk#1#137
# Simulation was run with conditional compilation settings of:
# `define TxPorts 4
# `define RxPorts 4
#
# Simulation run with default random seed
# Config: numRx=4, numTx=4, nCells=1 (0 0 1 0 ), enabled RX: 2
# Warning: In instance '\/top/t1/Coverage::CG_Forward ' the 'option.per_instance' is set to '0' (false). Assignment to members 'weight', 'goal' and 'comment' of 'option' would not have any effect.
# Memory: Loading ... CellFwd.FWD[0]=2
# CellFwd.FWD[1]=0
# CellFwd.FWD[2]=13
# CellFwd.FWD[3]=6
# CellFwd.FWD[4]=9
# CellFwd.FWD[5]=2
# CellFwd.FWD[6]=3
# CellFwd.FWD[7]=9
# CellFwd.FWD[8]=13
# CellFwd.FWD[9]=9
# CellFwd.FWD[10]=5
# CellFwd.FWD[11]=12
# CellFwd.FWD[12]=7
# CellFwd.FWD[13]=13
# CellFwd.FWD[14]=8
# CellFwd.FWD[15]=6
# CellFwd.FWD[16]=15
# CellFwd.FWD[17]=15
# CellFwd.FWD[18]=12
# CellFwd.FWD[19]=12
# CellFwd.FWD[20]=13
# CellFwd.FWD[21]=10
# CellFwd.FWD[22]=15
# CellFwd.FWD[23]=10
# CellFwd.FWD[24]=8
# CellFwd.FWD[25]=1
# CellFwd.FWD[26]=13
# CellFwd.FWD[27]=14
# CellFwd.FWD[28]=5
# CellFwd.FWD[29]=0
# CellFwd.FWD[30]=4
# CellFwd.FWD[31]=7
# CellFwd.FWD[32]=2
# CellFwd.FWD[33]=7
# CellFwd.FWD[34]=11
# CellFwd.FWD[35]=2
# CellFwd.FWD[36]=10
# CellFwd.FWD[37]=7
# CellFwd.FWD[38]=14
# CellFwd.FWD[39]=5
# CellFwd.FWD[40]=6
# CellFwd.FWD[41]=11
# CellFwd.FWD[42]=13
# CellFwd.FWD[43]=12
# CellFwd.FWD[44]=13
# CellFwd.FWD[45]=10
# CellFwd.FWD[46]=7
# CellFwd.FWD[47]=2
# CellFwd.FWD[48]=9
# CellFwd.FWD[49]=10
# CellFwd.FWD[50]=9
# CellFwd.FWD[51]=6
# CellFwd.FWD[52]=8
# CellFwd.FWD[53]=10
# CellFwd.FWD[54]=4
# CellFwd.FWD[55]=13
# CellFwd.FWD[56]=6
# CellFwd.FWD[57]=0
# CellFwd.FWD[58]=14
# CellFwd.FWD[59]=0
# CellFwd.FWD[60]=14
# CellFwd.FWD[61]=1
# CellFwd.FWD[62]=11
# CellFwd.FWD[63]=9
# CellFwd.FWD[64]=0
# CellFwd.FWD[65]=13
# CellFwd.FWD[66]=8
# CellFwd.FWD[67]=3
# CellFwd.FWD[68]=6
# CellFwd.FWD[69]=5
# CellFwd.FWD[70]=5
# CellFwd.FWD[71]=13
# CellFwd.FWD[72]=12
# CellFwd.FWD[73]=7
# CellFwd.FWD[74]=10
# CellFwd.FWD[75]=4
# CellFwd.FWD[76]=15
# CellFwd.FWD[77]=6
# CellFwd.FWD[78]=10
# CellFwd.FWD[79]=5
# CellFwd.FWD[80]=3
# CellFwd.FWD[81]=15
# CellFwd.FWD[82]=2
# CellFwd.FWD[83]=15
# CellFwd.FWD[84]=1
# CellFwd.FWD[85]=8
# CellFwd.FWD[86]=3
# CellFwd.FWD[87]=1
# CellFwd.FWD[88]=6
# CellFwd.FWD[89]=1
# CellFwd.FWD[90]=9
# CellFwd.FWD[91]=8
# CellFwd.FWD[92]=14
# CellFwd.FWD[93]=0
# CellFwd.FWD[94]=8
# CellFwd.FWD[95]=8
# CellFwd.FWD[96]=11
# CellFwd.FWD[97]=4
# CellFwd.FWD[98]=12
# CellFwd.FWD[99]=15
# CellFwd.FWD[100]=1
# CellFwd.FWD[101]=11
# CellFwd.FWD[102]=14
# CellFwd.FWD[103]=6
# CellFwd.FWD[104]=13
# CellFwd.FWD[105]=4
# CellFwd.FWD[106]=6
# CellFwd.FWD[107]=9
# CellFwd.FWD[108]=0
# CellFwd.FWD[109]=2
# CellFwd.FWD[110]=9
# CellFwd.FWD[111]=8
# CellFwd.FWD[112]=1
# CellFwd.FWD[113]=11
# CellFwd.FWD[114]=2
# CellFwd.FWD[115]=2
# CellFwd.FWD[116]=12
# CellFwd.FWD[117]=12
# CellFwd.FWD[118]=13
# CellFwd.FWD[119]=11
# CellFwd.FWD[120]=3
# CellFwd.FWD[121]=8
# CellFwd.FWD[122]=15
# CellFwd.FWD[123]=14
# CellFwd.FWD[124]=4
# CellFwd.FWD[125]=1
# CellFwd.FWD[126]=10
# CellFwd.FWD[127]=15
# CellFwd.FWD[128]=11
# CellFwd.FWD[129]=15
# CellFwd.FWD[130]=9
# CellFwd.FWD[131]=10
# CellFwd.FWD[132]=5
# CellFwd.FWD[133]=9
# CellFwd.FWD[134]=0
# CellFwd.FWD[135]=14
# CellFwd.FWD[136]=7
# CellFwd.FWD[137]=8
# CellFwd.FWD[138]=13
# CellFwd.FWD[139]=7
# CellFwd.FWD[140]=14
# CellFwd.FWD[141]=2
# CellFwd.FWD[142]=12
# CellFwd.FWD[143]=15
# CellFwd.FWD[144]=5
# CellFwd.FWD[145]=10
# CellFwd.FWD[146]=14
# CellFwd.FWD[147]=3
# CellFwd.FWD[148]=14
# CellFwd.FWD[149]=0
# CellFwd.FWD[150]=13
# CellFwd.FWD[151]=10
# CellFwd.FWD[152]=10
# CellFwd.FWD[153]=9
# CellFwd.FWD[154]=4
# CellFwd.FWD[155]=6
# CellFwd.FWD[156]=12
# CellFwd.FWD[157]=14
# CellFwd.FWD[158]=9
# CellFwd.FWD[159]=3
# CellFwd.FWD[160]=8
# CellFwd.FWD[161]=12
# CellFwd.FWD[162]=11
# CellFwd.FWD[163]=13
# CellFwd.FWD[164]=4
# CellFwd.FWD[165]=8
# CellFwd.FWD[166]=8
# CellFwd.FWD[167]=10
# CellFwd.FWD[168]=14
# CellFwd.FWD[169]=10
# CellFwd.FWD[170]=14
# CellFwd.FWD[171]=3
# CellFwd.FWD[172]=0
# CellFwd.FWD[173]=2
# CellFwd.FWD[174]=9
# CellFwd.FWD[175]=6
# CellFwd.FWD[176]=12
# CellFwd.FWD[177]=8
# CellFwd.FWD[178]=5
# CellFwd.FWD[179]=2
# CellFwd.FWD[180]=14
# CellFwd.FWD[181]=15
# CellFwd.FWD[182]=1
# CellFwd.FWD[183]=8
# CellFwd.FWD[184]=4
# CellFwd.FWD[185]=13
# CellFwd.FWD[186]=1
# CellFwd.FWD[187]=13
# CellFwd.FWD[188]=9
# CellFwd.FWD[189]=12
# CellFwd.FWD[190]=2
# CellFwd.FWD[191]=13
# CellFwd.FWD[192]=13
# CellFwd.FWD[193]=8
# CellFwd.FWD[194]=1
# CellFwd.FWD[195]=12
# CellFwd.FWD[196]=6
# CellFwd.FWD[197]=14
# CellFwd.FWD[198]=2
# CellFwd.FWD[199]=4
# CellFwd.FWD[200]=3
# CellFwd.FWD[201]=11
# CellFwd.FWD[202]=13
# CellFwd.FWD[203]=4
# CellFwd.FWD[204]=5
# CellFwd.FWD[205]=10
# CellFwd.FWD[206]=15
# CellFwd.FWD[207]=9
# CellFwd.FWD[208]=14
# CellFwd.FWD[209]=15
# CellFwd.FWD[210]=8
# CellFwd.FWD[211]=8
# CellFwd.FWD[212]=12
# CellFwd.FWD[213]=6
# CellFwd.FWD[214]=10
# CellFwd.FWD[215]=10
# CellFwd.FWD[216]=7
# CellFwd.FWD[217]=5
# CellFwd.FWD[218]=6
# CellFwd.FWD[219]=10
# CellFwd.FWD[220]=12
# CellFwd.FWD[221]=5
# CellFwd.FWD[222]=12
# CellFwd.FWD[223]=3
# CellFwd.FWD[224]=15
# CellFwd.FWD[225]=13
# CellFwd.FWD[226]=7
# CellFwd.FWD[227]=11
# CellFwd.FWD[228]=10
# CellFwd.FWD[229]=14
# CellFwd.FWD[230]=7
# CellFwd.FWD[231]=14
# CellFwd.FWD[232]=0
# CellFwd.FWD[233]=13
# CellFwd.FWD[234]=13
# CellFwd.FWD[235]=6
# CellFwd.FWD[236]=10
# CellFwd.FWD[237]=4
# CellFwd.FWD[238]=4
# CellFwd.FWD[239]=12
# CellFwd.FWD[240]=11
# CellFwd.FWD[241]=8
# CellFwd.FWD[242]=5
# CellFwd.FWD[243]=11
# CellFwd.FWD[244]=5
# CellFwd.FWD[245]=14
# CellFwd.FWD[246]=5
# CellFwd.FWD[247]=4
# CellFwd.FWD[248]=12
# CellFwd.FWD[249]=14
# CellFwd.FWD[250]=8
# CellFwd.FWD[251]=12
# CellFwd.FWD[252]=14
# CellFwd.FWD[253]=11
# CellFwd.FWD[254]=10
# CellFwd.FWD[255]=0
# Verifying ...Verified
# @25705: Gen2: UNI id:4 GFC=8, VPI=d9, VCI=dec0, CLP=1, PT=0, HEC=25, Payload[0]=e4
# @25705: Gen2: 8d 9d ec 08 25 e4 a3 14 7f aa b9 b7 3f 19 4b 4d 71 1c 26 01 d5 b8 a4 4a c4 a4 c6 19 7d 93 c9 84 92 78 bf 00 ed f2 43 f1 88 59 4c a4 67 b0 23 f9 e6 10 6e 01 a7
#
# @25705: Drv2: UNI id:4 GFC=8, VPI=d9, VCI=dec0, CLP=1, PT=0, HEC=25, Payload[0]=e4
# @25705: Drv2: 8d 9d ec 08 25 e4 a3 14 7f aa b9 b7 3f 19 4b 4d 71 1c 26 01 d5 b8 a4 4a c4 a4 c6 19 7d 93 c9 84 92 78 bf 00 ed f2 43 f1 88 59 4c a4 67 b0 23 f9 e6 10 6e 01 a7
#
# Sending cell: 8d 9d ec 08 25 e4 a3 14 7f aa b9 b7 3f 19 4b 4d 71 1c 26 01 d5 b8 a4 4a c4 a4 c6 19 7d 93 c9 84 92 78 bf 00 ed f2 43 f1 88 59 4c a4 67 b0 23 f9 e6 10 6e 01 a7
# @26245: Scb save: VPI=d9, Forward=0101
# @26245: Scb save: NNI id:5 VPI=0d9, VCI=dec0, CLP=1, PT=0, HEC=25, Payload[0]=e4
# @26245: Scb save: 0d 9d ec 08 25 e4 a3 14 7f aa b9 b7 3f 19 4b 4d 71 1c 26 01 d5 b8 a4 4a c4 a4 c6 19 7d 93 c9 84 92 78 bf 00 ed f2 43 f1 88 59 4c a4 67 b0 23 f9 e6 10 6e 01 a7
#
# @26825: Mon2: NNI id:6 VPI=0d9, VCI=dec0, CLP=1, PT=0, HEC=25, Payload[0]=e4
# @26825: Mon2: 0d 9d ec 08 25 e4 a3 14 7f aa b9 b7 3f 19 4b 4d 71 1c 26 01 d5 b8 a4 4a c4 a4 c6 19 7d 93 c9 84 92 78 bf 00 ed f2 43 f1 88 59 4c a4 67 b0 23 f9 e6 10 6e 01 a7
#
# @26825: Scb check: NNI id:6 VPI=0d9, VCI=dec0, CLP=1, PT=0, HEC=25, Payload[0]=e4
# @26825: Scb check: 0d 9d ec 08 25 e4 a3 14 7f aa b9 b7 3f 19 4b 4d 71 1c 26 01 d5 b8 a4 4a c4 a4 c6 19 7d 93 c9 84 92 78 bf 00 ed f2 43 f1 88 59 4c a4 67 b0 23 f9 e6 10 6e 01 a7
#
# @26825: Match found for cell
# @26825: Coverage: src=2. FWD=0101
# @26825: Mon0: NNI id:7 VPI=0d9, VCI=dec0, CLP=1, PT=0, HEC=25, Payload[0]=e4
# @26825: Mon0: 0d 9d ec 08 25 e4 a3 14 7f aa b9 b7 3f 19 4b 4d 71 1c 26 01 d5 b8 a4 4a c4 a4 c6 19 7d 93 c9 84 92 78 bf 00 ed f2 43 f1 88 59 4c a4 67 b0 23 f9 e6 10 6e 01 a7
#
# @26825: Scb check: NNI id:7 VPI=0d9, VCI=dec0, CLP=1, PT=0, HEC=25, Payload[0]=e4
# @26825: Scb check: 0d 9d ec 08 25 e4 a3 14 7f aa b9 b7 3f 19 4b 4d 71 1c 26 01 d5 b8 a4 4a c4 a4 c6 19 7d 93 c9 84 92 78 bf 00 ed f2 43 f1 88 59 4c a4 67 b0 23 f9 e6 10 6e 01 a7
#
# @26825: Match found for cell
# @26825: Coverage: src=0. FWD=0101
# @36245: End of simulation, 0 errors, 0 warnings
# @36245: top.t1.Scoreboard.wrap_up 2 expected cells, 2 actual cells received
```

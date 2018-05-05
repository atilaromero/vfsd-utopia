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

Esta foi a saída da simulação, ainda sem nenhuma adição de novos testes (algumas linhas de debug do tipo *CellFwd* foram suprimidas):
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
...
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

## Tarefas

### Coverage

Para aumentar coverage, foi incluida no modulo test.sv duas classes, MyCover e MyCover_cbs.
A classe MyCover contém as o coveragegroup e a classe MyCover_cbs é o gancho para que o driver chame o callback.

A seguir as classes e a inclusão do gancho no driver no módulo principal do test.sv:
```
class MyCover;
  bit [3:0] GFC;

  covergroup GFC_cover;
    coverpoint GFC;
  endgroup: GFC_cover


  function new;
    GFC_cover = new;
  endfunction : new

   // Sample input data
   function void sample(input bit [3:0] GFC);
      this.GFC = GFC;
      GFC_cover.sample();
   endfunction : sample

endclass: MyCover

class MyCover_cbs extends Driver_cbs;
  MyCover cov;
  Config cfg;

  function new(MyCover cov, ref Config cfg);
    this.cov = cov;
    this.cfg = cfg;
  endfunction : new

  virtual task post_tx(input Driver drv,
         input UNI_cell c);
    cov.sample(c.GFC);
  endtask : post_tx

endclass : MyCover_cbs

initial begin
  env = new(Rx, Tx, NumRx, NumTx, mif);

  env.gen_cfg();
  env.build();

  begin
     automatic MyCover cov = new;
     automatic MyCover_cbs cbs = new(cov, env.cfg);
     automatic Driver drv[] = env.drv;
     foreach (drv[i]) drv[i].cbsq.push_back(cbs);  // Add cov to every monitor
  end

  env.run();
  env.wrap_up();
end
```

Para visualizar o relatório de coverage é preciso rodar:
```
vsim -c
> do sim.do
> coverage report -verbose
```

## Assertion

A assertion incluída foi colocada no próprio post_tx, porque o callback já estava pronto.
Outra opção seria criar um callback só para a assertion.

Sem a constraint que será descrita mais a frente, ou se ela for modificada,
este assertion irá aumentar o nErrors counter.

```
virtual task post_tx(input Driver drv,
       input UNI_cell c);
  cov.sample(c.GFC);
  assert(c.GFC[0]==0) else
  begin
    $display("GFC[0] != 0 (No idea if that is bad or not...)");
    cfg.nErrors++;
  end
endtask : post_tx

```

## Constraint

Para incluir a constraint, foi criada a classe My_cell extends UNI_cell, para
ser usada como blueprint nos generators.

```
class My_cell extends UNI_cell;
  constraint myConstraint {
    GFC[0] == 0;
  }
endclass: My_cell

foreach(env.gen[i]) begin
  automatic My_cell blueprint = new;
  env.gen[i].blueprint = blueprint;
end

```

# Finalização

Além das alterações descritas, foram suprimidas mensagens de debug, que dificultavam
a visualização das mensagens do início da simulação.

As três modificações de teste (coverage, assertion e constraint) puderam ser
incluídas diretamente no test.sv, sem necessidade de alteração de outros módulos.
Isso mostra o quanto os design patterns de blueprint e callbacks são úteis para
concentrar a personalização de testes em um único local, o que favorece o
reaproveitamento de código, pois evita que eventos particulares de teste poluam
módulos como generator, driver e scoreboard.

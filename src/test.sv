/**********************************************************************
 * Utopia ATM testbench
 *
 * To simulate this example with stimulus, invoke simulation on
 * 10.00.00_example_top.sv.  This top-level file includes all of the
 * example files in chapter 10.
 *
 * Author: Lee Moore, Stuart Sutherland
 *
 * (c) Copyright 2003, Sutherland HDL, Inc. *** ALL RIGHTS RESERVED ***
 * www.sutherland-hdl.com
 *
 * This example is based on an example from Janick Bergeron's
 * Verification Guild[1].  The original example is a non-synthesizable
 * behavioral model written in Verilog-1995 of a quad Asynchronous
 * Transfer Mode (ATM) user-to-network interface and forwarding node.
 * This example modifies the original code to be synthesizable, using
 * SystemVerilog constructs.  Also, the model has been made to be
 * configurable, so that it can be easily scaled from a 4x4 quad switch
 * to a 16x16 switch, or any other desired configuration.  The example,
 * including a nominal test bench, is partitioned into 8 files,
 * numbered 10.xx.xx_example_10-1.sv through 10-8.sv (where xx
 * represents section and subsection numbers in the book "SystemVerilog
 * for Design" (first edition).  The file 10.00.00_example_top.sv
 * includes all of the other files.  Simulation only needs to be
 * invoked on this one file.  Conditional compilation switches (`ifdef)
 * is used to compile the examples for simulation or for synthesis.
 *
 * [1] The Verification Guild is an independent e-mail newsletter and
 * moderated discussion forum on hardware verification.  Information on
 * the original Verification Guild example can be found at
 * www.janick.bergeron.com/guild/project.html.
 *
 * Used with permission in the book, "SystemVerilog for Design"
 *  By Stuart Sutherland, Simon Davidmann, and Peter Flake.
 *  Book copyright: 2003, Kluwer Academic Publishers, Norwell, MA, USA
 *  www.wkap.il, ISBN: 0-4020-7530-8
 *
 * Revision History:
 *   1.00 15 Dec 2003 -- original code, as included in book
 *   1.01 10 Jul 2004 -- cleaned up comments, added expected results
 *                       to output messages
 *   1.10 21 Jul 2004 -- corrected errata as printed in the book
 *                       "SystemVerilog for Design" (first edition) and
 *                       to bring the example into conformance with the
 *                       final Accellera SystemVerilog 3.1a standard
 *                       (for a description of changes, see the file
 *                       "errata_SV-Design-book_26-Jul-2004.txt")
 *
 * Caveat: Expected results displayed for this code example are based
 * on an interpretation of the SystemVerilog 3.1 standard by the code
 * author or authors.  At the time of writing, official SystemVerilog
 * validation suites were not available to validate the example.
 *
 * RIGHT TO USE: This code example, or any portion thereof, may be
 * used and distributed without restriction, provided that this entire
 * comment block is included with the example.
 *
 * DISCLAIMER: THIS CODE EXAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY
 * OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
 * TO WARRANTIES OF MERCHANTABILITY, FITNESS OR CORRECTNESS. IN NO
 * EVENT SHALL THE AUTHOR OR AUTHORS BE LIABLE FOR ANY DAMAGES,
 * INCLUDING INCIDENTAL OR CONSEQUENTIAL DAMAGES, ARISING OUT OF THE
 * USE OF THIS CODE.
 *********************************************************************/

// The following include file listed in the book text is in an example
// file that is included by 10.00.00_example_top.sv
//`include "methods.sv"

`include "definitions.sv"  // include external definitions

program automatic test
  #(parameter int NumRx = 4, parameter int NumTx = 4)
   (Utopia.TB_Rx Rx[0:NumRx-1],
    Utopia.TB_Tx Tx[0:NumTx-1],
    cpu_ifc.Test mif,
    input logic rst, clk);

  // Miscellaneous control interfaces
  logic Initialized;

  initial begin
    $display("Simulation was run with conditional compilation settings of:");
    $display("`define TxPorts %0d", `TxPorts);
    $display("`define RxPorts %0d", `RxPorts);
    `ifdef FWDALL
      $display("`define FWDALL");
    `endif
    `ifdef SYNTHESIS
      $display("`define SYNTHESIS");
    `endif
    $display("");
  end

`include "environment.sv"
  Environment env;

// class Driver_cbs_drop extends Driver_cbs;
//  virtual task pre_tx(input ATM_cell cell, ref bit drop);
//     // Randomly drop 1 out of every 100 transactions
//     drop = ($urandom_range(0,99) == 0);
//   endtask
// endclass

// class Config_10_cells extends Config;
//    constraint ten_cells {nCells == 10; }

//    function new(input int NumRx,NumTx);
//       super.new(NumRx,NumTx);
//    endfunction : new
// endclass : Config_10_cells

class MyCover;
// copy of UNI_cell specs:
// rand bit        [3:0]  GFC;
// rand bit        [7:0]  VPI;
// rand bit        [15:0] VCI;
// rand bit               CLP;
// rand bit        [2:0]  PT;
//    bit        [7:0]  HEC;
// rand bit [0:47] [7:0]  Payload;
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


  // virtual task pre_tx(input Driver drv,
  //        input UNI_cell c,
  //        inout bit drop);
  // endtask : pre_tx

  virtual task post_tx(input Driver drv,
         input UNI_cell c);
    cov.sample(c.GFC);
    assert(c.GFC[0]==0) else
    begin
      $display("GFC[0] != 0 (No idea if that is bad or not...)");
      cfg.nErrors++;
    end
  endtask : post_tx

endclass : MyCover_cbs


  initial begin
    env = new(Rx, Tx, NumRx, NumTx, mif);

//      begin // Just simulate for 10 cells
// 	Config_10_cells c10 = new(NumRx,NumTx);
// 	env.cfg = c10;
//      end

    env.gen_cfg();
//     env.cfg.nCells = 100_000;
//     $display("nCells = 100_000");
    env.build();

//     begin             // Create error injection callback
//       Driver_cbs_drop dcd = new();
//       env.drv.cbs.push_back(dcd); // Put into driver's Q
//     end

    begin
       automatic MyCover cov = new;
       automatic MyCover_cbs cbs = new(cov, env.cfg);
       automatic Driver drv[] = env.drv;
       foreach (drv[i]) drv[i].cbsq.push_back(cbs);  // Add cov to every monitor
    end

    env.run();
    env.wrap_up();
  end

endprogram // test

`timescale 1 ns / 1 ps

/*******************************************************************************
Copyright 2018-2020 Ryan Clarke

Licensed under the Solderpad Hardware License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License. You may obtain a
copy of the License at

    https://solderpad.org/licenses/SHL-2.0/

Unless required by applicable law or agreed to in writing, software, hardware
and materials distributed under the License are distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.
*******************************************************************************/

/*******************************************************************************
Module Name : debounce
File Name   : debounce.v
Project     : Kit-3 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose     : Button synchronizer and debouncer.
*******************************************************************************/


module debounce
(
    input  wire i_clk,          // core clock

    input  wire i_in,           // input
    output wire o_debounce      // debounced output
);


/*  INPUT SYNCHRONIZER ********************************************************/

wire sync;

input_sync input_sync
(
    .i_clk  (i_clk),
    .i_async(i_in),
    .o_sync (sync)
);


/* DEBOUNCE COUNTER ***********************************************************/

reg  [16:0] count_reg;
wire [16:0] count_ns;

// only increment if output doesn't equal input
assign count_ns = (debounce_ff != sync) ? count_reg + 17'd1 : 17'd0;

initial count_reg = 17'd0;
always @(posedge i_clk)
    count_reg <= count_ns;


/* DEBOUNCE OUTPUT ************************************************************/

reg  debounce_ff;
wire debounce_ns;

assign debounce_ns = (& count_reg) ? ~debounce_ff : debounce_ff;

initial debounce_ff = 1'b0;
always @(posedge i_clk)
    debounce_ff <= debounce_ns;

assign o_debounce = debounce_ff;


/******************************************************************************/

endmodule

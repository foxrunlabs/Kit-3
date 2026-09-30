`timescale 1 ns / 1 ps

/*******************************************************************************
Copyright 2020 Ryan Clarke

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
Module Name : kit3_top
File Name   : kit3_top.v
Project     : Kit-3 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose     : Top module.
*******************************************************************************/

module kit3_top
(
    input  wire       CLK100MHZ,        // Nexys 4 DDR clock
    input  wire       CPU_RESETN,       // active-low asynchronous reset
    
    output wire [3:0] VGA_R,            // red
    output wire [3:0] VGA_G,            // green
    output wire [3:0] VGA_B,            // blue
    output wire       VGA_HS,           // horizontal sync
    output wire       VGA_VS,           // vertical sync

    input  wire       PS2_CLK,          // open-drain clock
    input  wire       PS2_DATA          // open-drain data
);


/* CLOCK GENERATOR ************************************************************/

wire clk_core;
wire clk_pixel;

clock_gen clock_gen
(
    .i_clk      (CLK100MHZ),
    .o_clk_core (clk_core),
    .o_clk_pixel(clk_pixel)
);


/* RESET BUTTON ***************************************************************/

wire reset;

debounce debounce
(
    .i_clk     (clk_core),
    .i_in      (~CPU_RESETN),
    .o_debounce(reset)
);


/* KIT-3 **********************************************************************/

kit3 kit3
(
    .i_clk_core (clk_core),
    .i_clk_pixel(clk_pixel),
    .i_reset    (reset),
    .i_ps2_clk  (PS2_CLK),
    .i_ps2_data (PS2_DATA),
    .o_rgb      ({VGA_R, VGA_G, VGA_B}),
    .o_hsync    (VGA_HS),
    .o_vsync    (VGA_VS)
);


/******************************************************************************/

endmodule

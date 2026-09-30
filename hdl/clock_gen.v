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
Module Name : clock_gen
File Name   : clock_gen.v
Project     : Kit-3 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose     : Generates a 7.875 MHz core clock and 31.5 MHz pixel clock from the
              100 MHz Nexys 4 DDR clock.
*******************************************************************************/


module clock_gen
(
    input  wire i_clk,          // Nexys4 DDR 100 MHz clock

    output wire o_clk_core,     // core clock
    output wire o_clk_pixel     // pixel clock
);


/* INPUT BUFFER ***************************************************************/

wire clk_buf;

IBUF clock_ibuf
(
    .I(i_clk),
    .O(clk_buf)
);


/* CLOCK MANAGER **************************************************************/

wire feedback;
wire clk_core;
wire clk_pixel;

MMCME2_BASE
#(
    .BANDWIDTH         ("OPTIMIZED"),
    .CLKFBOUT_MULT_F   (7.875),
    .CLKFBOUT_PHASE    (0.000),
    .CLKIN1_PERIOD     (10.000),
    .CLKOUT0_DIVIDE_F  (100.000),
    .CLKOUT0_DUTY_CYCLE(0.50),
    .CLKOUT0_PHASE     (0.000),
    .CLKOUT1_DIVIDE    (25),
    .CLKOUT1_DUTY_CYCLE(0.50),
    .CLKOUT1_PHASE     (0.000),
    .DIVCLK_DIVIDE     (1),
    .REF_JITTER1       (0.0)
)
clock_divider
(
    .CLKIN1   (clk_buf),
    .RST      (1'b0),
    .PWRDWN   (1'b0),
    .CLKOUT0  (clk_core),
    .CLKOUT0B (),
    .CLKOUT1  (clk_pixel),
    .CLKOUT1B (),
    .CLKOUT2  (),
    .CLKOUT2B (),
    .CLKOUT3  (),
    .CLKOUT3B (),
    .CLKOUT4  (),
    .CLKOUT5  (),
    .CLKOUT6  (),
    .CLKFBOUT (feedback),
    .CLKFBOUTB(),
    .CLKFBIN  (feedback),
    .LOCKED   ()
);


/* OUTPUT BUFFERS *************************************************************/

BUFG core_clock_bufg
(
    .I(clk_core),
    .O(o_clk_core)
);

BUFG pixel_clock_bufg
(
    .I(clk_pixel),
    .O(o_clk_pixel)
);


/******************************************************************************/

endmodule

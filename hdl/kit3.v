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
Module Name : kit3
File Name   : kit3.v
Project     : Kit-3 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose     : Wrapper module for the Kit-3 to allow for use with Verilator.
*******************************************************************************/


module kit3
(
    input  wire        i_clk_core,      // core clock
    input  wire        i_clk_pixel,     // pixel clock
    input  wire        i_reset,

    output wire [11:0] o_rgb,           // RGB444 output
    output wire        o_hsync,         // horizontal sync
    output wire        o_vsync          // vertical sync
);


/* CPU ************************************************************************/

wire [15:0] addr_bus;               // 16-bit address bus
wire [7:0]  dout_bus;               // 8-bit data output bus
wire [7:0]  din_bus;                // 8-bit data input bus
wire        cpu_we;                 // write enable

cpu_65c02 cpu
(
    .clk  (i_clk_core),

    .reset(i_reset),

    .AB   (addr_bus),
    .DI   (din_bus),
    .DO   (dout_bus),
    .WE   (cpu_we),

    .IRQ  (1'b0),
    .NMI  (1'b0),
    .RDY  (1'b1)
);


/* ADDRESS BUS DECODER ********************************************************/

localparam IO_SEGMENT = 8'h02;

wire       io_en;
reg        io_en_ff;
wire [7:0] display_dout;

wire       ram_en;
wire [7:0] ram_dout;

assign io_en  = (addr_bus[15:8] == IO_SEGMENT);
assign ram_en = ~io_en;

initial io_en_ff = 1'b0;
always @(posedge i_clk_core)
    io_en_ff <= io_en;

// data input bus multiplexer
assign din_bus = (io_en_ff) ? display_dout : ram_dout;


/* SYSTEM RAM *****************************************************************/

ram ram
(
    .i_clk (i_clk_core),

    .i_en  (ram_en),
    .i_we  (cpu_we),
    
    .i_addr(addr_bus),
    .i_data(dout_bus),
    .o_data(ram_dout)
);


/* DISPLAY ********************************************************************/

wire [2:0] display_reg;

assign display_reg = addr_bus[2:0];

vga vga
(
    .i_clk_core (i_clk_core),
    .i_clk_pixel(i_clk_pixel),

    .i_en       (io_en),
    .i_we       (cpu_we),
    .i_regsel   (display_reg),
    .i_data     (dout_bus),
    .o_data     (display_dout),
    
    .o_hsync    (o_hsync),
    .o_vsync    (o_vsync),
    .o_rgb      (o_rgb)
);


/******************************************************************************/

endmodule

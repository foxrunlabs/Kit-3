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
Module Name : ram
File Name   : ram.v
Project     : Kit-3 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose     : 64 KiB single port RAM initialized with a .MEM file.
*******************************************************************************/


module ram
(
    input wire        i_clk,        // clock
    input wire        i_en,         // enable
    input wire        i_we,         // write enable

    input wire [15:0] i_addr,       // address bus

    input wire [7:0]  i_data,       // data input bus
    output reg [7:0]  o_data        // data output bus
);


/* SINGLE PORT RAM ************************************************************/

reg [7:0] ram_reg [0:65535];

initial $readmemh("bootload.mem", ram_reg);
always @(posedge i_clk) begin
    if(i_en) begin
        if(i_we)
            ram_reg[i_addr] <= i_data;
        
        o_data <= ram_reg[i_addr];
    end
end


/******************************************************************************/

endmodule

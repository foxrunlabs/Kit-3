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
Module Name : vram
File Name   : vram.v
Project     : Kit-3 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose     : 4 KiB dual port RAM for the display module.
*******************************************************************************/


module vram
(
    input wire        i_clk_a,
    input wire        i_en_a,
    input wire        i_we_a,

    input wire [11:0] i_addr_a,
    input wire [7:0]  i_data_a,
    output reg [7:0]  o_data_a,

    input wire        i_clk_b,
    input wire        i_en_b,
    input wire        i_we_b,

    input wire [11:0] i_addr_b,
    input wire [7:0]  i_data_b,
    output reg [7:0]  o_data_b
);


/* DUAL PORT RAM **************************************************************/

reg [7:0] ram_reg [0:4095];

// Port A (read first)
always @(posedge i_clk_a) begin
    if(i_en_a) begin
        if(i_we_a) begin
            ram_reg[i_addr_a] <= i_data_a;
        end
        
        o_data_a <= ram_reg[i_addr_a];
    end
end

// Port B (read first)
always @(posedge i_clk_b) begin
    if(i_en_b) begin
        if(i_we_b) begin
            ram_reg[i_addr_b] <= i_data_b;
        end
    
        o_data_b <= ram_reg[i_addr_b];
    end
end


/******************************************************************************/

endmodule

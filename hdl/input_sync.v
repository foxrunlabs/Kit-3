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
Module Name : input_sync
File Name   : input_sync.v
Project     : Kit-3 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose     : Input synchonizer for crossing clock domains.
*******************************************************************************/

module input_sync
#(
    parameter INITIAL = 1'b0
)
(
    input  wire i_clk,

    input  wire i_async,
    output  reg o_sync
);


/*  SYNCHRONIZER **************************************************************/

reg async_ff;

initial async_ff = INITIAL;
always @(posedge i_clk) begin
    async_ff <= i_async;
    o_sync   <= async_ff;
end


/******************************************************************************/

endmodule

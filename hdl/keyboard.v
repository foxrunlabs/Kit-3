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
Module Name : keyboard
File Name   : keyboard.v
Project     : Kit-3 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose     : PS/2 keyboard controller for the Kit-3 8-bit Computer.
*******************************************************************************/

// TODO: implement a control interface, which bypasses the PS/2-to-ASCII
// module (disables it), so that we can write and read to the PS/2 keyboard.


module keyboard
    (
    input  wire       i_clk,        // CPU clock
    
    input  wire       i_en,         // controller bus select
    input  wire       i_regsel,     // 1-bit register select
    output reg  [7:0] o_data,       // 8-bit register data output
    
    input  wire       i_ps2_clk,    // PS/2 clock
    input  wire       i_ps2_data    // PS/2 serial data
    );


/* CONTROLLER REGISTERS *******************************************************/

localparam STATUS = 1'b0,
           KEY    = 1'b1;

initial o_data = 8'h00;
always @(posedge i_clk) begin
    if(i_en) begin
        case(i_regsel)
            STATUS:  o_data <= {7'b0000_000, data_full_ff};
            KEY:     o_data <= key_reg;
            default: o_data <= 8'h00;
        endcase
    end
end
 

/* PS/2 INPUT SYNCHRONIZERS AND CLOCK FALLING EDGE DETECTOR *******************/

wire ps2_clk;
reg  ps2_clk_prev_ff;
wire ps2_clk_fe;
wire ps2_data;

input_sync
#(
    .INITIAL(1'b1)
)
input_sync
(
    .i_clk  (i_clk),
    .i_async(i_ps2_clk),
    .o_sync (ps2_clk)
);

initial ps2_clk_prev_ff = 1'b1;
always @(posedge i_clk) begin
    ps2_clk_prev_ff <= #1 ps2_clk;
end

// PS/2 clock falling edge detector
assign ps2_clk_fe = ps2_clk_prev_ff & ~ps2_clk;

input_sync
#(
    .INITIAL(1'b1)
)
input_sync
(
    .i_clk  (i_clk),
    .i_async(i_ps2_data),
    .o_sync (ps2_data)
);


/* PS/2 RECEIVER **************************************************************/

wire       rx_en;           // PS/2 RX enable
wire       rx_stb;          // PS/2 RX complete strobe
wire [7:0] rx_dout;         // PS/2 RX 8-bit data output
wire       rx_parity_err;   // PS/2 RX parity error flag

// RX disabled if TX busy or RX buffer full
assign rx_en = ~data_full_ff;

ps2_rx ps2_rx
(
    .i_clk           (i_clk),
    .i_en            (rx_en),
    .i_ps2_clk_fe_stb(ps2_clk_fe),
    .i_ps2_data      (ps2_data),
    .o_rx_stb        (rx_stb),
    .o_data          (rx_dout),
    .o_parity_err    (rx_parity_err)
);


/* RECEIVE REGISTER ***********************************************************/
    
    reg [7:0] data_reg;         // 8-bit data register
    
    initial data_reg = 8'h00;
    always @(posedge i_clk)
        if(ascii_valid)
            data_reg <= #1 ascii;


/* BUFFER FULL BIT ************************************************************/
    
    wire data_rd;               // CPU reading DATA register
    reg  data_full_ff;          // DATAFULL bit of STATUS register
    
    assign data_rd = i_en & (i_reg_sel == DATA);
    
    // set if data register full, clear if data register read by CPU
    initial data_full_ff = 1'b0;
    always @(posedge i_clk) begin
        if(ascii_valid)
            data_full_ff <= #1 1'b1;
        else
            if(data_rd)
                data_full_ff <= #1 1'b0;
    end
    
endmodule

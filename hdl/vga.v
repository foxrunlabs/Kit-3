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
Module Name : vga
File Name   : vga.v
Project     : Kit-3 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose     : Display module for the Kit-3. Generates a 640 x 480 VGA signal
              with a 75 Hz refresh rate by default.
*******************************************************************************/


module vga
#(
    // 640 x 480 @ 75 Hz (31.5 MHz pixel clock)
    parameter H_TOTAL_TIME = 10'd840,   // pixels per line
              H_ADDR_TIME  = 10'd640,   // addressable pixels
              H_SYNC_START = 10'd656,   // horizontal sync start
              H_SYNC_TIME  = 10'd64,    // horizontal sync length
              H_SYNC_POL   = 1'b0,      // horizontal sync polarity
              V_TOTAL_TIME = 10'd500,   // lines per frame
              V_ADDR_TIME  = 10'd480,   // addressable lines
              V_SYNC_START = 10'd481,   // vertical sync start
              V_SYNC_TIME  = 10'd3,     // vertical sync length
              V_SYNC_POL   = 1'b0       // vertical sync polarity
)
(
    input wire         i_clk_core,      // core clock
    input wire         i_clk_pixel,     // pixel clock

    input wire         i_en,            // register enable
    input wire         i_we,            // register write enable
    input wire [2:0]   i_regsel,        // register select
    input wire [7:0]   i_data,          // register data input
    output reg [7:0]   o_data,          // register data output

    output reg         o_hsync,         // horizontal sync
    output reg         o_vsync,         // vertical sync
    output reg [11:0]  o_rgb            // RGB444 color
);


/*******************************************************************************
REGISTERS
*******************************************************************************/

localparam CTRL  = 3'b000,
           COLOR = 3'b001,
           ADDRL = 3'b010,
           ADDRH = 3'b011,
           VRAM  = 3'b100,
           CURSL = 3'b101,
           CURSH = 3'b110;


/* CONTROL REGISTER ***********************************************************/

// 7 6 5 4 3 2 1 0
// V x x x M B C D
// D = display on/off, C = cursor on/off, B = cursor blink on/off
// M = addressing mode, V = vertical blank interval

reg  [6:0] ctrl_reg;
wire       display_on;
wire       cursor_on;
wire       blink_on;
wire       addr_mode;

initial ctrl_reg = 7'b000_0000;
always @(posedge i_clk_core) begin
    if(i_en & i_we & (i_regsel == CTRL)) begin
        ctrl_reg <= i_data[6:0];
    end
end

assign display_on = ctrl_reg[0];
assign cursor_on  = ctrl_reg[1];
assign blink_on   = ctrl_reg[2];
assign addr_mode  = ctrl_reg[3];


/* COLOR REGISTER *************************************************************/

// 7 6 5 4 3 2 1 0
// B B B B F F F F
// F = foreground, B = background

reg  [7:0] color_reg;
wire [3:0] fg_color;
wire [3:0] bg_color;

initial color_reg = 8'h00;
always @(posedge i_clk_core) begin
    if(i_en & i_we & (i_regsel == COLOR)) begin
        color_reg <= i_data;
    end
end

assign fg_color = color_reg[3:0];
assign bg_color = color_reg[7:4];


/* VRAM ADDRESS REGISTERS *****************************************************/

reg  [7:0]  addrl_reg;
reg  [7:0]  addrh_reg;
wire [11:0] logical_addr;
wire [11:0] col_row_addr;
wire [11:0] cpu2vram_addr;

initial addrl_reg = 8'h00;
always @(posedge i_clk_core) begin
    if(i_en & i_we & (i_regsel == ADDRL)) begin
        addrl_reg <= i_data;
    end
end

initial addrh_reg = 8'h00;
always @(posedge i_clk_core) begin
    if(i_en & i_we & (i_regsel == ADDRH)) begin
        addrh_reg <= i_data;
    end
end

assign logical_addr = {addrh_reg[3:0], addrl_reg};

// addr = col + 80 * row = col + row << 4 + row << 6
assign col_row_addr = {5'd0, addrl_reg[6:0]} +
                      {1'd0, addrh_reg[4:0], 6'd0} +
                      {3'd0, addrh_reg[4:0], 4'd0};

assign cpu2vram_addr = (addr_mode) ? col_row_addr : logical_addr;


/* CURSOR ADDRESS REGISTERS ***************************************************/

reg  [7:0]  cursl_reg;
reg  [7:0]  cursh_reg;
wire [11:0] curs_logical_addr;
wire [11:0] curs_col_row_addr;
wire [11:0] curs_addr;

initial cursl_reg = 8'h00;
always @(posedge i_clk_core) begin
    if(i_en & i_we & (i_regsel == CURSL)) begin
        cursl_reg <= i_data;
    end
end

initial cursh_reg = 8'h00;
always @(posedge i_clk_core) begin
    if(i_en & i_we & (i_regsel == CURSH)) begin
        cursh_reg <= i_data;
    end
end

assign curs_logical_addr = {cursh_reg[3:0], cursl_reg};

// addr = col + 80 * row = col + row << 4 + row << 6
assign curs_col_row_addr = {5'd0, cursl_reg[6:0]} +
                           {1'd0, cursh_reg[4:0], 6'd0} +
                           {3'd0, cursh_reg[4:0], 4'd0};

assign curs_addr = (addr_mode) ? curs_col_row_addr : curs_logical_addr;


/* DATA OUTPUT REGISTER *******************************************************/

reg  [7:0] data_ns;
wire [7:0] vram2cpu_data;   // assigned in VRAM logic

always @* begin
    data_ns = o_data;

    case(i_regsel)
        CTRL:    data_ns = {vblank_p1_ff, ctrl_reg};
        COLOR:   data_ns = color_reg;
        ADDRL:   data_ns = addrl_reg;
        ADDRH:   data_ns = addrh_reg;
        VRAM:    data_ns = vram2cpu_data;
        CURSL:   data_ns = cursl_reg;
        CURSH:   data_ns = cursh_reg;
        default: data_ns = 8'h00;
    endcase
end

initial o_data = 8'h00;
always @(posedge i_clk_core) begin
    if(i_en) begin
        o_data <= data_ns;
    end
end


/*******************************************************************************
SYNC LOGIC
*******************************************************************************/

/* X-AXIS PIXEL COUNTER *******************************************************/

reg  [9:0] x_reg;
wire [9:0] x_ns;
wire       line_end;

assign line_end = (x_reg == (H_TOTAL_TIME - 10'd1));

assign x_ns = (line_end) ? 10'd0 : x_reg + 10'd1;

initial x_reg = H_TOTAL_TIME - 10'd1;
always @(posedge i_clk_pixel) begin
    x_reg <= x_ns;
end


/* Y-AXIS LINE COUNTER ********************************************************/

reg  [9:0] y_reg;
reg  [9:0] y_ns;
wire       last_line;

assign last_line = (y_reg == (V_TOTAL_TIME - 10'd1));

always @* begin
    y_ns = y_reg;

    if(line_end) begin
        y_ns = (last_line) ? 10'd0 : y_reg + 10'd1;
    end
end

initial y_reg = V_TOTAL_TIME - 10'd1;
always @(posedge i_clk_pixel) begin
    y_reg <= y_ns;
end


/* HORIZONTAL SYNC ************************************************************/

reg  hsync_ff;
wire hsync_ns;
wire hsync_on;

assign hsync_on = (x_reg >= H_SYNC_START) &
                  (x_reg < (H_SYNC_START + H_SYNC_TIME));

assign hsync_ns = (hsync_on) ? H_SYNC_POL : ~H_SYNC_POL;

initial hsync_ff = ~H_SYNC_POL;
initial o_hsync  = ~H_SYNC_POL;
always @(posedge i_clk_pixel) begin
    hsync_ff <= hsync_ns;
    o_hsync  <= hsync_ff;   // pipeline to account for font ROM access
end


/* VERTICAL SYNC **************************************************************/

reg  vsync_ff;
wire vsync_ns;
wire vsync_on;

assign vsync_on = (y_reg >= V_SYNC_START) &
                  (y_reg < (V_SYNC_START + V_SYNC_TIME));

assign vsync_ns = (vsync_on) ? V_SYNC_POL : ~V_SYNC_POL;

initial vsync_ff = ~V_SYNC_POL;
initial o_vsync  = ~V_SYNC_POL;
always @(posedge i_clk_pixel) begin
    vsync_ff <= vsync_ns;
    o_vsync  <= vsync_ff;   // pipeline to account for font ROM access
end


/* VERTICAL BLANK FLAG ********************************************************/

wire vblank_ns;
reg  vblank_ff;
reg  vblank_p1_ff;

assign vblank_ns = (y_reg >= V_ADDR_TIME);

initial vblank_ff    = 1'b0;
initial vblank_p1_ff = 1'b0;
always @(posedge i_clk_pixel) begin
    vblank_ff    <= vblank_ns;
    vblank_p1_ff <= vblank_ff; // pipeline to account for font ROM access
end


/*******************************************************************************
VIDEO RAM LOGIC
*******************************************************************************/

/* VIDEO RAM ******************************************************************/

wire        cpu2vram_we;
wire        vga2vram_en;
wire [6:0]  next_col;
wire [4:0]  next_row;
wire [11:0] vga2vram_addr;
wire [7:0]  vram2vga_data;

assign cpu2vram_we = i_we & (i_regsel == VRAM);
assign vga2vram_en = (x_ns[2:0] == 3'o0);

assign next_col = x_ns[9:3];    // columns are 8 pixels wide
assign next_row = y_ns[8:4];    // rows are 16 pixels high

// addr = col + 80 * row = col + row << 4 + row << 6
assign vga2vram_addr = {5'd0, next_col} +
                       {1'd0, next_row, 6'd0} +
                       {3'd0, next_row, 4'd0};

vram vram
(
    .i_clk_a (i_clk_core),
    .i_en_a  (i_en),
    .i_we_a  (cpu2vram_we),
    .i_addr_a(cpu2vram_addr),
    .i_data_a(i_data),
    .o_data_a(vram2cpu_data),

    .i_clk_b (i_clk_pixel),
    .i_en_b  (vga2vram_en),
    .i_we_b  (1'b0),
    .i_addr_b(vga2vram_addr),
    .i_data_b(8'h00),
    .o_data_b(vram2vga_data)
);


/*******************************************************************************
DISPLAY GENERATION LOGIC
*******************************************************************************/

/* FONT ROM *******************************************************************/

reg [7:0] font_rom_reg [0:4095];

initial $readmemh("font.mem", font_rom_reg);


/* PIXEL GENERATOR ************************************************************/

wire [2:0]  char_pixel;
wire [3:0]  char_line;
wire [11:0] font_addr;
wire        next_font;

reg  [7:0]  pixels_reg;
wire [7:0]  pixels_ns;

assign char_pixel = x_reg[2:0];                 // fonts are 8 pixels wide
assign next_char  = (char_pixel == 3'o0);

assign char_line = y_reg[3:0];                  // fonts are 16 pixels high
assign font_addr = {vram2vga_data, char_line};

assign pixels_ns = (next_char) ? font_rom_reg[font_addr]
                               : {pixels_reg[6:0], 1'b0};

initial pixels_reg = 8'b0000_0000;
always @(posedge i_clk_pixel) begin
    pixels_reg <= pixels_ns;
end


/* CURSOR GENERATOR ***********************************************************/

reg  [23:0] cursor_timing_reg;
wire [11:0] scan_addr;
reg         cursor_ff;
wire        cursor_ns;

// blink timing counter
initial cursor_timing_reg = 24'd0;
always @(posedge i_clk_pixel) begin
    cursor_timing_reg <= cursor_timing_reg + 24'd1;
end

// addr = col + 80 * row = col + row << 4 + row << 6
assign scan_addr = {5'd0, x_reg[9:3]} +
                   {1'd0, y_reg[8:4], 6'd0} +
                   {3'd0, y_reg[8:4], 4'd0};

// cursor pixel is active when cursor on, VGA scan at cursor location, and
// either the timing is active high or the blink is turned off.
assign cursor_ns = cursor_on &
                   (scan_addr == curs_addr) &
                   (cursor_timing_reg[23] | ~blink_on);

initial cursor_ff = 1'b0;
always @(posedge i_clk_pixel) begin
    cursor_ff <= cursor_ns;
end


/* VISIBLE FLAG ***************************************************************/

wire visible_ns;
reg  visible_ff;

assign visible_ns = (x_reg < H_ADDR_TIME) && (y_reg < V_ADDR_TIME);

initial visible_ff = 1'b0;
always @(posedge i_clk_pixel) begin
    visible_ff <= visible_ns;
end


/* ATTRIBUTE DECODER **********************************************************/

// RGB444 color attributes
localparam BLACK         = 12'h000,     // 0x0
           BLUE          = 12'h00A,     // 0x1
           GREEN         = 12'h0A0,     // 0x2
           CYAN          = 12'h0AA,     // 0x3
           RED           = 12'hA00,     // 0x4
           MAGENTA       = 12'hA0A,     // 0x5
           BROWN         = 12'hA50,     // 0x6
           LIGHT_GRAY    = 12'hAAA,     // 0x7
           DARK_GRAY     = 12'h555,     // 0x8
           LIGHT_BLUE    = 12'h55F,     // 0x9
           LIGHT_GREEN   = 12'h5F5,     // 0xA
           LIGHT_CYAN    = 12'h5FF,     // 0xB
           LIGHT_RED     = 12'hF55,     // 0xC
           LIGHT_MAGENTA = 12'hF5F,     // 0xD
           YELLOW        = 12'hFF5,     // 0xE
           WHITE         = 12'hFFF;     // 0xF

reg  [11:0] rgb_ns;
wire        current_pixel;

assign current_pixel = pixels_reg[7] | cursor_ff;

always @* begin
    rgb_ns = BLACK;

    if(display_on & visible_ff) begin
        if(current_pixel) begin
            case(fg_color)
                4'h0: rgb_ns = BLACK;
                4'h1: rgb_ns = BLUE;
                4'h2: rgb_ns = GREEN;
                4'h3: rgb_ns = CYAN;
                4'h4: rgb_ns = RED;
                4'h5: rgb_ns = MAGENTA;
                4'h6: rgb_ns = BROWN;
                4'h7: rgb_ns = LIGHT_GRAY;
                4'h8: rgb_ns = DARK_GRAY;
                4'h9: rgb_ns = LIGHT_BLUE;
                4'hA: rgb_ns = LIGHT_GREEN;
                4'hB: rgb_ns = LIGHT_CYAN;
                4'hC: rgb_ns = LIGHT_RED;
                4'hD: rgb_ns = LIGHT_MAGENTA;
                4'hE: rgb_ns = YELLOW;
                4'hF: rgb_ns = WHITE;
            endcase
        end else begin
            case(bg_color)
                4'h0: rgb_ns = BLACK;
                4'h1: rgb_ns = BLUE;
                4'h2: rgb_ns = GREEN;
                4'h3: rgb_ns = CYAN;
                4'h4: rgb_ns = RED;
                4'h5: rgb_ns = MAGENTA;
                4'h6: rgb_ns = BROWN;
                4'h7: rgb_ns = LIGHT_GRAY;
                4'h8: rgb_ns = DARK_GRAY;
                4'h9: rgb_ns = LIGHT_BLUE;
                4'hA: rgb_ns = LIGHT_GREEN;
                4'hB: rgb_ns = LIGHT_CYAN;
                4'hC: rgb_ns = LIGHT_RED;
                4'hD: rgb_ns = LIGHT_MAGENTA;
                4'hE: rgb_ns = YELLOW;
                4'hF: rgb_ns = WHITE;
            endcase
        end
    end
end

initial o_rgb = BLACK;
always @(posedge i_clk_pixel) begin
    o_rgb <= rgb_ns;
end


/******************************************************************************/

endmodule

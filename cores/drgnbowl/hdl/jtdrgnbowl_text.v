/*  This file is part of DragonBowl (not an official jotego core).
    DragonBowl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Dragon Bowl (Nics, 1992), a bootleg of Tecmo's Ninja Gaiden.
    Based on jtgaiden_text.v from jtcores (cores/gaiden),
    SPDX-FileCopyrightText: 2026 Jose Tejada Gomez, GPL-3.0-or-later,
    modified for Dragon Bowl. Date: 23-10-2026 */

// 32x32 text layer of 8x8 tiles, as jtgaiden_text without scroll registers.
// RAM words 000-3FF attribute (palette in bits 7-4), 400-7FF tile code.
module jtdrgnbowl_text(
    input               rst,
    input               clk,
    input               pxl_cen,

    input               hs,
    input               blankn,
    input         [8:0] vdump,
    input         [8:0] hdump,
    input         [7:0] scr_x,
    input         [7:0] scr_y,

    // video RAM
    output       [11:1] ram_addr,
    input        [15:0] ram_dout,

    // ROM
    output              rom_cs,
    output       [15:2] rom_addr,
    input        [31:0] rom_data,
    input               rom_ok,

    output       [ 7:0] pxl
);

wire [10:0] code;
wire [ 3:0] pal;
wire [31:0] ram_full, sorted;

assign code = ram_full[16+:11];
assign pal  = ram_full[7:4];

jtframe_8x8x4_packed_msb u_conv(
    .raw    ( rom_data  ),
    .sorted ( sorted    )
);

jtframe_bram_burst u_txtburst(
    .clk    ( clk          ),
    .sel    ( ram_addr[11] ),
    .din16  ( ram_dout     ),
    .dout32 ( ram_full     )
);

jtframe_scroll #(.VA(10),.CW(11),.MAP_HW(8),.MAP_VW(8),.HJUMP(0)) u_scroll(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .pxl_cen    ( pxl_cen   ),

    .hs         ( hs        ),
    .vdump      ( vdump     ),
    .hdump      ( hdump     ),
    .blankn     ( blankn    ),  // if !blankn there are no ROM requests
    .flip       ( 1'b0      ),
    .scrx       ( scr_x     ),
    .scry       ( scr_y     ),

    .vram_addr  ( ram_addr[10:1] ),

    .code       ( code      ),
    .pal        ( pal       ),
    .hflip      ( 1'b0      ),
    .vflip      ( 1'b0      ),

    .rom_addr   ( rom_addr  ),
    .rom_data   ( sorted    ),
    .rom_cs     ( rom_cs    ),
    .rom_ok     ( rom_ok    ),

    .pxl        ( pxl       )
);

endmodule

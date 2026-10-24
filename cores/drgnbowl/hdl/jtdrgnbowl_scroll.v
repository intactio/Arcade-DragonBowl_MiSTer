/*  This file is part of DragonBowl (not an official jotego core).
    DragonBowl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Dragon Bowl (Nics, 1992), a bootleg of Tecmo's Ninja Gaiden.
    Based on jtgaiden_scroll.v from jtcores (cores/gaiden),
    SPDX-FileCopyrightText: 2026 Jose Tejada Gomez, GPL-3.0-or-later,
    modified for Dragon Bowl. Date: 23-10-2026 */

// 64x32 map of 16x16 tiles, as jtgaiden_scroll with Dragon Bowl's planar
// graphics. RAM words 000-7FF attribute (palette in bits 7-4), 800-FFF code.
// The MRA stores the four bit planes of each tile row as the four bytes of a
// 32-bit word (byte n = pixel bit n), which is jtframe_scroll's format, at the
// board's scrambled address: for a tile-row address d the ROM holds it at r
// with r17=d16, r16=d17, r12=d4, r11=d3, r10-3=d12-5 (MAME descramble_drgnbowl).
module jtdrgnbowl_scroll(
    input               rst,
    input               clk,
    input               pxl_cen,

    input               layer,      // 0 = background tiles, 1 = foreground tiles
    input               hs,
    input         [8:0] vdump,
    input         [8:0] hdump,
    input         [9:0] scr_x,
    input         [8:0] scr_y,

    // video RAM
    output       [12:1] ram_addr,
    input        [15:0] ram_dout,

    // ROM
    output              rom_cs,
    output       [19:2] rom_addr,
    input        [31:0] rom_data,
    input               rom_ok,

    output       [ 7:0] pxl
);

wire [31:0] ram_full;
wire [16:0] tile_addr;      // code, half, row
wire [17:0] d;
wire [11:0] code;
wire [ 3:0] pal;

assign code     = ram_full[16+:12];
assign pal      = ram_full[7:4];
assign d        = { layer, tile_addr };
assign rom_addr = { d[16], d[17], d[15:13], d[4], d[3], d[12:5], d[2:0] };

jtframe_bram_burst u_burst(
    .clk    ( clk          ),
    .sel    ( ram_addr[12] ),
    .din16  ( ram_dout     ),
    .dout32 ( ram_full     )
);

localparam [8:0] DEEP_IN_HB=9'h120;

jtframe_scroll #(
    .PW(8),.SIZE(16),.VA(11),
    .MAP_HW(10),.MAP_VW(9),
    .HJUMP(0),.HLOOP(DEEP_IN_HB))
u_scroll(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .pxl_cen    ( pxl_cen   ),

    .hs         ( hs        ),
    .vdump      ( vdump     ),
    .hdump      ( hdump     ),
    .blankn     ( 1'b1      ),
    .flip       ( 1'b0      ),
    .scrx       ( scr_x     ),
    .scry       ( scr_y     ),

    .vram_addr  ( ram_addr[11:1] ),

    .code       ( code      ),
    .pal        ( pal       ),
    .hflip      ( 1'b0      ),
    .vflip      ( 1'b0      ),

    .rom_addr   ( tile_addr ),
    .rom_data   ( rom_data  ),
    .rom_cs     ( rom_cs    ),
    .rom_ok     ( rom_ok    ),

    .pxl        ( pxl       )
);

endmodule

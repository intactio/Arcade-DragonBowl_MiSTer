/*  This file is part of DragonBowl (not an official jotego core).
    DragonBowl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Dragon Bowl (Nics, 1992), a bootleg of Tecmo's Ninja Gaiden.
    Built on JTFRAME and jtgaiden by Jose Tejada Gomez. Date: 24-10-2026 */

// Layer order from MAME's drgnbowl screen_update: background, foreground,
// text, then sprites. Foreground, text and sprites use pen 15 as
// transparent. A sprite with the "behind" bit only shows where foreground
// and text are transparent; without it, it is on top of everything.
// No blending.
// Palette RAM: 4096 words of xBGR 444; text 000, sprites 100, foreground
// 200, background 300 (16 palettes of 16 colours each).
module jtdrgnbowl_colmix(
    input               clk,
    input               pxl_cen,

    output reg   [12:1] pal_addr,
    input        [15:0] pal_dout,

    input        [ 7:0] txt_pxl, fg_pxl, bg_pxl,  // {palette, pen}
    input        [ 8:0] obj_pxl,                  // {behind, palette, pen}

    output reg   [ 3:0] red,
    output reg   [ 3:0] green,
    output reg   [ 3:0] blue,
    // Test
    input        [ 3:0] gfx_en
);

wire txt_op = txt_pxl[3:0]!=4'hf && gfx_en[0];
wire fg_op  = fg_pxl [3:0]!=4'hf && gfx_en[1];
wire obj_op = obj_pxl[3:0]!=4'hf && gfx_en[3] && !(obj_pxl[8] && (txt_op || fg_op));

always @(posedge clk) begin
    pal_addr <= obj_op ? { 4'h1, obj_pxl[7:0] } :
                txt_op ? { 4'h0, txt_pxl } :
                fg_op  ? { 4'h2, fg_pxl  } :
                gfx_en[2] ? { 4'h3, bg_pxl } : 12'd0;
    if( pxl_cen ) { blue, green, red } <= pal_dout[11:0];
end

endmodule

/*  This file is part of DragonBowl (not an official jotego core).
    DragonBowl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Dragon Bowl (Nics, 1992), a bootleg of Tecmo's Ninja Gaiden.
    Built on JTFRAME and jtgaiden by Jose Tejada Gomez. Date: 23-10-2026 */

module jtdrgnbowl_video(
    input             rst,
    input             clk,
    input             pxl_cen,

    output            LHBL,
    output            LVBL,
    output            HS,
    output            VS,

    // scroll registers
    input      [15:0] bg_x, bg_y, fg_x, fg_y,

    // video RAM
    output     [11:1] tram_addr,
    input      [15:0] tram_dout,
    output     [12:1] fram_addr,
    input      [15:0] fram_dout,
    output     [12:1] bram_addr,
    input      [15:0] bram_dout,
    output     [12:1] oram_addr,
    input      [15:0] oram_dout,
    output     [12:1] pal_addr,
    input      [15:0] pal_dout,

    // ROM
    output            txt_cs,
    output     [15:2] txt_addr,
    input      [31:0] txt_data,
    input             txt_ok,

    output            scr1_cs,
    output     [19:2] scr1_addr,
    input      [31:0] scr1_data,
    input             scr1_ok,

    output            obj_cs,
    output     [19:2] obj_addr,
    input      [31:0] obj_data,
    input             obj_ok,

    output            scr2_cs,
    output     [19:2] scr2_addr,
    input      [31:0] scr2_data,
    input             scr2_ok,

    output     [ 3:0] red,
    output     [ 3:0] green,
    output     [ 3:0] blue,
    input      [ 3:0] gfx_en
);

// MAME tilemap offsets: map x = screen x + scroll + 248 (background),
// + 252 (foreground); the text layer does not scroll. One more pixel on
// each makes up for the palette read in jtdrgnbowl_colmix (device
// screenshots vs MAME frames: equal with these values)
localparam [9:0] BG_DX = 10'd249, FG_DX = 10'd253;
localparam [7:0] TXT_DX = 8'd1;

wire [8:0] vdump, vrender, hdump;
wire [7:0] txt_pxl, fg_pxl, bg_pxl;
wire [8:0] obj_pxl;
wire [9:0] bg_scrx = bg_x[9:0] + BG_DX,
           fg_scrx = fg_x[9:0] + FG_DX;
// shorter blanking to cut SDRAM requests, as jtgaiden
reg        vblankn, hblankn, cblankn;

always @(posedge clk) begin
    vblankn <= !(vdump>9'd240 || vdump<9'd14);
    hblankn <= !(hdump>9'o411);
    cblankn <= vblankn & hblankn;
end

// 6 MHz, 384 x 264 = 59.19 Hz as jtgaiden (the PCB videos give ~59.17 Hz)
// visible lines 16-239 as MAME's drgnbowl
jtframe_vtimer #(
    .HS_START( 9'o452 ),
    .HB_START( 9'o410 ),
    .HB_END  ( 9'o010 ),
    .HCNT_END( 9'o577 ),

    .V_START ( 9'd0   ),
    .VS_START( 9'd248 ),
    .VS_END  ( 9'd251 ),
    .VB_START( 9'd239 ),
    .VB_END  ( 9'd15  ),
    .VCNT_END( 9'd263 )
)u_timer(
    .clk        ( clk           ),
    .pxl_cen    ( pxl_cen       ),
    .vdump      ( vdump         ),
    .vrender    ( vrender       ),
    .vrender1   (               ),
    .H          ( hdump         ),
    .Hinit      (               ),
    .Vinit      (               ),
    .LHBL       ( LHBL          ),
    .LVBL       ( LVBL          ),
    .HS         ( HS            ),
    .VS         ( VS            )
);

jtdrgnbowl_text u_text(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .pxl_cen    ( pxl_cen   ),
    .hs         ( HS        ),
    .blankn     ( cblankn   ),
    .vdump      ( vdump     ),
    .hdump      ( hdump     ),
    .scr_x      ( TXT_DX    ),
    .scr_y      ( 8'd0      ),
    .ram_addr   ( tram_addr ),
    .ram_dout   ( tram_dout ),
    .rom_cs     ( txt_cs    ),
    .rom_addr   ( txt_addr  ),
    .rom_data   ( txt_data  ),
    .rom_ok     ( txt_ok    ),
    .pxl        ( txt_pxl   )
);

jtdrgnbowl_scroll u_bg(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .pxl_cen    ( pxl_cen   ),
    .layer      ( 1'b0      ),
    .hs         ( HS        ),
    .vdump      ( vdump     ),
    .hdump      ( hdump     ),
    .scr_x      ( bg_scrx   ),
    .scr_y      ( bg_y[8:0] ),
    .ram_addr   ( bram_addr ),
    .ram_dout   ( bram_dout ),
    .rom_cs     ( scr1_cs   ),
    .rom_addr   ( scr1_addr ),
    .rom_data   ( scr1_data ),
    .rom_ok     ( scr1_ok   ),
    .pxl        ( bg_pxl    )
);

jtdrgnbowl_scroll u_fg(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .pxl_cen    ( pxl_cen   ),
    .layer      ( 1'b1      ),
    .hs         ( HS        ),
    .vdump      ( vdump     ),
    .hdump      ( hdump     ),
    .scr_x      ( fg_scrx   ),
    .scr_y      ( fg_y[8:0] ),
    .ram_addr   ( fram_addr ),
    .ram_dout   ( fram_dout ),
    .rom_cs     ( scr2_cs   ),
    .rom_addr   ( scr2_addr ),
    .rom_data   ( scr2_data ),
    .rom_ok     ( scr2_ok   ),
    .pxl        ( fg_pxl    )
);

jtdrgnbowl_obj u_obj(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .pxl_cen    ( pxl_cen   ),
    .hs         ( HS        ),
    .blankn     ( vblankn   ),
    .hdump      ( hdump     ),
    .vrender    ( vrender   ),
    .ram_addr   ( oram_addr ),
    .ram_dout   ( oram_dout ),
    .rom_cs     ( obj_cs    ),
    .rom_addr   ( obj_addr  ),
    .rom_data   ( obj_data  ),
    .rom_ok     ( obj_ok    ),
    .pxl        ( obj_pxl   )
);

jtdrgnbowl_colmix u_colmix(
    .clk        ( clk       ),
    .pxl_cen    ( pxl_cen   ),
    .pal_addr   ( pal_addr  ),
    .pal_dout   ( pal_dout  ),
    .txt_pxl    ( txt_pxl   ),
    .fg_pxl     ( fg_pxl    ),
    .bg_pxl     ( bg_pxl    ),
    .obj_pxl    ( obj_pxl   ),
    .red        ( red       ),
    .green      ( green     ),
    .blue       ( blue      ),
    .gfx_en     ( gfx_en    )
);

endmodule

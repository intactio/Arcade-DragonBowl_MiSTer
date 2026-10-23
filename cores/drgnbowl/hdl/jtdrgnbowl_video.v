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

    output     [ 3:0] red,
    output     [ 3:0] green,
    output     [ 3:0] blue
);

wire [8:0] vdump, vrender, hdump;

assign { red, green, blue } = 0;

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

endmodule

/*  This file is part of DragonBowl (not an official jotego core).
    DragonBowl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Dragon Bowl (Nics, 1992), a bootleg of Tecmo's Ninja Gaiden.
    Built on JTFRAME and jtgaiden by Jose Tejada Gomez. Date: 23-10-2026 */

module jtdrgnbowl_game(
    `include "jtframe_game_ports.inc" // see $JTFRAME/hdl/inc/jtframe_game_ports.inc
);

wire [ 7:0] snd_cmd;
wire        snd_wr;
wire [15:0] bg_x, bg_y, fg_x, fg_y;
wire [ 1:0] ram_dsn;
wire        pre_ramwe, ram_cs, ram_ok, ramcs_l;

assign dip_flip   = 0;
assign debug_view = 0;
assign ram_addr   = main_addr[13:1];
assign ram_we     = {2{pre_ramwe}} & ~ram_dsn;
// BRAM data is valid two clocks after the select, as in jtgaiden
assign ram_ok     = ramcs_l | ~ram_cs;
jtframe_sh #(.W(1),.L(2)) u_sh(clk,1'b1,ram_cs,ramcs_l);


jtdrgnbowl_main u_main(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .LVBL       ( LVBL      ),

    .main_addr  ( main_addr ),
    .main_dout  ( ram_din   ),
    .rom_cs     ( main_cs   ),
    .ram_cs     ( ram_cs    ),
    .ram_we     ( pre_ramwe ),
    .dsn        ( ram_dsn   ),

    .snd_cmd    ( snd_cmd   ),
    .snd_wr     ( snd_wr    ),
    .txt_we     ( txt_we    ),
    .fg_we      ( fg_we     ),
    .bg_we      ( bg_we     ),
    .obj_we     ( obj_we    ),
    .pal_we     ( pal_we    ),

    .mt_dout    ( mt_dout   ),
    .mf_dout    ( mf_dout   ),
    .mb_dout    ( mb_dout   ),
    .mo_dout    ( mo_dout   ),
    .mp_dout    ( mp_dout   ),

    .bg_x       ( bg_x      ),
    .bg_y       ( bg_y      ),
    .fg_x       ( fg_x      ),
    .fg_y       ( fg_y      ),

    .ram_dout   ( ram_dout  ),
    .rom_data   ( main_data ),
    .ram_ok     ( ram_ok    ),
    .rom_ok     ( main_ok   ),

    .joystick1  ( joystick1[6:0] ),
    .joystick2  ( joystick2[6:0] ),
    .cab_1p     ( cab_1p[1:0] ),
    .coin       ( coin[1:0] ),
    .dip_pause  ( dip_pause ),
    .dipsw      ( dipsw[15:0] )
);

jtdrgnbowl_video u_video(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .pxl_cen    ( pxl_cen   ),

    .LHBL       ( LHBL      ),
    .LVBL       ( LVBL      ),
    .HS         ( HS        ),
    .VS         ( VS        ),

    .bg_x       ( bg_x      ),
    .bg_y       ( bg_y      ),
    .fg_x       ( fg_x      ),
    .fg_y       ( fg_y      ),

    .tram_addr  ( tram_addr ),
    .tram_dout  ( tram_dout ),
    .fram_addr  ( fram_addr ),
    .fram_dout  ( fram_dout ),
    .bram_addr  ( bram_addr ),
    .bram_dout  ( bram_dout ),
    .oram_addr  ( oram_addr ),
    .oram_dout  ( oram_dout ),
    .pal_addr   ( pal_addr  ),
    .pal_dout   ( pal_dout  ),

    .obj_cs     ( obj_cs    ),
    .obj_addr   ( obj_addr  ),
    .obj_data   ( obj_data  ),
    .obj_ok     ( obj_ok    ),

    .txt_cs     ( txt_cs    ),
    .txt_addr   ( txt_addr  ),
    .txt_data   ( txt_data  ),
    .txt_ok     ( txt_ok    ),
    .scr1_cs    ( scr1_cs   ),
    .scr1_addr  ( scr1_addr ),
    .scr1_data  ( scr1_data ),
    .scr1_ok    ( scr1_ok   ),
    .scr2_cs    ( scr2_cs   ),
    .scr2_addr  ( scr2_addr ),
    .scr2_data  ( scr2_data ),
    .scr2_ok    ( scr2_ok   ),

    .red        ( red       ),
    .green      ( green     ),
    .blue       ( blue      ),
    .gfx_en     ( gfx_en    )
);

jtdrgnbowl_sound u_sound(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .cen6       ( cen6      ),
    .cen4       ( cen4      ),
    .cen2       ( cen2      ),
    .cen1       ( cen1      ),

    .cmd        ( snd_cmd   ),
    .cmd_wr     ( snd_wr    ),
    .rom_addr   ( snd_addr  ),
    .rom_cs     ( snd_cs    ),
    .rom_data   ( snd_data  ),
    .rom_ok     ( snd_ok    ),
    .pcm_addr   ( pcm_addr  ),
    .pcm_cs     ( pcm_cs    ),
    .pcm_data   ( pcm_data  ),
    .pcm_ok     ( pcm_ok    ),
    .fm_l       ( fm_l      ),
    .fm_r       ( fm_r      ),
    .pcm        ( pcm       )
);

endmodule

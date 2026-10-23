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

// sound (task 3)
assign { snd_cs, snd_addr, pcm_cs, pcm_addr } = 0;
assign { fm_l, fm_r, pcm } = 0;
// graphics (tasks 4 and 5)
assign { txt_cs, txt_addr, obj_cs, obj_addr, scr_cs, scr_addr } = 0;
assign { tram_addr, fram_addr, bram_addr, oram_addr, pal_addr } = 0;

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

    .red        ( red       ),
    .green      ( green     ),
    .blue       ( blue      )
);

endmodule

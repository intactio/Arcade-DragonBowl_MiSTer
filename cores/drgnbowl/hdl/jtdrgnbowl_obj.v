/*  This file is part of DragonBowl (not an official jotego core).
    DragonBowl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Dragon Bowl (Nics, 1992), a bootleg of Tecmo's Ninja Gaiden.
    Built on JTFRAME and jtgaiden by Jose Tejada Gomez. Date: 24-10-2026 */

// Sprites as MAME's drgnbowl_state::draw_sprites: 256 entries of 16x16, read
// live from sprite RAM. Entry i: words 4i..4i+3 and a colour word at 400+4i
//   word 0  code[7:0]                  word 2  x[7:0]
//   word 1  y: screen y = 244 - y      word 3  bit 7 flip y, 6 flip x,
//                                              5 behind foreground/text,
//                                              4-0 code[12:8]
//   colour  bit 7 = x on screen (x bit 8 clear: the sprite starts left of
//           the screen), 3-0 palette
// Earlier entries stay on top of later ones. The graphics are stored inverted:
// raw pen 0 is the transparent pen 15, so jtframe_objdraw's default
// transparent value 0 works on the raw data and the pen is inverted after.
module jtdrgnbowl_obj(
    input               rst,
    input               clk,
    input               pxl_cen,

    input               hs,
    input               blankn,
    input        [ 8:0] hdump,
    input        [ 8:0] vrender,

    output reg   [12:1] ram_addr,
    input        [15:0] ram_dout,

    output              rom_cs,
    output       [19:2] rom_addr,
    input        [31:0] rom_data,
    input               rom_ok,

    output       [ 8:0] pxl         // {behind, palette, pen}, pen 15 = none
);

localparam [8:0] XOFFSET = 9'd8;

wire [ 2:0] st;
wire [ 7:0] objcnt;
wire [ 8:0] vlatch, ydiff;
wire [ 8:0] raw_pxl;
wire        draw_step, skip, dr_draw, dr_busy, inzone;
reg  [ 8:0] y, x;
reg  [12:0] code;
reg  [ 3:0] pal, ysub;
reg         hflip, vflip, prio;

assign draw_step = st==5;
assign ydiff     = vlatch - y;
assign inzone    = ydiff[8:4]==0;
assign skip      = st==1 && !inzone;
assign pxl       = { raw_pxl[8:4], ~raw_pxl[3:0] };

// scan order: y first, so entries off this line are skipped after two steps
always @* begin
    case( st )
        0:       ram_addr = { 2'b00, objcnt, 2'd1 };  // y
        1:       ram_addr = { 2'b00, objcnt, 2'd0 };  // code low
        2:       ram_addr = { 2'b00, objcnt, 2'd2 };  // x
        3:       ram_addr = { 2'b00, objcnt, 2'd3 };  // code high, flags
        default: ram_addr = { 2'b01, objcnt, 2'd0 };  // colour, x high
    endcase
end

always @(posedge clk) begin
    case( st )
        0: y <= 9'd244 - { 1'b0, ram_dout[7:0] };
        1: code[7:0] <= ram_dout[7:0];
        2: x[7:0] <= ram_dout[7:0];
        3: begin
            code[12:8] <= ram_dout[4:0];
            prio       <= ram_dout[5];
            hflip      <= ram_dout[6];
            vflip      <= ram_dout[7];
        end
        4: begin
            x[8] <= ~ram_dout[7];
            pal  <=  ram_dout[3:0];
            ysub <=  ydiff[3:0];
        end
        default:;
    endcase
end

jtframe_objscan #(.OBJW(8),.STW(3)) u_scan(
    .clk        ( clk       ),
    .cen        (           ),
    .hs         ( hs        ),
    .blankn     ( blankn    ),
    .vrender    ( vrender   ),
    .vlatch     ( vlatch    ),

    .draw_step  ( draw_step ),
    .skip       ( skip      ),
    .inzone     ( inzone    ),

    .hsize      ( 3'd0      ),
    .hsub       (           ),
    .haddr      (           ),
    .hflip      ( 1'b0      ),
    .hcnt_nx    (           ),

    .dr_busy    ( dr_busy   ),
    .dr_draw    ( dr_draw   ),

    .addr       ( { objcnt, st } ),
    .step       (           )
);

// KEEP_OLD: the first opaque pixel stays, as MAME's prio_transpen marks
// each sprite pixel (drawn or hidden by the "behind" bit) so later ones skip it
jtframe_objdraw #(.CW(13),.PW(9),.LATCH(1),.HFIX(0),.KEEP_OLD(1),
    .SWAPH(1)) u_draw( // SWAPH: our ROM has the left half first (device screenshot vs model)
    .rst        ( rst       ),
    .clk        ( clk       ),
    .pxl_cen    ( pxl_cen   ),
    .hs         ( hs        ),
    .flip       ( 1'b0      ),
    .hdump      ( hdump     ),

    .draw       ( dr_draw   ),
    .busy       ( dr_busy   ),
    .code       ( code      ),
    .xpos       ( x + XOFFSET ),
    .ysub       ( ysub      ),
    .hzoom      ( 6'd0      ),
    .hz_keep    ( 1'b0      ),

    .hflip      ( ~hflip    ),  // jtframe_draw's natural order is mirrored
    .vflip      ( vflip     ),
    .pal        ( { prio, pal } ),

    .rom_addr   ( rom_addr  ),
    .rom_cs     ( rom_cs    ),
    .rom_ok     ( rom_ok    ),
    .rom_data   ( rom_data  ),

    .pxl        ( raw_pxl   )
);

endmodule

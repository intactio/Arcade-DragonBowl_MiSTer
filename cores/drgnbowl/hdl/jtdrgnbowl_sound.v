/*  This file is part of DragonBowl (not an official jotego core).
    DragonBowl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Dragon Bowl (Nics, 1992), a bootleg of Tecmo's Ninja Gaiden.
    Based on jtgaiden_sound.v from jtcores (cores/gaiden),
    SPDX-FileCopyrightText: 2026 Jose Tejada Gomez, GPL-3.0-or-later,
    modified for Dragon Bowl. Date: 23-10-2026 */

// Z80 at 6 MHz, YM2151 at 4 MHz, OKI M6295 at 1 MHz (pin 7 high)
// MAME drgnbowl_state::sound_map and sound_port_map
module jtdrgnbowl_sound(
    input                rst,
    input                clk,
    input                cen6,
    input                cen4,
    input                cen2,
    input                cen1,

    input         [ 7:0] cmd,
    input                cmd_wr,
    // ROM
    output        [15:0] rom_addr,
    output reg           rom_cs,
    input         [ 7:0] rom_data,
    input                rom_ok,
    // ADPCM ROM
    output        [17:0] pcm_addr,
    output               pcm_cs,
    input         [ 7:0] pcm_data,
    input                pcm_ok,
    // Sound
    output signed [15:0] fm_l, fm_r,
    output signed [13:0] pcm
);

wire [15:0] A;
wire [ 7:0] dout, fm_dout, oki_dout, ram_dout;
reg  [ 7:0] din;
wire        rd_n, wr_n, mreq_n, rfsh_n, m1_n, iorq_n, int_n, oki_wrn;
reg         ram_cs, fm_cs, oki_cs, cmd_cs, rstn;
wire        io_cs = !iorq_n && m1_n;

assign pcm_cs   = 1;
assign oki_wrn  = ~oki_cs | wr_n;
assign rom_addr = A;

always @(posedge clk) rstn <= ~rst;

always @* begin
    rom_cs = !mreq_n && rfsh_n && A[15:11]!=5'h1f;  // 0000-F7FF
    ram_cs = !mreq_n && rfsh_n && A[15:11]==5'h1f;  // F800-FFFF
    fm_cs  = io_cs && A[7:6]==0;                    // 00-01
    oki_cs = io_cs && A[7:6]==2;                    // 80
    cmd_cs = io_cs && A[7:6]==3 && !rd_n;           // C0
end

always @(posedge clk) begin
    din <= rom_cs ? rom_data :
           ram_cs ? ram_dout :
           fm_cs  ? fm_dout  :
           oki_cs ? oki_dout :
           cmd_cs ? cmd      : 8'hff;   // 8'hff = RST 38h on interrupt acknowledge
end

// the latch raises INT until the Z80 reads it (MAME generic_latch_8)
jtframe_edge #(.QSET(0)) u_edge(
    .rst    ( rst       ),
    .clk    ( clk       ),
    .edgeof ( cmd_wr    ),
    .clr    ( cmd_cs    ),
    .q      ( int_n     )
);

jtframe_sysz80 #(.RAM_AW(11)) u_cpu(
    .rst_n      ( rstn        ),
    .clk        ( clk         ),
    .cen        ( cen6        ),
    .cpu_cen    (             ),
    .int_n      ( int_n       ),
    .nmi_n      ( 1'b1        ),
    .busrq_n    ( 1'b1        ),
    .m1_n       ( m1_n        ),
    .mreq_n     ( mreq_n      ),
    .iorq_n     ( iorq_n      ),
    .rd_n       ( rd_n        ),
    .wr_n       ( wr_n        ),
    .rfsh_n     ( rfsh_n      ),
    .halt_n     (             ),
    .busak_n    (             ),
    .A          ( A           ),
    .cpu_din    ( din         ),
    .cpu_dout   ( dout        ),
    .ram_dout   ( ram_dout    ),
    .ram_cs     ( ram_cs      ),
    .rom_cs     ( rom_cs      ),
    .rom_ok     ( rom_ok      )
);

jt51 u_fm(
    .rst    ( rst         ),
    .clk    ( clk         ),
    .cen    ( cen4        ),
    .cen_p1 ( cen2        ),
    .cs_n   ( ~fm_cs      ),
    .wr_n   ( wr_n        ),
    .a0     ( A[0]        ),
    .din    ( dout        ),
    .dout   ( fm_dout     ),
    .ct1    (             ),
    .ct2    (             ),
    .irq_n  (             ),   // not connected (MAME)
    .sample (             ),
    .left   (             ),
    .right  (             ),
    .xleft  ( fm_l        ),
    .xright ( fm_r        )
);

jt6295 #(.INTERPOL(0)) u_adpcm(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .cen        ( cen1      ),
    .ss         ( 1'b1      ),
    // CPU interface
    .wrn        ( oki_wrn   ),  // active low
    .din        ( dout      ),
    .dout       ( oki_dout  ),
    // ROM interface
    .rom_addr   ( pcm_addr  ),
    .rom_data   ( pcm_data  ),
    .rom_ok     ( pcm_ok    ),
    // Sound output
    .sound      ( pcm       ),
    .sample     (           )
);

endmodule

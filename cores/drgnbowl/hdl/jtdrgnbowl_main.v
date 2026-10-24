/*  This file is part of DragonBowl (not an official jotego core).
    DragonBowl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Dragon Bowl (Nics, 1992), a bootleg of Tecmo's Ninja Gaiden.
    Based on jtgaiden_main.v from jtcores (cores/gaiden),
    SPDX-FileCopyrightText: 2026 Jose Tejada Gomez, GPL-3.0-or-later,
    modified for Dragon Bowl. Date: 23-10-2026 */

module jtdrgnbowl_main(
    input                rst,
    input                clk,
    input                LVBL,

    output        [17:1] main_addr,
    output        [15:0] main_dout,
    output reg           rom_cs,
    output reg           ram_cs,
    output               ram_we,
    output        [ 1:0] dsn,

    output        [ 7:0] snd_cmd,
    output reg           snd_wr,
    // video memories
    output        [ 1:0] txt_we,
    output        [ 1:0] fg_we,
    output        [ 1:0] bg_we,
    output        [ 1:0] obj_we,
    output        [ 1:0] pal_we,

    input         [15:0] mt_dout,
    input         [15:0] mf_dout,
    input         [15:0] mb_dout,
    input         [15:0] mo_dout,
    input         [15:0] mp_dout,

    // video registers
    output        [15:0] bg_x, bg_y, fg_x, fg_y,

    input         [15:0] ram_dout,
    input         [15:0] rom_data,
    input                ram_ok,
    input                rom_ok,

    input         [ 6:0] joystick1,
    input         [ 6:0] joystick2,
    input         [ 1:0] cab_1p,
    input         [ 1:0] coin,
    input                dip_pause,
    input         [15:0] dipsw
);

wire [23:1] A;
wire        cpu_cen, cpu_cenb;
wire        UDSn, LDSn, RnW, ASn, VPAn, DTACKn, BUSn;
wire [ 2:0] FC, IPLn;
reg         txt_cs, fg_cs, bg_cs, obj_cs, pal_cs, cab_cs, scr_cs, snd_cs, clr_int;
reg  [15:0] cpu_din, cab_dout;
wire        rom_ok_dly;
wire [15:0] cpu_dout;
wire        bus_cs, bus_busy, intn;

assign main_addr= A[17:1];
assign dsn      = {UDSn, LDSn};
assign main_dout= cpu_dout;
assign IPLn     = { intn, 1'b1, intn };  // level 5
assign VPAn     = !(!ASn && FC==7 && RnW);
assign ram_we   = ram_cs & ~RnW;
assign bus_cs   = rom_cs | ram_cs;
assign bus_busy = (rom_cs & ~rom_ok_dly) | (ram_cs & ~ram_ok);
assign BUSn     = ASn | (LDSn & UDSn);
assign txt_we   = {2{txt_cs &~RnW}} & ~{UDSn,LDSn};
assign fg_we    = {2{fg_cs  &~RnW}} & ~{UDSn,LDSn};
assign bg_we    = {2{bg_cs  &~RnW}} & ~{UDSn,LDSn};
assign obj_we   = {2{obj_cs &~RnW}} & ~{UDSn,LDSn};
assign pal_we   = {2{pal_cs &~RnW}} & ~{UDSn,LDSn};

jtframe_okdly u_rom_okdly(
    .rst    ( rst        ),
    .clk    ( clk        ),
    .cs     ( rom_cs     ),
    .ok     ( rom_ok     ),
    .ok_dly ( rom_ok_dly )
);

// MAME drgnbowl_state::main_map
always @* begin
    rom_cs  = !ASn  && A[19:18]==0;                     // 000000-03FFFF
    ram_cs  = !BUSn && A[19:14]==6'h18;                 // 060000-063FFF
    txt_cs  = !BUSn && A[19:12]==8'h70;                 // 070000-070FFF
    fg_cs   = !BUSn && A[19:13]==7'h39;                 // 072000-073FFF
    bg_cs   = !BUSn && A[19:13]==7'h3a;                 // 074000-075FFF
    obj_cs  = !BUSn && A[19:13]==7'h3b;                 // 076000-077FFF
    pal_cs  = !BUSn && A[19:13]==7'h3c;                 // 078000-079FFF
    cab_cs  = !ASn  && A[19:12]==8'h7a &&  RnW;         // 07A000-07A005 inputs
    snd_cs  = !ASn  && A[19:12]==8'h7a && !RnW && A[3:1]==7 && !UDSn; // 07A00E, even byte = D15-8
    clr_int = !BUSn && A[19:12]==8'h7e && !RnW;         // 07E000 IRQ 5 ack
    scr_cs  = !BUSn && A[19:12]==8'h7f && !RnW;         // 07F000-07F007 scroll
end

always @(posedge clk) begin
    case(A[2:1])
        0: cab_dout <= {8'hff, coin, 4'hf, cab_1p};
        1: cab_dout <= {1'b1, joystick2, 1'b1, joystick1};
        2: cab_dout <= dipsw;
        default: cab_dout <= 16'hffff;
    endcase
end

always @(posedge clk) begin
    cpu_din <= rom_cs  ? rom_data :
               ram_cs  ? ram_dout :
               txt_cs  ? mt_dout  :
               fg_cs   ? mf_dout  :
               bg_cs   ? mb_dout  :
               obj_cs  ? mo_dout  :
               pal_cs  ? mp_dout  :
               cab_cs  ? cab_dout : 16'hffff;
end

jtframe_16bit_reg u_bgy(rst,clk,RnW,dsn,cpu_dout,scr_cs && A[2:1]==0,bg_y);
jtframe_16bit_reg u_bgx(rst,clk,RnW,dsn,cpu_dout,scr_cs && A[2:1]==1,bg_x);
jtframe_16bit_reg u_fgy(rst,clk,RnW,dsn,cpu_dout,scr_cs && A[2:1]==2,fg_y);
jtframe_16bit_reg u_fgx(rst,clk,RnW,dsn,cpu_dout,scr_cs && A[2:1]==3,fg_x);

// one clock pulse per write: the sound latch and its IRQ
reg [7:0] latch;
reg       snd_cs_l;
assign snd_cmd = latch;

always @(posedge clk) begin
    snd_cs_l <= snd_cs;
    snd_wr   <= snd_cs & ~snd_cs_l;
    if( snd_cs & ~snd_cs_l ) latch <= cpu_dout[15:8];
end

jtframe_edge #(.QSET(0)) u_vbl(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .edgeof     ( ~LVBL     ),
    .clr        ( clr_int   ),
    .q          ( intn      )
);

jtframe_68kdtack_cen #(.W(8)) u_dtack(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .cpu_cen    ( cpu_cen   ),
    .cpu_cenb   ( cpu_cenb  ),
    .bus_cs     ( bus_cs    ),
    .bus_busy   ( bus_busy  ),
    .bus_legit  ( 1'd0      ),
    .bus_ack    ( 1'd0      ),
    .ASn        ( ASn       ),
    .DSn        ({UDSn,LDSn}),
    .num        ( 7'd5      ),  // 10 MHz from 48 MHz
    .den        ( 8'd24     ),
    .DTACKn     ( DTACKn    ),
    .wait2      ( 1'b0      ),
    .wait3      ( 1'b0      ),
    // Frequency report
    .fave       (           ),
    .fworst     (           )
);

jtframe_m68k u_cpu(
    .clk        ( clk         ),
    .rst        ( rst         ),
    .RESETn     (             ),
    .cpu_cen    ( cpu_cen     ),
    .cpu_cenb   ( cpu_cenb    ),

    // Buses
    .eab        ( A           ),
    .iEdb       ( cpu_din     ),
    .oEdb       ( cpu_dout    ),

    .eRWn       ( RnW         ),
    .LDSn       ( LDSn        ),
    .UDSn       ( UDSn        ),
    .ASn        ( ASn         ),
    .VPAn       ( VPAn        ),
    .FC         ( FC          ),

    .BERRn      ( 1'b1        ),
    // Bus arbitrion
    .HALTn      ( dip_pause   ),
    .BRn        ( 1'b1        ),
    .BGACKn     ( 1'b1        ),
    .BGn        (             ),

    .DTACKn     ( DTACKn      ),
    .IPLn       ( IPLn        ) // VBLANK
);

endmodule

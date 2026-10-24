# DragonBowl — Dragon Bowl for MiSTer

English · [한국어](README.ko.md) · [日本語](README.ja.md)

A MiSTer FPGA core for **Dragon Bowl**, the 1992 Korean arcade game by Nics. Dragon Bowl is an unlicensed bootleg of Tecmo's arcade *Ninja Gaiden* (1988) running on its own board, with new graphics and sound.

This is a hobby project. It is **not an official jotego core**, although it is built on jotego's JTFRAME framework and borrows from his Ninja Gaiden core (JTGAIDEN).

## AI-assisted development

This core was developed with the help of an AI coding assistant (Anthropic's Claude, through Claude Code).

## Supported games

| MAME set | Title | MRA |
|---|---|---|
| `drgnbowl` | Dragon Bowl (set 1, encrypted program) | `mra/Dragon Bowl (set 1, encrypted program).mra` |
| `drgnbowla` | Dragon Bowl (set 2, unencrypted program) | `mra/_alternatives/_Dragon Bowl/Dragon Bowl (set 2, unencrypted program).mra` |

As in MAME, set 1 is the parent and set 2 a clone, so set 2 sits under `_alternatives`. The `mra/` folder mirrors `_Arcade/` on the SD card. Set 1's program ROMs have two address lines swapped; the MRA puts the blocks back in order, so both sets load the same program and play the same.

ROMs are not included: put your own MAME sets (`drgnbowl.zip`, `drgnbowla.zip`) in `games/mame/`.

## Goal: behave like the PCB

The aim is to behave like the original PCB, not to copy an emulator. Where sources disagree, this order decides:

1. The original PCB (recordings of real hardware).
2. MAME's `tecmo/gaiden.cpp` driver: trusted for what the game's program sees (memory map, I/O, interrupts, ROM layout).

The board's custom logic sits in two unidentified FPGAs and no schematics are known, so most hardware details come from MAME and from comparing the core's output with the recordings.

## Hardware

| Part | Chip | Implementation |
|---|---|---|
| Main CPU | 68000 @ 10 MHz | fx68k through `jtframe_m68k` |
| Sound CPU | Z80 @ 6 MHz | T80 through `jtframe_sysz80` |
| FM | YM2151 @ 4 MHz | `jt51` |
| ADPCM | OKI M6295 @ 1 MHz | `jt6295` |
| Video | 6 MHz pixel clock, 384 × 264 total (59.19 Hz), 256 × 224 visible | `jtframe_vtimer` |
| Layers | text (8 × 8), foreground and background (16 × 16) | `jtframe_scroll`, as in JTGAIDEN |
| Sprites | 256 sprites of 16 × 16 | `jtframe_objscan`, `jtframe_objdraw` |
| Colours | 4096 colours in palette RAM, 4 bits per R/G/B | own colour mixer |

## Status

Works:

- Both sets boot and play: picture, music, sound effects and voices, two players, DIP switches, reset. Play has been checked up to the middle of stage 1.
- The text layer (score bar, "DEMO GAME") is drawn in front of the sprites, as on the PCB recordings.
- The refresh rate is 59.19 Hz, close to the 59.17 Hz measured on PCB recordings.
- After some demos the ranking screen still shows "DEMO GAME". This is how the game's program behaves.

Known differences from the PCB:

- The attract-mode demo follows the PCB recording for about four seconds and then takes a different course. The cause is not known yet.
- The PCB blanks about one to three columns at the left of the picture. The exact number can't be measured from the recordings, so the core shows all 256 columns.
- The PCB's colours are only known from camera recordings of a CRT, so they could not be compared exactly.
- How many sprites the PCB can draw on one line (flicker or drop-outs in busy scenes) has not been compared.
- Flip screen is not supported.

## Controls

8-way joystick and three buttons, as on Ninja Gaiden:

| Input | Action |
|---|---|
| Button 1 | Grab |
| Button 2 | Attack |
| Button 3 | Jump |

DIP switches (defaults come from the MRA, change them in the OSD): Demo Sounds, Coin A, Coin B, Difficulty, Energy, Lives.

Difficulty: Tecmo's manuals for Ninja Gaiden, whose DIP switches Dragon Bowl keeps, only call the settings NORMAL, TBL 1, TBL 2 and TBL 3 (Normal and Table 1 to 3 in the OSD). Each one picks a different table of enemy settings in the program; going by the values in the tables, Normal looks like the easiest and Table 3 the hardest.

## Building

See [BUILD.md](BUILD.md). The core is built inside a [jtcores](https://github.com/jotego/jtcores) checkout with jotego's `jtcore` tool.

## Credits

- **Jose Tejada (jotego)**: JTFRAME, and the cores and modules this one is based on: JTGAIDEN (Ninja Gaiden), `jt51`, `jt6295`, `jtframe_scroll`, `jtframe_objdraw`. https://github.com/jotego/jtcores
- **Jorge Cwik (ijor)**: fx68k, the 68000 core. **Daniel Wallner**: T80, the Z80 core.
- **Alexey Melnikov (sorgelig) and the MiSTer project**: the MiSTer framework (`sys/`) that JTFRAME uses.
- **MAME**: the `gaiden.cpp` driver, used as a reference (no MAME code is included).
- **Nics**: the original game.

## Support

The core is free and stays free, with nothing locked behind tips. If you enjoy it, you can buy me a coffee on [Ko-fi](https://ko-fi.com/intactio). Tips support the work on this core only; they don't pay for the game, and ROMs are never provided.

## License

GPLv3, see [LICENSE](LICENSE). Files based on jtcores name the original file and keep its copyright notice and GPLv3 licence.

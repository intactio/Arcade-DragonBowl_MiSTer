# DragonBowl — MiSTer 用ドラゴンボウル

[English](README.md) · [한국어](README.ko.md) · 日本語

![MiSTer で動かしたドラゴンボウルのタイトル画面](screenshots/01-title.png)

**ドラゴンボウル（Dragon Bowl）** の MiSTer FPGA コアです。ドラゴンボウルは 1992 年に韓国のニックス（Nics）が作ったアーケードゲームで、テクモのアーケード版『忍者龍剣伝』（1988 年）を無断で改造したブートレグです。専用基板で動き、グラフィックとサウンドが新しく作られています。

趣味のプロジェクトで、**jotego の公式コアではありません**。jotego の JTFRAME の上に作り、彼の忍者龍剣伝コア（JTGAIDEN）を参考にしています。

## AI による支援

このコアは AI コーディングアシスタント（Anthropic の Claude、Claude Code）の支援を受けて開発しました。

## 対応ゲーム

| MAME セット | タイトル | MRA |
|---|---|---|
| `drgnbowl` | Dragon Bowl (set 1, encrypted program) | `mra/Dragon Bowl (set 1, encrypted program).mra` |
| `drgnbowla` | Dragon Bowl (set 2, unencrypted program) | `mra/_alternatives/_Dragon Bowl/Dragon Bowl (set 2, unencrypted program).mra` |

MAME と同じく set 1 が親、set 2 がクローンなので、set 2 は `_alternatives` の下にあります。`mra/` フォルダは SD カードの `_Arcade/` と同じ構成です。set 1 のプログラム ROM はアドレス線が 2 本入れ替わっていますが、MRA がブロックの順番を戻すので、両セットとも同じプログラムを読み、同じように動きます。

ROM は含まれていません。お手持ちの MAME セット（`drgnbowl.zip`、`drgnbowla.zip`）を `games/mame/` に置いてください。

## スクリーンショット

| | |
|---|---|
| ![1 面開始の画面](screenshots/02-round-start.png)<br>1 面開始 | ![1 面、家の前](screenshots/03-stage1.png)<br>1 面 |

## 目標：実機どおりに動くこと

エミュレーターを写すのではなく、元の基板どおりに動くことを目指しています。資料が食い違うときは次の順で決めます。

1. 元の基板（実機の録画）
2. MAME の `tecmo/gaiden.cpp` ドライバ：ゲームのプログラムから見える部分（メモリマップ、入出力、割り込み、ROM 配置）を信頼します。

基板のカスタムロジックは正体不明の FPGA 2 個の中にあり、回路図も知られていません。そのため、ハードウェアの細部はほとんどが MAME と、コアの出力を実機の録画と比べた結果によるものです。

## ハードウェア

| 部品 | チップ | 実装 |
|---|---|---|
| メイン CPU | 68000 @ 10 MHz | fx68k（`jtframe_m68k`） |
| サウンド CPU | Z80 @ 6 MHz | T80（`jtframe_sysz80`） |
| FM | YM2151 @ 4 MHz | `jt51` |
| ADPCM | OKI M6295 @ 1 MHz | `jt6295` |
| 映像 | ピクセルクロック 6 MHz、全体 384 × 264（59.19 Hz）、表示 256 × 224 | `jtframe_vtimer` |
| レイヤー | テキスト（8 × 8）、前景と背景（16 × 16） | `jtframe_scroll`（JTGAIDEN と同じ方式） |
| スプライト | 16 × 16 のスプライト 256 個 | `jtframe_objscan`、`jtframe_objdraw` |
| 色 | パレット RAM 4096 色、R/G/B 各 4 ビット | 独自のカラーミキサー |

## 状態

動くもの：

- 両セットとも起動してプレイできます：画面、音楽、効果音と音声、2 人プレイ、ディップスイッチ、リセット。プレイは 1 面の中盤まで確認しました。
- テキストレイヤー（スコア表示、「DEMO GAME」）は実機の録画どおりスプライトの手前に描かれます。
- リフレッシュレートは、実機の録画で測った約 59.17 Hz に近い 59.19 Hz です。
- 一部のデモのあとのランキング画面に「DEMO GAME」の文字が残るのは、ゲームのプログラムの動作です。

実機との違い：

- アトラクトモードのデモは約 4 秒間は実機の録画どおりに進み、その後は別の展開になります。原因はまだ分かっていません。
- 実機は画面左端の 1〜3 列ほどを表示しません。録画からは正確な列数を測れないため、コアは 256 列すべてを表示します。
- 実機の色は CRT をカメラで撮った録画しかないため、正確には比べられていません。
- スプライトの多い場面で 1 ラインに描けるスプライト数の上限は、実機と比べられていません。
- 画面反転には対応していません。

## 操作

忍者龍剣伝と同じ 8 方向レバーとボタン 3 つです。

| 入力 | 動作 |
|---|---|
| ボタン 1 | 掴み（Grab） |
| ボタン 2 | 攻撃（Attack） |
| ボタン 3 | ジャンプ（Jump） |

ディップスイッチ（初期値は MRA で決まり、OSD で変更できます）：Demo Sounds、Coin A、Coin B、Difficulty、Energy、Lives。

Difficulty：ドラゴンボウルは忍者龍剣伝のディップスイッチをそのまま使っており、テクモの忍者龍剣伝マニュアルでも設定名は NORMAL、TBL 1、TBL 2、TBL 3 とだけ書かれています（OSD では Normal、Table 1〜3）。設定ごとにプログラム内の別の敵設定テーブルを選び、テーブルの値を見ると Normal がいちばんやさしく、Table 3 がいちばん難しいようです。

## ビルド

[BUILD.md](BUILD.md)（英語）を参照してください。[jtcores](https://github.com/jotego/jtcores) のチェックアウトの中で jotego の `jtcore` ツールを使ってビルドします。

## クレジット

- **Jose Tejada（jotego）**：JTFRAME、そしてこのコアの元になったコアとモジュール：JTGAIDEN（忍者龍剣伝）、`jt51`、`jt6295`、`jtframe_scroll`、`jtframe_objdraw`。https://github.com/jotego/jtcores
- **Jorge Cwik（ijor）**：68000 コア fx68k。**Daniel Wallner**：Z80 コア T80。
- **Alexey Melnikov（sorgelig）と MiSTer プロジェクト**：JTFRAME が使う MiSTer フレームワーク（`sys/`）。
- **MAME**：参考にした `gaiden.cpp` ドライバ（MAME のコードは含まれていません）。
- **ニックス（Nics）**：元のゲーム。

## サポート

このコアは無料で、これからも無料です。チップで解放される機能はありません。気に入っていただけたら [Ko-fi](https://ko-fi.com/intactio) でコーヒーを一杯おごってください。チップはこのコアの作業のためだけのもので、ゲームの代金ではなく、ROM は一切提供しません。

## ライセンス

GPLv3。[LICENSE](LICENSE) を参照してください。jtcores を元にしたファイルには元のファイル名を記し、元の著作権表示と GPLv3 ライセンスをそのまま残しています。

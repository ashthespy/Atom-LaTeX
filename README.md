# Atom-LaTeX package

Atom-LaTeX is an extension for [Atom.io](https://atom.io/), aiming to provide all-in-one features and utilities for latex typesetting with Atom.

## Features

Atom-LaTeX is currently under active development. More features coming soon.
Some features have screencasts available in the `Screencasts` section. Have a check!

- Compile LaTeX with BibTeX
- Preview PDF with build-in viewer
- Parse LaTeX compiling log
- Autocomplete
- Syntax highlight
- Direct and reverse SyncTeX

If you figured out some features neat but not included, [create an issue](https://github.com/James-Yu/Atom-LaTeX/issues/new)!

## Why another LaTeX package?

Unification provides seamless experience. Aiming to make it work and work perfectly.

## Requirements

- LaTeX distribution in system PATH. For example, [TeX Live](https://www.tug.org/texlive/).
  - [MiKTeX](https://miktex.org/) does not ship with SyncTeX, but basic build and preview and non-SyncTeX related features work fine.
- `[Optional]` Add the folder with your main LaTeX file as Atom project folder.
  - Main LaTeX file is the LaTeX file with the `\begin{document}` command. Atom-LaTeX will automatically detect on the first time of calling `atom-latex:build`.
  - You can also open your main LaTeX file and use `atom-latex:build-here` to manually set your main.

## Installation

Installing Atom-LaTeX is simple. You can find it in [the atom.io package registry](https://atom.io/packages/atom-latex), or simply run `apm install atom-latex` in command line.

Alternatively, you can check out this repository and copy it to the Atom package folder:
- Windows `%USERPROFILE%\.atom\packages`
- Mac/Linux `$HOME/.atom/packages`

## Usage

All commands can be invoked from `Package`-`Atom-LaTeX` menu or by command palette. Alternatively, keybinds are provided.

For reverse SyncTeX from PDF to LaTeX, use <kbd>ctrl</kbd>+<kbd>Mouse Left Click</kbd> in the PDF viewer to reveal the line in editor.

Mac OS users can use <kbd>command</kbd> key as a replacement of <kbd>ctrl</kbd>.

| Command               | Default Keybind                             | Function |
|-----------------------|---------------------------------------------|----------|
| `atom-latex:build`      | <kbd>ctrl</kbd>+<kbd>alt</kbd>+<kbd>B</kbd> | Build LaTeX file. |
| `atom-latex:build-here` | <kbd>ctrl</kbd>+<kbd>alt</kbd>+<kbd>H</kbd> | Build LaTeX using active text editor file if possible. |
| `atom-latex:preview`    | <kbd>ctrl</kbd>+<kbd>alt</kbd>+<kbd>P</kbd> | Preview generated PDF file with in-browser viewer. |
| `atom-latex:kill`       | <kbd>ctrl</kbd>+<kbd>alt</kbd>+<kbd>K</kbd> | Terminate current LaTeX building process. |
| `atom-latex:synctex`   | <kbd>ctrl</kbd>+<kbd>alt</kbd>+<kbd>S</kbd> | Direct SyncTeX from the current cursor position. |
| `atom-latex:show-log`   | <kbd>ctrl</kbd>+<kbd>alt</kbd>+<kbd>L</kbd> | Show Atom-LaTeX log panel. |

## Screencasts

Screencasts may be generated with different platforms. Some may demonstrate features in earlier versions which got updated.

### Build and Preview
![Build and Preview](https://raw.githubusercontent.com/James-Yu/Atom-LaTeX/master/figures/build.gif)

### Autocomplete
![Autocomplete](https://raw.githubusercontent.com/James-Yu/Atom-LaTeX/master/figures/command-autocomplete.gif)

![Autocomplete](https://raw.githubusercontent.com/James-Yu/Atom-LaTeX/master/figures/reference-autocomplete.gif)

### Log Parser
![Log Parser](https://raw.githubusercontent.com/James-Yu/Atom-LaTeX/master/figures/log-parser.gif)

## Contributing

- [Creat issues](https://github.com/James-Yu/Atom-LaTeX/issues) for bugs
- [Fork and PR](https://github.com/James-Yu/Atom-LaTeX/pulls) for fixes
- Thank you so much!

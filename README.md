# Atom-LaTeX package

Atom-LaTeX is an extension for [Atom.io](https://atom.io/), aiming to provide all-in-one features and utilities for latex typesetting with Atom.

## Why another LaTeX package?

Unification provides seamless experience. Aiming to make it work and work perfectly.

## Features

Atom-LaTeX is currently under active development. More features coming soon.
Some features have screencasts available at the `Screencast` section. Have a check!

- [x] Compile LaTeX with BibTeX
- [x] Preview PDF with in-browser viewer
- [x] Log parser
- [x] Autocomplete
- [ ] Support direct and reverse SyncTex
- [ ] Colorize

## Requirements

- LaTeX distribution in system PATH. For example, [TeX Live](https://www.tug.org/texlive/).
  - [MiKTeX](https://miktex.org/) does not ship with SyncTex.

## Installation

Installing Atom-LaTeX is simple. You can find it in [the atom.io package registry](https://atom.io/packages/atom-latex), or simply run `apm install atom-latex` in command line.

Alternatively, you can check out this repository and copy it to the Atom package folder:
- Windows `%USERPROFILE%\.atom\packages`
- Mac/Linux `$HOME/.atom/packages`

## Usage

All commands can be invoked from `Package`-`Atom-LaTeX` menu or by command palette. Alternatively, keybinds are provided.

| Command               | Default Keybind                             | Function |
|-----------------------|---------------------------------------------|----------|
| `atom-latex:build`    | <kbd>ctrl</kbd>-<kbd>alt</kbd>-<kbd>B</kbd> | Build LaTeX file. |
| `atom-latex:preview`  | <kbd>ctrl</kbd>-<kbd>alt</kbd>-<kbd>P</kbd> | Preview generated PDF file with in-browser viewer. |
| `atom-latex:kill`     | <kbd>ctrl</kbd>-<kbd>alt</kbd>-<kbd>K</kbd> | Terminate current LaTeX building process. |
| `atom-latex:show-log` | <kbd>ctrl</kbd>-<kbd>alt</kbd>-<kbd>L</kbd> | Show Atom-LaTeX log panel. |

## Screencasts

Screencasts may be generated with different platforms. Some may demonstrate features in earlier versions which got updated.

### Build and Preview
![Build and Preview](https://raw.githubusercontent.com/James-Yu/Atom-LaTeX/master/figures/build.gif)

### Autocomplete
![Autocomplete](https://raw.githubusercontent.com/James-Yu/Atom-LaTeX/master/figures/reference-autocomplete.gif)

### Log Parser
![Log Parser](https://raw.githubusercontent.com/James-Yu/Atom-LaTeX/master/figures/log-parser.png)

## Contributing

- Submit issues for bugs
- Fork and PR for fixes
- Thank you so much!

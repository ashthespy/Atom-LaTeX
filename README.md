# Atom-LaTeX package

Atom-LaTeX is an extension for [Atom.io](https://atom.io/), aiming to provide all-in-one features and utilities for latex typesetting with Atom.

## Why another LaTeX package?

Unification provides seamless experience. Aiming to make it work and work perfectly.

## Features

- [x] Compile LaTeX with BibTeX
- [x] Preview PDF
- [ ] Support direct and reverse SyncTex
- [ ] Autocomplete
- [ ] Colorize
- [ ] Log parser

## Requirements

- LaTeX distribution in system PATH. For example, [TeX Live](https://www.tug.org/texlive/).
  - [MiKTeX](https://miktex.org/) does not ship with SyncTex.

## Installation

Installing LaTeX Toolbox is simple. You can find it in [the atom.io package registry](https://atom.io/packages/Atom-Toolbox), or simply run `apm install Atom-Toolbox` in command line.

Alternatively, you can check out this repository and copy it to the Atom package folder:
- Windows `%USERPROFILE%\.atom\packages`
- Mac/Linux `$HOME/.atom/packages`

## Usage

- Compile: Use command `Atom-Toolbox:build` for now. Will have alternative ways.
- In-browser Preview: Use command `Atom-Toolbox:preview` for now. Will have alternative ways.

## Commands

- `Atom-Toolbox:build`: Compile LaTeX to PDF.
- `Atom-Toolbox:preview`: Open a live preview column for LaTeX.

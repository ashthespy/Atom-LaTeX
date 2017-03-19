# Atom-LaTeX package

Atom-LaTeX is an extension for [Atom.io](https://atom.io/), aiming to provide all-in-one features and utilities for latex typesetting with Atom.

## Features

Atom-LaTeX is currently under active development. More features coming soon.
Some features have screenshots/screencasts available [here](https://github.com/James-Yu/Atom-LaTeX/blob/master/GALLERY.md). Have a check!

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
- [Set LaTeX root file](#root_file).

## Installation

Installing Atom-LaTeX is simple. You can find it in [the atom.io package registry](https://atom.io/packages/atom-latex), or simply run `apm install atom-latex` in command line.

For cutting edge features or changes, you can check out this repository to the Atom package folder:
- Windows `%USERPROFILE%\.atom\packages`
- Mac/Linux `$HOME/.atom/packages`

## Usage

All commands can be invoked from `Package`-`Atom-LaTeX` menu or by command palette. Alternatively, keybinds are provided. Each command is invoked if the two key combinations are pressed sequentially.

For reverse SyncTeX from PDF to LaTeX, use <kbd>ctrl</kbd>+<kbd>Mouse Left Click</kbd> in the PDF viewer to reveal the line in editor.

Mac OS users can use <kbd>command</kbd> key as a replacement of <kbd>ctrl</kbd>.

| Command               | Default Keybind                             | Function |
|-----------------------|---------------------------------------------|----------|
| `atom-latex:build`      | <kbd>ctrl</kbd>+<kbd>L</kbd> <kbd>ctrl</kbd>+<kbd>B</kbd> | Build LaTeX file. |
| `atom-latex:build-here` | <kbd>ctrl</kbd>+<kbd>L</kbd> <kbd>ctrl</kbd>+<kbd>H</kbd> | Build LaTeX using active text editor file if possible. |
| `atom-latex:clean`      | <kbd>ctrl</kbd>+<kbd>L</kbd> <kbd>ctrl</kbd>+<kbd>C</kbd> | Clean LaTeX auxillary files. |
| `atom-latex:preview`    | <kbd>ctrl</kbd>+<kbd>L</kbd> <kbd>ctrl</kbd>+<kbd>P</kbd> | Preview generated PDF file with in-browser viewer. |
| `atom-latex:kill`       | <kbd>ctrl</kbd>+<kbd>L</kbd> <kbd>ctrl</kbd>+<kbd>K</kbd> | Terminate current LaTeX building process. |
| `atom-latex:synctex`    | <kbd>ctrl</kbd>+<kbd>L</kbd> <kbd>ctrl</kbd>+<kbd>S</kbd> | Direct SyncTeX from the current cursor position. |
| `atom-latex:toggle-panel`   | <kbd>ctrl</kbd>+<kbd>L</kbd> <kbd>ctrl</kbd>+<kbd>L</kbd> | Toggle Atom-LaTeX panel display. |

## Project-based Configuration
Atom currently does not provide per-project configuration. Atom-LaTeX uses a `.latexcfg` file under the root directory of LaTeX project to partially control its behavior. Following is a complete example of its content.
   ```
   {
     "root" : "\path\to\root\file.tex",
     "toolchain" : "%TEX %ARG %DOC",
     "latex_ext": [".tikz", ".Rnw"]
   }
   ```
If a key is set, the config will overwrite the global one in atom settings.

## How To
### <a name="root_file"></a>Set LaTeX root file
LaTeX root file is essential to Atom-LaTeX. Building, preview, autocompletion, and more features rely on its proper configuration. You can select to manually set the file by clicking the `home` icon on the control bar, or let Atom-LaTeX automatically find it given proper project structures:
   ```
   { "root" : "\path\to\root\file.tex" }
   ```

1. Create a `.latexcfg` file at the root directory of your project. The file should contain a json object with `root` key set to the root file. An example:
   ```
   { "root" : "\path\to\root\file.tex" }
   ```
2. Add a magic comment `% !TEX root = \path\to\root\file.tex` to all of your LaTeX source file. The path can be absolute or relative.
3. Open the root file and use `Build Here` command. Alternatively, use `Build LaTeX from active editor` menu item.
4. If all previous checks fail to find a root file, Atom-LaTeX will iterate through all LaTeX files in the root directory.

You can choose one or multiple methods stated above to set the root file.

### Set per-project LaTeX toolchain
LaTeX toolchain can be controlled by either atom configuration or `.latexcfg` file under root directory. If LaTeX projects need special toolchain, one can add a `toolchain` key to this file. An example:
```
{ "toolchain" : "%TEX %ARG %DOC" }
```
This example will only use the defined compiler in atom configuration to build the project. Alternatively, you can also have this example that provides the same functionality:
```
{ "toolchain" : "pdflatex -synctex=1 -interaction=nonstopmode -file-line-error -pdf %DOC" }
```

### Support non-tex files
Atom-LaTeX has limited support to LaTeX source files with a non-`.tex` extension. To consider such files as valid LaTeX documents, one can add a `latex_ext` key to the `.latexcfg` local configuration file. An example:
```
{ "latex_ext": [".tikz", ".Rnw"] }
```
Note that the value must be a JSON array, even when there is only one alternative file extension.

### Enable spell check
- Open setting panel of build-in package `spell-check`.
- Add `text.tex.latex` to the `Grammars` edit box.

## Contributing

- [Creat issues](https://github.com/James-Yu/Atom-LaTeX/issues) for bugs
- [Fork and PR](https://github.com/James-Yu/Atom-LaTeX/pulls) for fixes
- Thank you so much!

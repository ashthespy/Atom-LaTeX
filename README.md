# Atom-LaTeX package

Atom-LaTeX is an extension for [Atom.io](https://atom.io/), aiming to provide all-in-one features and utilities for LaTeX typesetting with Atom.

###### Note
The original package author [`James-Yu`](https://github.com/James-Yu) switched back to [Visual Studio Code](https://code.visualstudio.com/) since late March 2017. If you prefer VS Code as well, check out the sibling of this package [LaTeX-Workshop](https://github.com/James-Yu/LaTeX-Workshop).

## Features

Some features have screenshots/screencasts available [here](https://github.com/James-Yu/Atom-LaTeX/blob/master/GALLERY.md). Have a check!

- Compile LaTeX with BibTeX
- Preview PDF with build-in viewer
- Parse LaTeX compiling log
- Autocomplete
- Syntax highlighting
- Direct and reverse SyncTeX

If you figured out some neat features, that you'd like included, [create an issue](https://github.com/James-Yu/Atom-LaTeX/issues/new)!

## Why another LaTeX package?

Unification provides a seamless experience. Aiming to make it work and work perfectly.

## Requirements

- LaTeX distribution in system PATH. For example, [TeX Live](https://www.tug.org/texlive/).
  -  Please note [MikTeX](https://miktex.org/) does not ship with SyncTeX. See [this link](http://tex.stackexchange.com/questions/338078/how-to-get-synctex-for-windows-to-allow-atom-pdf-view-to-synch#comment877274_338117) for a possible solution.
- [Set LaTeX root file](#root_file).

## Installation

Installing Atom-LaTeX is simple. You can find it in [the atom.io package registry](https://atom.io/packages/atom-latex), or simply run `apm install atom-latex` from the command line.

For cutting edge features or changes, you can clone this repository to the Atom package folder:
- Windows `%USERPROFILE%\.atom\packages`
- Mac/Linux `$HOME/.atom/packages`

## Usage

All commands can be invoked from `Package`→`Atom-LaTeX` menu or from the command palette. Alternatively, keybindings are provided. Each command is invoked if the two key combinations are pressed sequentially.

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

### <a name="root_file"></a>Setting the LaTeX root file
A LaTeX root file is essential for Atom-LaTeX. Building, preview, autocompletion, and more features rely on its proper configuration. Atom-LaTeX provides multiple methods of setting this up.

1. Open the root file, then use the `Build Here` command. Alternatively, use `Build LaTeX from active editor` menu item.

2. Manually select the file by clicking the `home` icon on the control panel

3. Add a magic comment `% !TEX root = \path\to\root\file.tex` to all of your LaTeX source file. The path can be absolute or relative.

4. Create a [project specific `.latexcfg` file](#latexcfg) at the root directory of your project. The file should contain a JSON object with `root` key set to the root file. For example:

   ```
   { "root" : "\path\to\root\file.tex" }
   ```

5. If all previous checks fail to find a root file, Atom-LaTeX will iterate through all LaTeX files in the root directory and set the first file with the sequence `\begin{document}` as the root file.

You can choose one or multiple methods stated above to set the root file.

### <a name="toolchain"></a> Setting up a toolchain
By default [`latexmk`](http://personal.psu.edu/jcc8/software/latexmk/) is used to automate the LaTeX building sequence. This tool is bundled in most LaTeX distributions, and requires [`perl`](https://www.perl.org/get.html) to execute.

If `latexmk` fails, the `custom toolchain` is utilised which by default sequentially runs the typical `pdflatex`>`bibtex`>`pdflatex`>`pdflatex` command chain:

```
%TEX %ARG %DOC.%EXT && %BIB %DOC && %TEX %ARG %DOC.%EXT && %TEX %ARG %DOC.%EXT
```
Multiple commands should be separated by `&&`. Placeholders `%TEX`,`%ARG` and `%BIB` will be replaced by tools defined in the settings menu
`%DOC` will be replaced by the [root LaTeX](root_file) filename (without extension), while `%EXT` gives the file extension


For non `perl` users, other automatic LaTeX helper utilities such as [`texify`](https://docs.miktex.org/manual/texifying.html) or [`arara`](https://www.ctan.org/pkg/arara?lang=en) can also be configured.
  * Sample `custom toolchain` configuration for `texify`
  ```
  texify --synctex --pdf --tex-option=\"-interaction=nonstopmode\" --tex-option=\"-file-line-error\" %DOC.%EXT
  ```
  Do note that `texify` requires the complete root file name with extension to compile.

  * Sample `custom toolchain` configuration for `arara`
  ```
  arara %DOC -v
  ```
  Have a look at [this comment](https://github.com/James-Yu/Atom-LaTeX/issues/4#issuecomment-280690169) for more details on setting up `arara`

### Enable spell check
  - Open the settings panel of Atom core package `spell-check`.
  - Add `text.tex.latex` to the `Grammars` section.


### <a name="latexcfg"></a> Project-based Configuration
Atom currently does not provide per-project configuration. Atom-LaTeX uses a `.latexcfg` file with a JSON object under the root directory of the LaTeX project to partially control its behaviour. Following is a complete example of its content.
   ```
   {
     "root" : "\path\to\root\file.tex",
     "toolchain" : "%TEX %ARG %DOC",
     "latex_ext": [".tikz", ".Rnw"]
   }
   ```
If a key is set, the configuration will overwrite the global one in atom settings.

### <a name="project_toolchain"></a> Set per-project LaTeX toolchain
If LaTeX projects need special toolchains, one can add a `toolchain` key to the `.latexcfg` file. For example:

```
{ "toolchain" : "%TEX %ARG %DOC" }
```
This example will only use the defined compiler in atom configuration to build the project.
 Alternatively, you can also directly specify compilers such as:
```
{ "toolchain" : "pdflatex -synctex=1 -interaction=nonstopmode -file-line-error -pdf %DOC" }
```

### Support for non `.tex` files
Atom-LaTeX has limited support to LaTeX source files with a non `.tex` extension. To consider such files as valid LaTeX documents, one can add a `latex_ext` key to the `.latexcfg` local configuration file. An example:
```
{ "latex_ext": [".tikz", ".Rnw"] }
```
Note that the value must be a JSON array, even when there is only one alternative file extension.

#### Sample toolchain for [`knitr`](https://github.com/yihui/knitr)
```
  {"toolchain": "Rscript -e \"library(knitr); knit('%DOC.%EXT')\" && latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf %DOC"}
```
Have a look at [this thread](https://github.com/James-Yu/Atom-LaTeX/issues/42) for more options for custom toolchains.

## Contributing

- [Create issues](https://github.com/James-Yu/Atom-LaTeX/issues) for bugs
- [Fork and PR](https://github.com/James-Yu/Atom-LaTeX/pulls) for fixes
- Thank you so much!

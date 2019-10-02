## [0.8.11]  2019-10-02
### Fixed
* [(##216)](https://github.com/James-Yu/Atom-LaTeX/issues/#216) Add missing `error` entry type to debug log
* [(##223)](https://github.com/James-Yu/Atom-LaTeX/issues/#223) Remember preview window position
* [(##225)](https://github.com/James-Yu/Atom-LaTeX/issues/#225) Use editor's default `tabLength`
* [(##217)](https://github.com/James-Yu/Atom-LaTeX/issues/#217) Escape `filename.aux` Regex

### Changed
* [(##141)](https://github.com/James-Yu/Atom-LaTeX/issues/#141) Wrap selection with environment
* Update `chokidar` to v3

## [0.8.10]  2019-08-05
### Fixed
* [(##186)](https://github.com/James-Yu/Atom-LaTeX/issues/#186) Fix reference autocomplete ':' issue
* [(##205)](https://github.com/James-Yu/Atom-LaTeX/issues/#205) Fix for filenames with dots

## [0.8.9]  2019-08-02
### Fixed
* [(##187)](https://github.com/James-Yu/Atom-LaTeX/issues/#187) Handle case of no rootDir

## [0.8.8]  2019-07-30
### Fixed
* [(##206)](https://github.com/James-Yu/Atom-LaTeX/issues/#206) Fix viewer issues with Atom 1.39/Electron 3.x

## [0.8.7]  2019-07-24
### Fixed
* [(##129)](https://github.com/James-Yu/Atom-LaTeX/issues/#129) Fix log parser attempting to parse non latex files as well

### Changed
* PDF Viewer improvements
  * Add a 'dark mode' via `invert_viewer` option 
    * Can be toggled with <kbd>ctrl</kbd><kbd>i</kbd>
  * Auto hide toolbar for viewer 
  * Style tweaks for viewer scrollbar

## [0.8.6]  2019-07-01
### Fixed
* [(#176)](https://github.com/James-Yu/Atom-LaTeX/issues/176) Fix `latex-beamer` artefact

### Changed
* Update `pdfjs-dist`
* PDF Viewer improvements
  * SynTeX/Reverse SynTeX indicators
* [(#159)](https://github.com/James-Yu/Atom-LaTeX/pull/171) Extended the log parser to catch more errors

## [0.8.5]  2018-08-31
### Fixed
* [(#158)](https://github.com/James-Yu/Atom-LaTeX/issues/158) Fix filenames escaping with whitespace on Unix
* [(#172)](https://github.com/James-Yu/Atom-LaTeX/issues/172) Fix parsing PDF path with periods
* [(#140)](https://github.com/James-Yu/Atom-LaTeX/issues/140) Disable `<>` bracket matching
* [(#34)](https://github.com/James-Yu/Atom-LaTeX/issues/34) Fix path determination when editor isn't active pane item

### Changed
* [(#157)](https://github.com/James-Yu/Atom-LaTeX/issues/157) Add a `hide_panel` option on startup
* New matches for `figure`, `table` and `includegraphics` which are excluded from spell-check
* Support optional parameters in custom command autocomplete parsing
* [(#136)](https://github.com/James-Yu/Atom-LaTeX/pull/136) Small changes to better support beamer `tex` files

## [0.8.3]  2018-01-27
### Fixed
* [(#95)](https://github.com/James-Yu/Atom-LaTeX/issues/95)  Add `error` listener for `ws` package compatibility
* [(#132)](https://github.com/James-Yu/Atom-LaTeX/issues/132) Fix `$` autocomplete, switch to `bracket-matcher`
* [(#121)](https://github.com/James-Yu/Atom-LaTeX/pull/122) Changes required for upcoming CoffeeScript upgrade

### Changed
* [(#128)](https://github.com/James-Yu/Atom-LaTeX/pull/122) Dismiss Failure Notification when "Show build log" Is Pressed
* PDF Viewer improvements
  * Switch from `iframe` to `webview`
  * Open links is default browser

## [0.8.2]  2017-09-29
### Fixed
* Tweak notification for invalid LaTeX root file
* [(#111)](https://github.com/James-Yu/Atom-LaTeX/issues/111) Better handling of single documents
* [(#16)](https://github.com/James-Yu/Atom-LaTeX/issues/16) Fix PDF window focus for non Windows platforms
* [(#106)](https://github.com/James-Yu/Atom-LaTeX/pull/106) Kill all children process

### Changed
* PDF Viewer improvements
  * Render PDF with WebGL
  * Faster refresh in Tab View
  * Refactor and use `manager.findPDF()`
* [(#117)](https://github.com/James-Yu/Atom-LaTeX/pull/117) Update package dependencies, switch to `pdfjs-dist`
* Use LaTeX Log grammar for highlighting raw logs
  * Set LaTeX Log grammar for raw logs
  * Enable LuaTeX and XeTeX log recognition
* [(#114)](https://github.com/James-Yu/Atom-LaTeX/issues/114) Add error notification for unparsed SyncTeX results
* [(#67)](https://github.com/James-Yu/Atom-LaTeX/issues/67) Add error notification for issues parsing citations
* [(#104)](https://github.com/James-Yu/Atom-LaTeX/pull/104) Add custom commands to autocomplete suggestions
* Clean files in project sub directories as well
* Support syntax highlight for long lines

## [0.8.1]  2017-08-24
### Fixed
* Missing changes in version 0.8.0

## [0.8.0]  2017-08-23
### Changed
* [(#50)](https://github.com/James-Yu/Atom-LaTeX/pull/50) Preliminary `arara` log parsing support
* [(#97)](https://github.com/James-Yu/Atom-LaTeX/pull/97) Add new `%EXT` placeholder for custom toolchains
* [(#98)](https://github.com/James-Yu/Atom-LaTeX/pull/98) Add `.bib` to subfile-autocomplete + code clean up
* [(#100)](https://github.com/James-Yu/Atom-LaTeX/pull/100) Add error notification for invalid LaTeX root file
### Fixed
* [(#102)](https://github.com/James-Yu/Atom-LaTeX/pull/102) Fix root directory determination

## [0.7.13]  2017-08-08
### Fixed
* [(#89)](https://github.com/James-Yu/Atom-LaTeX/pull/89)
* [(#90)](https://github.com/James-Yu/Atom-LaTeX/pull/90)
* [(#92)](https://github.com/James-Yu/Atom-LaTeX/pull/92)
* [(#94)](https://github.com/James-Yu/Atom-LaTeX/pull/94)

## [0.7.12]  2017-07-27
### Fixed
* [(#83)](https://github.com/James-Yu/Atom-LaTeX/pull/83) Fix failures due to buffer.lines being undefined @mortenpi.

## [0.7.11]  2017-06-15
### Fixed
* `await` won't work with coffee-script.

## [0.7.10]  2017-06-15
### Changed
* [(#77)](https://github.com/James-Yu/Atom-LaTeX/issues/77) Cope with async save() in new atom.

## [0.7.9]  2017-05-10
### Changed
* [(#65)](https://github.com/James-Yu/Atom-LaTeX/pull/65) Multi-file handling improvements and minor tweaks.

## [0.7.8]  2017-05-01
### Fixed
* [(#61)](https://github.com/James-Yu/Atom-LaTeX/pull/61) Fix [#59](https://github.com/James-Yu/Atom-LaTeX/issues/59) - Set focus only activeItem is defined.

## [0.7.7]  2017-04-27
### Fixed
* [(#57)](https://github.com/James-Yu/Atom-LaTeX/pull/57) Fix prevBibWatcherClosed issue in [#56](https://github.com/James-Yu/Atom-LaTeX/issues/56).

## [0.7.6]  2017-04-22
### Changed
* [(#47)](https://github.com/James-Yu/Atom-LaTeX/pull/49) Use `chokidar` to watch files and folders.

### Fixed
* [(#49)](https://github.com/James-Yu/Atom-LaTeX/pull/49) Also respect `Focus Viewer` setting for on launching from preview icon.

## [0.7.5]  2017-04-07
### Added
* [(#40)](https://github.com/James-Yu/Atom-LaTeX/pull/40) Added sub-file autocomplete support.

### Changed
* [(#35)](https://github.com/James-Yu/Atom-LaTeX/pull/35) Use `relativizePath` to get current project path and change order in `findMain` to check `findMainConfig` first.
* [(#36)](https://github.com/James-Yu/Atom-LaTeX/pull/36) Display correct file path for infos and warnings.
* [(#44)](https://github.com/James-Yu/Atom-LaTeX/pull/44) `%DOC` now removes file extension.

## [0.7.4]  2017-03-27
### Changed
* [(#32)](https://github.com/James-Yu/Atom-LaTeX/pull/32) Save all files before build.
* [(#31)](https://github.com/James-Yu/Atom-LaTeX/issues/31) Find local config use current active editor directory first.
* [(#30)](https://github.com/James-Yu/Atom-LaTeX/pull/30) Formatted PDF viewer title.
* Slightly adjust SyncTeX accuracy.

## [0.7.3]  2017-03-23
### Added
* [(#22)](https://github.com/James-Yu/Atom-LaTeX/issues/22) Add tikz and knitr syntax highlighting.

### Changed
* [(#25)](https://github.com/James-Yu/Atom-LaTeX/issues/25) [(#26)](https://github.com/James-Yu/Atom-LaTeX/pull/26) Remove pdf page borders.
* Hide PDF Viewer menus when possible.

## [0.7.2]  2017-03-19
### Added
* [(#21)](https://github.com/James-Yu/Atom-LaTeX/issues/21) A setting item to auto-collapse log panel upon successful building process.
* [(#22)](https://github.com/James-Yu/Atom-LaTeX/issues/22) Support LaTeX files with non-`.tex` extension.

### Changed
* [(#21)](https://github.com/James-Yu/Atom-LaTeX/issues/21) Now raw log will be contained in a temp file to avoid the save file popup.

### Fixed
* [(#20)](https://github.com/James-Yu/Atom-LaTeX/issues/20) `\begin` environment wrongly uses two spaces instead of `\t`.

## [0.7.1]  2017-03-15
### Added
* A setting item controlling the PDF viewer focus behavior.

### Changed
* [(#16)](https://github.com/James-Yu/Atom-LaTeX/issues/16) Tweak the PDF viewer gain focus behavior.

## [0.7.0]  2017-03-12
### Added
* [(#18)](https://github.com/James-Yu/Atom-LaTeX/issues/18) Per-project toolchain setting in `.latexcfg` file.

### Changed
* [(#16)](https://github.com/James-Yu/Atom-LaTeX/issues/16) The viewer window is bring to front after building process or SyncTeX.

### Fixed
* [(#4)](https://github.com/James-Yu/Atom-LaTeX/issues/4) Atom-LaTeX complaining `arara` returning `null`.

## [0.6.3]  2017-03-06
### Added
* A delay-minimap-refresh feature to prevent keystroke stuttering in long LaTeX files.

## [0.6.2]  2017-02-28
### Fixed
* Build-after-save not working.

## [0.6.1]  2017-02-28
### Changed
* [(#9)](https://github.com/James-Yu/Atom-LaTeX/issues/9) Use glob matching for cleaning project.
* [(#11)](https://github.com/James-Yu/Atom-LaTeX/issues/11) Dollar sign matching pattern.
* [(#12)](https://github.com/James-Yu/Atom-LaTeX/issues/12) Focus editor window after reverse synctex.
* Click on home icon of control bar to manually set root file.

### Fixed
* Significantly reduce loading time with lazy load.

## [0.6.0]  2017-02-23
### Added
* Clean LaTeX project command and auto-clean after build.

### Changed
* Also consider current buffer when generating command auto-complete.

## [0.5.8]  2017-02-22
### Changed
* Now Atom-LaTeX prioritize `.latexcfg` file over magic comments.

### Fixed
* Root file cannot have spaces in file name.

## [0.5.7]  2017-02-21
### Fixed
* bibtex file cannot be located elsewhere than the root directory.

## [0.5.6]  2017-02-21
### Fixed
* [(#6)](https://github.com/James-Yu/Atom-LaTeX/issues/6) bibtex file cannot include file extension.

## [0.5.5]  2017-02-21
### Fixed
* [(#6)](https://github.com/James-Yu/Atom-LaTeX/issues/6) `\addbibresource` is not considered as bibtex file definition command.

## [0.5.4]  2017-02-20
### Fixed
* LaTeX error does not show in panel when latexmk toolchain is used.

## [0.5.3]  2017-02-20
### Changed
* Better latexmk log message parsing.

## [0.5.2]  2017-02-19
### Changed
* [(#5)](https://github.com/James-Yu/Atom-LaTeX/issues/5) Remove default stdout buffer size limit.

## [0.5.1]  2017-02-17
### Changed
* Atom-LaTeX log area is now resizable.

## [0.5.0]  2017-02-16
### Changed
* Redesign Atom-LaTeX control panel.
* Move screencasts to a new file to avoid lag while loading settings.

## [0.4.5]  2017-02-15
### Changed
* LaTeX command autocompletion now also sort by the number of appearances.

## [0.4.4]  2017-02-13
### Changed
* Way of showing error notification.

## [0.4.3]  2017-02-09
### Changed
* Default command autocompletion is to create a new line.
* All default key binds to avoid conflict

### Fixed
* Not including new references in unsaved buffer.
* Not parsing fatal error LaTeX log.
* Mispositioned environment autocompletion items.

## [0.4.2]  2017-02-08
### Fixed
* Keymap not properly binded.
* TabView Panel undefined preventing switching preview mode.

## [0.4.1]  2017-02-08
### Added
* Better logging for main file detection.
* Two new methods to set LaTeX main file.

## [0.4.0]  2017-02-07
### Added
* Add a preview-in-tab PDF viewer.

### Fixed
* Remove console messages.

## [0.3.3]  2017-02-06
### Added
* Auto-enable word wrap.
* Allow `ctrl`+`/` for auto comment.

### Fixed
* Wrong direct synctex position when word wrap is on

## [0.3.2]  2017-02-06
### Fixed
* Unnecessary `\begin{\w+}` syntax highlight leading to typing lag.
* Escaped curly brackets in citation title should not be removed.

## [0.3.1]  2017-02-05
### Changed
* Command autocomplete will guess the number of curly brackets needed.

## [0.3.0]  2017-02-05
### Added
* Direct and reverse SyncTeX support.

### Changed
* Status bar now alerts LaTeX building warninngs.

### Fixed
* Pre-mature activation of package leading to significant startup time.

## [0.2.6]  2017-02-03
### Added
* Use npm package `latex-symbols-list` to develop more autocomplete symbols.

## [0.2.5]  2017-02-03
### Added
* Autocomplete for commands and environments.
  * Commands are gathered from all LaTeX source files in the project, and some predefined ones.
  * Environments are predefined.

### Changed
* Now autocomplete will sort according to prefix and displayed text.

## [0.2.4] - 2017-02-03
### Added
* A new `Build LaTeX from Active Editor` command to set main LaTeX file to current active editor if it contains `\begin{document}`, and start building.

## [0.2.3] - 2017-02-03
### Changed
* Use cached results for autocomplete when already typed some characters to reduce I/O operations.

### Fixed
* Autocomplete prefix is not removed after confirming a suggestion.

## [0.2.2] - 2017-02-02
### Added
* Screencasts of some select features.

## [0.2.1] - 2017-02-02
### Added
* Auto-complete for cross-references.

### Changed
* Now Atom-LaTeX will search all tex files recursively from the main file with `\input{}` commands.

## [0.2.0] - 2017-02-01
### Added
* Auto-complete for citations.
  * Atom-LaTeX will search all bibTeX files referenced in the main LaTeX file to develop bibitem keys.

### Fixed
* Now alerts when no main LaTeX file can be detected.
  * It will try to check the current active editor first. If not, all root files are checked.

## [0.1.1] - 2017-02-01
### Changed
* Create new Atom window to display PDF viewer.

### Fixed
* Menu items not working.

## [0.1.0] - 2017-01-31
### Added
* Initial release.

## [0.2.7]  2017-02-04
### Added
* Syntax highlight using textmate latex bundle.
### Changed
* Lazy load package to reduce activation time.
* Readme figures are not included to reduce the package size.

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

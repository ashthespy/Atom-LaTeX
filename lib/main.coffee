{ CompositeDisposable, Disposable } = require 'atom'
path = require 'path'
Builder = require './builder'
Manager = require './manager'
Server = require './server'
Viewer = require './viewer'
Parser = require './parser'
LogPanel = require './log-panel'

module.exports =
  config:
    toolchain:
      title: 'Toolchain to use'
      order: 1
      description: 'The toolchain to build LaTeX. `auto` tries `latexmk \
                    toolchain` and fallbacks to the default `custom` toolchain.'
      type: 'string'
      default: 'auto'
      enum: [
        'auto'
        'latexmk toolchain'
        'custom toolchain'
      ]
    latexmk_param:
      title: 'latexmk execution parameters'
      order: 2
      description: 'The parameters to use when invoking `latexmk`.'
      type: 'string'
      default: '-synctex=1 -interaction=nonstopmode -file-line-error -pdf'
    custom_toolchain:
      title: 'Custom toolchain commands'
      order: 3
      description: 'The commands to execute in `custom` toolchain. Multiple \
                    commands should be seperated by `&&`. Placeholders `%TEX` \
                    `%ARG` `%BIB` will be replaced by the following settings, \
                    and `%DOC` will be replaced by the main LaTeX file which \
                    is automatically detected under the root folder of the \
                    openning project.'
      type: 'string'
      default: '%TEX %ARG %DOC && %BIB %DOC && %TEX %ARG %DOC && %TEX %ARG %DOC'
    compiler:
      title: 'LaTeX compiler to use'
      order: 4
      description: 'The LaTeX compiler to use in `custom` toolchain. Replaces \
                    all `%TEX` string in `custom` toolchain command.'
      type: 'string'
      default: 'pdflatex'
    compiler_param:
      title: 'LaTeX compiler execution parameters'
      order: 5
      description: 'The parameters to use when invoking the custom compiler. \
                    Replaces all `%ARG` string in `custom` toolchain command.'
      type: 'string'
      default: '-synctex=1 -interaction=nonstopmode -file-line-error'
    bibtex:
      title: 'bibTeX compiler to use'
      order: 6
      description: 'The bibTeX compiler to use in `custom` toolchain. Replaces \
                    all `%BIB` string in `custom` toolchain command.'
      type: 'string'
      default: 'bibtex'
    build_after_save:
      title: 'Build LaTeX after saving'
      order: 7
      description: 'Start building with toolchain after saving a `.tex` file.'
      type: 'boolean'
      default: true
    preview_after_build:
      title: 'Preview PDF after building process'
      order: 8
      description: 'Open a webbrowser tab to preview the generated PDF file \
                    after successfully building LaTeX.'
      type: 'boolean'
      default: true

  activate: ->
    @disposables = new CompositeDisposable

    @latex = new AtomLaTeX
    global.atom_latex = @latex
    @latex.package = this
    @disposables.add @latex

    @disposables.add atom.commands.add 'atom-workspace',
      'atom-latex:build': () => this.latex.builder.build()
      'atom-latex:preview': () => this.latex.viewer.openViewerTab()
      'atom-latex:kill': () => this.latex.builder.killProcess()
      'atom-latex:show-log': () => this.latex.logPanel.showPanel()

    @disposables.add atom.workspace.observeTextEditors (editor) =>
      @disposables.add editor.onDidSave () =>
        activeEditor = atom.workspace.getActiveTextEditor()
        if editor == activeEditor and \
            atom.config.get('atom-latex.build_after_save') and \
            editor.buffer.file?.path and \
            path.extname(editor.buffer.file?.path) == '.tex'
          @latex.builder.build()

    @latex.logPanel.showText icon: 'check', 'Activated.', 5000, true

  deactivate: ->
    return @disposables.dispose()

class AtomLaTeX extends Disposable
  constructor: ->
    super () => @disposables.dispose()
    @disposables = new CompositeDisposable

    @builder = new Builder(this)
    @manager = new Manager(this)
    @viewer = new Viewer(this)
    @server = new Server(this)
    @logPanel = new LogPanel(this)
    @parser = new Parser(this)

    @disposables.add @builder, @manager, @server, @viewer, @logPanel

  dispose: ->
    @disposables.dispose()

{ CompositeDisposable, Disposable } = require 'atom'
path = require 'path'
Builder = require './builder'
Manager = require './manager'
Server = require './server'
Viewer = require './viewer'
Parser = require './parser'
LogPanel = require './log-panel'
Provider = require './provider'

module.exports =
  config: require './config'

  activate: ->
    @disposables = new CompositeDisposable

    @latex = new AtomLaTeX
    global.atom_latex = @latex
    @latex.package = this
    @disposables.add @latex

    @disposables.add atom.commands.add 'atom-workspace',
      'atom-latex:build': () => this.latex.builder.build()
      'atom-latex:preview': () => this.latex.viewer.openViewerNewWindow()
      'atom-latex:kill': () => this.latex.builder.killProcess()
      'atom-latex:show-log': () => this.latex.logPanel.showPanel()

    @disposables.add atom.workspace.observeTextEditors (editor) =>
      @disposables.add editor.onDidSave () =>
        if atom.config.get('atom-latex.build_after_save') and \
            editor.buffer.file?.path and \
            path.extname(editor.buffer.file?.path) == '.tex'
          @latex.builder.build()

    @latex.logPanel.showText icon: 'check', 'Activated.', 5000, true

  deactivate: ->
    return @disposables.dispose()

  provide: ->
    return @latex.provider.provider

class AtomLaTeX extends Disposable
  constructor: ->
    @disposables = new CompositeDisposable

    @builder = new Builder(this)
    @manager = new Manager(this)
    @viewer = new Viewer(this)
    @server = new Server(this)
    @logPanel = new LogPanel(this)
    @parser = new Parser(this)
    @provider = new Provider(this)

    @disposables.add @builder, @manager, @server, @viewer, @logPanel, @parser,
      @provider

  dispose: ->
    @disposables.dispose()

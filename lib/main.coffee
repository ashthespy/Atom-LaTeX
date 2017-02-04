{ CompositeDisposable, Disposable } = require 'atom'
path = require 'path'

module.exports =
  config: require './config'

  activate: ->
    @disposables = new CompositeDisposable
    @activated = false
    global.atom_latex = this
    @disposables.add atom.workspace.observeTextEditors (editor) =>
      return if @activated
      editor.observeGrammar (grammar) =>
        if (grammar.packageName is 'atom-latex') or
          (grammar.scopeName is 'text.tex.latex') or
          (grammar.name is 'LaTeX')
            promise = new Promise (resolve, reject) => @lazyLoad()

  lazyLoad: ->
    @activated = true

    @latex = new AtomLaTeX

    @provide()
    @provider.lazyLoad(@latex)
    @latex.provider = @provider
    @latex.package = this

    @disposables.add @latex, @provider

    @disposables.add atom.commands.add 'atom-workspace',
      'atom-latex:build': () => this.latex.builder.build()
      'atom-latex:build-here': () => this.latex.builder.build(true)
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
    if !@provider?
      Provider = require './provider'
      @provider = new Provider()
    return @provider.provider

class AtomLaTeX extends Disposable
  constructor: ->
    @disposables = new CompositeDisposable
    Builder = require './builder'
    Manager = require './manager'
    Server = require './server'
    Viewer = require './viewer'
    Parser = require './parser'
    LogPanel = require './log-panel'

    @builder = new Builder(this)
    @manager = new Manager(this)
    @viewer = new Viewer(this)
    @server = new Server(this)
    @logPanel = new LogPanel(this)
    @parser = new Parser(this)

    @disposables.add @builder, @manager, @server, @viewer, @logPanel, @parser

  dispose: ->
    @disposables.dispose()

module.exports =
  config: require './config'

  activate: ->
    { CompositeDisposable } = require 'atom'
    @disposables = new CompositeDisposable
    @activated = false
    global.atom_latex = this
    @disposables.add atom.workspace.observeTextEditors (editor) =>
      return if @activated
      editor.observeGrammar (grammar) =>
        if (grammar.packageName is 'atom-latex') or
            (grammar.scopeName.indexOf('text.tex.latex') > -1) or
            (grammar.name is 'LaTeX')
          promise = new Promise (resolve, reject) =>
            setTimeout(( => @lazyLoad()), 100)
            resolve()

  lazyLoad: ->
    return if @activated
    @activated = true

    @latex = new AtomLaTeX

    @provide()
    @provider.lazyLoad(@latex)
    @latex.provider = @provider
    @latex.package = this

    @disposables.add @latex

    @disposables.add atom.commands.add 'atom-workspace',
      'atom-latex:build': () => @latex.builder.build()
      'atom-latex:build-here': () => @latex.builder.build(true)
      'atom-latex:clean': () => @latex.cleaner.clean()
      'atom-latex:preview': () => @latex.viewer.openViewerNewWindow()
      'atom-latex:preview-tab': () => @latex.viewer.openViewerNewTab()
      'atom-latex:kill': () => @latex.builder.killProcess()
      'atom-latex:toggle-panel': () => @latex.panel.togglePanel()
      'atom-latex:synctex': () => @latex.locator.synctex()
      'atom-latex:tools-doublequote': () => @latex.provider.syntax.doublequote()
      'atom-latex:tools-environment': () => @latex.provider.command.environment()

    path = require 'path'
    @disposables.add atom.workspace.observeTextEditors (editor) =>
      @disposables.add editor.onDidSave () =>
        if atom.config.get('atom-latex.build_after_save') and \
            editor.buffer.file?.path
          if @latex.manager.isTexFile(editor.buffer.file?.path)
            @latex.builder.build()

    if @minimap? and atom.config.get('atom-latex.delayed_minimap_refresh')
      @disposables.add @minimap.observeMinimaps (minimap) =>
        minimapElement = atom.views.getView(minimap)
        editor = minimap.getTextEditor()
        if editor.buffer.file?.path and \
            @latex.manager.isTexFile(editor.buffer.file?.path)
          handlers = editor.emitter?.handlersByEventName?['did-change']
          if handlers
            for i of handlers
              if handlers[i].toString().indexOf('this.emitChanges(changes)') < 0
                continue
              handlers[i] = (changes) ->
                clearTimeout(minimap.latexTimeout)
                minimap.latexTimeout = setTimeout( ->
                  minimap.emitChanges(changes)
                , 500)
    if atom.config.get('atom-latex.hide_panel')
      @latex.panel.hidePanel()

  deactivate: ->
    @latex?.dispose()
    @disposables.dispose()

  provide: ->
    if !@provider?
      Provider = require './provider'
      @provider = new Provider()
      @disposables.add @provider
    return @provider.provider

  consumeMinimap: (minimap) ->
    @minimap = minimap

  consumeStatusBar: (statusBar) ->
    if !@status?
      Status = require './view/status'
      @status = new Status
      @disposables.add @status
    @status.attach statusBar
    { Disposable } = require 'atom'
    return new Disposable( => @status.detach())

class AtomLaTeX
  constructor: ->
    { CompositeDisposable } = require 'atom'
    @disposables = new CompositeDisposable
    Builder = require './builder'
    Cleaner = require './cleaner'
    Manager = require './manager'
    Server = require './server'
    Viewer = require './viewer'
    Parser = require './parser'
    Locator = require './locator'
    Panel = require './view/panel'
    Logger = require './logger'

    @builder = new Builder(this)
    @cleaner = new Cleaner(this)
    @manager = new Manager(this)
    @viewer = new Viewer(this)
    @server = new Server(this)
    @parser = new Parser(this)
    @locator = new Locator(this)
    @panel = new Panel(this)
    @logger = new Logger(this)

    @disposables.add @builder, @cleaner, @manager, @server, @viewer, @parser,
      @locator, @panel, @logger

  dispose: ->
    @disposables.dispose()

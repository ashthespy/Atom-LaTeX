{ CompositeDisposable, Disposable } = require 'atom'
Builder = require './builder'
Manager = require './manager'
Server = require './server'
Viewer = require './viewer'
Parser = require './parser'
LogPanel = require './log-panel'

module.exports =
  activate: ->
    @disposables = new CompositeDisposable

    @latex = new AtomLaTeX
    global.atom_latex = @latex
    @disposables.add @latex

    @disposables.add atom.commands.add 'atom-workspace',
      'Atom-LaTeX:build': () => this.latex.builder.build()
      'Atom-LaTeX:preview': () => this.latex.viewer.openViewerTab()
      'Atom-LaTeX:kill': () => this.latex.builder.killProcess()
      'Atom-LaTeX:show-log': () => this.latex.logPanel.showPanel()

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

{ CompositeDisposable, Disposable } = require 'atom'
Builder = require './builder'
Manager = require './manager'
Server = require './server'
Viewer = require './viewer'
Status = require './view/status'

module.exports =
  activate: ->
    @disposables = new CompositeDisposable

    @latex = new AtomLaTeX
    global.latex = @latex
    @disposables.add @latex

    @disposables.add atom.commands.add 'atom-workspace', {
      'Atom-LaTeX:build': () => this.latex.builder.build(),
      'Atom-LaTeX:preview': () => this.latex.viewer.openViewerTab(),
      'Atom-LaTeX:kill': () => this.latex.builder.killProcess(),
    }

    @latex.status.showText 'Atom-LaTeX Activated.', 5000

  deactivate: ->
    return @disposables.dispose()

  consumeStatusBar: (statusBar) ->
    @latex.status.attach(statusBar)
    @disposables.add new Disposable => @latex.status.detach()

class AtomLaTeX extends Disposable
  constructor: ->
    super(() => @disposables.dispose())
    @disposables = new CompositeDisposable

    @builder = new Builder(this)
    @manager = new Manager(this)
    @viewer = new Viewer(this)
    @server = new Server(this)
    @status = new Status(this)

    @disposables.add @builder, @manager, @server, @viewer

  dispose: ->
    @disposables.dispose()

{ Disposable } = require 'atom'
getCurrentWindow = require('electron').remote.getCurrentWindow
BrowserWindow = require('electron').remote.BrowserWindow
fs = require 'fs'
path = require 'path'

module.exports =
class Viewer extends Disposable
  constructor: (latex) ->
    @latex = latex
    @client = {}

  dispose: ->
    if @window? and !@window.isDestroyed()
      @window.destroy()

  wsHandler: (ws, msg) ->
    data = JSON.parse msg
    switch data.type
      when 'open'
        @client.ws?.close()
        @client.ws = ws
      when 'loaded'
        if @client.position and @client.ws?
          @client.ws.send JSON.stringify @client.position
        @client.ws.send JSON.stringify {
                            type: 'params',
                            invert: atom.config.get('atom-latex.invert_viewer'),
                            }
      when 'position'
        @client.position = data
      when 'click'
        @latex.locator.locate(data)
      when 'close'
        @client.ws = undefined
      when 'link' # Open link externally
        require('electron').shell.openExternal(data.href)

  refresh: ->
    newTitle = path.basename(@latex.manager.findPDF())

    if @tabView? and @tabView.title isnt newTitle and\
        atom.workspace.paneForItem(@tabView)?
      atom.workspace.paneForItem(@tabView).activeItem.updateTitle(newTitle)
    else if @window? and !@window.isDestroyed() and @window.getTitle() isnt newTitle
      @window.setTitle("""Atom-LaTeX PDF Viewer - [#{@latex.mainFile}]""")
    @client.ws?.send JSON.stringify type: "refresh"

    @latex.viewer.focusViewer()
    if !atom.config.get('atom-latex.focus_viewer')
      @latex.viewer.focusMain()

  focusViewer: ->
    if @window? and !@window.isDestroyed()
      @window.setBounds(@window.getBounds())
      @window.focus() 

  focusMain: ->
    @self.focus() if @self? and !@self.focused

  synctex: (record) ->
    @client.ws?.send JSON.stringify
      type: "synctex"
      data: record
    if atom.config.get('atom-latex.focus_viewer')
      @focusViewer()

  openViewer: ->
    if @client.ws?
      @refresh()
    else if atom.config.get('atom-latex.preview_after_build') is\
        'View in PDF viewer window'
      @openViewerNewWindow()
      if !atom.config.get('atom-latex.focus_viewer')
        @latex.viewer.focusMain()
    else if atom.config.get('atom-latex.preview_after_build') is\
        'View in PDF viewer tab'
      @openViewerNewTab()
      if !atom.config.get('atom-latex.focus_viewer')
        @latex.viewer.focusMain()

  openViewerNewWindow: ->
    pdfPath = @latex.manager.findPDF()
    if !fs.existsSync pdfPath
      @latex.logger.debuglog.error("""#{pdfPath} Doesn't exist""")
      return

    if !@getUrl()
      return

    if @tabView? and atom.workspace.paneForItem(@tabView)?
      atom.workspace.paneForItem(@tabView).destroyItem(@tabView)
      @tabView = undefined
    if !@window? or @window.isDestroyed()
      @self = getCurrentWindow()
      @window = new BrowserWindow()
    else
      @window.show()
      @window.focus()

    @window.loadURL(@url)
    @window.setMenuBarVisibility(false)
    @window.setTitle("""Atom-LaTeX PDF Viewer - [#{@latex.mainFile}]""")

  openViewerNewTab: ->
    pdfPath = @latex.manager.findPDF()

    if !fs.existsSync pdfPath
      return

    if !@getUrl()
      return

    @self = atom.workspace.getActivePane()
    if @tabView? and atom.workspace.paneForItem(@tabView)?
      atom.workspace.paneForItem(@tabView).activateItem(@tabView)
    else
      @tabView = new PDFView(@url,path.basename(pdfPath))
      atom.workspace.getActivePane().splitRight().addItem(@tabView)

  getUrl: ->
    try
      { address, port } = @latex.server.http.address()
      @url = """http://#{address}:#{port}/viewer.html?file=preview.pdf"""
    catch err
      @latex.server.openTab = true
      return false
    return true

class PDFView
  constructor: (url,title) ->
    @element = document.createElement 'webview'
    @element.setAttribute 'src', url
    @element.addEventListener 'console-message', (e) -> console.log e.message
    @title = title
    @titleCallbacks = []

  updateTitle:(newTitle) ->
    @title = newTitle
    @titleCallbacks.map (cb) -> cb()
    return true

  onDidChangeTitle: (cb) ->
    @titleCallbacks.push(cb)
    return dispose: () => @removeTitleCallback(cb)

  removeTitleCallback: (cb) ->
    @titleCallbacks.pop(cb)

  getTitle: ->
    return """Atom-LaTeX - #{@title}"""

  serialize: ->
    return @element.getAttribute 'src'

  destroy: ->
    @element.remove()

  getElement: ->
    return @element

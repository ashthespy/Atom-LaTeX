{ Disposable } = require 'atom'
BrowserWindow = require('electron').remote.BrowserWindow
fs = require 'fs'

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
        if @client.position
          @client.ws.send JSON.stringify @client.position
      when 'position'
        @client.position = data
      when 'close'
        @client.ws = undefined

  refresh: () ->
    @client.ws?.send JSON.stringify type:"refresh"

  openViewerNewWindow: ->
    if !@latex.manager.findMain()
      return

    pdfPath = """#{@latex.mainFile.substr(
      0, @latex.mainFile.lastIndexOf('.'))}.pdf"""
    if !fs.existsSync pdfPath
      return

    if !@getUrl()
      return

    if !@window? or @window.isDestroyed()
      @window = new BrowserWindow()
    else
      @window.show()
      @window.focus()

    @window.loadURL(@url)
    @window.setMenu(null)
    @window.setTitle("""Atom-LaTeX PDF Viewer - [#{@latex.mainFile}]""")

  getUrl: ->
    try
      { address, port } = @latex.server.http.address()
      @url = """http://#{address}:#{port}/viewer.html?file=preview.pdf"""
    catch err
      @latex.server.openTab = true
      return false
    return true

{ Disposable } = require 'atom'
open = require 'open'
fs = require 'fs'

module.exports =
class Viewer extends Disposable
  constructor: (latex) ->
    @latex = latex
    @client = {}

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

  openViewerTab: ->
    if !@latex.manager.findMain()
      return

    pdfPath = """#{@latex.mainFile.substr(
      0, @latex.mainFile.lastIndexOf('.'))}.pdf"""
    if !fs.existsSync pdfPath
      return

    if @getUrl()
      open(@url)

  getUrl: ->
    try
      { address, port } = @latex.server.http.address()
      @url = """http://#{address}:#{port}/viewer.html?file=preview.pdf"""
    catch err
      @latex.server.openTab = true
      return false
    return true

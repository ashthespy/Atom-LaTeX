{ Disposable } = require 'atom'
open = require 'open'
fs = require 'fs'

module.exports =
class Viewer extends Disposable
  constructor: (latex) ->
    super () => @disposables.dispose()
    @latex = latex

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

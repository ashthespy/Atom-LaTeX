{ Disposable } = require 'atom'

module.exports =
class Status extends Disposable
  constructor: (toolbox) ->
    super(() => @disposables.dispose())
    @toolbox = toolbox
    @tileItem = new StatusTileView

  attach: (statusBar) ->
    @tile = statusBar.addLeftTile {
      item: @tileItem.element,
      priority: 10
    }

  showText: (text, timeout) ->
    clearTimeout(@timeout) if @timeout
    @tileItem.link.text = text
    if timeout?
      @timeout = setTimeout (() => @tileItem.link.text = ''), timeout

  detach: ->
    @tileItem?.destroy()
    @tileItem = undefined
    @tile?.destroy()
    @tile = undefined

class StatusTileView
  constructor: ->
    @element = document.createElement 'status-bar-latex-toolbox'
    @element.classList.add 'inline-block'
    @link = document.createElement 'a'
    @link.classList.add 'inline-block'
    @link.text = ''
    @link.href = '#'
    @element.appendChild(@link)

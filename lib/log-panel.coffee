{ Disposable } = require 'atom'
{ MessagePanelView, LineMessageView } = require 'atom-message-panel'

module.exports =
class LogPanel extends Disposable
  constructor: (latex) ->
    super () => @disposables.dispose()
    @latex = latex
    @title = 'Atom-LaTeX'
    @logPanelView = new LogPanelView(@title)
    @logPanelView.attach()
    @logPanelView.toggle()

  showText: (text, timeout, hide) ->
    clearTimeout(@timeout) if @timeout
    @logPanelView.attach()
    @logPanelView.heading.text """#{@title} Status: #{text}"""
    if timeout?
      @timeout = setTimeout (() =>
        @logPanelView.heading.text @title
        @logPanelView.close() if hide
      ), timeout

  show: () ->
    @logPanelView.attach()
  toggle: () ->
    @logPanelView.toggle()
  unfold: () ->
    @logPanelView.unfold()

class LogPanelView extends MessagePanelView
  constructor: (title) ->
    super title: title
    @addClass 'atom-latex'

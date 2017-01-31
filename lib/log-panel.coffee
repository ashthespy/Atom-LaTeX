{ Disposable } = require 'atom'
{ MessagePanelView, LineMessageView, View } = require 'atom-message-panel'
{ $$ } = require 'atom-space-pen-views'

module.exports =
class LogPanel extends Disposable
  constructor: (latex) ->
    super () => @disposables.dispose()
    @latex = latex
    @logPanelView = new LogPanelView(@title)
    @logPanelView.attach()

    @logPanelView.showLogBtn.click () => @showLog()

  showText: (icon, text, timeout, hide) ->
    clearTimeout(@timeout) if @timeout
    @logPanelView.attach()
    @setTitle(icon, text)
    if timeout?
      @timeout = setTimeout (() =>
        @setTitle(icon)
        @logPanelView.close() if hide
      ), timeout

  setTitle: (icon, text) ->
    classes = ['icon', """icon-#{icon.icon}"""]
    if icon.spin
      classes.push 'icon-spin'
    title = """<div id="atom-latex-log-icon"\
                    class="#{classes.join ' '}">\
               </div>\
               <span class="atom-latex-title">Atom-LaTeX</span>"""
    if text
      title += """<span class="atom-latex-title"> Status: #{text}</span>"""
    @logPanelView.heading.html title

  showLog: () ->
    cmd = @latex?.builder.execCmds?[@latex?.builder.execCmds?.length - 1]
    log = @latex?.builder.buildLogs?[@latex?.builder.buildLogs?.length - 1]
    if cmd?
      atom.workspace.open().then(
        (editor) ->
          editor.setText("""> #{cmd}\n\n#{log}""")
      )

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
    @heading.parent().css({'padding': 5})

    @showLogBtn = $$(() ->
      this.div
        class: 'heading-show-in-tab inline-block icon-file-text',
        style: 'cursor: pointer;',
        title: 'Show log in new tab'
    )
    @showLogBtn.insertBefore(@btnAutoScroll)

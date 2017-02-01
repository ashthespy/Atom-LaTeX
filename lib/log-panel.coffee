{ Disposable } = require 'atom'
{ MessagePanelView, LineMessageView,
  PlainMessageView, View } = require 'atom-message-panel'
{ $$ } = require 'atom-space-pen-views'

module.exports =
class LogPanel extends Disposable
  constructor: (latex) ->
    @latex = latex
    @logPanelView = new LogPanelView
    @logPanelView.attach()

    @logPanelView.showLogBtn.click () => @showLog()

  showPanel: () ->
    @logPanelView.attach()

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

  addStepLog: (id, cmd) ->
    msg = new PlainMessageView message: """Step #{id}> #{cmd}"""
    @logPanelView.add msg
    @logPanelView.updateScroll()
    @logPanelView.setSummary msg.getSummary()

  addPlainLog: (msg) ->
    msg = new PlainMessageView message: msg
    @logPanelView.add msg
    @logPanelView.updateScroll()
    @logPanelView.setSummary summary: ''

  addParserLog: (item) ->
    msg = new LogMessageView item
    @logPanelView.add msg
    @logPanelView.updateScroll()
    @logPanelView.setSummary summary: ''

  show: () ->
    @logPanelView.attach()
  toggle: () ->
    @logPanelView.toggle()
  unfold: () ->
    @logPanelView.unfold()
  clear: () ->
    @logPanelView.clear()

class LogPanelView extends MessagePanelView
  constructor: () ->
    super
      autoScroll: true
    @addClass 'atom-latex'
    @heading.parent().css({'padding': 5})

    @showLogBtn = $$(() ->
      this.div
        class: 'heading-show-in-tab inline-block icon-file-text',
        style: 'cursor: pointer;',
        title: 'Show log in new tab'
    )
    @showLogBtn.insertBefore(@btnAutoScroll)

class LogMessageView extends LineMessageView
  constructor: (item) ->
    super
      line: item.line
      message: item.text
      file: item.file

    @logType = $$(() ->
      this.div
        class: """message inline-block atom-latex-parser-message \
                  atom-latex-#{item.type}"""
    )
    @logType.text item.type.charAt(0).toUpperCase() + item.type.slice(1)
    @logType.insertBefore(@position)

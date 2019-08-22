{ Disposable } = require 'atom'

module.exports =
class Logger extends Disposable
  constructor: (latex) ->
    @latex = latex
    @log = []
    @debuglog = new DebugLog

  missingMain: ->
    if @missingMainNotification? and !@missingMainNotification.dismissed
      return
    @missingMainNotification =
      atom.notifications.addError(
        """Cannot find the LaTeX root file with `\\begin{document}`.""", {
          dismissable: true
          description:
            """Please configure your LaTeX root file first. You can use any one\
               of the following methods to do so:
               1. Click the `home` icon on the control bar.
               2. Create a `.latexcfg` file at the root directory of your\
                  project. The file should contain a json object with `root`\
                  key set to the root file. An example:
                  ```
                  { "root" : "\\path\\to\\root\\file.tex" }
                  ```
               3. Add a magic comment \
                  `% !TEX root = \\path\\to\\root\\file.tex` \
                  to all of your LaTeX source file. The path can be absolute \
                  or relative.
               4. Open the root file and use `Build Here` command. \
                  Alternatively, use `Build LaTeX from active editor` menu item.
               5. If all previous checks fail to find a root file, Atom-LaTeX \
                  will iterate through all LaTeX files in the root directory.
               You can choose one or multiple methods stated above to set\
               the root file.
               """
          buttons: [{
            text: "Dismiss"
            onDidClick: => @missingMainNotification.dismiss() \
              if @missingMainNotification? and \
                !@missingMainNotification.dismissed
          }]
        })

  setMain: (method) ->
    if @setMainNotification? and !@setMainNotification.dismissed
      @setMainNotification.dismiss()

    switch method
      when 'self'
        methodText = 'The active editor is a valid LaTeX main file.'
      when 'magic'
        methodText = 'The active editor has the magic comment line.'
      when 'config'
        methodText = 'The configuration file setting.'
      when 'all'
        methodText = 'Found in the root directory.'

    @setMainNotification =
      atom.notifications.addInfo(
        """Set the following file as LaTeX main file.""", {
          detail: @latex.mainFile
          description: """Reason: #{methodText}"""
        }
      )

  processError: (title, msg, buildError, button) ->
    if buildError
      @clearBuildError()
    error =
      atom.notifications.addError(title, {
        detail: msg
        dismissable: true
        buttons: button
      })
    if buildError
      @buildError = error

  clearBuildError: ->
    if @buildError? and !@buildError.dismissed
      @buildError.dismiss()

  showLog: () ->
    cmd = @latex?.builder.execCmds?[@latex?.builder.execCmds?.length - 1]
    log = @latex?.builder.buildLogs?[@latex?.builder.buildLogs?.length - 1]
    if cmd?
      tmp = require('tmp')
      fs = require('fs')
      logFile = tmp.fileSync()
      fs.writeFileSync(logFile.fd,"""> #{cmd}\n\n#{log}""")
      atom.workspace.open(logFile.name).then((editor) ->
        # Force LaTeX Log editor grammar
        atom.textEditors.setGrammarOverride(editor, 'text.log.latex')
        )

  showDebugLog: () ->
    atom.workspace.open().then( (editor) =>
      editor.setText(
        """ <detail>
          <summary> Atom-LaTeX Debug Log </summary>

          ```
          #{@debuglog.dump()}
          ```
          </detail>""")
    )

  class DebugLog
    constructor:  ->
      @log = [] # Just a simple array for now
      @logSize = 100  # Limit size to 100 lines
      @logIdx = 1
      @log[0] = "Atom-LaTeX debug log initiated at #{new Date().toLocaleTimeString('en-US', {hour12: false})} \n\n"

    dump: ->
      return @log.join('\n')

    write: (msg) ->
      @log[@logIdx] = msg
      if @logIdx == (@logSize - 1)
        @logIdx += 1
        @info('Log limit reached, overwriting!')
      else
        @logIdx = (@logIdx + 1) % @logSize

    info: (msg) ->
      @write("[#{new Date().toLocaleTimeString('en-US', {hour12: false})}| Info] #{msg}")

    debug: (msg) ->
      @write("[#{new Date().toLocaleTimeString('en-US', {hour12: false})}| Debug] #{msg}")

    command: (msg) ->
      @write("[#{new Date().toLocaleTimeString('en-US', {hour12: false})}| Command] #{msg}")

    error: (msg) ->
      @write("[#{new Date().toLocaleTimeString('en-US', {hour12: false})}| Error] #{msg}")
      
    warn: (msg) ->
      @write("[#{new Date().toLocaleTimeString('en-US', {hour12: false})}| Warn] #{msg}")

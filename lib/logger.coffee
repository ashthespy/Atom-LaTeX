{ Disposable } = require 'atom'

module.exports =
class Logger extends Disposable
  constructor: (latex) ->
    @latex = latex

  missingMain: ->
    if @missingMainNotification? and !@missingMainNotification.dismissed
      return
    @missingMainNotification =
      atom.notifications.addError(
        """Cannot find the LaTeX main file with `\\begin{document}`.""", {
          dismissable: true
          description:
            """Please configure your LaTeX main file first. Multiple methods:
               1. Add a magic comment \
                  `% !TEX root = \\path\\to\\main\\file.tex` \
                  to your LaTeX source file. The path can be absolute or \
                  relative.
               2. Create a `.latexcfg` file at the root directory of your\
                  project. The file should contain a json object with `root`\
                  key set to the main file. An example:
                  ```
                  { "root" : "\\path\\to\\main\\file.tex" }
                  ```
               3. Open the main file and use `Build Here` command. \
                  Alternatively, use `Build LaTeX from active editor` menu item.
               4. If all previous checks fail to find a main file, Atom-LaTeX \
                  will iterate through all LaTeX files in the root directory.
               You can choose one or multiple methods stated above to set\
               the main file.
               """
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

  processError: (title, msg) ->
    atom.notifications.addError(title, {
      detail: msg
      dismissable: true
    })

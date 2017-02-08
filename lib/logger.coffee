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
            """Please configure your LaTeX main file first. There are multiple \
               ways to do so:
               """
        })

  setMain: ->
    if @setMainNotification? and !@setMainNotification.dismissed
      @setMainNotification.dismiss()
    @setMainNotification =
      atom.notifications.addInfo(
        """Set the following file as LaTeX main file.""", {
          detail: @latex.mainFile
        }
      )

  processError: (title, msg) ->
    atom.notifications.addError(title, {
      detail: msg
      dismissable: true
    })

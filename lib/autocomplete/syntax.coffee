{ Disposable } = require 'atom'

module.exports =
class Syntax extends Disposable
  constructor: (latex) ->
    @latex = latex

  doublequote: ->
    editor = atom.workspace.getActiveTextEditor()
    selected = editor.getSelectedText()
    if selected
      range = editor.getSelectedBufferRange()
      range.start.column += 1
      range.end.column += 1
      editor.insertText("""``#{selected}\'\'""")
      editor.setSelectedBufferRange(range)
      return

    editor.insertText('\"')

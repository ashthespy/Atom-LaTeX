{ Disposable } = require 'atom'

module.exports =
class Syntax extends Disposable
  constructor: (latex) ->
    @latex = latex

  dollarsign: ->
    editor = atom.workspace.getActiveTextEditor()
    selected = editor.getSelectedText()
    if selected
      range = editor.getSelectedBufferRange()
      range.start.column += 1
      range.end.column += 1
      editor.insertText("""$#{selected}$""")
      editor.setSelectedBufferRange(range)
      return

    cursor = editor.getCursorBufferPosition()
    if editor?.buffer?.lines[cursor.row][cursor.column] is '$'
      editor.moveRight()
    else if editor?.buffer?.lines[cursor.row][cursor.column - 1] is '$'
      editor.insertText('$')
    else
      editor.insertText('$$')
      editor.moveLeft()

  backquote: ->
    editor = atom.workspace.getActiveTextEditor()
    selected = editor.getSelectedText()
    if selected
      range = editor.getSelectedBufferRange()
      range.start.column += 1
      range.end.column += 1
      editor.insertText("""`#{selected}'""")
      editor.setSelectedBufferRange(range)
      return

    editor.insertText('`')

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

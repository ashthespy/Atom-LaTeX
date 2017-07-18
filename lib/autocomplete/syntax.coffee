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
    allowedNextChar = [' ', '.']
    lines = editor.getBuffer().getLines()
    if lines[cursor.row][cursor.column - 1] is ' ' or \
        lines[cursor.row].length is 0
      if lines[cursor.row].length is cursor.column or \
          allowedNextChar.indexOf(lines[cursor.row][cursor.column]) > -1
        editor.insertText('$$')
        editor.moveLeft()
        return
    editor.insertText('$')

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

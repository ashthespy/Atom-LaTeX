{ Disposable } = require 'atom'
fs = require 'fs'
path = require 'path'

module.exports =
class Reference extends Disposable
  constructor: (latex) ->
    @latex = latex
    @suggestions = []
    @items = {}

  provide: (prefix) ->
    suggestions = []
    if prefix.length > 0
      for item in @suggestions
        if item.text.indexOf(prefix) > -1
          item.replacementPrefix = prefix
          suggestions.push item
      suggestions.sort((a, b) ->
        return a.text.indexOf(prefix) - b.text.indexOf(prefix))
      return suggestions

    if !@latex.manager.findAll()
      return suggestions

    editor = atom.workspace.getActivePaneItem()
    currentPath = editor?.buffer.file?.path
    currentContent = editor?.getText()

    if currentPath and currentContent
      if @latex.manager.isTexFile(currentPath)
        @getRefItems currentPath

    for tex of @items
      if tex in  @latex.texFiles
        for item in @items[tex]
          suggestions.push
            text: item
            type: 'tag'
            latexType: 'reference'

    suggestions.sort((a, b) ->
      return -1 if a.text < b.text
      return 1)
    @suggestions = suggestions
    return suggestions

  getItems: (content) ->
    items = []
    itemReg = /(?:\\label(?:\[[^\[\]\{\}]*\])?){([^}]*)}/g
    loop
      result = itemReg.exec content
      break if !result?
      if items.indexOf result[1] < 0
        items.push result[1]
    return items

  getRefItems: (tex) ->
    if !fs.existsSync(tex)
      return []
    content = fs.readFileSync tex, 'utf-8'
    @items[tex] = @getItems(content)

  resetRefItems: (tex) ->
    if tex?
      delete @items[tex]
    else
      @items = {}

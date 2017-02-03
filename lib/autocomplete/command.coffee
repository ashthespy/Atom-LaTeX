{ Disposable } = require 'atom'
fs = require 'fs'

module.exports =
class Command extends Disposable
  constructor: (latex) ->
    @latex = latex
    @additionalSuggestions = []

  provide: (prefix) ->
    suggestions = []
    for env of @suggestions.latex
      item = @suggestions.latex[env]
      if prefix.length is 0 or env.indexOf(prefix) > -1
        item.replacementPrefix = prefix
        item.type = 'function'
        item.latexType = 'command'
        suggestions.push item
    if prefix.length > 0
      for item in @additionalSuggestions
        if item.displayText.indexOf(prefix) > -1
          item.replacementPrefix = prefix
          suggestions.push item
      return suggestions
    if !@latex.manager.findAll()
      return suggestions
    @additionalSuggestions = []
    items = {}
    for tex in @latex.texFiles
      texItems = @getCommands(tex)
      for key of texItems
        items[key] = texItems[key] if not (key of items)
    for key of items
      for pkg of @suggestions
        if !(key of @suggestions[pkg])
          @additionalSuggestions.push items[key]
    return suggestions.concat @additionalSuggestions

  getCommands: (tex) ->
    items = {}
    if !fs.existsSync(tex)
      return items
    content = fs.readFileSync tex, 'utf-8'
    itemReg = /\\([a-zA-Z]+)(.?)/g
    loop
      result = itemReg.exec content
      break if !result?
      if not (result[1] of items)
        if result[2] is '{'
          chainComplete = true
          snippet = result[1] + '{$1}'
        else
          chainComplete = false
          snippet = result[1]
        items[result[1]] =
          displayText: result[1]
          snippet: snippet
          type: 'function'
          latexType: 'command'
          chainComplete: chainComplete
    return items

  suggestions:
    latex:
      begin:
        displayText: 'begin'
        snippet: 'begin{$1}\n  $2\n\\\\end{$1}'
        chainComplete: true
      cite:
        displayText: 'cite'
        snippet: 'cite{$1}'
        chainComplete: true
      ref:
        displayText: 'ref'
        snippet: 'ref{$1}'
        chainComplete: true

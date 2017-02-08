{ Disposable } = require 'atom'
fs = require 'fs'
latexSymbols = require('latex-symbols-list')

module.exports =
class Command extends Disposable
  constructor: (latex) ->
    @latex = latex
    @additionalSuggestions = []

  provide: (prefix) ->
    suggestions = @predefinedCommands(prefix)
    if prefix.length > 0
      for item in @additionalSuggestions
        if item.displayText.indexOf(prefix) > -1
          item.replacementPrefix = prefix
          suggestions.push item
      suggestions.sort((a, b) ->
        return a.displayText.indexOf(prefix) - b.displayText.indexOf(prefix))
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

    suggestions = suggestions.concat @additionalSuggestions
    suggestions.sort((a, b) ->
      return -1 if a.displayText < b.displayText
      return 1)
    suggestions.unshift(
      text: '\n'
      displayText: 'Press ENTER for new line.'
      chainComplete: false
      replacementPrefix: ''
      latexType: 'command')
    return suggestions

  predefinedCommands: (prefix) ->
    suggestions = []
    for env of @suggestions.latex
      item = @suggestions.latex[env]
      if prefix.length is 0 or env.indexOf(prefix) > -1
        item.replacementPrefix = prefix
        item.type = 'function'
        item.latexType = 'command'
        suggestions.push item
    for symbol in latexSymbols
      if prefix.length is 0 or symbol.indexOf(prefix) > -1
        if symbol[0] isnt '\\'
          continue
        suggestions.push
          displayText: symbol.slice(1)
          snippet: symbol.slice(1)
          chainComplete: false
          replacementPrefix: prefix
          type: 'function'
          latexType: 'command'
    return suggestions

  getCommands: (tex) ->
    items = {}
    if !fs.existsSync(tex)
      return items
    content = fs.readFileSync tex, 'utf-8'
    itemReg = /\\([a-zA-Z]+)({[^{}]*})?({[^{}]*})?({[^{}]*})?/g
    loop
      result = itemReg.exec content
      break if !result?
      if not (result[1] of items)
        if result[2]
          chainComplete = true
          snippet = result[1] + '{$1}'
          if result[3]
            snippet += '{$2}'
            if result[4]
              snippet += '{$3}'
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

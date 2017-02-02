{ Disposable } = require 'atom'
fs = require 'fs'
path = require 'path'

module.exports =
class Reference extends Disposable
  constructor: (latex) ->
    @latex = latex

  provide: (prefix) ->
    suggestions = []
    if !@latex.manager.findAll()
      return suggestions
    items = []
    for tex in @latex.texFiles
      items = items.concat @getRefItems tex
    for item in items
      if prefix.length is 0 or item.indexOf(prefix) > -1
        suggestions.push
          text: item
          type: 'tag'
    return suggestions

  getRefItems: (tex) ->
    items = []
    if !fs.existsSync(tex)
      return items
    content = fs.readFileSync tex, 'utf-8'
    itemReg = /(?:\\label(?:\[[^\[\]\{\}]*\])?){([^}]*)}/g
    loop
      result = itemReg.exec content
      break if !result?
      if items.indexOf result[1] < 0
        items.push result[1]
    return items

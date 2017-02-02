{ Disposable } = require 'atom'
fs = require 'fs'
path = require 'path'

module.exports =
class Citation extends Disposable
  constructor: (latex) ->
    @latex = latex

  provide: (prefix) ->
    suggestions = []
    if !@latex.manager.findAll()
      return suggestions
    items = []
    for bib in @latex.bibFiles
      items = items.concat @getBibItems bib
    for item in items
      if prefix.length is 0 or item.key.indexOf(prefix) > -1
        description = item.title
        if item.author?
          description += """ - #{item.author.split(' and ').join('; ')}"""
        suggestions.push
          text: item.key
          type: 'tag'
          description: description
    return suggestions

  getBibItems: (bib) ->
    items = []
    if !fs.existsSync(bib)
      return items
    content = fs.readFileSync bib, 'utf-8'
    content = content.replace(/[\r\n]/g, ' ')
    itemReg = /@(\w+){/g
    result = itemReg.exec content
    prev_result = undefined
    while result? or prev_result?
      if prev_result? and prev_result[1].toLowerCase() != 'comment'
        item = content.substring(prev_result.index, result?.index).trim()
        items.push @splitBibItem item
      prev_result = result
      if result?
        result = itemReg.exec content

    return items

  splitBibItem: (item) ->
    unclosed = 0
    lastSplit = -1
    segments = []
    for char, i in item
      if char is '{' and item[i - 1] isnt '\\'
        unclosed++
      else if char is '}' and item[i - 1] isnt '\\'
        unclosed--
      else if char is ',' and unclosed is 1
        segments.push item.substring(lastSplit + 1, i).trim()
        lastSplit = i
    segments.push item.substring(lastSplit + 1).trim()
    bibItem = {}
    bibItem.key = segments.shift()
    bibItem.key = bibItem.key.substring(bibItem.key.indexOf('{') + 1)
    last = segments[segments.length - 1]
    last = last.substring(0, last.lastIndexOf('}'))
    segments[segments.length - 1] = last
    for segment in segments
      eqSign = segment.indexOf('=')
      key = segment.substring(0, eqSign).trim()
      value = segment.substring(eqSign + 1).trim()
      if value[0] is '{' and value[value.length - 1] is '}'
        value = value.substring(1, value.length - 1)
      value = value.replace(/{{/g, '').replace(/}}/g, '')
      bibItem[key] = value
    return bibItem

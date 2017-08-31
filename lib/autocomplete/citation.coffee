{ Disposable } = require 'atom'
fs = require 'fs'
path = require 'path'

module.exports =
class Citation extends Disposable
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
    for bib of @items
      for item in @items[bib]
        description = item.title
        if item.author?
          description += """ - #{item.author.split(' and ').join('; ')}"""
        suggestions.push
          text: item.key
          type: 'tag'
          latexType: 'citation'
          description: description
    suggestions.sort((a, b) ->
      return -1 if a.text < b.text
      return 1)
    @suggestions = suggestions
    return suggestions

  getBibItems: (bib) ->
    items = []
    if !fs.existsSync(bib)
      return @items
    fileContent = fs.readFileSync bib, 'utf-8'
    content = fileContent.replace(/[\r\n]/g, ' ')
    itemReg = /@(\w+){/g
    result = itemReg.exec content
    prev_result = undefined
    try
      while result? or prev_result?
        if prev_result? and prev_result[1].toLowerCase() in bibEntries
          item = content.substring(prev_result.index, result?.index).trim()
          itemPos = fileContent.substring(0, prev_result.index).split('\n')
          items.push @splitBibItem item
        prev_result = result
        if result?
          result = itemReg.exec content
    catch error
      atom.notifications.addError("Error parsing citations in `#{path.basename(bib)}`",
      detail: """Unexpected syntax in the entry:

              #{fileContent.substring(prev_result.index, result?.index)}"""
      dismissable:true
      buttons: [
        text: 'Open File'
        onDidClick: ->
          atom.workspace.open(bib,
          initialLine: itemPos.length-1)
        ]
      )
    @items[bib] = items

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
      value = value.replace(/(\\.)|({)/g, '$1').replace(/(\\.)|(})/g, '$1')
      bibItem[key] = value
    return bibItem

  resetBibItems: (bib) ->
    # Remove specific or all citation suggestions
    if bib?
      delete @items[bib]
    else
      @items = []

bibEntries = ['article', 'book', 'bookinbook', 'booklet', 'collection', 'conference', 'inbook',
              'incollection', 'inproceedings', 'inreference', 'manual', 'mastersthesis', 'misc',
              'mvbook', 'mvcollection', 'mvproceedings', 'mvreference', 'online', 'patent', 'periodical',
              'phdthesis', 'proceedings', 'reference', 'report', 'set', 'suppbook', 'suppcollection',
              'suppperiodical', 'techreport', 'thesis', 'unpublished']

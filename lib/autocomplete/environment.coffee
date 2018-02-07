{ Disposable } = require 'atom'

module.exports =
class Environment extends Disposable
  constructor: (latex) ->
    @latex = latex

  provide: (prefix) ->
    suggestions = []
    for env of @suggestions.latex
      item = @suggestions.latex[env]
      if prefix.length is 0 or item.text.indexOf(prefix) > -1
        item.replacementPrefix = prefix
        item.type = 'tag'
        item.latexType = 'environment'
        suggestions.push item
    suggestions.sort((a, b) ->
      return -1 if a.text < b.text
      return 1)
    return suggestions

  suggestions:
    latex:
      figure:
        text: 'figure'
        additionalInsert: '\\caption{title}'
      table:
        text: 'table'
        additionalInsert: '\\caption{title}'
      description:
        text: 'description'
        additionalInsert: '\\item [label] '
      enumerate:
        text: 'enumerate'
        additionalInsert: '\\item '
      itemize:
        text: 'itemize'
        additionalInsert: '\\item '
      math:
        text: 'math'
      displaymath:
        text: 'displaymath'
      split:
        text: 'split'
      array:
        text: 'array'
      eqnarray:
        text: 'eqnarray'
      equation:
        text: 'equation'
      equationAst:
        text: 'equation*'
      subequations:
        text: 'subequations'
      subequationsAst:
        text: 'subequations*'
      multiline:
        text: 'multiline'
      multilineAst:
        text: 'multiline*'
      gather:
        text: 'gather'
      gatherAst:
        text: 'gather*'
      align:
        text: 'align'
      alignAst:
        text: 'align*'
      alignat:
        text: 'alignat'
      alignatAst:
        text: 'alignat*'
      flalign:
        text: 'flalign'
      flalignAst:
        text: 'flalign*'
      theorem:
        text: 'theorem'
      cases:
        text: 'cases'
      center:
        text: 'center'
      flushleft:
        text: 'flushleft'
      flushright:
        text: 'flushright'
      minipage:
        text: 'minipage'
      quotation:
        text: 'quotation'
      quote:
        text: 'quote'
      verbatim:
        text: 'verbatim'
      verse:
        text: 'verse'
      picture:
        text: 'picture'
      tabbing:
        text: 'tabbing'
      tabular:
        text: 'tabular'
      thebibliography:
        text: 'thebibliography'
      titlepage:
        text: 'titlepage'
      frame:
        text: 'frame'

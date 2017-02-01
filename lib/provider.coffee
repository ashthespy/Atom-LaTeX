{ Disposable } = require 'atom'
Citation = require './autocomplete/citation'

module.exports =
class Provider extends Disposable
  constructor: (latex) ->
    @latex = latex
    @citation = new Citation(@latex)

  provider:
    selector: '.text.tex.latex'
    inclusionPriority: 1
    getSuggestions: ({editor, bufferPosition}) ->
      new Promise (resolve) ->
        suggestions = []
        line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
        citeReg = /(?:\\[a-zA-Z]*cite[a-zA-Z]*(?:\[[^\[\]]*\])?){([^}]*)$/
        result = line.match(citeReg)
        if result
          prefix = result[1]
          allKeys = prefix.split(',')
          currentPrefix = allKeys[allKeys.length - 1].trim()
          suggestions = atom_latex.provider.citation.provide(currentPrefix)
        resolve(suggestions)

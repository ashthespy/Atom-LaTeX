{ Disposable } = require 'atom'
Citation = require './autocomplete/citation'
Reference = require './autocomplete/reference'

module.exports =
class Provider extends Disposable
  constructor: (latex) ->
    @latex = latex
    @citation = new Citation(@latex)
    @reference = new Reference(@latex)

  provider:
    selector: '.text.tex.latex'
    inclusionPriority: 1
    suggestionPriority: 2
    getSuggestions: ({editor, bufferPosition}) ->
      new Promise (resolve) ->
        line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
        if line[line.length - 1] is '{'
          atom.packages.getActivePackage('autocomplete-plus')\
            .mainModule.autocompleteManager.shouldDisplaySuggestions = true

        suggestions = atom_latex.provider.completeCommand(line, 'citation')
        resolve(suggestions) if suggestions?

        suggestions = atom_latex.provider.completeCommand(line, 'reference')
        resolve(suggestions) if suggestions?

        resolve(suggestions)

  completeCommand: (line, type) ->
    switch type
      when 'citation'
        reg = /(?:\\[a-zA-Z]*cite[a-zA-Z]*(?:\[[^\[\]]*\])?){([^}]*)$/
        provider = @citation
      when 'reference'
        reg = /(?:\\[a-zA-Z]*ref[a-zA-Z]*(?:\[[^\[\]]*\])?){([^}]*)$/
        provider = @reference

    result = line.match(reg)
    if result
      prefix = result[1]
      allKeys = prefix.split(',')
      currentPrefix = allKeys[allKeys.length - 1].trim()
      suggestions = provider.provide(currentPrefix)
    return suggestions

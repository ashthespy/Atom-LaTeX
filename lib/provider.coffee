{ Disposable } = require 'atom'
Citation = require './autocomplete/citation'
Reference = require './autocomplete/reference'
Environment = require './autocomplete/environment'

module.exports =
class Provider extends Disposable
  constructor: (latex) ->
    @latex = latex
    @citation = new Citation(@latex)
    @reference = new Reference(@latex)
    @environment = new Environment(@latex)

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

        for command in ['citation', 'reference', 'environment']
          suggestions = atom_latex.provider.completeCommand(line, command)
          resolve(suggestions) if suggestions?

        resolve(suggestions)

    onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->
      if suggestion.latexType is 'environment'
        spaces = editor.buffer.lines[triggerPosition.row].match(/^(\s)*/)[0]
        editor.buffer.insert({row: triggerPosition.row + 1, column: 0},
          """#{spaces}\\end{#{suggestion.text}}\n""")
        if suggestion.additionalInsert?
          for content, i in suggestion.additionalInsert
            editor.buffer.insert({row: triggerPosition.row + i + 1, column: 0},
              """#{spaces}#{content}\n""")

  completeCommand: (line, type) ->
    switch type
      when 'citation'
        reg = /(?:\\[a-zA-Z]*cite[a-zA-Z]*(?:\[[^\[\]]*\])?){([^}]*)$/
        provider = @citation
      when 'reference'
        reg = /(?:\\[a-zA-Z]*ref[a-zA-Z]*(?:\[[^\[\]]*\])?){([^}]*)$/
        provider = @reference
      when 'environment'
        reg = /(?:\\begin(?:\[[^\[\]]*\])?){([^}]*)$/
        provider = @environment

    result = line.match(reg)
    if result
      prefix = result[1]
      allKeys = prefix.split(',')
      currentPrefix = allKeys[allKeys.length - 1].trim()
      suggestions = provider.provide(currentPrefix)
    return suggestions
